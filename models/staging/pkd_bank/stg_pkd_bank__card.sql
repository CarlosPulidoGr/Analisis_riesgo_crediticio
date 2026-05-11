WITH raw_card AS (
    SELECT * FROM {{ source('pkd_bank', 'card') }}
)

SELECT
    card_id,
    disp_id AS disposition_id,
    LOWER(TRIM(type)) AS card_type,
    
    -- Cogemos solo los 6 primeros caracteres (YYMMDD) y los pasamos a Date
    TO_DATE(SUBSTR(CAST(issued AS VARCHAR), 1, 6), 'YYMMDD') AS card_issued_date

FROM raw_card