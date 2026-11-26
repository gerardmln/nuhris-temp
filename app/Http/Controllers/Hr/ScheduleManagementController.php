<?php

namespace App\Http\Controllers\Hr;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\AnnouncementNotification;
use App\Models\Department;
use App\Models\Employee;
use App\Models\EmployeeScheduleSubmission;
use App\Models\User;
use App\Services\AuditLogService;
use App\Services\EmployeeScheduleService;
use App\Services\LeaveBalanceService;
use App\Support\EmployeeWorkTimeConstraints;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\View\View;

class ScheduleManagementController extends Controller
{
    private const ALLOWED_TERM_LABELS = [
        '1st Term',
        '2nd Term',
        '3rd Term',
    ];

    public function index(EmployeeScheduleService $scheduleService): View
    {
        $request = request();
        $search = $request->string('search')->trim()->toString();
        $departmentId = $request->string('department_id')->toString();
        $statusFilter = $request->string('status')->toString() ?: 'all';

        $employees = Employee::query()
            ->with('department')
            ->when($search !== '', function ($query) use ($search): void {
                $query->where(function ($employeeQuery) use ($search): void {
                    $employeeQuery->where('first_name', 'like', '%'.$search.'%')
                        ->orWhere('last_name', 'like', '%'.$search.'%')
                        ->orWhere('email', 'like', '%'.$search.'%')
                        ->orWhereHas('department', function ($departmentQuery) use ($search): void {
                            $departmentQuery->where('name', 'like', '%'.$search.'%');
                        });
                });
            })
            ->when($departmentId !== '' && $departmentId !== 'all', function ($query) use ($departmentId): void {
                if ($departmentId === 'asp') {
                    $query->where(function ($nested): void {
                        $nested->where('employment_type', 'Admin Support Personnel')
                            ->orWhereHas('department', fn ($department) => $department->where('name', 'ASP'));
                    });

                    return;
                }

                $query->where('department_id', $departmentId);
            })
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        $latestSubmissions = EmployeeScheduleSubmission::query()
            ->with(['days', 'submitter', 'reviewer'])
            ->whereIn('employee_id', $employees->pluck('id'))
            ->orderByDesc('submitted_at')
            ->orderByDesc('id')
            ->get()
            ->groupBy('employee_id')
            ->map(fn ($items) => $items->first());

        $employeeSchedules = $employees->map(function (Employee $employee) use ($latestSubmissions, $scheduleService) {
            $latestSubmission = $latestSubmissions->get($employee->id);

            if (! $latestSubmission || $latestSubmission->status === EmployeeScheduleSubmission::STATUS_RESET) {
                return [
                    'employee' => $employee,
                    'submission' => null,
                    'status' => 'needs_upload',
                ];
            }

            return [
                'employee' => $employee,
                'submission' => $latestSubmission,
                'status' => $latestSubmission->status,
                'weekly_work_hours' => $scheduleService->weeklyWorkHoursLabel($latestSubmission),
            ];
        })->when($statusFilter !== 'all', function ($collection) use ($statusFilter) {
            return $collection->filter(function (array $entry) use ($statusFilter) {
                if ($statusFilter === 'needs_upload') {
                    return $entry['status'] === 'needs_upload';
                }

                return $entry['status'] === $statusFilter;
            })->values();
        });

        return view('hr.schedule-management', [
            'employeeSchedules' => $employeeSchedules,
            'departments' => Department::query()->facultySchools()->orderBy('name')->get(),
            'filters' => [
                'search' => $search,
                'department_id' => $departmentId,
                'status' => $statusFilter,
            ],
        ]);
    }

    public function create(?Employee $employee, EmployeeScheduleService $scheduleService): View
    {
        $employees = Employee::query()
            ->with('department')
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        $employee?->loadMissing('department');

        return view('hr.schedule-management-create', [
            'selectedEmployee' => $employee,
            'employees' => $employees,
            'weekDays' => $scheduleService->weeklyDays(),
            'termLabels' => self::ALLOWED_TERM_LABELS,
        ]);
    }

