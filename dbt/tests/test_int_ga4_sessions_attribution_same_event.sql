with attribution_check as (

    select
        s.user_id,
        s.session_id,
        s.campaign_id,
        s.landing_timestamp,
        count(e.user_id) as matching_landing_events

    from {{ ref('int_ga4_sessions') }} s

    left join {{ ref('stg_google_analytics_events') }} e
        on s.user_id = e.user_id
       and s.session_id = e.session_id
       and e.event_name = 'landing_page'
       and e.event_timestamp = s.landing_timestamp
       and nullif(e.campaign_id, '') is not distinct from s.campaign_id

    group by
        s.user_id,
        s.session_id,
        s.campaign_id,
        s.landing_timestamp

)

select *
from attribution_check
where
    (
        campaign_id is not null
        and landing_timestamp is null
    )
    or (
        landing_timestamp is not null
        and matching_landing_events <> 1
    )