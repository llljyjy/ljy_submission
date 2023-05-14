{{
  config(
    materialized='view'
  )
}}

-- create a subquery to get total gmv for each vendor with ranking based on country
with subquery as (
  SELECT
    o.country_name,
    v.vendor_name,
    ROUND(SUM(o.gmv_local), 2) AS total_gmv,
    RANK() OVER(PARTITION BY o.country_name ORDER BY ROUND(SUM(o.gmv_local), 2) DESC) AS ranking
  FROM
    `orders` AS o
  JOIN
    `vendors` AS v
  ON
    o.vendor_id = v.id
  GROUP BY
    o.country_name,
    v.vendor_name
)

-- select only the top vendor in each country
SELECT
  country_name,
  vendor_name,
  total_gmv
FROM
  subquery
WHERE
  ranking = 1
ORDER BY
  country_name