    public function store(Request $request, EmployeeScheduleService $scheduleService): RedirectResponse
    {
        $validated = $request->validate([
            'employee_id' => ['required', 'integer', 'exists:employees,id'],
        ]);

        $employee = Employee::query()->findOrFail($validated['employee_id']);
        $rules = [];

        foreach ($scheduleService->weeklyDays() as $day) {
            $rules["days.{$day['key']}.mode"] = ['required', 'in:with_work,no_work'];
            $rules["days.{$day['key']}.time_in"] = ['nullable', 'required_if:days.'.$day['key'].'.mode,with_work', 'date_format:H:i'];
            $rules["days.{$day['key']}.time_out"] = ['nullable', 'required_if:days.'.$day['key'].'.mode,with_work', 'date_format:H:i', 'after:days.'.$day['key'].'.time_in'];
        }

        $rules['term_label'] = ['required', 'string', 'in:'.implode(',', self::ALLOWED_TERM_LABELS)];
        $rules['term_start_date'] = $employee->isContractualFaculty() ? ['required', 'date'] : ['prohibited'];

        $validator = Validator::make($request->all(), $rules, [
            'days.*.time_in.required_if' => 'Please enter a time in for each work day.',
            'days.*.time_out.required_if' => 'Please enter a time out for each work day.',
            'days.*.time_out.after' => 'The time out must be later than the time in.',
            'term_start_date.required' => 'Please enter the date your term starts.',
        ]);

        foreach ($scheduleService->weeklyDays() as $day) {
            if (data_get($request->all(), "days.{$day['key']}.mode") === 'with_work') {
                EmployeeWorkTimeConstraints::applyToValidator(
                    $validator,
                    "days.{$day['key']}.time_in",
                    "days.{$day['key']}.time_out",
                    EmployeeWorkTimeConstraints::SCHEDULE_MIN_DURATION_MINUTES,
                );
            }
        }

        $scheduleData = $validator->validate();
        $activeSubmission = EmployeeScheduleSubmission::query()
            ->where('employee_id', $employee->id)
            ->whereIn('status', [EmployeeScheduleSubmission::STATUS_PENDING, EmployeeScheduleSubmission::STATUS_APPROVED])
            ->latest('submitted_at')
            ->first();

        if ($activeSubmission) {
            return back()->withInput()->with('error', 'This employee already has an active schedule. Clear or edit the existing schedule before adding a replacement.');
        }

        $scheduleRows = $scheduleService->normalizeWeeklyInput($scheduleData['days'] ?? []);

        $submission = DB::transaction(function () use ($employee, $request, $scheduleRows, $scheduleData): EmployeeScheduleSubmission {
            $submission = EmployeeScheduleSubmission::create([
                'employee_id' => $employee->id,
                'submitted_by' => $request->user()->id,
                'reviewed_by' => $request->user()->id,
                'semester_label' => $scheduleData['term_label'],
                'term_label' => $scheduleData['term_label'],
                'academic_year' => null,
                'term_start_date' => $scheduleData['term_start_date'] ?? null,
                'status' => EmployeeScheduleSubmission::STATUS_APPROVED,
                'submitted_at' => now(),
                'reviewed_at' => now(),
                'review_notes' => 'Added and approved by HR',
                'is_current' => true,
            ]);

            foreach ($scheduleRows as $row) {
                $submission->days()->create($row);
            }

            EmployeeScheduleSubmission::query()
                ->where('employee_id', $employee->id)
                ->whereKeyNot($submission->id)
                ->update(['is_current' => false]);

            return $submission;
        });

        $leaveTermStarted = app(LeaveBalanceService::class)->applyApprovedSchedule($submission);

        $this->notifyEmployee(
            $request,
            $submission,
            'Schedule added by HR',
            sprintf('A weekly schedule for term "%s" was added and approved for you by HR.', $scheduleData['term_label'])
        );

        app(AuditLogService::class)->record(
            'CREATE',
            'Schedules',
            'Added and approved schedule for '.$employee->full_name.'.',
            'Success',
            [
                'submission_id' => $submission->id,
                'employee_id' => $employee->employee_id,
                'leave_term_started' => $leaveTermStarted,
            ]
        );

        return redirect()->route('schedules.index')
            ->with('success', 'Schedule added and approved successfully.');
    }

    public function approve(Request $request, EmployeeScheduleSubmission $submission): RedirectResponse
    {
        $validated = $request->validate([
            'confirmed' => ['accepted', 'in:1'],
            'review_notes' => ['nullable', 'string', 'max:1000'],
        ]);

        $submission->loadMissing('employee');

        $submission->update([
            'status' => EmployeeScheduleSubmission::STATUS_APPROVED,
            'reviewed_by' => $request->user()?->id,
            'reviewed_at' => now(),
            'review_notes' => $validated['review_notes'] ?? null,
            'is_current' => true,
        ]);

        EmployeeScheduleSubmission::query()
            ->where('employee_id', $submission->employee_id)
            ->whereKeyNot($submission->id)
            ->update(['is_current' => false]);

        $this->notifyEmployee(
            $request,
            $submission,
            'Schedule approved',
            sprintf('Your weekly schedule for %s %s was approved by HR.', $submission->semester_label, $submission->academic_year)
        );

        $leaveTermStarted = app(LeaveBalanceService::class)->applyApprovedSchedule($submission);
        $leaveTermNote = $leaveTermStarted
            ? ' Leave term starts '.$submission->term_start_date->format('M j, Y').' (3 VL / 3 SL / 3 EL).'
            : '';

        app(AuditLogService::class)->record(
            'APPROVE',
            'Schedules',
            'Approved schedule for '.($submission->employee?->full_name ?? 'an employee').'.'.$leaveTermNote,
            'Success',
            ['submission_id' => $submission->id, 'employee_id' => $submission->employee?->employee_id, 'leave_term_started' => $leaveTermStarted]
        );

        return back()->with('success', 'Schedule approved successfully.'.$leaveTermNote);
    }

