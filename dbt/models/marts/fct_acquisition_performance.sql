select
    s.user_id,
    s.session_id,
    s.landing_timestamp,
    s.campaign_id,

    case
        when s.campaign_id like 'GADS_%' then 'google_ads'
        when s.campaign_id like 'META_%' then 'meta_ads'
    end as platform,

    case
        when s.campaign_id is null then 'unattributed'
        else 'paid_campaign'
    end as attribution_status,

    coalesce(m.conversions, 0) as conversions,
    coalesce(m.purchases, 0) as purchases,
    coalesce(m.revenue, 0) as revenue

from {{ ref('int_ga4_sessions') }} s

left join {{ ref('int_ga4_session_metrics') }} m
    on s.user_id = m.user_id
   and s.session_id = m.session_id