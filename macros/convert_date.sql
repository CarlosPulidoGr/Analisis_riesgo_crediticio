{% macro convert_yymmdd_to_date(column_name) %}
    -- Castea el número a string y luego usa la función de Snowflake para parsearlo a fecha
    to_date(cast({{ column_name }} as string), 'YYMMDD')
{% endmacro %}