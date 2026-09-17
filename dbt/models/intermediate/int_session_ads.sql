select
    s.user_id,
    s.session_id,
    s.campaign_id,
    s.landing_timestamp,
    a.platform,
    a.date as ads_date,
    a.batch_window_start,
    a.batch_window_end
from {{ ref('int_ga4_sessions') }} s
left join {{ ref('int_ads_unified') }} a
    on s.campaign_id = a.campaign_id
   and s.landing_timestamp >= a.batch_window_start
   and s.landing_timestamp < a.batch_window_end