SELECT
    PRESCRIPTION_ID,
    CONSULTATION_ID,
    PATIENT_ID,
    DOCTOR_ID,
    MEDICINE_NAME,
    DOSAGE,
    FREQUENCY,
    DURATION_DAYS,
    QUANTITY,
    IS_GENERIC,
    NOTES,
    PRESCRIBED_AT
FROM {{ source('healthcare_raw', 'prescriptions') }}
