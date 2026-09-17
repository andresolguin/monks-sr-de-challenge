select
    user_id,
    session_id,
    count(*) as copies
from {{ ref('fct_acquisition_performance') }}
group by
    user_id,
    session_id
having count(*) <> 1