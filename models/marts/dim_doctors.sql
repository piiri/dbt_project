{{
    config(
        materialized='table'
    )
}}

SELECT
    DOCTOR_ID                                       AS doctor_key,
    DOCTOR_ID,
    FIRST_NAME,
    LAST_NAME,
    'Dr. ' || FIRST_NAME || ' ' || LAST_NAME        AS full_name,
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
    IS_ACTIVE
FROM {{ ref('scd2_doctors') }}
WHERE is_current = TRUE
