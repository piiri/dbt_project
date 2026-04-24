# Data Validation Report: DOCTORS

**Source:** `HEALTHCARE_DW.RAW.DOCTORS`
**Total Rows:** 10
**dbt Models:** `stg_doctors`, `scd2_doctors`, `doctors_snapshot`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `DOCTOR_ID` | PASS | 10 distinct values out of 10 rows (100% unique) |
| Not Null | `DOCTOR_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### All Fields — Zero Nulls

| Column | Null Count | Status |
|--------|-----------|--------|
| `DOCTOR_ID` | 0 | PASS |
| `FIRST_NAME` | 0 | PASS |
| `LAST_NAME` | 0 | PASS |
| `SPECIALIZATION` | 0 | PASS |
| `QUALIFICATION` | 0 | PASS |
| `CLINIC_NAME` | 0 | PASS |
| `CLINIC_CITY` | 0 | PASS |
| `CONSULTATION_FEE` | 0 | PASS |
| `RATING` | 0 | PASS |
| `LICENSE_NUMBER` | 0 | PASS |

---

## 3. Accepted Values Validation

### SPECIALIZATION

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Cardiology`, `Dermatology`, `General Medicine`, `Orthopedics`, `Psychiatry`, `Pediatrics`, `ENT`, `Gynecology`, `Neurology`, `Diabetology` | 10 | PASS |

### CLINIC_CITY

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Mumbai`, `New Delhi`, `Bangalore`, `Chennai`, `Gurugram`, `Kochi`, `Pune`, `Hyderabad` | 8 | PASS |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `CONSULTATION_FEE` | 500 | 1500 | PASS | 100 - 5000 INR |
| `RATING` | 4.30 | 4.90 | PASS | 1.0 - 5.0 |
| `YEARS_OF_EXPERIENCE` | 10 | 25 | PASS | 0 - 50 |

---

## 5. SCD2 Hash Columns (scd2_doctors)

| Column | In Hash | Rationale |
|--------|---------|-----------|
| `SPECIALIZATION` | Yes | Doctor adds new specialization |
| `CLINIC_NAME` | Yes | Moves to a different hospital |
| `CLINIC_CITY` | Yes | Relocates practice |
| `CLINIC_STATE` | Yes | State-level relocation |
| `CONSULTATION_FEE` | Yes | Fee revision = business event |
| `AVAILABLE_ONLINE` | Yes | Online availability change |
| `IS_ACTIVE` | Yes | Doctor deactivation |
| `FIRST_NAME` | No | Rarely changes |
| `QUALIFICATION` | No | Append-only, not tracked |
| `RATING` | No | Too volatile, changes frequently |
| `YEARS_OF_EXPERIENCE` | No | Auto-increments, not a real change |

---

## 6. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null | 10 | 10 | 0 |
| Accepted Values | 2 | 2 | 0 |
| Numeric Ranges | 3 | 3 | 0 |
| **Total** | **17** | **17** | **0** |
