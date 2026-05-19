-- Un préstamo no puede tener una fecha anterior a la creación de su cuenta asociada
select
    l.loan_id,
    l.loan_date,
    a.account_creation_date
from {{ ref('stg_loan') }} l
join {{ ref('stg_account') }} a on l.account_id = a.account_id
where l.loan_date < a.account_creation_date
