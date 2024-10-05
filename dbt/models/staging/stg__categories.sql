{{ config(
    materialized='table'
) }}

with source as (
    select
        id,
        disabled,
        parent_id
    from {{ source('raw_layer', 'de_test_categories') }}
),

clean_source as (
    select
        id,
        disabled,
        NULLIF(lower(trim(parent_id)), 'null') as parent_id
    from source
),

parent_disabled_status as (
    select
        child.id,
        child.parent_id,
        child.disabled,
        parent.disabled as parent_disabled
    from clean_source as child
    left join clean_source as parent on child.parent_id = parent.id
),

renamed as (
    select
        id,
        parent_id,
        coalesce(disabled, parent_disabled) as disabled
    from parent_disabled_status
)

select *
from renamed