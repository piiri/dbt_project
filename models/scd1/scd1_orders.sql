{{
    config(
        materialized='incremental',
        unique_key='ORDER_ID',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

SELECT
    ORDER_ID,
    PATIENT_ID,
    PRESCRIPTION_ID,
    ORDER_DATE,
    ORDER_STATUS,
    DELIVERY_TYPE,
    DELIVERY_ADDRESS,
    DELIVERY_CITY,
    DELIVERY_PIN_CODE,
    SUBTOTAL,
    DISCOUNT,
    DELIVERY_FEE,
    TOTAL_AMOUNT,
    EXPECTED_DELIVERY_DATE,
    ACTUAL_DELIVERY_DATE,
    LAST_UPDATED,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS updated_at
FROM {{ source('healthcare_raw', 'orders') }}

{% if is_incremental() %}
WHERE LAST_UPDATED > (SELECT MAX(LAST_UPDATED) FROM {{ this }})
{% endif %}
