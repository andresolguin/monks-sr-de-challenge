select
    a.platform,
    a.date,
    a.campaign_name,
    a.campaign_id,
    a.placement_id,
    a.ad_location,
    a.account_id,
    a.account_name,
    a.country,
    a.batch_window_start,
    a.batch_window_end,

    a.impressions,
    a.clicks,
    a.spend,

    coalesce(g.sessions, 0) as sessions,
    coalesce(g.conversions, 0) as conversions,
    coalesce(g.purchases, 0) as purchases,
    coalesce(g.revenue, 0) as revenue,

    a.spend / nullif(a.clicks, 0) as cpc,

    a.spend / nullif(coalesce(g.conversions, 0), 0) as cpa,

    (
        coalesce(g.revenue, 0) - a.spend
    ) / nullif(a.spend, 0) as roi

from {{ ref('int_ads_unified') }} a

left join {{ ref('int_ga4_campaign_window_metrics') }} g
    on a.platform = g.platform
   and a.campaign_id = g.campaign_id
   and a.batch_window_start = g.batch_window_start
   and a.batch_window_end = g.batch_window_end