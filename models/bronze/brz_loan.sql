{{ config(
    materialized='view',
    tags=['bronze']
) }}

with source as (
    select * from {{ source('pkdd99_raw', 'raw_loan') }}
)

select
    *,
    current_timestamp() as _loaded_at,
    'loan.csv' as _source_file
from source