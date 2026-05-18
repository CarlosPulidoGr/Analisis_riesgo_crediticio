{{ config(
    materialized='table',
    tags=['analytics', 'ml_features']
) }}

with loans as (
    select 
        loan_id,
        account_id,
        date_id,  -- ACTUALIZADO: Leemos date_id de tu fact_loan
        loan_amount,
        duration_months,
        monthly_payment,
        loan_status,
        is_default_flag
    from {{ ref('fct_loan') }}
),

transactions as (
    select 
        account_id,
        transaction_date,
        amount,
        balance,
        transaction_type
    from {{ ref('stg_trans') }} -- Aseguramos que lea de stg_trans
),

accounts as (
    select 
        account_id,
        branch_district_id
    from {{ ref('dim_account') }}
),

districts as (
    select 
        district_id,
        average_salary,
        unemployment_rate_96
    from {{ ref('stg_district') }} -- Aseguramos que lea de stg_district
),

-- Agregamos las transacciones previas a la fecha de cada préstamo
historical_trans_features as (
    select
        l.loan_id,
        count(t.transaction_date) as tx_count_pre_loan,
        coalesce(avg(t.balance), 0) as avg_balance_pre_loan,
        coalesce(stddev(t.balance), 0) as stddev_balance_pre_loan,
        coalesce(avg(case when t.transaction_type = 'CREDIT' then t.amount else 0 end), 0) as avg_credit_amount_pre_loan,
        coalesce(avg(case when t.transaction_type = 'WITHDRAWAL' then t.amount else 0 end), 0) as avg_withdrawal_amount_pre_loan
    from loans l
    left join transactions t 
        on l.account_id = t.account_id 
        -- ACTUALIZADO: Evitamos Data Leakage usando date_id
        and t.transaction_date < l.date_id
    group by l.loan_id
)

select
    -- Identificadores y Variables Objetivo (Labels)
    l.loan_id,
    l.account_id,
    l.loan_status,
    l.is_default_flag,

    -- Características del Préstamo (Loan Features)
    l.loan_amount,
    l.duration_months,
    l.monthly_payment,

    -- Características del Comportamiento Financiero Pasado (Behavioral Features)
    f.tx_count_pre_loan,
    f.avg_balance_pre_loan,
    f.stddev_balance_pre_loan,
    f.avg_credit_amount_pre_loan,
    f.avg_withdrawal_amount_pre_loan,

    -- Características Contextuales/Demográficas (Contextual Features)
    d.average_salary as district_avg_salary,
    d.unemployment_rate_96 as district_unemployment_rate

from loans l
join historical_trans_features f on l.loan_id = f.loan_id
join accounts a on l.account_id = a.account_id
join districts d on a.branch_district_id = d.district_id