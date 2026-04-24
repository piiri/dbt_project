{{
    config(
        materialized='table'
    )
}}

SELECT
    DIAGNOSIS_CODE                                  AS diagnosis_key,
    DIAGNOSIS_CODE,
    DIAGNOSIS                                       AS diagnosis_description
FROM {{ ref('stg_consultations') }}
WHERE DIAGNOSIS_CODE IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY DIAGNOSIS_CODE ORDER BY CONSULTATION_DATE) = 1
