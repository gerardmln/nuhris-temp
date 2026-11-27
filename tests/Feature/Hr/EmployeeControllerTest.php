<?php

namespace Tests\Feature\Hr;

use App\Models\Department;
use App\Models\Employee;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EmployeeControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_hr_employee_filters_are_preserved_through_profile_and_modal_edit(): void
    {
        $hr = User::factory()->create(['user_type' => User::TYPE_HR]);
        $department = Department::query()->create(['name' => 'ASP']);
        $employee = Employee::query()->create([
            'first_name' => 'Jane',
            'last_name' => 'Doe',
            'email' => 'jane.doe@example.com',
            'employment_type' => 'Admin Support Personnel',
            'employment_status' => 'regular',
            'position' => 'Asset Management Office',
            'department_id' => $department->id,
            'status' => 'active',
        ]);
        $filters = [
            'search' => 'Jane',
            'department_id' => (string) $department->id,
            'employee_class' => 'regular',
            'status' => 'active',
            'position' => 'Asset Management Office',
            'page' => '1',
        ];

        $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($hr)
            ->get(route('employees.index', $filters))
            ->assertOk()
            ->assertSee(route('employees.profile', ['employee' => $employee->id] + $filters))
            ->assertSee('name="status"', false)
            ->assertSee('window.location.search', false);

        $this->get(route('employees.profile', ['employee' => $employee->id] + $filters))
            ->assertOk()
            ->assertSee(route('employees.index', $filters));

        $this->put(route('employees.update', ['employee' => $employee] + $filters), [
            'employee_id' => $employee->employee_id,
            'first_name' => 'Jane',
            'last_name' => 'Doe',
            'email' => 'jane.doe@example.com',
            'employment_type' => 'Admin Support Personnel',
            'employment_status' => 'probationary',
            'position' => 'Asset Management Office',
            'department_id' => $department->id,
            'status' => 'active',
        ])->assertRedirect(route('employees.index', $filters));

        $this->get(route('employees.index', $filters))
            ->assertOk()
            ->assertDontSee('jane.doe@example.com');
    }

    public function test_timekeeping_filters_require_explicit_submission_and_follow_dtr_navigation(): void
    {
        $hr = User::factory()->create(['user_type' => User::TYPE_HR]);
        $department = Department::query()->create(['name' => 'Timekeeping Test']);
        $employee = Employee::query()->create([
            'first_name' => 'Sam',
            'last_name' => 'Staff',
            'email' => 'sam.staff@example.com',
            'employment_type' => 'Faculty',
            'employment_status' => 'regular',
            'position' => 'Instructor',
            'department_id' => $department->id,
            'status' => 'active',
        ]);
        $filters = [
            'search' => 'Sam',
            'department_id' => (string) $department->id,
            'employee_class' => 'all',
            'attendance_range' => 'month',
            'month' => (string) now()->month,
            'year' => (string) now()->year,
        ];

        $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($hr)
            ->get(route('timekeeping.index', $filters))
            ->assertOk()
            ->assertSee('Filter')
            ->assertSee(route('timekeeping.dtr', ['employee' => $employee->id]), false)
            ->assertSee('search=Sam', false)
            ->assertSee('department_id='.$department->id, false);
    }
}
