select
    user_id,
    session_id,
    max(
        case
            when event_name = 'landing_page'
             and nullif(campaign_id, '') is not null
            then campaign_id
        end
    ) as campaign_id,
    min(
        case
            when event_name = 'landing_page'
            then event_timestamp
        end
    ) as landing_timestamp
from {{ ref('stg_google_analytics_events') }}
group by
    user_id,
    session_id