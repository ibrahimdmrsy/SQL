--------------3----
with user_sessions as (
  select
  user_pseudo_id || cast((select value.int_value from unnest(event_params) where key = 'ga_session_id') as string) as user_session_id,
(select value.string_value from unnest(event_params) where key = 'page_location') as page_location,
REGEXP_EXTRACT((select value.string_value FROM UNNEST(event_params) WHERE KEY = 'page_location'), r'https://[^\/]+/([^7#]*)') as page_path
FROM 
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
Where 
_TABLE_SUFFIX < '20210101'
AND event_name = 'session_start'
),
Purchases AS (
  SELECT
 user_pseudo_id || CAST((SELECT value.int_value FROM e.event_params WHERE KEY = 'ga_session_id') AS STRING) AS user_session_id
FROM 
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as e
WHERE
_TABLE_SUFFIX < '20210101'
AND event_name = 'purchase'
)
SELECT
page_path,
COUNT(DISTINCT (s.user_session_id)) as sessions_count,
COUNT(DISTINCT (p.user_session_id)) as purchases_count,
COUNT(DISTINCT (p.user_session_id))/COUNT(DISTINCT (s.user_session_id)) as Session_start_to_purchase_CR
FROM user_sessions AS s
LEFT JOIN purchases AS p
USING (user_session_id)
GROUP BY 1
ORDER BY 2 DESC;
--------4------------------------
WITH
user_sessions as (
select
  user_pseudo_id || CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE KEY = 'ga_session_id') AS string) as user_session_id,
  SUM(COALESCE((SELECT value.int_value FROM UNNEST(event_params) WHERE KEY = 'engagement_time_msec'), 0)) As total_engagement_time,
  CASE
   WHEN SUM(COALESCE(SAFE_CAST((SELECT value.string_value FROM UNNEST(event_params) WHERE KEY = 'session_engaged') AS integer), 0) ) > 0 THEN 1 ELSE 0
  END AS is_session_engaged
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as e
  GROUP by 1
),
purchases as(
select
user_pseudo_id || CAST((SELECT value.int_value FROM e.event_params WHERE KEY = 'ga_session_id') AS string) as user_session_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as e
Where event_name = 'purchase'
)
SELECT
CORR(s.total_engagement_time, CASE WHEN p.user_session_id IS NOT NULL THEN 1 else 0 end) as engagement_time_to_purchase,
CORR(s.is_session_engaged,CASE WHEN p.user_session_id IS NOT NULL THEN 1 else 0 end) as is_engaged_time_to_purchase,
FROM user_sessions as s
LEFT JOIN purchases as p
   USING (user_session_id);
