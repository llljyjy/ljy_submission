{{
  config(
    materialized='view'
  )
}}

with vendor_customer_gmv as (
  select
    v.id as vendor_id,
    v.vendor_name,
    o.customer_id,
    o.gmv_local
  from
    `orders` as o
  join
    `vendors` as v
  on
    o.vendor_id = v.id
  where
    o.country_name = 'Taiwan'
),

vendor_customer_summary as (
  select
    vendor_id,
    vendor_name,
    count(distinct customer_id) as customer_count,
    round(sum(gmv_local), 2) as total_gmv
  from
    vendor_customer_gmv
  group by
    1, 2
)

select
  vendor_name,
  customer_count,
  total_gmv
from
  vendor_customer_summary
order by
  total_gmv desc
