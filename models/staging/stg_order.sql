{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_order') }}
)

select
    cast(order_id as integer) as order_id,
    cast(account_id as integer) as account_id,
    nullif(cast(bank_to as varchar), '') as bank_to_partner,
    nullif(cast(account_to as varchar), '') as account_to_partner,
    cast(amount as float) as amount,
    
    -- Traducción de k_symbol (propósito del pago)
    case nullif(cast(k_symbol as varchar), '')
        when 'POJISTNE' then 'INSURANCE PAYMENT'
        when 'SIPO' then 'HOUSEHOLD PAYMENT'
        when 'LEASING' then 'LEASING PAYMENT'
        when 'UVER' then 'LOAN PAYMENT'
        else nullif(cast(k_symbol as varchar), '')
    end as payment_purpose,
    
    _loaded_at,
    _source_file
from source