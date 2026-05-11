WITH raw_trans AS (
    SELECT * FROM {{ source('pkd_bank', 'trans') }}
)

SELECT
    trans_id AS transaction_id,
    account_id,
    
    -- 1. Parseo de la fecha (de YYMMDD a DATE)
    TO_DATE(CAST("date" AS VARCHAR), 'YYMMDD') AS transaction_date,
    
    -- 2. Traducción de la dirección del flujo de caja (type)
    CASE UPPER(TRIM("type"))
        WHEN 'PRIJEM' THEN 'Credit'               -- Ingreso
        WHEN 'VYDAJ' THEN 'Withdrawal'            -- Gasto
        WHEN 'VYBER' THEN 'Withdrawal in Cash'    -- Retirada en efectivo
        ELSE 'Unknown'
    END AS transaction_type,
    
    -- 3. Traducción del método de operación (operation)
    CASE UPPER(TRIM(operation))
        WHEN 'VYBER KARTOU' THEN 'Credit Card Withdrawal'
        WHEN 'VKLAD' THEN 'Credit in Cash'
        WHEN 'PREVOD Z UCTU' THEN 'Collection from Another Bank'
        WHEN 'VYBER' THEN 'Withdrawal in Cash'
        WHEN 'PREVOD NA UCET' THEN 'Remittance to Another Bank'
        WHEN '' THEN 'Internal/Other'
        ELSE 'Internal/Other'
    END AS operation_mode,
    
    -- 4. Casteo de métricas financieras
    CAST(amount AS FLOAT) AS transaction_amount,
    CAST(balance AS FLOAT) AS account_balance,
    
    -- 5. Traducción de la categoría de la transacción (k_symbol)
    CASE TRIM(k_symbol)
        WHEN 'POJISTNE' THEN 'Insurance Payment'
        WHEN 'SLUZBY' THEN 'Statement Payment'
        WHEN 'UROK' THEN 'Interest Credited'
        WHEN 'SANKC. UROK' THEN 'Sanction Interest'
        WHEN 'SIPO' THEN 'Household Payment'
        WHEN 'DUCHOD' THEN 'Old Age Pension'
        WHEN 'UVER' THEN 'Loan Payment'
        WHEN '' THEN 'Other'
        ELSE 'Other'
    END AS transaction_category,
    
    -- 6. Manejo avanzado de Nulos con COALESCE
    -- Si no hay banco o cuenta destino (ej. operaciones en efectivo), ponemos 'N/A'
    COALESCE(NULLIF(TRIM(bank), ''), 'N/A') AS partner_bank,
    COALESCE(NULLIF(TRIM(account), ''), 'N/A') AS partner_account

FROM raw_trans