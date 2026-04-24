{{
    config(
        materialized='table'
    )
}}

WITH prescription_counts AS (
    SELECT
        CONSULTATION_ID,
        COUNT(*)           AS prescription_count,
        SUM(QUANTITY)      AS total_medicines_quantity
    FROM {{ ref('stg_prescriptions') }}
    GROUP BY CONSULTATION_ID
)

SELECT
    c.CONSULTATION_ID,
    c.PATIENT_ID                                        AS patient_key,
    c.DOCTOR_ID                                         AS doctor_key,
    c.CONSULTATION_DATE::DATE                           AS date_key,
    c.DIAGNOSIS_CODE                                    AS diagnosis_key,
    c.CONSULTATION_TYPE,
    c.CHIEF_COMPLAINT,
    c.DIAGNOSIS,
    c.DIAGNOSIS_CODE,
    c.FOLLOW_UP_REQUIRED,
    c.FOLLOW_UP_DATE,
    c.DURATION_MINUTES,
    COALESCE(pc.prescription_count, 0)                  AS prescription_count,
    COALESCE(pc.total_medicines_quantity, 0)             AS total_medicines_quantity,
    CASE WHEN pc.CONSULTATION_ID IS NOT NULL THEN TRUE ELSE FALSE END AS has_prescriptions
FROM {{ ref('stg_consultations') }} c
LEFT JOIN prescription_counts pc
    ON c.CONSULTATION_ID = pc.CONSULTATION_ID
