<?php

namespace Tests\Feature;

use App\Models\AttendanceRecord;
use App\Models\Department;
use App\Models\Employee;
use App\Models\LeaveBalance;
use App\Models\LeaveRequest;
use App\Models\User;
use App\Services\EmployeeBulkImportService;
use App\Services\ImportVerificationService;
use App\Services\LeaveMonitoringService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Tests\TestCase;

class ImportVerificationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Mail::fake();
        Http::fake();
    }

    /**
     * @param  array<int, array<int, mixed>>  $rows  first row is the header
     */
    private function excel(array $rows, string $name, string $sheetTitle = 'Sheet1'): UploadedFile
    {
        $spreadsheet = new Spreadsheet();
        $spreadsheet->getActiveSheet()->setTitle($sheetTitle)->fromArray($rows, null, 'A1', true);
        $path = tempnam(sys_get_temp_dir(), 'imp').'.xlsx';
        (new Xlsx($spreadsheet))->save($path);

        return new UploadedFile($path, $name, null, null, true);
    }

    private function employeeFile(): UploadedFile
    {
        return $this->excel([
            ['Employee ID', 'Email', 'First Name', 'Last Name', 'Employee Type', 'Employment Status', 'Department', 'Rank', 'Level', 'Hire Date'],
            ['2508064', 'angelus.malaluan@gmail.com', 'Reymark', 'Natividad', 'Faculty', 'Probationary', 'SACE', 'Assistant Professor', '3', '2025-07-31'],
            ['238041', 'malaluangerard@gmail.com', 'Jei', 'Pastrana', 'Faculty', 'Regular', 'SACE', 'Assistant Professor', '3', '2023-07-04'],
            ['2408130', 'donoharmbygrd@gmail.com', 'Allainer', 'Reyes', 'Part-Time Faculty', 'Probationary', 'SACE', 'Part-Time Faculty', null, '2024-08-08'],
            ['238111', 'pritongtalong808@gmail.com', 'Jerimaiah', 'Padua', 'Admin Support Personnel', 'Regular', null, 'Human Resource Office', null, '2024-08-11'],
        ], 'employee_import_sample.xlsx', 'Employees');
    }

    private function leaveFile(): UploadedFile
    {
        return $this->excel([
            ['Leave ID', 'Employee ID', 'Employee Name', 'Application', 'Type', 'Date Filed', 'Date From', 'Date To', 'Total Hours', 'Status'],
            ['L-1001', '23-8041', 'Pastrana, Jei', 'Vacation Leave', 'With Pay', '2026-09-01', '2026-09-07', '2026-09-08', 16, 'APPROVED'],
            ['L-1002', '238041', 'Pastrana, Jei', 'Sick Leave', 'With Pay', '2026-09-10', '2026-09-14', '2026-09-14', 4, 'FOR APPROVAL'],
            ['L-1003', '99-9999', 'Unknown, Person', 'Vacation Leave', 'With Pay', '2026-09-01', '2026-09-02', '2026-09-02', 8, 'APPROVED'],
            ['L-1004', '23-8041', 'Pastrana, Jei', 'Vacation Leave', 'With Pay', '2026-09-15', '2026-09-21', '2026-09-25', 44, 'DISAPPROVED'],
            ['L-1004', '23-8041', 'Pastrana, Jei', 'Vacation Leave', 'With Pay', '2026-09-15', '2026-09-21', '2026-09-25', 44, 'APPROVED'],
        ], 'leaves_september.xlsx');
    }

    private function registerPastrana(): Employee
    {
        return Employee::query()->create([
            'employee_id' => '23-8041',
            'first_name' => 'Jei',
            'last_name' => 'Pastrana',
            'email' => 'jei@example.com',
            'department_id' => Department::query()->create(['name' => 'SACE'])->id,
            'position' => 'Assistant Professor',
            'employment_type' => 'Faculty',
            'employment_status' => 'regular',
            'hire_date' => '2023-07-04',
        ]);
    }

    private function as(int $userType): static
    {
        return $this->withSession(['privacy_notice_acknowledged_version' => config('privacy.notice_version')])
            ->actingAs(User::factory()->create(['user_type' => $userType]));
    }

    public function test_bulk_employee_upload_reports_full_verification(): void
    {
        $this->as(User::TYPE_HR)->post(route('employees.bulk-upload'), ['employees_file' => $this->employeeFile()]);

        $verification = session('bulk_upload_result')['verification'];
        $this->assertSame(4, $verification['records_checked']);
        $this->assertSame(4, $verification['records_found']);
        $this->assertSame(35, $verification['fields_checked']); // 4 x 8 fields + 3 departments
        $this->assertSame(100.0, $verification['field_accuracy']);
        $this->assertSame(100.0, $verification['record_accuracy']);
        $this->assertDatabaseHas('admin_audit_logs', ['module' => 'Employees', 'metadata->verification->field_accuracy' => 100]);
    }

    public function test_employee_verification_flags_saved_data_that_differs_from_the_file(): void
    {
        $file = $this->employeeFile();
        $result = app(EmployeeBulkImportService::class)->import($file);
        Employee::query()->where('employee_id', '238041')->update(['last_name' => 'Pastranna', 'ranking' => 'Assistant Professor 2']);

        $verification = app(ImportVerificationService::class)->verifyEmployeeImport($file, $result['created']);

        $this->assertSame(33, $verification['fields_correct']);
        $this->assertSame(75.0, $verification['record_accuracy']);
        $this->assertSame([['Last name', 'Pastrana', 'Pastranna'], ['Level', '3', 'Assistant Professor 2']], array_map(
            fn (array $mismatch) => [$mismatch['field'], $mismatch['file'], $mismatch['saved']],
            $verification['mismatches'],
        ));
    }

    public function test_leave_upload_reports_full_verification_for_hr_and_admin(): void
    {
        $this->registerPastrana();

        foreach ([[User::TYPE_HR, 'leaves.upload'], [User::TYPE_ADMIN, 'admin.leave.upload']] as [$userType, $route]) {
            LeaveRequest::query()->delete();

            $this->as($userType)->post(route($route), ['leaves_file' => $this->leaveFile()]);

            $verification = session('import_verification');
            $this->assertSame(3, $verification['records_checked'], $route);
            $this->assertSame(3, $verification['records_found'], $route);
            $this->assertSame(1, $verification['not_imported'], $route);  // unregistered employee
            $this->assertSame(1, $verification['superseded'], $route);    // L-1004 appears twice
            $this->assertSame(15, $verification['fields_checked'], $route);
            $this->assertSame(100.0, $verification['field_accuracy'], $route);
        }

        $this->assertEqualsWithDelta(5.5, LeaveRequest::query()->where('source_leave_id', 'L-1004')->value('days_deducted'), 0.001);
        $this->assertSame('approved', LeaveRequest::query()->where('source_leave_id', 'L-1004')->value('status'));
    }

    public function test_leave_upload_marks_employees_absent_without_eligible_credits(): void
    {
        $this->travelTo(Carbon::parse('2026-11-27 12:00:00'));

        $departmentId = Department::query()->create(['name' => 'SACE'])->id;
        $faculty = Employee::query()->create([
            'employee_id' => '26-0201',
            'first_name' => 'Early',
            'last_name' => 'Faculty',
            'email' => 'early-faculty@example.com',
            'department_id' => $departmentId,
            'position' => 'Instructor',
            'employment_type' => 'Faculty',
            'employment_status' => 'regular',
            'hire_date' => '2025-11-28',
        ]);
        $asp = Employee::query()->create([
            'employee_id' => '26-0202',
            'first_name' => 'Eligible',
            'last_name' => 'Admin',
            'email' => 'eligible-admin@example.com',
            'department_id' => $departmentId,
            'position' => 'HR Officer',
            'employment_type' => 'Admin Support Personnel',
            'employment_status' => 'probationary',
            'hire_date' => '2026-05-27',
        ]);
        $partTime = Employee::query()->create([
            'employee_id' => '26-0203',
            'first_name' => 'Part Time',
            'last_name' => 'Faculty',
            'email' => 'part-time-faculty@example.com',
            'department_id' => $departmentId,
            'position' => 'Part-Time Faculty',
            'employment_type' => 'Part-Time Faculty',
            'employment_status' => 'probationary',
            'hire_date' => '2020-01-01',
        ]);
        $file = $this->excel([
            ['Leave ID', 'Employee ID', 'Employee Name', 'Application', 'Type', 'Date Filed', 'Date From', 'Date To', 'Total Hours', 'Status'],
            ['L-FAC', '26-0201', 'Early, Faculty', 'Vacation Leave', 'With Pay', '2026-11-01', '2026-11-27', '2026-11-27', 8, 'APPROVED'],
            ['L-ASP', '26-0202', 'Eligible, Admin', 'Vacation Leave', 'With Pay', '2026-11-01', '2026-11-27', '2026-11-27', 8, 'APPROVED'],
            ['L-PT', '26-0203', 'Part Time, Faculty', 'Vacation Leave', 'With Pay', '2026-11-01', '2026-11-27', '2026-11-27', 8, 'APPROVED'],
        ], 'eligibility_leaves.xlsx');

        $this->as(User::TYPE_HR)->post(route('leaves.upload'), ['leaves_file' => $file])->assertSessionHasNoErrors();

        $this->assertSame('absent', AttendanceRecord::query()->where('employee_id', $faculty->id)->whereDate('record_date', '2026-11-27')->value('status'));
        $this->assertSame('present', AttendanceRecord::query()->where('employee_id', $asp->id)->whereDate('record_date', '2026-11-27')->value('status'));
        $this->assertSame('absent', AttendanceRecord::query()->where('employee_id', $partTime->id)->whereDate('record_date', '2026-11-27')->value('status'));
        $this->assertSame(0.0, (float) LeaveBalance::query()->where('employee_id', $faculty->id)->where('leave_type', 'Vacation Leave')->value('remaining_days'));
        $this->assertSame(8.0, (float) LeaveBalance::query()->where('employee_id', $asp->id)->where('leave_type', 'Vacation Leave')->value('remaining_days'));
        $this->assertSame(0.0, (float) LeaveBalance::query()->where('employee_id', $partTime->id)->where('leave_type', 'Vacation Leave')->value('remaining_days'));
    }

    public function test_hr_and_admin_leave_management_show_the_leave_credit_rules(): void
    {
        foreach ([[User::TYPE_HR, 'leave.index'], [User::TYPE_ADMIN, 'admin.leave.index']] as [$userType, $route]) {
            $this->as($userType)->get(route($route))
                ->assertOk()
                ->assertSee('Leave Credit Rules')
                ->assertSee('At 1 year: 11 VL / 11 SL / 3 EL')
                ->assertSee('At 6 months: 9 VL / 9 SL / 3 EL')
                ->assertSee('Part-Time Faculty')
                ->assertSee('Contractual Faculty');
        }
    }

    public function test_leave_verification_flags_saved_data_that_differs_from_the_file(): void
    {
        $this->registerPastrana();
        $file = $this->leaveFile();
        $this->as(User::TYPE_HR)->post(route('leaves.upload'), ['leaves_file' => $file]);

        LeaveRequest::query()->where('source_leave_id', 'L-1001')->update(['days_deducted' => 3]);
        LeaveRequest::query()->where('source_leave_id', 'L-1002')->delete();

        $verification = app(ImportVerificationService::class)->verifyLeaveImport($file, app(LeaveMonitoringService::class));

        $this->assertSame(2, $verification['records_found']);
        $this->assertSame(9, $verification['fields_correct']);
        $this->assertSame(10, $verification['fields_checked']);
        $this->assertEqualsCanonicalizing(['Days (hours ÷ 8)', 'Record'], array_column($verification['mismatches'], 'field'));
    }
}
