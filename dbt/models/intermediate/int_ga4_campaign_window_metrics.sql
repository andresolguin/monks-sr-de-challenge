select
    s.platform,
    s.campaign_id,
    s.ads_date,
    s.batch_window_start,
    s.batch_window_end,
    count(*) as sessions,
    sum(m.conversions) as conversions,
    sum(m.purchases) as purchases,
    sum(m.revenue) as revenue
from {{ ref('int_session_ads') }} s
join {{ ref('int_ga4_session_metrics') }} m
    on s.user_id = m.user_id
   and s.session_id = m.session_id
where s.campaign_id is not null
  and s.platform is not null
group by
    s.platform,
    s.campaign_id,
    s.ads_date,
    s.batch_window_start,
    s.batch_window_end