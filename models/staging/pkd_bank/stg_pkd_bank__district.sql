WITH raw_district AS (
    SELECT * FROM {{ source('pkd_bank', 'district') }}
)

SELECT
    A1 AS district_id,
    A2 AS district_name,
    A3 AS region,
    CAST(A4 AS INTEGER) AS population,
    CAST(A9 AS INTEGER) AS number_of_cities,
    CAST(A10 AS FLOAT) AS urban_ratio,
    CAST(A11 AS FLOAT) AS average_salary,
    -- Usamos los datos más recientes (1996) como métricas actuales
    CAST(A13 AS FLOAT) AS current_unemployment_rate,
    CAST(A14 AS INTEGER) AS entrepreneurs_per_1000,
    CAST(A16 AS INTEGER) AS current_committed_crimes
FROM raw_district