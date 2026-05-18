{{ config(materialized='table', tags=['gold', 'dimension']) }}

with date_spine as (
    -- Genera fechas desde el primer día de datos (1993) hasta el último (1999)
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1993-01-01' as date)",
        end_date="cast('1999-12-31' as date)"
    ) }}
)

select
    date_day as date_id,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(quarter from date_day) as quarter,
    dayname(date_day) as day_name,
    monthname(date_day) as month_name
from date_spine