-- 1-2 kısım
with CTE_5 as (
SELECT 
a.ad_date,
coalesce (a.spend, 0) as spend,
coalesce(a.impressions, 0) as impressions, 
coalesce (a.reach, 0) as reach,
coalesce (a.clicks, 0) as clicks,  
coalesce (a.value, 0) as value, 
a.url_parameters
FROM public.facebook_ads_basic_daily a 
join "public".facebook_adset b  on b.adset_id=a.adset_id
join "public".facebook_campaign c  on  c.campaign_id=a.campaign_id
union all
select 
go.ad_date,
coalesce (go.spend, 0) as spend, 
coalesce (go.impressions, 0) as impressions, 
coalesce (go.reach, 0) as reach,
coalesce (go.clicks, 0) as clicks,  
coalesce (go.value, 0) as value, 
go.url_parameters
FROM public.google_ads_basic_daily go
),
process_5 as (
select 
ad_date, 
sum (spend) as Toplam_harcama,
sum(clicks) as Toplam_clicks,
sum(reach) as toplam_reach,
sum (impressions) as toplam_gösterim,
sum (value) as toplam_value,
              case when sum(impressions)=0 then null
              else round (sum(clicks)*1.0/sum(impressions),3)*100 end as Toplam_dönüşüm_değeri,
                   case when sum(clicks)=0 then null 
                   else round(sum(spend)*1.0/sum(clicks),2) end as CPC,
                          case when sum(impressions)=0 then null
                          else round(sum(spend) * 1000.0/sum(impressions),2) end as CPM,
                                       case when sum(impressions)=0 then null
                                       else round(sum(clicks)*100.0/sum(impressions),3) end as CTR,
          case when sum(spend)=0 then null
          else round((sum(value)-sum(spend))*(1.0)/sum(spend),3)*100 end as ROMI,
(regexp_matches(url_parameters,'utm_campaign=([^&#$]+)')) as utm_campaign
from CTE_5 
group by utm_campaign, ad_date
)
select 
date(date_trunc('month', ad_date)) as date_month, utm_campaign,
AVG(CPC) as M_CPC,
AVG(CPM)  as M_CPM, 
AVG(CTR) as M_CTR,
AVG(ROMI) as M_ROMI, utm_campaign
from process_5 
group by date_trunc('month', ad_date), utm_campaign
order by date_month

------------------------------------------------------
-- 3 kısım
with CTE_5 as (
SELECT 
a.ad_date,
coalesce (a.spend, 0) as spend,
coalesce(a.impressions, 0) as impressions, 
coalesce (a.reach, 0) as reach,
coalesce (a.clicks, 0) as clicks,  
coalesce (a.value, 0) as value, 
a.url_parameters
FROM public.facebook_ads_basic_daily a 
join "public".facebook_adset b  on b.adset_id=a.adset_id
join "public".facebook_campaign c  on  c.campaign_id=a.campaign_id
union all
select 
go.ad_date,
coalesce (go.spend, 0) as spend, 
coalesce (go.impressions, 0) as impressions, 
coalesce (go.reach, 0) as reach,
coalesce (go.clicks, 0) as clicks,  
coalesce (go.value, 0) as value, 
go.url_parameters
FROM public.google_ads_basic_daily go
),
process_5 as (
select 
ad_date, 
sum (spend) as Toplam_harcama,
sum(clicks) as Toplam_clicks,
sum(reach) as toplam_reach,
sum (impressions) as toplam_gösterim,
sum(value) as toplam_value, 
                   case when sum(clicks)=0 then null 
                   else round(sum(spend)*1.0/sum(clicks),2) end as CPC,
                          case when sum(impressions)=0 then null
                          else round(sum(spend) * 1000.0/sum(impressions),2) end as CPM,
                                       case when sum(impressions)=0 then null
                                       else round(sum(clicks)*100.0/sum(impressions),3) end as CTR,
          case when sum(spend)=0 then null
          else round((sum(value)-sum(spend))*(1.0)/sum(spend),3)*100 end as ROMI,                         
(regexp_matches(url_parameters,'utm_campaign=([^&#$]+)')) as utm_campaign
from CTE_5 
group by ad_date, utm_campaign
),
WWY as (
SELECT 
DATE(DATE_trunc('month',ad_date)) as date_month, utm_campaign,
AVG(CPM) as CPM,
AVG(CPC) as CPC,
AVG(ROMI) as ROMI,
AVG(CTR) as CTR,
Lag(AVG(CPM)) OVER (PARTITION by utm_campaign order by date_trunc('month', ad_date)) as previous_month_CPM,
lag(AVG(CTR)) OVER (PARTITION by utm_campaign order by date_trunc('month', ad_date)) as previous_month_CTR,
lag(AVG(ROMI)) OVER (PARTITION by utm_campaign order by date_trunc('month', ad_date)) as previous_month_ROMI
from process_5 
group by utm_campaign, DATE_trunc('month',ad_date)
)
select 
date_month, utm_campaign, CPM, CTR, ROMI, previous_month_CPM, previous_month_ROMI, previous_month_CTR, 
case 
 	 when previous_month_CPM = 0 then 0
 	 else round((CPM - previous_month_CPM) * 100.0/ previous_month_CPM, 3)
 end as CPM_difference,
case 
 	 when previous_month_romi = 0 then 0
 	 else round((ROMI - previous_month_romi) * 100.0/previous_month_romi, 3)
 end as Romi_difference,
 case 
 	 when previous_month_ctr = 0 then 0
 	 else round((CTR - previous_month_ctr) * 100.0/previous_month_ctr, 3) 
 end as CTR_difference
from wwy
order by date_month, utm_campaign 

