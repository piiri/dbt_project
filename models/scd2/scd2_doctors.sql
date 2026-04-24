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
        DOCTOR_ID,
        FIRST_NAME,
        LAST_NAME,
        SPECIALIZATION,
        QUALIFICATION,
        CLINIC_NAME,
        CLINIC_CITY,
        CLINIC_STATE,
        CONSULTATION_FEE,
        YEARS_OF_EXPERIENCE,
        RATING,
        AVAILABLE_ONLINE,
        LICENSE_NUMBER,
        IS_ACTIVE,
        LAST_UPDATED,
        MD5(
            COALESCE(SPECIALIZATION, '') || '|' ||
            COALESCE(CLINIC_NAME, '') || '|' ||
            COALESCE(CLINIC_CITY, '') || '|' ||
            COALESCE(CLINIC_STATE, '') || '|' ||
            COALESCE(CONSULTATION_FEE::VARCHAR, '') || '|' ||
            COALESCE(AVAILABLE_ONLINE::VARCHAR, '') || '|' ||
            COALESCE(IS_ACTIVE::VARCHAR, '')
        ) AS row_hash
    FROM {{ source('healthcare_raw', 'doctors') }}
),

{% if is_incremental() %}

existing AS (
    SELECT DOCTOR_ID, row_hash, valid_from, valid_to, is_current
    FROM {{ this }}
    WHERE is_current = TRUE
),

changes AS (
    SELECT s.*
    FROM source_data s
    LEFT JOIN existing e ON s.DOCTOR_ID = e.DOCTOR_ID
    WHERE e.DOCTOR_ID IS NULL OR e.row_hash != s.row_hash
),

expired AS (
    SELECT
        MD5(e.DOCTOR_ID || '|' || e.valid_from::VARCHAR) AS scd_key,
        e.DOCTOR_ID,
        NULL::VARCHAR AS FIRST_NAME, NULL::VARCHAR AS LAST_NAME,
        NULL::VARCHAR AS SPECIALIZATION, NULL::VARCHAR AS QUALIFICATION,
        NULL::VARCHAR AS CLINIC_NAME, NULL::VARCHAR AS CLINIC_CITY,
        NULL::VARCHAR AS CLINIC_STATE, NULL::NUMBER AS CONSULTATION_FEE,
        NULL::NUMBER AS YEARS_OF_EXPERIENCE, NULL::NUMBER AS RATING,
        NULL::BOOLEAN AS AVAILABLE_ONLINE, NULL::VARCHAR AS LICENSE_NUMBER,
        NULL::BOOLEAN AS IS_ACTIVE, NULL::TIMESTAMP_NTZ AS LAST_UPDATED,
        e.row_hash,
        e.valid_from,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS valid_to,
        FALSE AS is_current
    FROM existing e
    INNER JOIN changes c ON e.DOCTOR_ID = c.DOCTOR_ID
),

new_records AS (
    SELECT
        MD5(c.DOCTOR_ID || '|' || CURRENT_TIMESTAMP()::VARCHAR) AS scd_key,
        c.DOCTOR_ID, c.FIRST_NAME, c.LAST_NAME, c.SPECIALIZATION, c.QUALIFICATION,
        c.CLINIC_NAME, c.CLINIC_CITY, c.CLINIC_STATE, c.CONSULTATION_FEE,
        c.YEARS_OF_EXPERIENCE, c.RATING, c.AVAILABLE_ONLINE, c.LICENSE_NUMBER,
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
        MD5(DOCTOR_ID || '|' || CURRENT_TIMESTAMP()::VARCHAR) AS scd_key,
        DOCTOR_ID, FIRST_NAME, LAST_NAME, SPECIALIZATION, QUALIFICATION,
        CLINIC_NAME, CLINIC_CITY, CLINIC_STATE, CONSULTATION_FEE,
        YEARS_OF_EXPERIENCE, RATING, AVAILABLE_ONLINE, LICENSE_NUMBER,
        IS_ACTIVE, LAST_UPDATED, row_hash,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS valid_from,
        NULL::TIMESTAMP_NTZ AS valid_to,
        TRUE AS is_current
    FROM source_data
)

SELECT * FROM initial_load

{% endif %}
