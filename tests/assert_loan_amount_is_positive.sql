-- Atrapar cualquier préstamo con importe cero o negativo.
select
    loan_id,
    loan_amount
from {{ ref('stg_loan') }}
where loan_amount <= 0
