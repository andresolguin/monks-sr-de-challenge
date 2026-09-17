with ads_source as (

    select
        platform,
        campaign_id,
        batch_window_start,
        batch_window_end,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        count(*) as source_rows

    from {{ ref('int_ads_unified') }}

    group by
        platform,
        campaign_id,
        batch_window_start,
        batch_window_end

),

mart_ads as (

    select
        platform,
        campaign_id,
        batch_window_start,
        batch_window_end,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        count(*) as mart_rows

    from {{ ref('fct_campaign_performance') }}

    where data_status = 'ads_available'

    group by
        platform,
        campaign_id,
        batch_window_start,
        batch_window_end

)

select
    coalesce(s.platform, m.platform) as platform,
    coalesce(s.campaign_id, m.campaign_id) as campaign_id,
    coalesce(s.batch_window_start, m.batch_window_start) as batch_window_start,
    s.impressions as source_impressions,
    m.impressions as mart_impressions,
    s.clicks as source_clicks,
    m.clicks as mart_clicks,
    s.spend as source_spend,
    m.spend as mart_spend

from ads_source s

full outer join mart_ads m
    on s.platform = m.platform
   and s.campaign_id = m.campaign_id
   and s.batch_window_start = m.batch_window_start
   and s.batch_window_end = m.batch_window_end

where
       s.source_rows is null
    or m.mart_rows is null
    or coalesce(s.impressions, 0) <> coalesce(m.impressions, 0)
    or coalesce(s.clicks, 0) <> coalesce(m.clicks, 0)
    or abs(coalesce(s.spend, 0) - coalesce(m.spend, 0)) > 0.000001