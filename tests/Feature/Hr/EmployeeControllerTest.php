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
}
