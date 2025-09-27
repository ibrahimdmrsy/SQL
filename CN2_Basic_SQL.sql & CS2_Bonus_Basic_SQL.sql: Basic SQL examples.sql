-- 1 question
SELECT ad_date, campaign_id
FROM public.facebook_ads_basic_daily

-- 2 question
SELECT ad_date, campaign_id, sum (spend) as Toplam_maliyet, sum (value) as total_value, 
sum (clicks) as tıklama_sayısı, sum (impressions) as gösterim_sayısı 
FROM public.facebook_ads_basic_daily
where clicks > 0
group by ad_date, campaign_id
order by ad_date asc

-- 3 question
SELECT ad_date, campaign_id,
(spend::numeric/clicks) as CPC, (Spend::numeric/impressions)*1000 as CPM, (Clicks::numeric/impressions)*100 as CTR,
((Value-spend)::numeric/spend)*100  as ROMI
FROM public.facebook_ads_basic_daily
where clicks > 0 
group by ad_date, campaign_id, spend, value, clicks, impressions
order by ad_date asc


