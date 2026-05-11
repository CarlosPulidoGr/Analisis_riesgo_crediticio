WITH raw_disp AS (
    SELECT * FROM {{ source('pkd_bank', 'disp') }}
)

SELECT
    disp_id AS disposition_id,
    client_id AS investor_id,
    account_id,
    UPPER(TRIM(type)) AS disposition_type -- Quedará como 'OWNER' o 'DISPONENT'
FROM raw_disp