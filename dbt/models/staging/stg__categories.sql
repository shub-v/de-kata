{{ config(
    materialized='table'
) }}

with source as (
    select *
    from {{ source('raw_layer', 'de_test_categories') }}
   -- todo
   -- this is handeled below by inheriting the parent's disabled status
    --
--    where disabled is not null
    -- ('161162d4-18b9-5cb0-be08-b54cbc321c37', '6c8be681-f04a-5a25-8efd-8feb0a21fc0e', None)
    -- not removing 161162d4-18b9-5cb0-be08-b54cbc321c37 as it fails for referential intgrity

),

clean_source as (


    select
        id,
        disabled,
        case when lower(parent_id) = 'null' then null else parent_id end
            as parent_id
    from source
),

parent_disabled_status AS (
    -- Join the table to itself to retrieve the parent's disabled status
    select
        c1.id,
        c1.parent_id,
        c1.disabled,
        -- Join on the parent_id to retrieve the parent's disabled status
        c2.disabled as parent_disabled
    from clean_source c1
    left join clean_source c2 on c1.parent_id = c2.id
),

renamed as (
    select
        id,
        parent_id,

        -- Set disabled to True if parent_id is null and disabled is False
        -- If disabled is null, inherit disabled status from parent
        case
            when disabled is null and parent_disabled is not null then parent_disabled
            else disabled
        end as disabled

    from parent_disabled_status
)

select *
from renamed
