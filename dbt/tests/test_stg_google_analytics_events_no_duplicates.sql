select
    user_id,
    session_id,
    event_timestamp,
    event_name,
    count(*) as copies
from {{ ref('stg_google_analytics_events') }}
group by
    user_id,
    session_id,
    event_timestamp,
    event_name
having count(*) > 1