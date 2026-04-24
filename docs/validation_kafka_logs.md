# Data Validation Report: KAFKA-LOGS

**Source:** `WM_OPENFLOW.KAFKA_LOGS."KAFKA-LOGS"`
**Total Rows:** 504
**Date Range:** 2026-02-10 11:28:48 → 2026-02-10 11:35:31
**dbt Models:** `stg_kafka_logs`, `scd2_kafka_logs`, `kafka_logs_snapshot`

---

## 1. Business Key Validation

| Check | Column | Result | Details |
|-------|--------|--------|---------|
| Uniqueness | `REQUEST_ID` | PASS | 504 distinct values out of 504 rows (100% unique) |
| Not Null | `REQUEST_ID` | PASS | 0 nulls |
| Not Null | `TIMESTAMP` | PASS | 0 nulls |

> `REQUEST_ID` is used as the business key (unique_key) for both the SCD2 incremental model and the snapshot.

---

## 2. Column-Level Validation

### Required Fields (zero nulls expected)

| Column | Null Count | Status |
|--------|-----------|--------|
| `TIMESTAMP` | 0 | PASS |
| `LEVEL` | 0 | PASS |
| `SERVICE` | 0 | PASS |
| `HOST` | 0 | PASS |
| `REQUEST_ID` | 0 | PASS |
| `MESSAGE` | 0 | PASS |
| `STATUS_CODE` | 0 | PASS |

### Optional Fields (nulls acceptable)

| Column | Null Count | Null % | Notes |
|--------|-----------|--------|-------|
| `DURATION_MS` | 38 | 7.5% | Missing for some non-timed events |
| `USER_ID` | 219 | 43.5% | System/anonymous requests |
| `AMOUNT` | 488 | 96.8% | Only populated for payment-related events |
| `ERROR` | 453 | 89.9% | Only populated when errors occur |

---

## 3. Accepted Values Validation

### LEVEL

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `INFO`, `WARN`, `ERROR` | 3 | PASS |

### SERVICE

| Accepted Values | Distinct Count | Status |
|----------------|---------------|--------|
| `auth-service`, `web-api`, `notification-service`, `inventory-service`, `payment-service`, `db-service`, `search-service`, `analytics-service` | 8 | PASS |

### HOST

| Distinct Count | Status | Sample Values |
|---------------|--------|---------------|
| 14 | PASS | `api-server-01`, `api-server-02`, `api-server-03`, `auth-server-01`, `auth-server-02`, `db-server-01`, `payment-server-01`, `payment-server-02`, `search-server-01`, `search-server-02`, `notif-server-01`, `inventory-server-01`, `inventory-server-02`, `analytics-server-01` |

---

## 4. Numeric Range Validation

| Column | Min | Max | Status | Expected Range |
|--------|-----|-----|--------|---------------|
| `DURATION_MS` | 10 | 9980 | PASS | 0 - 30000 ms |
| `STATUS_CODE` | 200 | 504 | PASS | Valid HTTP codes (100-599) |

---

## 5. SCD2 Model Validation

### Hash Columns Used in `scd2_kafka_logs`

The `row_hash` is computed from:

| Column | In Hash | Rationale |
|--------|---------|-----------|
| `LEVEL` | Yes | Change in severity = new version |
| `SERVICE` | Yes | Service reassignment = new version |
| `HOST` | Yes | Host migration = new version |
| `STATUS_CODE` | Yes | Status change = new version |
| `AMOUNT` | Yes | Financial value change = new version |
| `ERROR` | Yes | Error state change = new version |
| `MESSAGE` | No | Too volatile, would create excessive versions |
| `DURATION_MS` | No | Varies per request, not a trackable attribute |
| `USER_ID` | No | Excluded — same request won't change user |

### SCD2 Metadata Columns

| Column | Type | Description |
|--------|------|-------------|
| `scd_key` | VARCHAR | MD5 surrogate key (REQUEST_ID + valid_from) |
| `valid_from` | TIMESTAMP_NTZ | Row effective start |
| `valid_to` | TIMESTAMP_NTZ | Row effective end (NULL = current) |
| `is_current` | BOOLEAN | TRUE for latest version |

---

## 6. Recommended dbt Tests

```yaml
# models/scd2/schema.yml
version: 2

models:
  - name: scd2_kafka_logs
    description: SCD Type 2 incremental model for Kafka logs
    columns:
      - name: scd_key
        tests:
          - unique
          - not_null
      - name: REQUEST_ID
        tests:
          - not_null
      - name: is_current
        tests:
          - accepted_values:
              values: [true, false]
      - name: valid_from
        tests:
          - not_null

  - name: stg_kafka_logs
    description: Staging model for raw Kafka logs
    columns:
      - name: REQUEST_ID
        tests:
          - unique
          - not_null
      - name: event_at
        tests:
          - not_null
      - name: log_level
        tests:
          - not_null
          - accepted_values:
              values: ['INFO', 'WARN', 'ERROR']
      - name: service_name
        tests:
          - not_null
          - accepted_values:
              values: ['auth-service', 'web-api', 'notification-service', 'inventory-service', 'payment-service', 'db-service', 'search-service', 'analytics-service']
      - name: STATUS_CODE
        tests:
          - not_null
```

---

## 7. Data Quality Summary

| Category | Checks | Passed | Failed |
|----------|--------|--------|--------|
| Business Key | 2 | 2 | 0 |
| Not Null (required) | 7 | 7 | 0 |
| Accepted Values | 2 | 2 | 0 |
| Numeric Ranges | 2 | 2 | 0 |
| **Total** | **13** | **13** | **0** |