    public function clear(Request $request, EmployeeScheduleSubmission $submission): RedirectResponse
    {
        $validated = $request->validate([
            'confirmed' => ['accepted', 'in:1'],
            'review_notes' => ['nullable', 'string', 'max:1000'],
        ]);

        if ($submission->status !== EmployeeScheduleSubmission::STATUS_APPROVED) {
            return back()->with('error', 'Only approved schedules can be cleared.');
        }

        $submission->loadMissing('employee');

        $submission->update([
            'status' => EmployeeScheduleSubmission::STATUS_RESET,
            'reviewed_by' => $request->user()?->id,
            'reviewed_at' => now(),
            'review_notes' => $validated['review_notes'] ?? 'Cleared by HR',
            'is_current' => false,
        ]);

        $submission->days()->delete();

        $this->notifyEmployee(
            $request,
            $submission,
            'Schedule cleared',
            sprintf('Your approved weekly schedule for term "%s" was cleared by HR. Please resubmit a revised schedule.', $submission->semester_label)
        );

        app(AuditLogService::class)->record(
            'DELETE',
            'Schedules',
            'Cleared approved schedule for '.($submission->employee?->full_name ?? 'an employee').'.',
            'Success',
            ['submission_id' => $submission->id, 'employee_id' => $submission->employee?->employee_id]
        );

        return back()->with('success', 'Approved schedule cleared successfully.');
    }

    public function resetEmployee(Request $request, Employee $employee): RedirectResponse
    {
        $request->validate([
            'confirmed' => ['accepted', 'in:1'],
        ]);

        $submissions = EmployeeScheduleSubmission::query()
            ->with('employee')
            ->where('employee_id', $employee->id)
            ->get();

        if ($submissions->isEmpty()) {
            return back()->with('error', 'This employee has no schedule submissions to reset.');
        }

        foreach ($submissions as $submission) {
            $submission->days()->delete();
            $submission->update([
                'status' => EmployeeScheduleSubmission::STATUS_RESET,
                'reviewed_by' => $request->user()?->id,
                'reviewed_at' => now(),
                'review_notes' => 'Reset by HR',
                'is_current' => false,
            ]);
        }

        $this->notifyEmployee(
            $request,
            $submissions->first(),
            'Schedule reset',
            sprintf('%s schedule has been reset by HR. Please submit a new schedule.', $employee->full_name)
        );

        app(AuditLogService::class)->record(
            'RESET',
            'Schedules',
            'Reset schedule for '.$employee->full_name.'.',
            'Success',
            ['employee_id' => $employee->employee_id, 'submissions' => $submissions->count()]
        );

        return back()->with('success', $employee->full_name.' schedule was reset successfully.');
    }

    public function decline(Request $request, EmployeeScheduleSubmission $submission): RedirectResponse
    {
        $validated = $request->validate([
            'confirmed' => ['accepted', 'in:1'],
            'review_notes' => ['required', 'string', 'max:1000'],
        ]);

        $submission->loadMissing('employee');

        $submission->update([
            'status' => EmployeeScheduleSubmission::STATUS_DECLINED,
            'reviewed_by' => $request->user()?->id,
            'reviewed_at' => now(),
            'review_notes' => $validated['review_notes'],
            'is_current' => false,
        ]);

        $this->notifyEmployee(
            $request,
            $submission,
            'Schedule declined',
            sprintf('Your weekly schedule for %s %s was declined by HR. Notes: %s', $submission->semester_label, $submission->academic_year, $validated['review_notes'])
        );

        app(AuditLogService::class)->record(
            'DECLINE',
            'Schedules',
            'Declined schedule for '.($submission->employee?->full_name ?? 'an employee').'.',
            'Success',
            ['submission_id' => $submission->id, 'employee_id' => $submission->employee?->employee_id, 'review_notes' => $validated['review_notes']]
        );

        return back()->with('success', 'Schedule declined. The employee has been notified.');
    }

    public function resetSemester(Request $request, EmployeeScheduleService $scheduleService): RedirectResponse
    {
        $request->validate([
            'confirmed' => ['accepted', 'in:1'],
        ]);

        $resetCount = EmployeeScheduleSubmission::query()->update([
            'status' => EmployeeScheduleSubmission::STATUS_RESET,
            'is_current' => false,
        ]);

        app(AuditLogService::class)->record(
            'RESET',
            'Schedules',
            'Reset all employee schedules.',
            'Success',
            ['submissions' => $resetCount]
        );

        return back()->with('success', 'All schedules were reset. Employees must resubmit before DTR validation resumes.');
    }

    private function notifyEmployee(Request $request, EmployeeScheduleSubmission $submission, string $title, string $content): void
    {
        if (! $submission->employee) {
            return;
        }

        $employeeUser = User::query()->where('email', $submission->employee->email)->first();

        if (! $employeeUser) {
            return;
        }

        $announcement = Announcement::forceCreate([
            'title' => $title,
            'content' => $content,
            'priority' => 'medium',
            'target_employee_type' => 'employee',
            'published_at' => now(),
            'is_published' => true,
            'created_by' => $request->user()->id,
        ]);

        AnnouncementNotification::create([
            'announcement_id' => $announcement->id,
            'user_id' => $employeeUser->id,
            'is_read' => false,
            'read_at' => null,
            'redirect_url' => route('employee.attendance'),
        ]);
    }
}
