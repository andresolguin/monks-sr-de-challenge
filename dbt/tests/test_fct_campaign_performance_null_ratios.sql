select
    platform,
    campaign_id,
    batch_window_start,
    spend,
    clicks,
    conversions,
    cpc,
    cpa,
    roi
from {{ ref('fct_campaign_performance') }}
where
    (
        (spend is null or clicks is null or clicks = 0)
        and cpc is not null
    )
    or (
        spend is not null
        and clicks is not null
        and clicks <> 0
        and cpc is null
    )
    or (
        (spend is null or conversions is null or conversions = 0)
        and cpa is not null
    )
    or (
        spend is not null
        and conversions is not null
        and conversions <> 0
        and cpa is null
    )
    or (
        (spend is null or spend = 0)
        and roi is not null
    )
    or (
        spend is not null
        and spend <> 0
        and roi is null
    )