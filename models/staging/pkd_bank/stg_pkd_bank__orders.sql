WITH raw_orders AS (
    SELECT * FROM {{ source('pkd_bank', 'orders') }} 
)

SELECT
    order_id,
    account_id,
    TRIM(bank_to) AS destination_bank,
    TRIM(account_to) AS destination_account,
    CAST(amount AS FLOAT) AS order_amount,
    
    -- Traducción de categorías de pagos
    CASE TRIM(k_symbol)
        WHEN 'POJISTNE' THEN 'Insurance Payment'
        WHEN 'SIPO' THEN 'Household Payment'
        WHEN 'UVER' THEN 'Loan Payment'
        WHEN 'LEASING' THEN 'Leasing Payment'
        WHEN '' THEN 'Other'
        ELSE 'Other'
    END AS payment_category

FROM raw_orders