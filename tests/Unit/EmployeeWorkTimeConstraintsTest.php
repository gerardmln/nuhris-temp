<?php

namespace Tests\Unit;

use App\Support\EmployeeWorkTimeConstraints;
use Illuminate\Support\Facades\Validator;
use Tests\TestCase;

class EmployeeWorkTimeConstraintsTest extends TestCase
{
    public function test_schedule_shift_of_one_hour_or_less_fails_validation(): void
    {
        $validator = Validator::make([
            'time_in' => '08:00',
            'time_out' => '09:00',
        ], []);

        EmployeeWorkTimeConstraints::applyToValidator(
            $validator,
            minimumDurationMinutes: EmployeeWorkTimeConstraints::SCHEDULE_MIN_DURATION_MINUTES,
        );

        $this->assertTrue($validator->fails());
        $this->assertSame(
            ['Time in and time out must be more than 1 hour apart.'],
            $validator->errors()->get('time_out'),
        );
    }

    public function test_schedule_shift_longer_than_one_hour_passes_validation(): void
    {
        $validator = Validator::make([
            'time_in' => '08:00',
            'time_out' => '09:01',
        ], []);

        EmployeeWorkTimeConstraints::applyToValidator(
            $validator,
            minimumDurationMinutes: EmployeeWorkTimeConstraints::SCHEDULE_MIN_DURATION_MINUTES,
        );

        $this->assertFalse($validator->fails());
    }
}
