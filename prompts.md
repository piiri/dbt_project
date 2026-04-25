# Prompts to Build This dbt Healthcare Data Warehouse from Scratch

Use these prompts sequentially with Cortex Code  to recreate this entire dbt project on Snowflake. Each prompt builds on the previous one.

---

## Prerequisites

- A Snowflake account with a database `HEALTHCARE_DW` containing a `RAW` schema
- The RAW schema should have 6 source tables: `patients`, `doctors`, `consultations`, `prescriptions`, `orders`, `payments`
- dbt-snowflake installed (`pip install dbt-snowflake`)
- A dbt project initialized (`dbt init dbt_project`)

---

## Prompt 1 — Configure the dbt Project

> I have a fresh dbt project called
  dbt_project targeting Snowflake. Create
  a profiles.yml file with:

    • type: snowflake
    • account: **Your_account_name**
    • user: "your_user_name**
    • authenticator: externalbrowser
    • role: **Your_role**
    • warehouse: **your_Warehouse**
    • database: HEALTHCARE_DW
    • schema: ANALYTICS
    • threads: 4
>
> **dbt_project.yml** — Set the default materialization to `view`, and override the `marts` subfolder to materialize as `table`.

---

## Prompt 2 — Define Sources

> Explore the tables in HEALTHCARE_DW.RAW and create a sources.yml with descriptions 
for all tables and key columns

## Prompt 3 — Create Staging Models

> Create staging views in `models/staging/` for all 6 source tables. Each staging model should:
> - Select all useful columns from the corresponding source
> - Add computed columns where valuable
>
> Specific requirements:
> - **stg_patients.sql** — Add `full_name` (FIRST_NAME || LAST_NAME) and `age` (DATEDIFF from DATE_OF_BIRTH)
> - **stg_doctors.sql** — Add `full_name` with "Dr." prefix
> - **stg_consultations.sql** — Pass through all columns including DIAGNOSIS_CODE
> - **stg_prescriptions.sql** — Pass through all columns
> - **stg_orders.sql** — Add `delivery_days` (DATEDIFF between ORDER_DATE and ACTUAL_DELIVERY_DATE)
> - **stg_payments.sql** — Add `is_insured` boolean flag (TRUE when INSURANCE_CLAIM_ID is not null)

---

## Prompt 4 — Create SCD Type 2 Models (Patient & Doctor History)

> Create SCD Type 2 incremental models to track full change history:
>
> **models/scd2/scd2_patients.sql** — Track changes to patients using an MD5 hash of: PHONE, EMAIL, ADDRESS_LINE1, CITY, STATE, PIN_CODE, INSURANCE_PROVIDER, INSURANCE_PLAN, EMERGENCY_CONTACT, IS_ACTIVE. Use `incremental` materialization with `merge` strategy, `scd_key` as unique key (MD5 of PATIENT_ID + valid_from). Include `row_hash`, `valid_from`, `valid_to`, and `is_current` columns. On incremental runs: expire changed records (set valid_to and is_current=FALSE) and insert new versions.
>
> **models/scd2/scd2_doctors.sql** — Same SCD2 pattern for doctors. Track changes to: SPECIALIZATION, CLINIC_NAME, CLINIC_CITY, CLINIC_STATE, CONSULTATION_FEE, AVAILABLE_ONLINE, IS_ACTIVE.

---

## Prompt 5 — Create SCD Type 1 Model (Order Status Overwrite)

> Create an SCD Type 1 incremental model:
>
> **models/scd1/scd1_orders.sql** — Overwrite order records when status changes. Use `incremental` materialization with `merge` strategy, `ORDER_ID` as unique key. On incremental runs, only process rows where `LAST_UPDATED > max(LAST_UPDATED)` from the existing table. Include an `updated_at` audit timestamp.

---

## Prompt 6 — Create Staging Layer Tests in schema.yml

