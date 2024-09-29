{% macro adjust_to_aedt_aest(timestamp_column) %}
    case
        -- If month is between October and April (inclusive), use AEDT (UTC+11)
        when extract(month from {{ timestamp_column }}) between 10 and 4
            then {{ timestamp_column }} + INTERVAL '11 hours'
        -- Otherwise, use AEST (UTC+10)
        else {{ timestamp_column }} + INTERVAL '10 hours'
    end
{% endmacro %}