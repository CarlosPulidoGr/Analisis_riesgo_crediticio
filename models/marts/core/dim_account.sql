{{ config(materialized='table', tags=['gold', 'dimension']) }}

with account as (
    select * from {{ ref('stg_account') }}
),
district as (
    select * from {{ ref('stg_district') }}
)

select
    a.account_id,
    a.statement_frequency,
    a.account_creation_date,
    a.district_id as branch_district_id,
    d.district_name as branch_name,
    d.region as branch_region
from account a
left join district d on a.district_id = d.district_id