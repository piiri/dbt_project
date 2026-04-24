# Data Validation Report: PAYMENTS

**Source:** `HEALTHCARE_DW.RAW.PAYMENTS`
**Total Rows:** 18
**dbt Models:** `stg_payments`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `PAYMENT_ID` | PASS | 18 distinct values out of 18 rows (100% unique) |
| Not Null | `PAYMENT_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### Required Fields

| Column | Null Count | Status |
|--------|-----------|--------|
| `PAYMENT_ID` | 0 | PASS |
| `ORDER_ID` | 0 | PASS |
| `PATIENT_ID` | 0 | PASS |
| `PAYMENT_DATE` | 0 | PASS |
| `AMOUNT` | 0 | PASS |
| `PAYMENT_METHOD` | 0 | PASS |
| `PAYMENT_STATUS` | 0 | PASS |

### Optional Fields

| Column | Null Count | Null % | Notes |
|--------|-----------|--------|-------|
| `INSURANCE_CLAIM_ID` | 6 | 33.3% | NULL for cash/non-insured payments |

---

## 3. Accepted Values Validation

### PAYMENT_METHOD

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `UPI`, `Credit Card`, `Debit Card`, `Cash`, `Net Banking` | 5 | PASS |

### PAYMENT_STATUS

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Success`, `Pending`, `Refunded` | 3 | PASS |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `AMOUNT` | 40.50 | 990.00 | PASS | > 0 |
| `PATIENT_PAID_AMOUNT` | 40.50 | 390.00 | PASS | >= 0 |

---

## 5. Financial Integrity

| Check | Details | Status |
|-------|---------|--------|
| `AMOUNT = INSURANCE_COVERED_AMOUNT + PATIENT_PAID_AMOUNT` | Total should equal sum of parts | TO VALIDATE via dbt test |

---

## 6. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null (required) | 7 | 7 | 0 |
| Accepted Values | 2 | 2 | 0 |
| Numeric Ranges | 2 | 2 | 0 |
| **Total** | **13** | **13** | **0** |
