with source_data as (

    select *
    from {{ source('raw', 'google_analytics_events') }}

),

ranked_events as (

    select
        *,
        row_number() over (
            partition by
                user_id,
                session_id,
                event_timestamp,
                event_name
            order by ingested_at asc
        ) as duplicate_rank
    from source_data

)

select
    user_id,
    session_id,
    event_timestamp,
    event_name,
    event_params,
    campaign_id,
    stream_name,
    page_url,
    country,
    is_conversion,
    ingested_at
from ranked_events
where duplicate_rank = 1