{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_loan') }}
)

select
    cast(loan_id as integer) as loan_id,
    cast(account_id as integer) as account_id,
    
    -- Uso de la macro para la fecha
    {{ convert_yymmdd_to_date('date') }} as loan_date,
    
    cast(amount as integer) as loan_amount,
    cast(duration as integer) as duration_months,
    cast(payments as float) as monthly_payment,
    cast(status as varchar) as loan_status,
    
    -- Columnas de auditoría
    _loaded_at,
    _source_file
from source