> Create `models/schema.yml` with comprehensive tests for all staging and SCD models:
>
> - **stg_patients**: unique + not_null on PATIENT_ID; accepted_values on GENDER (Male/Female), INSURANCE_PROVIDER (Star Health, ICICI Lombard, HDFC ERGO, Max Bupa, Bajaj Allianz, New India Assurance), INSURANCE_PLAN (Gold/Silver/Platinum), BLOOD_GROUP (A+, A-, B+, B-, AB+, AB-, O+, O-)
> - **stg_doctors**: unique + not_null on DOCTOR_ID; not_null on SPECIALIZATION and CONSULTATION_FEE; unique + not_null on LICENSE_NUMBER; accepted_values on SPECIALIZATION (Cardiology, Dermatology, General Medicine, Orthopedics, Psychiatry, Pediatrics, ENT, Gynecology, Neurology, Diabetology)
> - **stg_consultations**: unique + not_null on CONSULTATION_ID; not_null on PATIENT_ID and DOCTOR_ID; relationship tests to source patients and doctors tables; accepted_values on CONSULTATION_TYPE (In-Person/Online)
> - **stg_prescriptions**: unique + not_null on PRESCRIPTION_ID; not_null on CONSULTATION_ID, PATIENT_ID, MEDICINE_NAME; relationship test CONSULTATION_ID → source consultations
> - **stg_orders**: unique + not_null on ORDER_ID; not_null on ORDER_STATUS, DELIVERY_TYPE, TOTAL_AMOUNT; accepted_values on ORDER_STATUS (Placed/Processing/Shipped/Delivered/Cancelled) and DELIVERY_TYPE (Home Delivery/Store Pickup)
> - **stg_payments**: unique + not_null on PAYMENT_ID; not_null on PAYMENT_METHOD, PAYMENT_STATUS, AMOUNT; accepted_values on PAYMENT_METHOD (UPI/Credit Card/Debit Card/Cash/Net Banking) and PAYMENT_STATUS (Success/Pending/Refunded/Failed)
> - **scd2_patients**: unique + not_null on scd_key; not_null on PATIENT_ID and valid_from; accepted_values on is_current (true/false)
> - **scd2_doctors**: same pattern as scd2_patients but for DOCTOR_ID
> - **scd1_orders**: unique + not_null on ORDER_ID; not_null + accepted_values on ORDER_STATUS

---

## Prompt 7 — Create Dimension and Fact Tables (Star Schema)

> Create dimension and fact tables in `models/marts/` to build a star schema analytics layer. All should be materialized as tables.
>
> ### Dimensions:
>
> **dim_date.sql** — Generate a calendar dimension for all of 2025 (365 rows) using Snowflake's `GENERATOR(ROWCOUNT => 365)` and `DATEADD`. Columns: date_key (the date itself), year, quarter, month, month_name, week_of_year, day_of_month, day_of_week, day_name, is_weekend (use `DAYNAME(date_day) IN ('Sat', 'Sun')` — NOT DAYOFWEEK which is session-parameter dependent), quarter_label ("Q1 2025"), month_label ("Jan 2025").
>
> **dim_patients.sql** — Patient dimension from `scd2_patients` filtered to `is_current = TRUE` only. Include patient_key (= PATIENT_ID), full_name, demographics, insurance info, blood_group, age.
>
> **dim_doctors.sql** — Doctor dimension from `scd2_doctors` filtered to `is_current = TRUE` only. Include doctor_key (= DOCTOR_ID), full_name with "Dr." prefix, specialization, clinic info, consultation_fee, rating.
>
> **dim_diagnosis.sql** — Distinct ICD-10 diagnosis codes extracted from `stg_consultations`. Deduplicate using `QUALIFY ROW_NUMBER() OVER (PARTITION BY DIAGNOSIS_CODE ORDER BY CONSULTATION_DATE) = 1` to keep one description per code (the same code can have different description text across consultations like "Stable Angina" vs "Stable Angina - Improved"). Columns: diagnosis_key (= DIAGNOSIS_CODE), DIAGNOSIS_CODE, diagnosis_description.
>
> ### Facts:
>
> **fct_consultations.sql** — One row per consultation (grain = CONSULTATION_ID). Join `stg_consultations` with an aggregated prescription CTE from `stg_prescriptions` (count of prescriptions and sum of quantity per consultation). FK columns: patient_key, doctor_key, date_key (CONSULTATION_DATE::DATE), diagnosis_key. Include consultation_type, chief_complaint, diagnosis, duration_minutes, prescription_count (COALESCE to 0), total_medicines_quantity, has_prescriptions boolean.
>
> **fct_orders.sql** — One row per order (grain = ORDER_ID). Join `stg_orders` → `stg_prescriptions` (via PRESCRIPTION_ID) → `stg_consultations` (via CONSULTATION_ID) → `stg_payments` (via ORDER_ID). All LEFT JOINs. FK columns: patient_key, doctor_key, date_key (ORDER_DATE::DATE), diagnosis_key. Include order_status, delivery info, financial columns (subtotal, discount, delivery_fee, total_amount), payment info (method, status, amount), insurance breakdown (insurance_covered_amount, patient_paid_amount with COALESCE to 0), is_insurance_claim boolean.

