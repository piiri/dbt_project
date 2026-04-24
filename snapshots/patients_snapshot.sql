{% snapshot patients_snapshot %}
{{
    config(
        target_schema='ANALYTICS',
        unique_key='PATIENT_ID',
        strategy='timestamp',
        updated_at='LAST_UPDATED',
        invalidate_hard_deletes=True
    )
}}

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
    REGISTRATION_DATE,
    LAST_UPDATED,
    IS_ACTIVE
FROM {{ source('healthcare_raw', 'patients') }}

{% endsnapshot %}
