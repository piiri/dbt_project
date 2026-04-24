{{
    config(
        materialized='table'
    )
}}

SELECT
    PATIENT_ID                                      AS patient_key,
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    FIRST_NAME || ' ' || LAST_NAME                  AS full_name,
    DATE_OF_BIRTH,
    DATEDIFF('year', DATE_OF_BIRTH, CURRENT_DATE()) AS age,
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
    IS_ACTIVE
FROM {{ ref('scd2_patients') }}
WHERE is_current = TRUE
