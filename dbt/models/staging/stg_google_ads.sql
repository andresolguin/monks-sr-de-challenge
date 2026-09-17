{{ config(
    materialized='incremental',
    unique_key=['campaign_id', 'date', 'batch_window_start'],
    incremental_strategy='delete+insert'
) }}

with source_data as (

    select *
    from {{ source('raw', 'google_ads') }}

    {% if is_incremental() %}
        where ingested_at >= (
            select
                coalesce(max(ingested_at), '1900-01-01'::timestamp)
                - interval '1 minute'
            from {{ this }}
        )
    {% endif %}

)

select
    date,
    campaign_name,
    campaign_id,
    placement_id,
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