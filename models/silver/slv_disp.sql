{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_disp') }}
)

select
    cast(disp_id as integer) as disp_id,
    cast(client_id as integer) as client_id,
    cast(account_id as integer) as account_id,
    
    -- Los valores ya están en inglés (OWNER, DISPONENT)
    cast(type as varchar) as disposition_type,
    
    _loaded_at,
    _source_file
from source