WITH raw_account AS (
    SELECT * FROM {{ source('pkd_bank', 'account') }}
)

SELECT
    account_id,
    district_id,
    
    -- Traducción de la frecuencia de emisión
    CASE TRIM(frequency)
        WHEN 'POPLATEK MESICNE' THEN 'Monthly Issuance'
        WHEN 'POPLATEK TYDNE' THEN 'Weekly Issuance'
        WHEN 'POPLATEK PO OBRATU' THEN 'Issuance After Transaction'
        ELSE 'Unknown'
    END AS statement_frequency,
    
    -- Parseo de fecha de Integer a Date
    TO_DATE(CAST("date" AS VARCHAR), 'YYMMDD') AS account_creation_date

FROM raw_account