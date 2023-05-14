{{
  config(
    materialized='view'
  )
}}

with vendor_gmv as (
  select
    date_trunc('year', date_local)::timestamp as year,
    o.country_name,
    v.vendor_name,
    round(sum(o.gmv_local), 2) as total_gmv,
    rank() over (
      partition by o.country_name, date_trunc('year', date_local)::timestamp
      order by round(sum(o.gmv_local), 2) desc
    ) as ranking
  from
    {{ ref('fp_dataset.orders') }} as o
    join {{ ref('fp_dataset.vendors') }} as v on o.vendor_id = v.id
  group by
    o.country_name,
    v.vendor_name,
    date_trunc('year', date_local)::timestamp,
    date_local
)

-- Select the top 2 vendors for each country and year
select
  year,
  country_name,
  vendor_name,
  total_gmv
from
  vendor_gmv
where
  ranking <= 2
order by
  year,
  country_name