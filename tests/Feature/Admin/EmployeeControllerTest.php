<?php

namespace Tests\Feature\Admin;

use App\Models\Department;
use App\Models\Employee;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class EmployeeControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_employee_create_stores_the_provided_employee_id(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);
        $department = Department::create(['name' => 'ASP']);

        Mail::fake();

        $response = $this
            ->actingAs($admin)
            ->post(route('admin.employees.store'), [
                'employee_id' => 'ADM-2026-001',
                'first_name' => 'Jane',
                'last_name' => 'Doe',
                'email' => 'jane.doe@example.com',
                'employment_type' => 'Admin Support Personnel',
                'position' => 'Asset Management Office',
                'department_id' => $department->id,
            ]);

        $response->assertRedirect(route('admin.employees.index'));

        $this->assertDatabaseHas('employees', [
            'employee_id' => 'ADM-2026-001',
            'email' => 'jane.doe@example.com',
        ]);
    }

    public function test_admin_employee_create_requires_employee_id(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);

        $response = $this
            ->actingAs($admin)
            ->from(route('admin.employees.create'))
            ->post(route('admin.employees.store'), [
                'first_name' => 'Jane',
                'last_name' => 'Doe',
                'email' => 'jane.doe@example.com',
                'employment_type' => 'Admin Support Personnel',
                'position' => 'Asset Management Office',
            ]);

        $response->assertSessionHasErrors('employee_id');
        $this->assertDatabaseMissing('employees', ['email' => 'jane.doe@example.com']);
    }

    public function test_admin_employee_filters_are_preserved_through_profile_edit_and_update(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);
        $department = Department::create(['name' => 'ASP']);
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
        ])->actingAs($admin)
            ->get(route('admin.employees.index', $filters))
            ->assertOk()
            ->assertSee(route('admin.employees.show', ['employee' => $employee] + $filters))
            ->assertSee(route('admin.employees.edit', ['employee' => $employee] + $filters));

        $this->get(route('admin.employees.show', ['employee' => $employee] + $filters))
            ->assertOk()
            ->assertSee(route('admin.employees.index', $filters));

        $this->get(route('admin.employees.edit', ['employee' => $employee] + $filters))
            ->assertOk()
            ->assertSee(route('admin.employees.index', $filters))
            ->assertSee(route('admin.employees.update', ['employee' => $employee] + $filters));

        $this->put(route('admin.employees.update', ['employee' => $employee] + $filters), [
            'employee_id' => $employee->employee_id,
            'first_name' => 'Jane',
            'last_name' => 'Doe',
            'email' => 'jane.doe@example.com',
            'employment_type' => 'Admin Support Personnel',
            'employment_status' => 'probationary',
            'position' => 'Asset Management Office',
            'department_id' => $department->id,
            'status' => 'active',
        ])->assertRedirect(route('admin.employees.index', $filters));

        $this->get(route('admin.employees.index', $filters))
            ->assertOk()
            ->assertDontSee('jane.doe@example.com');
    }
}
