{% snapshot doctors_snapshot %}
{{
    config(
        target_schema='ANALYTICS',
        unique_key='DOCTOR_ID',
        strategy='timestamp',
        updated_at='LAST_UPDATED',
        invalidate_hard_deletes=True
    )
}}

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
    PHONE,
    LICENSE_NUMBER,
    JOINED_DATE,
    LAST_UPDATED,
    IS_ACTIVE
FROM {{ source('healthcare_raw', 'doctors') }}

{% endsnapshot %}
