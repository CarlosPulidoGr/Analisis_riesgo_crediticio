{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_card') }}
)

select
    cast(card_id as integer) as card_id,
    cast(disp_id as integer) as disp_id,
    cast(type as varchar) as card_type,
    
    -- El campo 'issued' viene con formato '931107 00:00:00'. Extraemos los primeros 6 caracteres.
    {{ convert_yymmdd_to_date("left(cast(issued as varchar), 6)") }} as issue_date,
    
    _loaded_at,
    _source_file
from source