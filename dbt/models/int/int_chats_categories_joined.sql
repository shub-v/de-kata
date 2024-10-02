with chats as (
    select *
    from {{ ref('stg__chats') }}
),

categories as (
    select *
    from {{ ref('stg__categories') }}
),

joined as (
    select
        chats.id as chat_id,
        chats.chat_category_id,
        chats.is_customer_initiated,
        chats.created_at_aedt,
        chats.resolved_at_aedt,
        categories.id as category_id,
        categories.parent_id,
        categories.disabled
    from chats
    inner join categories
        on chats.chat_category_id = categories.id
)

select * from joined
