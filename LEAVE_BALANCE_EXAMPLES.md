# Leave Balance Calculation Examples

## Scenario 1: Faculty Employee - Before 1 Year

**Employee Details**:
- Employment Type: Faculty
- Hire Date: May 1, 2026 (4 months ago)
- Not yet eligible for credits

Before completing 1 year of service, credits are **0 VL / 0 SL / 0 EL**. An approved leave during this period is recorded but the employee is marked absent in DTR; it does not consume credits earned later.

---

## Scenario 2: Faculty Employee - 1 Year of Service

**Employee Details**:
- Employment Type: Faculty
- Hire Date: May 1, 2025 (13 months ago)
- Has completed 1 year of service

**Leave Credits Calculation**:
```
At the 1-year mark, initial credits begin:
- Vacation Leave: 11 days
- Sick Leave: 11 days
- Emergency Leave: 3 days
```

**Usage Example**:
- Approved Vacation Leave: 5 days
- Approved Sick Leave: 3 days
- Approved Emergency Leave: 1 day

**Remaining Balance**:
- Vacation Leave: 11 - 5 = 6 days
- Sick Leave: 11 - 3 = 8 days
- Emergency Leave: 3 - 1 = 2 days ✓

---

## Scenario 3: Faculty Employee - Year 3 and Maximum

**Employee Details**:
- Employment Type: Faculty
- Hire Date: May 1, 2023 (3 years ago)
- Has completed 3 years of service

**Leave Credits Calculation**:
```
- Year 1: 11 VL / 11 SL / 3 EL
- Year 2: 13 VL / 13 SL / 3 EL
- Year 3: 15 VL / 15 SL / 3 EL
- Year 4 and later: remains capped at 15 VL / 15 SL / 3 EL

Total Credits:
- Vacation Leave: 15
- Sick Leave: 15
- Emergency Leave: 3 (never increments)
```

**Usage Example**:
- Approved Vacation Leave: 8 days
- Approved Sick Leave: 6 days
- Approved Emergency Leave: 0 days

**Remaining Balance**:
- Vacation Leave: 15 - 8 = 7 days ✓
- Sick Leave: 15 - 6 = 9 days ✓
- Emergency Leave: 3 - 0 = 3 days ✓

---

## Scenario 4: ASP Employee - Before 6 Months

**Employee Details**:
- Employment Type: Admin Support Personnel
- Hire Date: May 1, 2026 (4 months ago)
- Not yet eligible for credits

**Leave Credits Calculation**:
```
Before completing 6 months of service, credits are 0 VL / 0 SL / 0 EL.

Total Credits:
- Vacation Leave: 0
- Sick Leave: 0
- Emergency Leave: 0
```

---

## Scenario 5: ASP Employee - 6 Months of Service

**Employee Details**:
- Employment Type: Admin Support Personnel
- Has completed 6 months of service

**Leave Credits Calculation**:
```
- Initial ASP credits begin at 6 months.
- Vacation Leave: 9
- Sick Leave: 9
- Emergency Leave: 3
```

---

## Scenario 6: ASP Employee - 1 Year of Service

**Employee Details**:
- Employment Type: Admin Support Personnel
- Has completed 1 year of service

**Leave Credits Calculation**:
```
- Initial credits at 6 months: 9 VL / 9 SL / 3 EL
- At 1 year: +2 VL and +2 SL

Total Credits:
- Vacation Leave: 11
- Sick Leave: 11
- Emergency Leave: 3
```

---

## Scenario 7: Part-Time Faculty (No Leave Benefits)

**Employee Details**:
- Employment Type: Part-Time Faculty
- Hire Date: May 1, 2022 (4 years ago)
- No leave benefits regardless of tenure

**Leave Credits Calculation**:
```
Part-Time Faculty always have zero leave credits.

Total Credits:
- Vacation Leave: 0 (not eligible)
- Sick Leave: 0 (not eligible)
- Emergency Leave: 0 (not eligible)

Approved leave is recorded but does not validate attendance as present in DTR.
```

---

## Leave Usage Breakdown Display

### Example Employee Leave History

**Deductible Leaves** (Affect Balance):
- ✓ Vacation Leave: 12 days used (3 requests)
- ✓ Sick Leave: 5 days used (2 requests)
- ✓ Emergency Leave: 1 day used (1 request)

**Tracked-Only Leaves** (No Balance Deduction):
- Bereavement Leave: 3 days (1 request)
- Training Leave: 8 days (1 request)
- Official Business: 2 days (2 requests)
- Work From Home: 15 days (monthly)
- Birthday Leave: 1 day (1 request)
- Research Leave: 5 days (1 request)
- Solo Parent Leave: 0 days
- Paternity Leave: 0 days
- Study Leave With Pay: 0 days
- Study Leave Without Pay: 0 days
- Leave Without Pay: 0 days
- Maternity Leave: 0 days
- Special Leave for Women: 0 days

**Summary**:
- Total Deductible Days Used: 18 days
- Remaining Balance: max(0, 15 - 18) = 0
- Total Tracked (Non-deductible) Days: 34 days
  - These are recorded but do NOT affect balance

---

## Implementation Notes

1. **Eligibility**:
   - Faculty credits begin at 1 year; ASP credits begin at 6 months.
   - Part-Time Faculty always have zero credits.
   - Contractual Faculty retain 3 / 3 / 3 credits per term.

2. **Accrual Timing**:
   - Faculty get +2 VL/SL at years 2 and later; ASP at years 1 and later.
   - Respects maximum credits (15 for VL/SL, 3 for EL).

3. **Balance Updates**:
   - Updated when leave requests are approved/rejected
   - Recalculated when running `leave-balance:initialize`
   - Leave used before eligibility does not reduce credits earned later.
   - The usage period resets every January 1 for most employees; contractual Faculty follow their term.

4. **Leave Request Processing**:
   - Only deductible leaves deduct from balance
   - All leaves are tracked in database
   - Approved status required for calculation
