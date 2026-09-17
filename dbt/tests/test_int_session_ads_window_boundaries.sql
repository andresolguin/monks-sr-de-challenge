with boundary_cases as (

    select *
    from (
        values
            (timestamp '2026-06-01 00:00:00', timestamp '2026-06-01 00:00:00'),
            (timestamp '2026-06-01 05:59:59', timestamp '2026-06-01 00:00:00'),
            (timestamp '2026-06-01 06:00:00', timestamp '2026-06-01 06:00:00'),
            (timestamp '2026-06-01 11:59:59', timestamp '2026-06-01 06:00:00'),
            (timestamp '2026-06-01 12:00:00', timestamp '2026-06-01 12:00:00'),
            (timestamp '2026-06-01 17:59:59', timestamp '2026-06-01 12:00:00'),
            (timestamp '2026-06-01 18:00:00', timestamp '2026-06-01 18:00:00'),
            (timestamp '2026-06-01 23:59:59', timestamp '2026-06-01 18:00:00')
    ) as t(landing_timestamp, expected_window_start)

)

select
    'matched_session_outside_window' as failure
where exists (

    select 1
    from {{ ref('int_session_ads') }}
    where platform is not null
      and (
            landing_timestamp < batch_window_start
            or landing_timestamp >= batch_window_end
          )

)

union all

select
    'exact_boundary_assignment' as failure
where exists (

    select 1
    from boundary_cases
    where
        date_trunc('day', landing_timestamp)
        + floor(extract(hour from landing_timestamp) / 6)
        * interval '6 hours'
        <> expected_window_start

)