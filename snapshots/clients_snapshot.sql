{% snapshot clients_snapshot %}

{{
    config(
      target_database=target.database,
      target_schema='snapshots',
      unique_key='client_id',
      strategy='check',
      check_cols=['district_id']
    )
}}

-- Leemos directamente de la fuente cruda para rastrear los cambios antes de limpiarlos
SELECT * FROM {{ source('pkd_bank', 'client') }}

{% endsnapshot %}