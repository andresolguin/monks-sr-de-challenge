select
    platform,
    campaign_id,
    batch_window_start,
    sessions,
    impressions,
    clicks,
    spend,
    cpc,
    cpa,
    roi
from {{ ref('fct_campaign_performance') }}
where data_status = 'pending_ads'
  and (
        sessions <= 0
        or impressions is not null
        or clicks is not null
        or spend is not null
        or cpc is not null
        or cpa is not null
        or roi is not null
      )