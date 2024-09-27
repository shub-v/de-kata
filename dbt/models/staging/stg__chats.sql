{{ config(
    materialized='incremental',
    unique_key='id'
) }}

with source as (
    select *
    from {{ source('raw_layer', 'de_test_chats') }}

    {% if is_incremental() %}
    -- Only process new or updated rows in an incremental run
        where created_at > (select max(created_at_aedt) from {{ this }})
    {% endif %}
),

renamed as (
    select
        id,
        chat_category_id,
        -- Convert the timestamps from UTC to AEDT (Melbourne time)
        is_customer_initiated,
        timezone('Australia/Melbourne', created_at) as created_at_aedt,
        timezone('Australia/Melbourne', resolved_at) as resolved_at_aedt
    from source
)

select *
from renamed
