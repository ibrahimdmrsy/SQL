-- 1 kısım (Google ve facebooktaki Tarih ve Media kaynakları)
SELECT ad_date,
       'Facebook' as media_source 
FROM public.facebook_ads_basic_daily
union 
select ad_date,
       'Google' as media_source
from public.google_ads_basic_daily
group by 1

--1 kısım (reklam setleri metrikleri)

SELECT spend, 
  impressions, 
  reach, 
  clicks, 
  leads, 
  value,
         'Facebook' as media_source
FROM public.facebook_ads_basic_daily
union 
select spend, 
  impressions, 
  reach, 
  clicks, 
  leads, 
  value,
         'Google' as media_source
from public.google_ads_basic_daily
group by spend, impressions, reach, clicks, leads, value

-- 2 kısım (birleştirilmiş tablo (CTE)) 

create table homeworks.conversion as
SELECT ad_date, 
  spend, 
  impressions, 
  reach, 
  clicks, 
  leads, 
  value,
 'Facebook' as media_source
FROM public.facebook_ads_basic_daily

union 
select ad_date, 
  spend, 
  impressions, 
  reach, 
  clicks, 
  leads, 
  value,
 'Google' as media_source
from public.google_ads_basic_daily
group by ad_date,spend, impressions, reach, clicks, leads, value

select * from homeworks.conversion

-- 2 kısım (CTE kullanarak gruplandırma ve sorgu)
select ad_date, 
  media_source, 
  sum(spend) as Toplam_harcama, 
  sum (impressions) as Toplam_gösterim, 
  sum (clicks) as Toplam_tıklama, 
  sum((clicks::numeric)/impressions *100) as Toplam_dönüşüm_değeri 
from homeworks.conversion
where impressions > 0
group by ad_date, media_source
