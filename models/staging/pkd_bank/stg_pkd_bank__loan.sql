WITH raw_loans AS (
    -- dbt leerá automáticamente de la fuente que definiste en _sources.yml
    SELECT * FROM {{ source('pkd_bank', 'loan') }}
)

SELECT
    loan_id,
    account_id,
    
    -- 1. Transformación de Fecha: De Integer (930705) a DATE real (1993-07-05)
    TO_DATE(CAST("DATE" AS VARCHAR), 'YYMMDD') AS investment_date,
    
    -- 2. Casteo de métricas financieras de la inversión
    CAST(amount AS FLOAT) AS investment_amount,
    CAST(duration AS INTEGER) AS duration_months,
    CAST(payments AS FLOAT) AS monthly_payment,
    
    -- 3. Lógica de Negocio: Clasificación del Riesgo de la Inversión
    status AS raw_status_code,
    CASE UPPER(TRIM(status))
        WHEN 'A' THEN 'Finished - No Risk'
        WHEN 'B' THEN 'Finished - Defaulted'
        WHEN 'C' THEN 'Running - OK'
        WHEN 'D' THEN 'Running - In Debt'
        ELSE 'Unknown'
    END AS investment_risk_status,
    
    -- 4. Creación de una Flag booleana para facilitar los cruces en la Capa Gold
    IFF(UPPER(TRIM(status)) IN ('B', 'D'), TRUE, FALSE) AS is_default_risk

FROM raw_loans