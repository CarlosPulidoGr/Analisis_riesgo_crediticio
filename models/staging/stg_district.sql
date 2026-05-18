{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_district') }}
)

select
    cast(a1 as integer) as district_id,
    cast(a2 as varchar) as district_name,
    cast(a3 as varchar) as region,
    cast(a4 as integer) as no_of_inhabitants,
    cast(a5 as integer) as municipalities_lt_499,
    cast(a6 as integer) as municipalities_500_1999,
    cast(a7 as integer) as municipalities_2000_9999,
    cast(a8 as integer) as municipalities_gt_10000,
    cast(a9 as integer) as no_of_cities,
    cast(a10 as float) as ratio_urban_inhabitants,
    cast(a11 as float) as average_salary,
    
    -- Algunos datos como la tasa de desempleo vienen con '?' en lugar de nulos
    cast(nullif(a12, '?') as float) as unemployment_rate_95,
    cast(nullif(a13, '?') as float) as unemployment_rate_96,
    
    cast(a14 as integer) as entrepreneurs_per_1000,
    
    cast(nullif(a15, '?') as integer) as committed_crimes_95,
    cast(nullif(a16, '?') as integer) as committed_crimes_96,
    
    _loaded_at,
    _source_file
from source