with source_data as (

    select *
    from {{ source('raw', 'meta_ads') }}

)

select
    date,
    campaign_name,
    campaign_id,
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
from source_data