select
    user_id,
    session_id
from {{ ref('int_session_ads') }}
where campaign_id is not null
group by
    user_id,
    session_id
having
    count(*) <> 1
    or count(platform) <> 1