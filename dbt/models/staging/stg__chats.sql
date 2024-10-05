{{ config(
    materialized='incremental',
    unique_key='id'
) }}

with source as (
    select *
    from {{ source('raw_layer', 'de_test_chats') }}

    {% if is_incremental() %}
        where adjust_to_aedt_aest(created_at) > (select max(created_at_aedt) from {{ this }})
    {% endif %}
),

renamed as (
    select
        id,
        chat_category_id,
        is_customer_initiated,
        {{ adjust_to_aedt_aest('created_at') }} as created_at_aedt,
        case
            when resolved_at is not null then {{ adjust_to_aedt_aest('resolved_at') }}
            else null
        end as resolved_at_aedt

    from source
)

select *
from renamed
