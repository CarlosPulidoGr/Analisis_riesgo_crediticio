{% macro convert_yymmdd_to_date(column_name) %}
    to_date(cast({{ column_name }} as string), 'YYMMDD')
{% endmacro %}