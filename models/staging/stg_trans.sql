{{ config(
    materialized='incremental',
    unique_key='trans_id',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_trans') }}
    
    {% if is_incremental() %}
        -- Esta lógica solo se ejecuta si la tabla ya existe.
        -- Filtramos en origen para procesar solo los IDs nuevos, optimizando la consulta.
        where cast(trans_id as integer) > (select coalesce(max(trans_id), 0) from {{ this }})
    {% endif %}
)

select
    cast(trans_id as integer) as trans_id,
    cast(account_id as integer) as account_id,
    
    {{ convert_yymmdd_to_date('date') }} as transaction_date,
    
    -- Traducción de PRIJEM/VYDAJ a inglés
    case type
        when 'PRIJEM' then 'CREDIT'
        when 'VYDAJ' then 'WITHDRAWAL'
        when 'VYBER' then 'WITHDRAWAL'
        else type
    end as transaction_type,
    
    -- Traducción de operaciones y gestión de cadenas vacías
    case operation
        when 'VYBER' then 'WITHDRAWAL IN CASH'
        when 'VYBER KARTOU' then 'CREDIT CARD WITHDRAWAL'
        when 'VKLAD' then 'CREDIT IN CASH'
        when 'PREVOD Z UCTU' then 'COLLECTION FROM ANOTHER BANK'
        when 'PREVOD NA UCET' then 'REMITTANCE TO ANOTHER BANK'
        else nullif(operation, '') 
    end as operation_type,
    
    cast(amount as float) as amount,
    cast(balance as float) as balance,
    
    -- Los CSV tienen celdas vacías ('') que deben ser NULL reales
    -- Casteamos a texto antes de evaluar el nulo para evitar errores de tipo numérico
    nullif(cast(k_symbol as varchar), '') as k_symbol,
    nullif(cast(bank as varchar), '') as bank_partner,
    nullif(cast(account as varchar), '') as account_partner,
    
    _loaded_at,
    _source_file
from source