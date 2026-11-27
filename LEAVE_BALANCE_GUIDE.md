# Leave Balance System - Implementation Guide

## What Has Been Implemented

A complete leave management system with:
1. ✅ Leave balance tracking (VL, SL, EL only)
2. ✅ Base leave credits by employment type
3. ✅ Tenure-based credits for Faculty and ASP, with eligibility thresholds
4. ✅ Detailed leave usage breakdown
5. ✅ Deductible vs tracked-only leave classification

---

## Quick Start

### 1. Initialize Employee Leave Balances

**First time setup** - Initialize all employees:
```bash
php artisan leave-balance:initialize --force
```

**Or initialize specific employee**:
```bash
php artisan leave-balance:initialize --employee-id=5
```

This command:
- Calculates credits based on employment type and service milestones
- Applies yearly accrual after the Faculty or ASP eligibility threshold
- Creates `LeaveBalance` records for VL, SL, EL
- Calculates remaining balance = total credits - used days

### 2. View Employee Leave Balances

Employee navigates to **Attendance & DTR** → **Leave Monitoring**:
- Sees remaining balance for VL, SL, EL (only deductible leaves)
- Sees detailed usage breakdown:
  - **Deductible Leaves**: VL, SL, EL (affect balance)
  - **Tracked-Only Leaves**: All other types (no balance deduction)
- Views full leave history table

---

## System Architecture

### Three Main Components

#### 1. LeaveBalanceService
**Location**: `app/Services/LeaveBalanceService.php`

**Key Methods**:
```php
// Initialize or update balance for an employee
initializeOrUpdateBalance(Employee $employee): void

// Get remaining balances for deductible leaves only
getDeductibleLeaveBalances(Employee $employee): Collection

// Get detailed usage breakdown (deductible + tracked)
getLeaveUsageBreakdown(Employee $employee): array

// Get remaining balance for specific leave type
getRemainingBalance(Employee $employee, string $leaveType): float

// Check if leave type affects balance
isDeductibleLeaveType(string $leaveType): bool
```

#### 2. Console Command
**Location**: `app/Console/Commands/InitializeLeaveBalances.php`

**Usage**:
```bash
php artisan leave-balance:initialize [--employee-id=ID] [--force]
```

#### 3. Enhanced Employee Portal
**Controller**: `app/Http/Controllers/Employee/PortalController.php`
**View**: `resources/views/employee/leave.blade.php`

---

## Leave Credit Structure

### Credits and Eligibility

| Employee Type | Before Eligibility | Initial Credits |
|---|---|---|
| Faculty (non-contractual, full-time) | 0 / 0 / 0 | At 1 year: 11 VL / 11 SL / 3 EL |
| ASP | 0 / 0 / 0 | At 6 months: 9 VL / 9 SL / 3 EL |
| Part-Time Faculty | 0 / 0 / 0 | Always 0 / 0 / 0 |
| Contractual Full-Time Faculty | Existing term rules | 3 VL / 3 SL / 3 EL per term |

After initial eligibility, Faculty receive +2 VL and +2 SL at each completed service-year milestone starting at year 2. ASP receive +2 VL and +2 SL at each completed service-year milestone starting at year 1. Both are capped at 15 VL and 15 SL; EL remains fixed at 3. Contractual faculty retain their existing per-term rules.

### Complete Example Timeline

**Faculty Employee Hired May 1, 2024**:
```
May 2024: Before 1 year
- VL: 0, SL: 0, EL: 0

May 2025: Year 1
- VL: 11, SL: 11, EL: 3 (initial credits)

May 2026: Year 2
- VL: 11+2=13, SL: 11+2=13, EL: 3

May 2027: Year 3
- VL: 13+2=15, SL: 13+2=15, EL: 3 (reaches max)

May 2028: Year 4+
- VL: 15 (max), SL: 15 (max), EL: 3 (no change, at max)
```

---

## Deductible vs Tracked-Only Leaves

### DEDUCTIBLE LEAVES (Affect Balance)
Only these 3 leave types reduce the remaining balance:
- ✓ **Vacation Leave** (VL)
- ✓ **Sick Leave** (SL)
- ✓ **Emergency Leave** (EL)

### TRACKED-ONLY LEAVES (No Balance Deduction)
These are recorded but do NOT reduce balance:
- Bereavement Leave
- Training Leave
- Official Business
- Work From Home
- Birthday Leave
- Maternity Leave
- Solo Parent Leave
- Paternity Leave
- Special Leave for Women
- Study Leave With Pay
- Study Leave Without Pay
- Leave Without Pay
- Research Leave

---

## Database Schema

### LeaveBalance Table
```sql
CREATE TABLE leave_balances (
  id BIGINT PRIMARY KEY,
  employee_id BIGINT REFERENCES employees,
  leave_type VARCHAR(50),
  remaining_days DECIMAL(5, 2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(employee_id, leave_type)
);
```

**Example Records**:
```
| ID | Employee | Leave Type | Remaining Days |
|----|-----------|-----------|-----------------|
| 1  | John (5) | Vacation Leave | 8.5 |
| 2  | John (5) | Sick Leave | 10.0 |
| 3  | John (5) | Emergency Leave | 3.0 |
| 4  | Jane (6) | Vacation Leave | 6.0 |
| 5  | Jane (6) | Sick Leave | 11.0 |
| 6  | Jane (6) | Emergency Leave | 3.0 |
```

### LeaveRequest Table
```sql
-- Already exists, no changes needed
-- Tracks ALL leave types (deductible + tracked-only)
-- Only approved requests are counted for balance deduction
```

