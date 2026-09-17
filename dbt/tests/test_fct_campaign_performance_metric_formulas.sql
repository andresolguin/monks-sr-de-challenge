select *
from {{ ref('fct_campaign_performance') }}
where
    (
        clicks > 0
        and abs(cpc - (spend / clicks)) > 0.01
    )
    or
    (
        conversions > 0
        and abs(cpa - (spend / conversions)) > 0.01
    )
    or
    (
        spend > 0
        and abs(roi - ((revenue - spend) / spend)) > 0.01
    )