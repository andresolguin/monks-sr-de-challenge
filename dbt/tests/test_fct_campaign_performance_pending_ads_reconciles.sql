select
    f.platform,
    f.campaign_id,
    f.batch_window_start,
    f.batch_window_end,
    f.sessions
from {{ ref('fct_campaign_performance') }} f

join {{ ref('int_ads_unified') }} a
    on f.platform = a.platform
   and f.campaign_id = a.campaign_id
   and f.batch_window_start = a.batch_window_start
   and f.batch_window_end = a.batch_window_end

where f.data_status = 'pending_ads'