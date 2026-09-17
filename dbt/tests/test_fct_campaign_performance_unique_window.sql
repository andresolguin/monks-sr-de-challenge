select
    platform,
    campaign_id,
    batch_window_start,
    count(*) as copies
from {{ ref('fct_campaign_performance') }}
group by
    platform,
    campaign_id,
    batch_window_start
having count(*) > 1