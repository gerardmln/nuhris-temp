<?php

namespace Tests\Feature\Admin;

use App\Models\Department;
use App\Models\Employee;
use App\Models\EmployeeScheduleSubmission;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduleManagementFilterTest extends TestCase
{
    use RefreshDatabase;

    public function test_schedule_filters_are_preserved_when_editing_and_saving_a_schedule(): void
    {
        $admin = User::factory()->create(['user_type' => User::TYPE_ADMIN]);
        $department = Department::query()->create(['name' => 'ASP']);
        $employee = Employee::query()->create([
            'first_name' => 'Jane',
            'last_name' => 'Doe',
            'email' => 'jane.doe@example.com',
            'employment_type' => 'Admin Support Personnel',
            'position' => 'Asset Management Office',
            'department_id' => $department->id,
        ]);
        $submission = EmployeeScheduleSubmission::query()->create([
            'employee_id' => $employee->id,
            'submitted_by' => $admin->id,
            'semester_label' => '1st Term',
            'academic_year' => '2026-2027',
            'status' => 'pending',
            'submitted_at' => now(),
            'is_current' => true,
        ]);
        $filters = [
            'department_id' => (string) $department->id,
            'status' => 'pending',
        ];

        $this->withSession([
            'privacy_notice_acknowledged_version' => config('privacy.notice_version'),
        ])->actingAs($admin)
            ->get(route('admin.schedules.index', $filters))
            ->assertOk()
            ->assertSee(route('admin.schedules.edit', ['submission' => $submission] + $filters));

        $this->get(route('admin.schedules.edit', ['submission' => $submission] + $filters))
            ->assertOk()
            ->assertSee(route('admin.schedules.index', $filters))
            ->assertSee(route('admin.schedules.update', ['submission' => $submission] + $filters));

        $this->put(route('admin.schedules.update', ['submission' => $submission] + $filters), [
            'days' => [
                [
                    'day_name' => 'Monday',
                    'day_index' => 1,
                    'has_work' => '1',
                    'time_in' => '08:00',
                    'time_out' => '17:00',
                ],
            ],
        ])->assertRedirect(route('admin.schedules.index', $filters));
    }
}
