with google_ads as (

    select
        'google_ads' as platform,
        date,
        campaign_name,
        campaign_id,
        placement_id,
        cast(null as text) as ad_location,
        account_id,
        account_name,
        country,
        clicks,
        impressions,
        spend,
        batch_window_start,
        batch_window_end,
        batch_id,
        ingested_at
    from {{ ref('stg_google_ads') }}

),

meta_ads as (

    select
        'meta_ads' as platform,
        date,
        campaign_name,
        campaign_id,
        cast(null as text) as placement_id,
        ad_location,
        account_id,
        account_name,
        country,
        clicks,
        impressions,
        spend,
        batch_window_start,
        batch_window_end,
        batch_id,
        ingested_at
    from {{ ref('stg_meta_ads') }}

)

select * from google_ads

union all

select * from meta_ads