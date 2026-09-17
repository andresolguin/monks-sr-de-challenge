select
    campaign_id,
    date,
    batch_window_start,
    count(*) as copies
from {{ ref('stg_meta_ads') }}
group by
    campaign_id,
    date,
    batch_window_start
having count(*) > 1