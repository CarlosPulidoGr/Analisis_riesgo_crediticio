WITH raw_clients AS (
    SELECT * FROM {{ source('pkd_bank', 'client') }}
)

SELECT
    client_id,
    district_id,
    
    -- 1. Extracción del Género
    -- En este dataset, a las mujeres se les suma 50 al mes de nacimiento (ej. mes 55 = Mayo, Mujer)
    -- Si el mes (caracteres 3 y 4) es mayor a 50, es mujer, si no, hombre.
    CASE 
        WHEN CAST(SUBSTR(CAST(birth_number AS VARCHAR), 3, 2) AS INTEGER) > 50 THEN 'Female'
        ELSE 'Male'
    END AS gender,

    -- 2. Reconstrucción de la Fecha de Nacimiento Real
    -- Años: Añadimos '19' delante porque sabemos que todos nacieron en el siglo XX (19XX)
    -- Meses: Si es mujer (>50), le restamos 50 para obtener el mes real. Si es hombre, se queda igual.
    -- Días: Los dos últimos dígitos.
    TO_DATE(
        '19' || SUBSTR(CAST(birth_number AS VARCHAR), 1, 2) || '-' || 
        LPAD(CAST(
            CASE 
                WHEN CAST(SUBSTR(CAST(birth_number AS VARCHAR), 3, 2) AS INTEGER) > 50 
                THEN CAST(SUBSTR(CAST(birth_number AS VARCHAR), 3, 2) AS INTEGER) - 50
                ELSE CAST(SUBSTR(CAST(birth_number AS VARCHAR), 3, 2) AS INTEGER)
            END 
        AS VARCHAR), 2, '0') || '-' || 
        SUBSTR(CAST(birth_number AS VARCHAR), 5, 2),
        'YYYY-MM-DD'
    ) AS birth_date

FROM raw_clients