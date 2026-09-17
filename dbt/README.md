# Monks Data Engineer Challenge - dbt Project

This dbt project implements the transformation and analytical layer for the Monks Data Engineer technical challenge.

It consumes only the raw PostgreSQL tables provided by the challenge emulator and builds staging, intermediate, and mart models for Google Analytics 4, Google Ads, and Meta Ads data.

## Technology

- dbt Core 1.12.5
- dbt-postgres 1.11.0
- PostgreSQL
- PowerShell for periodic execution simulation

## Data Sources

The project reads from the following raw tables:

- `raw.google_analytics_events`
- `raw.google_ads`
- `raw.meta_ads`

The raw tables are treated as source data and are not modified by dbt.

## Model Structure

### Staging

The staging layer cleans, deduplicates, and incrementally processes raw data.

Models:

- `stg_google_analytics_events`
- `stg_google_ads`
- `stg_meta_ads`

The staging models use incremental loading with a small lookback window based on `ingested_at`.

This allows late-arriving records to be reconsidered while keeping repeated executions efficient.

### Intermediate

The intermediate layer contains reusable transformation logic.

Models:

- `int_ads_unified`
- `int_ga4_sessions`
- `int_ga4_session_metrics`
- `int_ga4_campaign_window_metrics`
- `int_session_ads`

Main responsibilities include:

- Unifying Google Ads and Meta Ads.
- Building GA4 sessions.
- Calculating conversions, purchases, and revenue at session level.
- Assigning sessions to six-hour advertising windows.
- Matching GA4 sessions with advertising data without multiplying spend.

Advertising windows use the following interval convention:

`batch_window_start <= landing_timestamp < batch_window_end`

This ensures that exact boundaries such as 06:00, 12:00, and 18:00 belong to the following six-hour window.

## Analytical Marts

### `fct_campaign_performance`

Provides campaign performance at platform, campaign, and six-hour window level.

Metrics include:

- impressions
- clicks
- spend
- sessions
- conversions
- purchases
- revenue
- CPC
- CPA
- ROI

Formulas:

- `CPC = spend / clicks`
- `CPA = spend / conversions`
- `ROI = (revenue - spend) / spend`

Division-by-zero situations return `NULL`.

The ROI metric represents an advertising return approximation based on attributed revenue and advertising spend. It should not be interpreted as company net profit.

### Partial Data Handling

GA4 events may arrive before the corresponding six-hour advertising batch.

The model therefore supports two states:

- `pending_ads`: GA4 activity exists but the corresponding Ads batch has not arrived yet.
- `ads_available`: the advertising batch is available and GA4 activity can be reconciled with it.

A pending GA4 session is preserved instead of being treated as an error or disappearing from analytical results.

When the corresponding Ads batch arrives, the next dbt execution automatically reconciles the data.

### `fct_acquisition_performance`

Provides session-level acquisition analysis while preserving sessions that do not contain a campaign identifier.

Sessions without an identifiable campaign are classified as:

`unattributed`

They are intentionally not labeled as `organic` or `direct`, because the provided dataset does not contain enough information to support that classification.

## Attribution

Campaign attribution is based on the selected GA4 `landing_page` event.

The `campaign_id` and `landing_timestamp` are taken from the same landing event to prevent inconsistent attribution.

Campaign sessions are associated with the corresponding six-hour Ads window.

## Conversions and Revenue

`conversions` represents events marked as conversion events in the source data.

This may include different conversion types, such as purchases and other conversion events.

`purchases` is exposed separately.

Revenue is calculated from purchase event values.

## Incremental Processing

The staging models are physically incremental.

On repeated execution, dbt processes recently ingested records using a short lookback window and replaces matching business keys.

This approach allows the project to handle:

- late-arriving events
- duplicate GA4 events
- repeated Ads ingestion
- repeated dbt execution

The downstream intermediate and mart models are views and therefore reflect the latest staged data whenever queried.

## Periodic Execution

The challenge emulator replays June data progressively.

The PowerShell script:

`../scripts/run_periodic.ps1`

simulates scheduled dbt execution while data is arriving.

Default configuration:

- 12 executions
- 60 seconds between executions

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_periodic.ps1
```

For a shorter validation run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_periodic.ps1 -Runs 2 -IntervalSeconds 5
```

Each iteration executes:

```powershell
dbt build
```

and stops immediately if the build fails.

## Running the Project

From the `dbt` directory:

```powershell
dbt debug
```

Then:

```powershell
dbt build
```

To run only models:

```powershell
dbt run
```

To run all data tests:

```powershell
dbt test
```

## Data Quality Tests

The project includes behavioral and reconciliation tests covering:

- GA4 duplicate removal
- Google Ads duplicate advertising windows
- Meta Ads duplicate advertising windows
- at most one Ads match per GA4 session
- six-hour window boundaries
- campaign and landing timestamp coming from the same GA4 event
- preservation of unattributed sessions
- pending Ads consistency
- reconciliation of pending GA4 activity when Ads arrives
- campaign-window uniqueness
- non-negative metrics
- CPC, CPA, and ROI formulas
- NULL ratio behavior when denominators are unavailable or zero
- reconciliation of impressions, clicks, and spend between Ads source data and the final campaign mart

## Hybrid Streaming / Batch Behavior

The implementation is designed to tolerate the different arrival patterns of the source systems:

- GA4 data arrives progressively.
- Google Ads and Meta Ads arrive in six-hour batches.

Therefore, analytical results can be provisional while data is still arriving.

Repeated dbt executions progressively reconcile the analytical layer as new data becomes available.

The process is idempotent: repeated execution should not multiply advertising spend or duplicate sessions.

## Full Refresh

For validation or development purposes, staging models can be rebuilt from the current raw state with:

```powershell
dbt run --full-refresh --select stg_google_analytics_events stg_google_ads stg_meta_ads
```

This is useful when restarting the challenge emulator and testing the pipeline against a partial replay state.

It is not required for normal incremental execution.