---

## Employee Portal Changes

### Leave Monitoring Page Now Shows

1. **Quick Usage Summary**
   - Vacation Used, Sick Used, Emergency Used (in colored cards)

2. **Remaining Leave Balance**
   - Only shows deductible leaves (VL, SL, EL)
   - Displays remaining days for each type
   - Example: "Vacation Leave: 8.5 remaining days"

3. **Detailed Usage Breakdown** (NEW)
   - **Deductible Leaves Section**:
     - Vacation Leave: 12 days used (3 requests)
     - Sick Leave: 5 days used (2 requests)
     - Emergency Leave: 1 day used (1 request)
   - **Tracked-Only Leaves Section**:
     - All other leave types with usage counts
     - Clearly marked: "Balance Not Affected"
     - Example: "Bereavement Leave: 3 days (1 request)"

4. **Leave History Table**
   - Complete record of all leave requests
   - Shows type, dates, days, status, cutoff, reason

---

## How to Use in Code

### In Controllers
```php
use App\Services\LeaveBalanceService;

public function someAction(LeaveBalanceService $leaveBalanceService)
{
    $employee = auth()->user()->employee();
    
    // Get deductible balances only
    $balances = $leaveBalanceService->getDeductibleLeaveBalances($employee);
    
    // Get detailed breakdown
    $breakdown = $leaveBalanceService->getLeaveUsageBreakdown($employee);
    
    // Check remaining for a specific leave
    $remaining = $leaveBalanceService->getRemainingBalance($employee, 'Vacation Leave');
}
```

### When Approving Leave Requests
```php
// After approving a leave request:
$leaveBalanceService->initializeOrUpdateBalance($employee);
// This recalculates remaining balance
```

### During Employee Onboarding
```php
// When creating a new employee:
$employee = Employee::create([...]);
$leaveBalanceService->initializeOrUpdateBalance($employee);
// This sets up initial leave balances
```

---

## Important Notes

### 1. Eligibility
- Faculty receive credits after 1 year of service; ASP receive credits after 6 months.
- Part-Time Faculty always have 0 VL / 0 SL / 0 EL, regardless of tenure.
- Contractual faculty retain their 3 / 3 / 3 per-term credits.

### 2. Yearly Accrual and Usage
- Calculated at completed service-year milestones, with +2 VL and +2 SL per year after initial eligibility.
- Approved deductible leave before eligibility does not use credits earned later.
- Leave usage resets every January 1 for most employees; contractual faculty use their current term start.
- The annual reset command runs daily at 12:05 AM and processes all employees on January 1
- The scheduler must be running for automatic resets: `php artisan schedule:work` or a server cron calling `php artisan schedule:run`

### 3. Balance Calculation Formula
```
Remaining Balance = Total Credits - Used Days

Where:
Total Credits = Base Credits + Yearly Accrual (capped at max)
Used Days = Sum of approved deductible leave days since the later of January 1 or the employee's eligibility date
```

For contractual faculty, the usage period starts at the approved term start date (or hire date before the first term).

### 4. Balance Limits
- Remaining balance is clamped at zero; it cannot become negative.
- Approved deductible leave with no eligible credits is recorded but does not validate attendance as present.
- Usage before the current period is not deducted from the current balance.

---

## Troubleshooting

### Employee Has No Leave Balance
**Cause**: Balance not initialized

**Solution**:
```bash
php artisan leave-balance:initialize --employee-id=<id>
```

### Balance Doesn't Update After Leave Approval
**Cause**: Balance cache or not recalculated

**Solution**:
```bash
php artisan leave-balance:initialize --force
```

### Employee Has Unexpected Credits
**Cause**: Employee type or hire date is not classified as expected

**Solution**: Verify `employment_type` and `hire_date`, then run `php artisan leave-balance:initialize --employee-id=<id>`. Part-Time Faculty should have zero credits; contractual faculty follow their term rules.

### ASP Shows Wrong Credits
**Cause**: Employment type not recognized

**Solution**: Verify employment_type contains:
- "asp" OR
- "admin support" OR
- "admin support personnel"

---

## Future Enhancements

1. **Admin Balance Adjustment UI**
   - HR interface to manually adjust balances
   - Audit trail for adjustments

2. **Leave Carryover Rules**
   - Set maximum carryover (e.g., max 5 days from previous year)
   - Automatic carryover logic

3. **Leave Surrender**
   - Track and report unused leaves at end of year
   - Compensation calculations

4. **Balance Warnings**
   - Alert when balance is running low
   - Block leave requests if insufficient balance (optional)

6. **Historical Tracking**
   - Archive old balances for audit
   - Year-over-year comparison reports

---

## Testing Checklist

- [ ] Initialize employee balances with command
- [ ] Verify Faculty has 0 credits before 1 year, then 11 / 11 / 3
- [ ] Verify Faculty gains +2 VL and SL each following year, capped at 15 / 15 / 3
- [ ] Verify ASP has 0 credits before 6 months, then 9 / 9 / 3
- [ ] Verify ASP gains +2 VL and SL at each completed year, capped at 15 / 15 / 3
- [ ] Verify Part-Time Faculty always has 0 credits and approved leave is absent in DTR
- [ ] Verify contractual faculty still receives 3 / 3 / 3 per term
- [ ] Approve leave request and recalculate
- [ ] Check remaining balance decreased correctly
- [ ] Verify deductible vs tracked-only separation in view
- [ ] Confirm non-deductible leaves don't reduce balance
- [ ] Test with multiple employees
- [ ] Check view cache is cleared
