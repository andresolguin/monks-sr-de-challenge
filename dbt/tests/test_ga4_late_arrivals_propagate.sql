with staging_checkpoint as (

    select max(ingested_at) as max_processed_ingested_at
    from {{ ref('stg_google_analytics_events') }}

),

ingest_points as (

    select
        ingested_at,
        max(event_timestamp) as max_event_timestamp
    from {{ source('raw', 'google_analytics_events') }}
    where ingested_at <= (
        select max_processed_ingested_at
        from staging_checkpoint
    )
    group by ingested_at

),

ordered_points as (

    select
        ingested_at,
        max(max_event_timestamp) over (
            order by ingested_at
            rows between unbounded preceding and 1 preceding
        ) as previous_max_event_timestamp
    from ingest_points

),

late_event_keys as (

    select distinct
        r.user_id,
        r.session_id,
        r.event_timestamp,
        r.event_name
    from {{ source('raw', 'google_analytics_events') }} r

    join ordered_points p
        on r.ingested_at = p.ingested_at

    where r.event_timestamp < p.previous_max_event_timestamp

),

checked as (

    select
        l.user_id,
        l.session_id,
        l.event_timestamp,
        l.event_name,
        count(s.user_id) as staging_matches

    from late_event_keys l

    left join {{ ref('stg_google_analytics_events') }} s
        on l.user_id = s.user_id
       and l.session_id = s.session_id
       and l.event_timestamp = s.event_timestamp
       and l.event_name = s.event_name

    group by
        l.user_id,
        l.session_id,
        l.event_timestamp,
        l.event_name

)

select *
from checked
where staging_matches <> 1