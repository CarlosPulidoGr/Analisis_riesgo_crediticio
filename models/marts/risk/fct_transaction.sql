{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    tags=['gold', 'fct']
) }}

with staging_transactions as (
    select * from {{ ref('stg_trans') }}
    
    {% if is_incremental() %}
        -- Filtro dinámico: Solo lee las transacciones más recientes que las ya procesadas en Snowflake
        where transaction_date > (select max(transaction_date) from {{ this }})
    {% endif %}
)

select
    trans_id as transaction_id,              -- Clave primaria del apunte bancario
    account_id,                  -- Clave foránea hacia dim_account
    transaction_date as date_id, -- Clave foránea hacia dim_date
    transaction_type,
    operation_type,
    amount,
    balance,
    k_symbol,
    bank_partner,
    account_partner
from staging_transactions