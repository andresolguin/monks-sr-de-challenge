select
    user_id,
    session_id,
    count(*) filter (where is_conversion = true) as conversions,
    count(*) filter (where event_name = 'purchase') as purchases,
    coalesce(
        sum(
            case
                when event_name = 'purchase'
                then (event_params ->> 'value')::numeric
                else 0
            end
        ),
        0
    ) as revenue
from {{ ref('stg_google_analytics_events') }}
group by
    user_id,
    session_id