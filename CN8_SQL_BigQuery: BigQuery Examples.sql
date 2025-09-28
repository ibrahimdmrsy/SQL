-----1-----
SELECT
TIMESTAMP_MICROS(event_timestamp) AS event_stamp,
event_name,
user_pseudo_id,
(select value.int_value from e.event_params where key = 'ga_session_id') as session_id,
traffic_source.medium,
traffic_source.source,
traffic_source.name,
device.category,
geo.country
FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as e,
UNNEST(event_params) as ep
where 
_TABLE_SUFFIX >= '20210101'
AND event_name in ('session_start', 
'purchase', 
'view_item',
'add_to_chart',
'begin_checkout',
'add_shipping_info',
'add_payment_info');
--------2------
WITH
  events AS (
  SELECT
    TIMESTAMP_MICROS(event_timestamp) AS event_date,
    event_name,
    user_pseudo_id ||CAST((
      SELECT
        value.int_value
      FROM
        ga.event_params
      WHERE
        KEY = 'ga_session_id') AS string) AS user_session_id,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign,
    traffic_source.source AS SOURCE,
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` AS ga
  WHERE
    event_name IN ('add_to_chart',
      'begin_checkout',
      'purchase')
    AND _TABLE_SUFFIX BETWEEN '20201127'AND '20201231' ),
  CTE AS (
  SELECT
    e.event_date,
    e.source,
    e.medium,
    e.campaign,
    COUNT(DISTINCT user_session_id) AS total_session_count,
    COUNT(DISTINCT CASE WHEN e.event_name = 'add_to_cart' THEN e.user_session_id END) AS add_to_cart_count_total,
    COUNT(DISTINCT CASE WHEN e.event_name = 'purchase' THEN e.user_session_id END) AS purchase_count_total,
    COUNT(DISTINCT CASE WHEN e.event_name = 'begin_checkout' THEN e.user_session_id END) AS begin_checkout_count_total
  FROM
    events AS e
  GROUP BY
    1,2,3,4
    )
SELECT *
FROM
  CTE
ORDER by
  1;
