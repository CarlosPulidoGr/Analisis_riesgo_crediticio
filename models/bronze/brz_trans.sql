{{ config(
    materialized='view',
    tags=['bronze']
) }}

with source as (
    select * from {{ source('pkdd99_raw', 'raw_trans') }}
)

select
    *,
    current_timestamp() as _loaded_at,
    'trans.csv' as _source_file
from source