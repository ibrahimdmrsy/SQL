--1 kısım
with CTE_5 as (
SELECT 
a.ad_date,
a.spend, 
a.impressions, 
a.reach, 
a.clicks, 
a.leads, 
a.value, 
a.url_parameters
FROM public.facebook_ads_basic_daily a 
join "public".facebook_adset b  on b.adset_id=a.adset_id
join "public".facebook_campaign c  on  c.campaign_id=a.campaign_id
union all
select 
ad_date,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value, 
url_parameters
FROM public.google_ads_basic_daily
),
process_5 as (
select ad_date, url_parameters,spend, impressions, coalesce (reach,0) as reach , clicks, leads, value 
from CTE_5
)
select ad_date, url_parameters, (regexp_matches(url_parameters,'utm_source=([^&#$]+)')) as utm_source,
                                (regexp_matches(url_parameters,'utm_medium=([^&#$]+)')) as utm_medium,
                                UPPER ((regexp_matches(url_parameters,'utm_campaign=([^&#$]+)'))[1]) as utm_campaign, 
spend, impressions, clicks, leads, value 
from process_5 
order by ad_date

--  2 kısım
with CTE_5 as (
SELECT 
a.ad_date,
a.spend, 
a.impressions, 
a.reach as reach , coalesce (reach,0),
a.clicks, 
a.leads, 
a.value, 
url_parameters
FROM public.facebook_ads_basic_daily a 
join "public".facebook_adset b  on b.adset_id=a.adset_id
join "public".facebook_campaign c  on  c.campaign_id=a.campaign_id
union all
select 
ad_date,
spend, 
impressions, 
reach, coalesce (reach,0), 
clicks, 
leads, 
value, 
url_parameters
FROM public.google_ads_basic_daily
),
process_5 as (
select ad_date, 
sum (spend) as Toplam_harcama,
sum(clicks) as Toplam_clicks,
sum (impressions) as toplam_gösterim,
              case when sum(impressions)=0 then null
              else round (sum(clicks)*1.0/sum(impressions),3)*100 end as Toplam_dönüşüm_değeri,
                   case when sum (clicks)=0 then null 
                   else round(sum(spend)*1.0/sum(clicks),2) end as CPC,
                          case when sum(impressions)=0 then null
                          else round(sum(spend)*1.0/sum(impressions),2)*1000 end as CPM,
                                       case when sum(impressions)=0 then null
                                       else round(sum(clicks)*1.0/sum(impressions),3)*100 end as CTR,
          case when sum(spend)=0 then null
          else round((sum(value)-sum(spend))*(1.0)/sum(spend),3)*100 end as ROMI,
url_parameters,
(regexp_matches(url_parameters,'utm_source=([^&#$]+)')) as utm_source,
(regexp_matches(url_parameters,'utm_medium=([^&#$]+)')) as utm_medium,
(regexp_matches(url_parameters,'utm_campaign=([^&#$]+)')) as utm_campaign,
        case when Lower((REGEXP_MATCH(url_parameters,'utm_campaign=([^&#$]+)'))[1])= '{nan}' then NULL 
        else Lower((REGEXP_MATCH(url_parameters,'utm_campaign=([^&#$]+)'))[1]) end as utm_campaign,
reach, leads, value 
from CTE_5
group by ad_date, reach, spend, impressions, clicks, leads, value, url_parameters
)
select *
from process_5 
order by ad_date



