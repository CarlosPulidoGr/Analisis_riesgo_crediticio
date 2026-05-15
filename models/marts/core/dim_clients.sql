{{ config(
    materialized='table'
) }}

WITH clients_historical AS (
    -- El snapshot tiene el historial de distritos y las fechas de control SCD2
    SELECT 
        client_id,
        district_id,
        dbt_valid_from,
        dbt_valid_to
    FROM {{ ref('clients_snapshot') }}
),

clients_clean AS (
    -- La tabla Silver tiene los datos limpios de la persona
    SELECT 
        client_id,
        birth_date, 
        gender
    FROM {{ ref('stg_pkd_bank__client') }}
),

districts AS (
    -- La tabla Silver con la información demográfica para inversiones
    SELECT * FROM {{ ref('stg_pkd_bank__district') }}
)

SELECT
    -- Identificadores
    h.client_id,
    h.district_id,
    
    -- Información Demográfica del Cliente (desde Silver)
    c.birth_date,
    c.gender,
    
    -- Información Enriquecida del Distrito (Denormalización total)
    d.district_name,
    d.region,
    d.population,
    d.urban_ratio,
    d.average_salary,
    d.current_unemployment_rate,
    d.entrepreneurs_per_1000,
    d.current_committed_crimes,
    
    -- Columnas de Control de Historial (SCD2)
    h.dbt_valid_from AS valid_from,
    h.dbt_valid_to AS valid_to,
    
    -- Marcador para saber cuál es el perfil actual del cliente
    CASE 
        WHEN h.dbt_valid_to IS NULL THEN TRUE 
        ELSE FALSE 
    END AS is_current_profile

FROM clients_historical h
LEFT JOIN clients_clean c
    ON h.client_id = c.client_id
LEFT JOIN districts d 
    ON h.district_id = d.district_id