{{ config(materialized='table', tags=['gold', 'fct']) }}

with transactions as (
    select * from {{ ref('stg_trans') }}
),

-- Agrupamos por cuenta y mes, y ordenamos las transacciones de más reciente a más antigua
ranked_balances as (
    select
        account_id,
        date_trunc('month', transaction_date) as month_date,
        balance as ending_balance,
        -- Window function: Asigna un 1 a la última transacción del mes para cada cuenta
        row_number() over (
            partition by account_id, date_trunc('month', transaction_date) 
            order by transaction_date desc, trans_id desc
        ) as rn
    from transactions
)

select
    -- Generamos una clave primaria para esta tabla de hechos
    {{ dbt_utils.generate_surrogate_key(['account_id', 'month_date']) }} as monthly_balance_sk,
    account_id,
    month_date as date_id,
    ending_balance
from ranked_balances
where rn = 1  -- Nos quedamos estrictamente con la foto del último momento del mes