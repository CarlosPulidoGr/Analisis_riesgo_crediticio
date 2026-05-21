{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    tags=['gold', 'fct']
) }}

with staging_transactions as (
    select * from {{ ref('stg_trans') }}
    
    {% if is_incremental() %}
        where trans_id > (select max(transaction_id) from {{ this }})
    {% endif %}
)

select
    trans_id as transaction_id,     
    account_id,                
    transaction_date as date_id,
    transaction_type,
    operation_type,
    amount,
    balance,
    k_symbol,
    bank_partner,
    account_partner
from staging_transactions