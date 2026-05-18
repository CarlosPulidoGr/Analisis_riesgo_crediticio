{{ config(materialized='table', tags=['gold', 'dimension']) }}

with snapshot as (
    select * from {{ ref('snp_client') }}
)

select
    -- Generamos una surrogate key porque un mismo client_id ahora puede aparecer varias veces (historial)
    {{ dbt_utils.generate_surrogate_key(['client_id', 'dbt_valid_from']) }} as client_sk,
    client_id,
    gender,
    birth_date,
    district_id,
    district_name,
    region,
    
    -- Columnas de control del SCD Tipo 2
    dbt_valid_from as valid_from_date,
    dbt_valid_to as valid_to_date,
    case 
        when dbt_valid_to is null then true 
        else false 
    end as is_current_record

from snapshot