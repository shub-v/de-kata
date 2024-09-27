{{ config(
    materialized='incremental',
    unique_key='id'
) }}

with source as (
    select *
    from {{ source('raw_layer', 'de_test_chats') }}

    {% if is_incremental() %}
        where created_at > (select max(created_at_aedt) from {{ this }})
    {% endif %}
),

renamed as (
    select
        id,
        chat_category_id,
        is_customer_initiated,
        -- I wish there was a better way to do this in duckdb
        -- Adjust created_at to AEDT/AEST based on month

        case
            when extract(month from created_at) between 10 and 4
                then created_at + INTERVAL '11 hours'  -- AEDT (UTC+11)
            else created_at + INTERVAL '10 hours'  -- AEST (UTC+10)
        end as created_at_aedt,
        -- Adjust resolved_at to AEDT/AEST only if it is not NULL
        case
            when resolved_at is not NULL
                then
                    case
                        when extract(month from resolved_at) between 10 and 4
                            -- AEDT (UTC+11)
                            then resolved_at + INTERVAL '11 hours'
                        else resolved_at + INTERVAL '10 hours'  -- AEST (UTC+10)
                    end
        end as resolved_at_aedt

    from source
)

select *
from renamed
