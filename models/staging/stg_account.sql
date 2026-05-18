{{ config(
    materialized='table',
    tags=['silver']
) }}

with source as (
    select * from {{ ref('brz_account') }}
)

select
    cast(account_id as integer) as account_id,
    cast(district_id as integer) as district_id,
    
    -- Traducción de las frecuencias de emisión
    case frequency
        when 'POPLATEK MESICNE' then 'MONTHLY ISSUANCE'
        when 'POPLATEK TYDNE' then 'WEEKLY ISSUANCE'
        when 'POPLATEK PO OBRATU' then 'ISSUANCE AFTER TRANSACTION'
        else frequency
    end as statement_frequency,
    
    {{ convert_yymmdd_to_date('date') }} as account_creation_date,
    
    _loaded_at,
    _source_file
from source