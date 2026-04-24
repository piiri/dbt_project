# Data Validation Report: PRESCRIPTIONS

**Source:** `HEALTHCARE_DW.RAW.PRESCRIPTIONS`
**Total Rows:** 20
**dbt Models:** `stg_prescriptions`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `PRESCRIPTION_ID` | PASS | 20 distinct values out of 20 rows (100% unique) |
| Not Null | `PRESCRIPTION_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### All Fields — Zero Nulls

| Column | Null Count | Status |
|--------|-----------|--------|
| `PRESCRIPTION_ID` | 0 | PASS |
| `CONSULTATION_ID` | 0 | PASS |
| `PATIENT_ID` | 0 | PASS |
| `DOCTOR_ID` | 0 | PASS |
| `MEDICINE_NAME` | 0 | PASS |
| `DOSAGE` | 0 | PASS |
| `FREQUENCY` | 0 | PASS |
| `DURATION_DAYS` | 0 | PASS |
| `QUANTITY` | 0 | PASS |

---

## 3. Accepted Values Validation

### FREQUENCY

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Once daily`, `Once daily morning`, `Once daily at night`, `Twice daily`, `Three times daily`, `As needed`, `As needed for panic` | 7 | PASS |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `DURATION_DAYS` | 5 | 90 | PASS | 1 - 365 |
| `QUANTITY` | 1 | 180 | PASS | > 0 |

---

## 5. Referential Integrity

| FK Column | References | Expected | Status |
|-----------|-----------|----------|--------|
| `CONSULTATION_ID` | `CONSULTATIONS.CONSULTATION_ID` | All values exist | TO VALIDATE |
| `PATIENT_ID` | `PATIENTS.PATIENT_ID` | All values exist | TO VALIDATE |
| `DOCTOR_ID` | `DOCTORS.DOCTOR_ID` | All values exist | TO VALIDATE |

---

## 6. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null | 9 | 9 | 0 |
| Accepted Values | 1 | 1 | 0 |
| Numeric Ranges | 2 | 2 | 0 |
| **Total** | **14** | **14** | **0** |
