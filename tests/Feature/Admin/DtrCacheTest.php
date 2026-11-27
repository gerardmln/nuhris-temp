<?php

namespace Tests\Feature\Admin;

use App\Models\AdminAuditLog;
use App\Models\AttendanceRecord;
use App\Models\Department;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DtrCacheTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_clear_dtr_upload_cache_without_deleting_attendance_records(): void
    {
        $admin = User::factory()->create([
            'user_type' => User::TYPE_ADMIN,
        ]);

        $department = Department::query()->create([
            'name' => 'Human Resources',
        ]);

        $employee = Employee::query()->create([
            'first_name' => 'Test',
            'last_name' => 'Employee',
            'email' => 'employee@example.com',
            'department_id' => $department->id,
            'position' => 'Staff',
        ]);

        AttendanceRecord::query()->create([
            'employee_id' => $employee->id,
            'record_date' => '2026-10-01',
            'time_in' => '08:00',
            'time_out' => '17:00',
            'status' => 'present',
        ]);

        AdminAuditLog::query()->create([
            'user_id' => $admin->id,
            'action' => 'CREATE',
            'module' => 'DTR',
            'description' => 'Imported DTR PDF.',
            'status' => 'Success',
            'metadata' => ['original_filename' => 'timesheet.pdf'],
        ]);

        $response = $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($admin)->post(route('admin.dtr.clear-cache', [
            'search' => 'Employee',
            'employee_class' => 'regular',
            'record_status' => 'present',
            'attendance_range' => 'month',
        ]));

        $response->assertRedirect(route('admin.dtr.index', [
            'search' => 'Employee',
            'employee_class' => 'regular',
            'record_status' => 'present',
            'attendance_range' => 'month',
        ]));
        $response->assertSessionHas('success', 'Cleared 1 DTR upload cache entry.');
        $this->assertDatabaseCount('attendance_records', 1);
        $this->assertDatabaseMissing('admin_audit_logs', [
            'action' => 'CREATE',
            'module' => 'DTR',
            'description' => 'Imported DTR PDF.',
        ]);
        $this->assertDatabaseHas('admin_audit_logs', [
            'action' => 'DELETE',
            'module' => 'DTR',
            'description' => 'Cleared 1 DTR upload cache entry.',
        ]);
    }

    public function test_dtr_filters_are_preserved_when_editing_and_saving_a_record(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);
        $department = Department::query()->create(['name' => 'DTR Test Department']);
        $recordDate = now()->subMonth()->startOfMonth();
        $employee = Employee::query()->create([
            'first_name' => 'Test',
            'last_name' => 'Employee',
            'email' => 'dtr.employee@example.com',
            'department_id' => $department->id,
            'position' => 'Staff',
        ]);
        $record = AttendanceRecord::query()->create([
            'employee_id' => $employee->id,
            'record_date' => $recordDate->toDateString(),
            'time_in' => '08:00',
            'time_out' => '17:00',
            'status' => 'present',
        ]);
        $filters = [
            'employee_id' => (string) $employee->id,
            'month' => (string) $recordDate->month,
            'year' => (string) $recordDate->year,
            'record_status' => 'all',
            'attendance_range' => 'month',
        ];
        $editParameters = ['record' => $record->id, 'return_route' => 'admin.dtr.index'] + $filters;

        $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($admin)
            ->get(route('admin.dtr.index', $filters))
            ->assertOk()
            ->assertSee(route('admin.dtr.edit', $editParameters));

        $this->get(route('admin.dtr.edit', $editParameters))
            ->assertOk()
            ->assertSee(route('admin.dtr.index', $filters))
            ->assertSee(route('admin.dtr.update', $editParameters));

        $this->put(route('admin.dtr.update', $editParameters), [
            'status' => 'absent',
            'time_in' => '08:00',
            'time_out' => '17:00',
        ])->assertRedirect(route('admin.dtr.index', $filters));

        $this->assertDatabaseHas('attendance_records', [
            'id' => $record->id,
            'status' => 'absent',
        ]);

        $detailQuery = [
            'employee' => (string) $employee->id,
            'month' => (string) $recordDate->month,
            'year' => (string) $recordDate->year,
            'attendance_range' => 'month',
        ];
        $this->get(route('admin.dtr.view', $detailQuery))
            ->assertOk()
            ->assertSee('5:00 PM')
            ->assertDontSee('17:00', false);

        $detailEditParameters = ['record' => $record->id, 'return_route' => 'admin.dtr.view'] + $detailQuery;

        $this->get(route('admin.dtr.edit', $detailEditParameters))
            ->assertOk()
            ->assertSee(route('admin.dtr.view', $detailQuery));

        $this->put(route('admin.dtr.update', $detailEditParameters), [
            'status' => 'present',
        ])->assertRedirect(route('admin.dtr.view', $detailQuery));
    }

    public function test_admin_can_clear_leave_file_cache_without_deleting_leave_records(): void
    {
        $admin = User::factory()->create([
            'user_type' => User::TYPE_ADMIN,
        ]);

        $department = Department::query()->create([
            'name' => 'Leave Test Department',
        ]);

        $employee = Employee::query()->create([
            'first_name' => 'Leave',
            'last_name' => 'Employee',
            'email' => 'leave.employee@example.com',
            'department_id' => $department->id,
            'position' => 'Staff',
        ]);

        LeaveRequest::query()->create([
            'employee_id' => $employee->id,
            'leave_type' => 'Vacation Leave',
            'start_date' => '2026-10-10',
            'end_date' => '2026-10-10',
            'days_deducted' => 1,
            'status' => 'approved',
        ]);

        AdminAuditLog::query()->create([
            'user_id' => $admin->id,
            'action' => 'CREATE',
            'module' => 'Leave Management',
            'description' => 'Imported leave file.',
            'status' => 'Success',
            'metadata' => ['original_filename' => 'leave-applications.xlsx'],
        ]);

        $response = $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($admin)->post(route('admin.leave.clear-cache', [
            'search' => 'Leave',
            'department_id' => 'asp',
            'employee_class' => 'regular',
        ]));

        $response->assertRedirect(route('admin.leave.index', [
            'search' => 'Leave',
            'department_id' => 'asp',
            'employee_class' => 'regular',
        ]));
        $response->assertSessionHas('success', 'Cleared 1 leave file cache entry.');
        $this->assertDatabaseCount('leave_requests', 1);
        $this->assertDatabaseMissing('admin_audit_logs', [
            'action' => 'CREATE',
            'module' => 'Leave Management',
            'description' => 'Imported leave file.',
        ]);
        $this->assertDatabaseHas('admin_audit_logs', [
            'action' => 'DELETE',
            'module' => 'Leave Management',
            'description' => 'Cleared 1 leave file cache entry.',
        ]);
    }

    public function test_admin_wfh_clear_all_returns_to_the_filtered_list(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);
        $filters = [
            'search' => 'Alex',
            'department_id' => 'asp',
            'status' => 'pending',
            'date_from' => '2026-10-01',
            'date_to' => '2026-10-31',
        ];

        $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($admin)
            ->delete(route('admin.wfh-monitoring.clear-all', $filters))
            ->assertRedirect(route('admin.wfh-monitoring.index', $filters));
    }
}
