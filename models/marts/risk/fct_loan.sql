{{ config(materialized='table', tags=['gold', 'fact']) }}

with loan as (
    select * from {{ ref('stg_loan') }}
)

select
    loan_id,
    account_id,
    loan_date as date_id, -- Clave foránea hacia dim_date
    loan_amount,
    duration_months,
    monthly_payment,
    loan_status,
    '{{ env_var("DBT_ENV_TAG", "DEV" )}}' AS dbt_enviroment,
    -- Creamos descriptivos claros para Power BI y una bandera (flag) de impago
    case
        when loan_status = 'A' then 'Contract Finished - No Problems'
        when loan_status = 'B' then 'Contract Finished - Loan Not Payed'
        when loan_status = 'C' then 'Running Contract - OK'
        when loan_status = 'D' then 'Running Contract - Client in Debt'
    end as status_description,
    case 
        when loan_status in ('B', 'D') then 1 
        else 0 
    end as is_default_flag
from loan