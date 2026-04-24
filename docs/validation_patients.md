# Data Validation Report: PATIENTS

**Source:** `HEALTHCARE_DW.RAW.PATIENTS`
**Total Rows:** 15
**Registration Date Range:** 2024-01-10 → 2024-08-01
**dbt Models:** `stg_patients`, `scd2_patients`, `patients_snapshot`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `PATIENT_ID` | PASS | 15 distinct values out of 15 rows (100% unique) |
| Not Null | `PATIENT_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### All Fields — Zero Nulls

| Column | Null Count | Status |
|--------|-----------|--------|
| `PATIENT_ID` | 0 | PASS |
| `FIRST_NAME` | 0 | PASS |
| `LAST_NAME` | 0 | PASS |
| `DATE_OF_BIRTH` | 0 | PASS |
| `GENDER` | 0 | PASS |
| `PHONE` | 0 | PASS |
| `EMAIL` | 0 | PASS |
| `CITY` | 0 | PASS |
| `STATE` | 0 | PASS |
| `INSURANCE_PROVIDER` | 0 | PASS |
| `INSURANCE_PLAN` | 0 | PASS |
| `BLOOD_GROUP` | 0 | PASS |
| `IS_ACTIVE` | 0 | PASS |

---

## 3. Accepted Values Validation

### GENDER

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Male`, `Female` | 2 | PASS |

### INSURANCE_PROVIDER

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Star Health`, `ICICI Lombard`, `HDFC ERGO`, `Max Bupa`, `Bajaj Allianz`, `New India Assurance` | 6 | PASS |

### INSURANCE_PLAN

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Gold`, `Silver`, `Platinum` | 3 | PASS |

### BLOOD_GROUP

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-` | 8 | PASS |

---

## 4. Geographic Coverage

| Dimension | Distinct Count | Values |
|-----------|---------------|--------|
| States | 10 | Maharashtra, Telangana, Delhi, Karnataka, Rajasthan, Tamil Nadu, Gujarat, Kerala, Uttar Pradesh, West Bengal |
| Cities | 13 | Mumbai, Hyderabad, New Delhi, Bangalore, Jaipur, Chennai, Ahmedabad, Kochi, Lucknow, Pune, Kolkata, Trivandrum, Noida |

---

## 5. SCD2 Hash Columns (scd2_patients)

| Column | In Hash | Rationale |
|--------|---------|-----------|
| `PHONE` | Yes | Patient changes phone number |
| `EMAIL` | Yes | Email updates |
| `ADDRESS_LINE1` | Yes | Address change = new version |
| `CITY` | Yes | Relocation tracking |
| `STATE` | Yes | State-level migration |
| `PIN_CODE` | Yes | Granular location change |
| `INSURANCE_PROVIDER` | Yes | Insurance switch = critical business event |
| `INSURANCE_PLAN` | Yes | Plan upgrade/downgrade |
| `EMERGENCY_CONTACT` | Yes | Emergency contact update |
| `IS_ACTIVE` | Yes | Patient deactivation tracking |
| `FIRST_NAME` | No | Rarely changes, not business-critical |
| `DATE_OF_BIRTH` | No | Immutable |
| `GENDER` | No | Rarely changes |
| `BLOOD_GROUP` | No | Immutable |

---

## 6. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null | 13 | 13 | 0 |
| Accepted Values | 4 | 4 | 0 |
| **Total** | **19** | **19** | **0** |
