{{ config(materialized='view') }}

with order_data as (
    select
        country_name,
        round(sum(gmv_local), 2) as total_gmv
    from {{ ref('fp_dataset', 'orders') }}
    group by 1
)

select *
from order_data;