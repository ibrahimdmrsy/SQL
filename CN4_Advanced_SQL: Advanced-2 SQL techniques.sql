-- 1 kısım
SELECT b.ad_date, 
  b.campaign_id,
  b.adset_id,
  b.spend, 
  b.impressions, 
  b.reach, 
  b.clicks, 
  b.leads, 
  b.value, 
  b.url_parameters,
  b.total,
a.adset_id,
  a.adset_name, 
  c.campaign_name,
  c.campaign_id
FROM "public".facebook_ads_basic_daily b
left join public.facebook_adset a on a.adset_id= b.adset_id
left join public.facebook_campaign c on c.campaign_id=b.campaign_id

-- 2 kısım
with homeworks_join as
(SELECT b.ad_date,
  b.spend, 
  b.impressions, 
  b.reach, 
  b.clicks, 
  b.leads,
  b.value, 
  a.adset_name,
  c.campaign_name
FROM "public".facebook_ads_basic_daily b
left join "public".facebook_adset a on a.adset_id = b.adset_id
left join "public".facebook_campaign c on c.campaign_id = b.campaign_id)
select ad_date, 
  campaign_name, 
  adset_name, 
  spend, 
  impressions as Gösterim, 
  reach, clicks as Tıklama, 
  'Facebook' as media_source
from homeworks_join
where impressions > 0
Group by ad_date, 
  spend,
  campaign_name, 
  adset_name, 
  impressions, 
  reach,
  clicks
union
SELECT ad_date, 
  campaign_name, 
  adset_name, sum(spend),
  impressions as Gösterim, 
  reach, 
  clicks as Tıklama, 
  'google' as media_source
FROM public.google_ads_basic_daily
where impressions > 0
Group by ad_date, 
  spend, 
  campaign_name, 
  adset_name, 
  impressions,
  reach, 
  clicks

-- 3 kısım
with homeworks_join as
(SELECT b.ad_date,
  b.spend, 
  b.impressions,
  b.reach, 
  b.clicks, 
  b.leads, 
  b.value,
  a.adset_name, 
  c.campaign_name
FROM "public".facebook_ads_basic_daily b
left join "public".facebook_adset a on a.adset_id = b.adset_id
left join "public".facebook_campaign c on c.campaign_id = b.campaign_id)
select ad_date, 
  campaign_name, 
  adset_name, 
  sum(spend), 
  impressions as Gösterim, 
  clicks as Tıklama, 
  'Facebook'as media_source, 
  sum((clicks::numeric)/impressions *100) as Toplam_dönüşüm_değeri
from homeworks_join
where impressions > 0
Group by ad_date,
  spend, 
  campaign_name, 
  adset_name, 
  impressions,
  clicks, 
  media_source
union
SELECT ad_date, 
  campaign_name,
  adset_name, sum(spend), 
  impressions as Gösterim, 
  clicks as Tıklama,
  'Google' as media_source,
sum((clicks::numeric)/impressions *100) as Toplam_dönüşüm_değeri
FROM public.google_ads_basic_daily
where impressions > 0
Group by ad_date, spend, campaign_name, adset_name, impressions, clicks, media_source

