# Data Validation Report: ORDERS

**Source:** `HEALTHCARE_DW.RAW.ORDERS`
**Total Rows:** 18
**dbt Models:** `stg_orders`, `scd1_orders`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `ORDER_ID` | PASS | 18 distinct values out of 18 rows (100% unique) |
| Not Null | `ORDER_ID` | PASS | 0 nulls |

---

## 2. Column-Level Validation

### Required Fields

| Column | Null Count | Status |
|--------|-----------|--------|
| `ORDER_ID` | 0 | PASS |
| `PATIENT_ID` | 0 | PASS |
| `PRESCRIPTION_ID` | 0 | PASS |
| `ORDER_DATE` | 0 | PASS |
| `ORDER_STATUS` | 0 | PASS |
| `DELIVERY_TYPE` | 0 | PASS |
| `TOTAL_AMOUNT` | 0 | PASS |

### Optional Fields

| Column | Null Count | Null % | Notes |
|--------|-----------|--------|-------|
| `ACTUAL_DELIVERY_DATE` | 5 | 27.8% | NULL for Placed, Processing, Shipped, Cancelled orders |

---

## 3. Accepted Values Validation

### ORDER_STATUS

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Placed`, `Processing`, `Shipped`, `Delivered`, `Cancelled` | 5 | PASS |

### DELIVERY_TYPE

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `Home Delivery`, `Store Pickup` | 2 | PASS |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `TOTAL_AMOUNT` | 40.50 | 990.00 | PASS | > 0 |
| `DISCOUNT` | 0.00 | 89.00 | PASS | >= 0 |

---

## 5. Order Status Lifecycle Validation

| Status | Expected ACTUAL_DELIVERY_DATE | Observation |
|--------|------------------------------|-------------|
| `Placed` | NULL | PASS |
| `Processing` | NULL | PASS |
| `Shipped` | NULL | PASS |
| `Delivered` | NOT NULL | PASS |
| `Cancelled` | NULL | PASS |

---

## 6. SCD1 Rationale

Orders use SCD1 (overwrite) because:
- Business analysts only care about **current order status**
- Historical status transitions are tracked via `LAST_UPDATED` timestamp
- No need to maintain multiple versions of the same order

---

## 7. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null (required) | 7 | 7 | 0 |
| Accepted Values | 2 | 2 | 0 |
| Numeric Ranges | 2 | 2 | 0 |
| Status Lifecycle | 5 | 5 | 0 |
| **Total** | **18** | **18** | **0** |
