{{ config(materialized='table', tags=['gold', 'dimension']) }}

with client as (
    select * from {{ ref('stg_client') }}
),
district as (
    select * from {{ ref('stg_district') }}
)

select
    c.client_id,
    -- El formato es YYMMDD. Si el mes es > 50, es mujer.
    case 
        when cast(substring(c.birth_number_raw, 3, 2) as integer) > 50 then 'Female'
        else 'Male'
    end as gender,
    
    -- Reconstrucción de la fecha de nacimiento (sumando 1900 al año)
    date_from_parts(
        1900 + cast(substring(c.birth_number_raw, 1, 2) as integer),
        case 
            when cast(substring(c.birth_number_raw, 3, 2) as integer) > 50 
            then cast(substring(c.birth_number_raw, 3, 2) as integer) - 50
            else cast(substring(c.birth_number_raw, 3, 2) as integer)
        end,
        cast(substring(c.birth_number_raw, 5, 2) as integer)
    ) as birth_date,
    
    c.district_id,
    d.district_name,
    d.region
from client c
left join district d on c.district_id = d.district_id