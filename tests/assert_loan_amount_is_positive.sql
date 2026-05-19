-- Queremos atrapar cualquier préstamo con importe cero o negativo.
-- Si esto devuelve 0 filas, el test PASA.

select
    loan_id,
    loan_amount
from {{ ref('stg_loan') }}
where loan_amount <= 0
