{{ config(
    materialized='table'
) }}

with source as (
    select *
    from {{ source('raw_layer', 'de_test_categories') }}

),

clean_source as (


    select
        id,
        disabled,
        case when lower(parent_id) = 'null' then null else parent_id end
            as parent_id
    from source
),

parent_disabled_status as (
    select
        c1.id,
        c1.parent_id,
        c1.disabled,
        c2.disabled as parent_disabled
    from clean_source as c1
    left join clean_source as c2 on c1.parent_id = c2.id
),

renamed as (
    select
        id,
        parent_id,
        case
            when
                disabled is null and parent_disabled is not null
                then parent_disabled
            else disabled
        end as disabled

    from parent_disabled_status
)

select *
from renamed
