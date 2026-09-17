with sessions as (

    select distinct
        user_id,
        session_id
    from {{ ref('stg_google_analytics_events') }}

),

landing_events as (

    select
        user_id,
        session_id,
        nullif(campaign_id, '') as campaign_id,
        event_timestamp as landing_timestamp,

        row_number() over (
            partition by user_id, session_id
            order by
                case
                    when nullif(campaign_id, '') is not null then 0
                    else 1
                end,
                event_timestamp,
                ingested_at
        ) as landing_rank

    from {{ ref('stg_google_analytics_events') }}

    where event_name = 'landing_page'

)

select
    s.user_id,
    s.session_id,
    l.campaign_id,
    l.landing_timestamp

from sessions s

left join landing_events l
    on s.user_id = l.user_id
   and s.session_id = l.session_id
   and l.landing_rank = 1