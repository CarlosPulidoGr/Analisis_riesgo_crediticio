{{ config(
    materialized='view',
    tags=['bronze']
) }}

with source as (
    select * from {{ source('pkdd99_raw', 'raw_order') }}
)

select
    *,
    current_timestamp() as _loaded_at,
    'order.csv' as _source_file
from source