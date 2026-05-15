{{ config(
    materialized='table'
) }}

WITH accounts AS (
    -- Datos limpios de la cuenta
    SELECT * FROM {{ ref('stg_pkd_bank__account') }}
),

dispositions AS (
    -- Buscamos quién es el inversor principal (dueño legal de la cuenta)
    SELECT * FROM {{ ref('stg_pkd_bank__disp') }}
    WHERE disposition_type = 'OWNER' 
)

SELECT
    -- Identificadores principales
    a.account_id,
    
    -- El dueño real de la cuenta (usando tu alias enfocado a inversiones)
    d.investor_id AS owner_investor_id,
    
    -- Características de la cuenta
    a.district_id AS account_district_id,
    a.statement_frequency,
    a.account_creation_date,
    
    -- Antigüedad de la cuenta (Métrica fundamental para el análisis de riesgo de la inversión)
    DATEDIFF(MONTH, a.account_creation_date, CURRENT_DATE) AS account_age_months

FROM accounts a
LEFT JOIN dispositions d
    ON a.account_id = d.account_id