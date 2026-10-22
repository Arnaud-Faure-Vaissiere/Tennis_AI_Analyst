# Match Charting Project (MCP) : SQL Pipeline

## Overview

This directory contains the SQL scripts used to integrate men's Match Charting Project (MCP) data into the PostgreSQL database of the Tennis AI Analyst project.

The MCP extension was developed to investigate whether detailed tennis-style statistics could improve the ATP match prediction model.

The first prediction model (V1) uses historical ATP results and pre-match features. The MCP extension adds information about serving patterns, shot directions, winners, unforced errors, return depth, and rallies.

The MCP-derived features were evaluated in an experimental model (V3a). They did not demonstrate a clear improvement over V1 in the current evaluation, so V1 remains the main prediction model and MCP is retained as an experimental extension.

## Data source

The data comes from Jeff Sackmann's Match Charting Project repository:

https://github.com/JeffSackmann/tennis_MatchChartingProject

The Match Charting Project contains user-submitted records of professional tennis matches, including match metadata, point-by-point information, and match-level aggregate statistics.

This project uses the following men's data files:

- `charting-m-matches.csv`
- `charting-m-stats-ServeBasics.csv`
- `charting-m-stats-ServeDirection.csv`
- `charting-m-stats-ShotDirection.csv`
- `charting-m-stats-ShotTypes.csv`
- `charting-m-stats-ReturnDepth.csv`
- `charting-m-stats-Rally.csv`

The metadata file describes charted matches, while the statistics files provide aggregate counts for different aspects of each match. The current pipeline uses these aggregate files rather than parsing the full point-by-point datasets.

The MCP dataset is not a complete census of all ATP matches. It contains matches that have been charted and submitted by contributors, so coverage varies across players and periods.

## Database design

The MCP SQL pipeline separates imported source data from structured match metadata and consolidated player statistics.

### Import tables

The staging tables preserve the structure of the source CSV files:

- `mcp_matches_import`
- `mcp_serve_basics_import`
- `mcp_serve_direction_import`
- `mcp_shot_direction_import`
- `mcp_shot_types_import`
- `mcp_return_depth_import`
- `mcp_rally_import`

The import tables allow the original records to be loaded before cleaning, deduplication, player mapping, and consolidation.

### Structured tables

#### `mcp_matches`

Stores match-level metadata, including the MCP match identifier, players, match date, tournament, round, and surface.

The MCP match identifier is used to connect the metadata to the aggregate statistics.

#### `mcp_player_map`

Maps MCP player names to the canonical `player_id` used in the ATP `players` table.

The mapping process first normalizes names by removing accents, standardizing case, and normalizing whitespace. Manual mappings are then used for known spelling variants and ambiguous identities.

Some names remain unresolved when an identity cannot be established confidently for the ATP prediction dataset. Unresolved names should not be force-matched to an unrelated player.

The mapping table records the matching method to make the process auditable.

#### `mcp_match_player_stats`

Stores consolidated statistics at the player-match level, with one logical record per MCP match and player.

The table combines aggregate service, service direction, shot direction, shot type, return-depth, and rally statistics.

Where the mapping is successful, the canonical ATP player identifier is stored alongside the original MCP player name.

## Deduplication

Some imported aggregate files contain multiple physical rows with the same logical key. Deduplication is performed before constructing the consolidated player-match statistics table.

For the serve, shot-direction, shot-type, and return-depth tables, the logical key is:

`(match_id, player, row)`

For the rally table, it is:

`(match_id, server, returner, row)`

The SQL scripts remove duplicate rows using PostgreSQL's physical tuple identifier, `ctid`.

This operation is intended to remove redundant copies of the same logical record, not to reconcile conflicting statistics. Duplicate keys should be inspected before deletion to confirm that their aggregate values agree. If conflicting values exist, they must be investigated rather than arbitrarily discarded.

## Why use the `Total` rows?

The aggregate files may contain totals and breakdowns for different subsets of a match.

The consolidation script uses rows where `row = 'Total'` to obtain match-level aggregate statistics. This avoids treating totals and their sub-breakdowns as independent observations or accidentally counting the same match statistics multiple times.

For the rally file, the server-side and returner-side statistics are transformed into separate player-level records:

- `PL1` represents the server.
- `PL2` represents the returner.

The resulting rows are merged into `mcp_match_player_stats` using the match identifier and player name.

## SQL execution workflow

Run the scripts in the following logical order:

1. `01_create_mcp_tables.sql` — create the import tables and structured MCP tables.
2. Import the MCP CSV files into the relevant staging tables.
3. `02_insert_mcp_matches.sql` — transform and insert the match metadata into `mcp_matches`.
4. `03_deduplicate_mcp_stats.sql` — inspect and remove redundant aggregate rows.
5. `04_map_mcp_players.sql` — create and populate the MCP-to-ATP player mapping.
6. `05_build_mcp_match_player_stats.sql` — consolidate the aggregate statistics into player-match records.

The exact execution order must respect table dependencies. The main ATP `players` table must already exist before the player-mapping step. Player identifier columns and rally-statistic columns must be created before scripts that populate them.

**Important:** any script containing `DROP TABLE`, `TRUNCATE`, or destructive reset statements can remove existing data. Such scripts should only be run intentionally in a development environment or after a verified backup.

## Missing data and data quality

MCP coverage is uneven because only charted matches are available. Not every ATP player or historical match has MCP statistics.

A missing statistic does not mean that the player recorded zero aces, zero winners, or zero errors. It means that the required information is unavailable in the corresponding charted data or aggregate field.

The pipeline retains missing values when a component statistic is not available. Subsequent feature engineering must distinguish missing coverage from a genuine numerical zero.

Ratio features must be built from compatible numerators and denominators. For example, a return-depth rate should not exceed 1 when its numerator counts a subset of the same denominator population. Unexpected ratios require source inspection and correction rather than artificial clipping.

## Role in the prediction project

MCP-derived profiles were constructed from charted matches strictly earlier than the ATP match being predicted. When exact match times are unavailable, same-day MCP matches are excluded to reduce the risk of temporal leakage.

MCP was tested as an extension to the baseline model through alternative historical and surface-specific player profiles. The current evidence does not establish a clear predictive advantage over V1, so MCP is retained for further analysis of playing styles rather than treated as a required dependency of the main model.

The clustering experiments are exploratory. Cluster labels should only be assigned from profiles available at the relevant prediction date, using standardization and cluster centres fitted on training-period data.

## Reproducibility

Record the download date, source repository version or commit, imported filenames, duplicate-resolution decisions, player-mapping decisions, and relevant SQL execution steps.

Do not commit database credentials, `.env` files, or large raw CSV files. Keep the SQL scripts and documentation sufficient for another user to reproduce the database preparation from the original data sources.
