{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_client') }}
)

select
    cast(client_id as integer) as client_id,
    cast(district_id as integer) as district_id,
    cast(birth_number as varchar) as birth_number_raw, -- Mantenido como varchar para facilitar la extracción en Gold
    
    _loaded_at,
    _source_file
from source