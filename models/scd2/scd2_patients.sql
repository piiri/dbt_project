{{
    config(
        materialized='incremental',
        unique_key='scd_key',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

WITH source_data AS (
    SELECT
        PATIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        DATE_OF_BIRTH,
        GENDER,
        PHONE,
        EMAIL,
        ADDRESS_LINE1,
        CITY,
        STATE,
        PIN_CODE,
        INSURANCE_PROVIDER,
        INSURANCE_PLAN,
        BLOOD_GROUP,
        EMERGENCY_CONTACT,
        IS_ACTIVE,
        LAST_UPDATED,
        MD5(
            COALESCE(PHONE, '') || '|' ||
            COALESCE(EMAIL, '') || '|' ||
            COALESCE(ADDRESS_LINE1, '') || '|' ||
            COALESCE(CITY, '') || '|' ||
            COALESCE(STATE, '') || '|' ||
            COALESCE(PIN_CODE, '') || '|' ||
            COALESCE(INSURANCE_PROVIDER, '') || '|' ||
            COALESCE(INSURANCE_PLAN, '') || '|' ||
            COALESCE(EMERGENCY_CONTACT, '') || '|' ||
            COALESCE(IS_ACTIVE::VARCHAR, '')
        ) AS row_hash
    FROM {{ source('healthcare_raw', 'patients') }}
),

{% if is_incremental() %}

existing AS (
    SELECT PATIENT_ID, row_hash, valid_from, valid_to, is_current
    FROM {{ this }}
    WHERE is_current = TRUE
),

changes AS (
    SELECT s.*
    FROM source_data s
    LEFT JOIN existing e ON s.PATIENT_ID = e.PATIENT_ID
    WHERE e.PATIENT_ID IS NULL OR e.row_hash != s.row_hash
),

expired AS (
    SELECT
        MD5(e.PATIENT_ID || '|' || e.valid_from::VARCHAR) AS scd_key,
        e.PATIENT_ID,
        NULL::VARCHAR AS FIRST_NAME, NULL::VARCHAR AS LAST_NAME,
        NULL::DATE AS DATE_OF_BIRTH, NULL::VARCHAR AS GENDER,
        NULL::VARCHAR AS PHONE, NULL::VARCHAR AS EMAIL,
        NULL::VARCHAR AS ADDRESS_LINE1, NULL::VARCHAR AS CITY,
        NULL::VARCHAR AS STATE, NULL::VARCHAR AS PIN_CODE,
        NULL::VARCHAR AS INSURANCE_PROVIDER, NULL::VARCHAR AS INSURANCE_PLAN,
        NULL::VARCHAR AS BLOOD_GROUP, NULL::VARCHAR AS EMERGENCY_CONTACT,
        NULL::BOOLEAN AS IS_ACTIVE, NULL::TIMESTAMP_NTZ AS LAST_UPDATED,
        e.row_hash,
        e.valid_from,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS valid_to,
        FALSE AS is_current
    FROM existing e
    INNER JOIN changes c ON e.PATIENT_ID = c.PATIENT_ID
),

new_records AS (
    SELECT
        MD5(c.PATIENT_ID || '|' || CURRENT_TIMESTAMP()::VARCHAR) AS scd_key,
        c.PATIENT_ID, c.FIRST_NAME, c.LAST_NAME, c.DATE_OF_BIRTH, c.GENDER,
        c.PHONE, c.EMAIL, c.ADDRESS_LINE1, c.CITY, c.STATE, c.PIN_CODE,
        c.INSURANCE_PROVIDER, c.INSURANCE_PLAN, c.BLOOD_GROUP, c.EMERGENCY_CONTACT,
        c.IS_ACTIVE, c.LAST_UPDATED, c.row_hash,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS valid_from,
        NULL::TIMESTAMP_NTZ AS valid_to,
        TRUE AS is_current
    FROM changes c
)

SELECT * FROM expired
UNION ALL
SELECT * FROM new_records

{% else %}

initial_load AS (
    SELECT
        MD5(PATIENT_ID || '|' || CURRENT_TIMESTAMP()::VARCHAR) AS scd_key,
        PATIENT_ID, FIRST_NAME, LAST_NAME, DATE_OF_BIRTH, GENDER,
        PHONE, EMAIL, ADDRESS_LINE1, CITY, STATE, PIN_CODE,
        INSURANCE_PROVIDER, INSURANCE_PLAN, BLOOD_GROUP, EMERGENCY_CONTACT,
        IS_ACTIVE, LAST_UPDATED, row_hash,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS valid_from,
        NULL::TIMESTAMP_NTZ AS valid_to,
        TRUE AS is_current
    FROM source_data
)

SELECT * FROM initial_load

{% endif %}
