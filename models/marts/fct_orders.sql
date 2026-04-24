{{
    config(
        materialized='table'
    )
}}

SELECT
    o.ORDER_ID,
    o.PATIENT_ID                                        AS patient_key,
    p.DOCTOR_ID                                         AS doctor_key,
    o.ORDER_DATE::DATE                                  AS date_key,
    c.DIAGNOSIS_CODE                                    AS diagnosis_key,
    o.PRESCRIPTION_ID,
    c.CONSULTATION_ID,
    p.MEDICINE_NAME,
    o.ORDER_STATUS,
    o.DELIVERY_TYPE,
    o.DELIVERY_CITY,
    o.SUBTOTAL,
    o.DISCOUNT,
    o.DELIVERY_FEE,
    o.TOTAL_AMOUNT,
    o.EXPECTED_DELIVERY_DATE,
    o.ACTUAL_DELIVERY_DATE,
    o.delivery_days,
    pay.PAYMENT_METHOD,
    pay.PAYMENT_STATUS,
    pay.AMOUNT                                          AS payment_amount,
    COALESCE(pay.INSURANCE_COVERED_AMOUNT, 0)           AS insurance_covered_amount,
    COALESCE(pay.PATIENT_PAID_AMOUNT, 0)                AS patient_paid_amount,
    CASE WHEN pay.INSURANCE_COVERED_AMOUNT > 0 THEN TRUE ELSE FALSE END AS is_insurance_claim
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_prescriptions') }} p
    ON o.PRESCRIPTION_ID = p.PRESCRIPTION_ID
LEFT JOIN {{ ref('stg_consultations') }} c
    ON p.CONSULTATION_ID = c.CONSULTATION_ID
LEFT JOIN {{ ref('stg_payments') }} pay
    ON o.ORDER_ID = pay.ORDER_ID
