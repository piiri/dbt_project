# Data Validation Report: CONSULTATIONS

**Source:** `HEALTHCARE_DW.RAW.CONSULTATIONS`
**Total Rows:** 20
**Date Range:** 2025-01-15 → 2025-10-20
**dbt Models:** `stg_consultations`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `CONSULTATION_ID` | PASS | 20 distinct values out of 20 rows (100% unique) |
| Not Null | `CONSULTATION_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### Required Fields

| Column | Null Count | Status |
|--------|-----------|--------|
| `CONSULTATION_ID` | 0 | PASS |
| `PATIENT_ID` | 0 | PASS |
| `DOCTOR_ID` | 0 | PASS |
| `CONSULTATION_TYPE` | 0 | PASS |
| `CONSULTATION_DATE` | 0 | PASS |
| `DIAGNOSIS` | 0 | PASS |
| `DIAGNOSIS_CODE` | 0 | PASS |
| `DURATION_MINUTES` | 0 | PASS |

---

## 3. Accepted Values Validation

### CONSULTATION_TYPE

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `In-Person`, `Online` | 2 | PASS |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `DURATION_MINUTES` | 15 | 45 | PASS | 5 - 120 min |

---

## 5. Referential Integrity

| FK Column | References | Expected | Status |
|-----------|-----------|----------|--------|
| `PATIENT_ID` | `PATIENTS.PATIENT_ID` | All values exist in patients | TO VALIDATE |
| `DOCTOR_ID` | `DOCTORS.DOCTOR_ID` | All values exist in doctors | TO VALIDATE |

---

## 6. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null | 8 | 8 | 0 |
| Accepted Values | 1 | 1 | 0 |
| Numeric Ranges | 1 | 1 | 0 |
| **Total** | **12** | **12** | **0** |