---

## Prompt 8 — Add Dimension/Fact Tests to schema.yml

> Add tests to `models/schema.yml` for all 6 mart models:
>
> **dim_date**: unique + not_null on date_key; not_null on year and month.
>
> **dim_patients**: unique + not_null on patient_key and PATIENT_ID; not_null on full_name; accepted_values on GENDER (Male/Female).
>
> **dim_doctors**: unique + not_null on doctor_key and DOCTOR_ID; not_null on full_name and SPECIALIZATION.
>
> **dim_diagnosis**: unique + not_null on diagnosis_key and DIAGNOSIS_CODE.
>
> **fct_consultations**: unique + not_null on CONSULTATION_ID; not_null on patient_key, doctor_key, date_key, prescription_count, DURATION_MINUTES; relationship tests for patient_key → dim_patients, doctor_key → dim_doctors, date_key → dim_date; accepted_values on CONSULTATION_TYPE.
>
> **fct_orders**: unique + not_null on ORDER_ID; not_null on patient_key, date_key, TOTAL_AMOUNT, ORDER_STATUS; relationship tests for ALL four FK columns: patient_key → dim_patients, doctor_key → dim_doctors, date_key → dim_date, diagnosis_key → dim_diagnosis; accepted_values on ORDER_STATUS.

---

## Prompt 9 — Build and Validate

> Run `dbt build` to compile all models, execute them on Snowflake, and run all tests. Fix any failures.
>
> Expected results:
> - 19 models (6 staging views, 2 SCD2 incremental, 1 SCD1 incremental, 6 mart tables, 2 placeholder models, 2 log stubs)
> - ~97+ data tests (unique, not_null, relationships, accepted_values)
> - All should PASS
>
> Expected row counts:
> | Model | Rows |
> |---|---|
> | dim_date | 365 |
> | dim_patients | 15 |
> | dim_doctors | 10 |
> | dim_diagnosis | 16 |
> | fct_consultations | 20 |
> | fct_orders | 18 |

---

## Key Lessons / Gotchas

1. **DAYOFWEEK is session-dependent** — Snowflake's `DAYOFWEEK()` result depends on the `WEEK_START` session parameter. Use `DAYNAME(date_day) IN ('Sat', 'Sun')` instead for weekend detection.

2. **ICD-10 codes need deduplication** — The same diagnosis code (e.g., I20.8) can appear with different description text across consultations ("Stable Angina" vs "Stable Angina - Improved"). `SELECT DISTINCT` on (code, description) won't deduplicate. Use `QUALIFY ROW_NUMBER() OVER (PARTITION BY DIAGNOSIS_CODE ORDER BY CONSULTATION_DATE) = 1`.

3. **Test all FK relationships in fact tables** — It's easy to add relationship tests for one FK (like patient_key) but forget the others (doctor_key, date_key, diagnosis_key). Test every foreign key column.

4. **SCD2 dimensions need `WHERE is_current = TRUE`** — The mart dimension tables should only expose current records. The full history stays in the SCD2 models.

5. **Verify join fan-out** — After building fact tables, confirm row counts match the grain table (e.g., fct_orders should have exactly as many rows as stg_orders). Fan-out from 1:many joins is a silent correctness bug.

6. **Snowflake warehouse must be set** — When running SQL outside of dbt (e.g., via sql_execute), you may need to explicitly `USE WAREHOUSE` first.
