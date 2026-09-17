with session_windows as (

    select
        user_id,
        session_id,
        campaign_id,
        landing_timestamp,

        case
            when campaign_id like 'GADS_%' then 'google_ads'
            when campaign_id like 'META_%' then 'meta_ads'
        end as platform,

        date_trunc('day', landing_timestamp)
            + floor(extract(hour from landing_timestamp) / 6)
            * interval '6 hours' as batch_window_start

    from {{ ref('int_ga4_sessions') }}

    where campaign_id is not null

),

sessions_with_metrics as (

    select
        s.platform,
        s.campaign_id,
        s.batch_window_start,
        s.batch_window_start + interval '6 hours' as batch_window_end,
        m.conversions,
        m.purchases,
        m.revenue

    from session_windows s

    join {{ ref('int_ga4_session_metrics') }} m
        on s.user_id = m.user_id
       and s.session_id = m.session_id

)

select
    platform,
    campaign_id,
    batch_window_start::date as ads_date,
    batch_window_start,
    batch_window_end,
    count(*) as sessions,
    sum(conversions) as conversions,
    sum(purchases) as purchases,
    sum(revenue) as revenue

from sessions_with_metrics

group by
    platform,
    campaign_id,
    batch_window_start,
    batch_window_end