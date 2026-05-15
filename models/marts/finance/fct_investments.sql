{{ config(
    materialized='table'
) }}

WITH loans AS (
    -- Nuestra base limpia de inversiones
    SELECT * FROM {{ ref('stg_pkd_bank__loan') }}
),

accounts AS (
    -- Traemos la dimensión de cuentas para descubrir quién es el dueño (inversor)
    SELECT 
        account_id,
        owner_investor_id 
    FROM {{ ref('dim_accounts') }}
)

SELECT
    -- 1. Clave Primaria
    l.loan_id AS investment_id,
    
    -- 2. Claves Foráneas (Foreign Keys para unir en Power BI / Tableau)
    l.account_id,
    a.owner_investor_id AS client_id, -- El ID clave para cruzar con dim_clients
    
    -- 3. Fechas
    l.investment_date,
    
    -- 4. Métricas Financieras (Los "Hechos")
    l.investment_amount,
    l.duration_months,
    l.monthly_payment,
    
    -- 5. Atributos de Riesgo y Estado
    l.investment_risk_status,
    l.is_default_risk

FROM loans l
LEFT JOIN accounts a
    ON l.account_id = a.account_id