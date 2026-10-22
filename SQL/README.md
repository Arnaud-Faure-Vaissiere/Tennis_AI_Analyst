# SQL : ATP Database

## Overview

This directory contains the SQL scripts used to create and populate the PostgreSQL database for the Tennis AI Analyst project.

The ATP database is the core data source for the first prediction model (V1). It stores player information, tournament metadata, match results, rankings, and available match statistics.

The current dataset covers ATP men's singles matches from **2010 to 2026**, based on the imported yearly CSV files. 

## Data source

The data originates from Jeff Sackmann's ATP tennis datasets:

- ATP match results: `atp_matches_YYYY.csv`
- Player reference data: `atp_players.csv`

Original project: https://github.com/Aneeshers/tennis-sackmann-archive/tree/main/atp

## Database design

The database separates raw imported files from structured relational tables.

### Staging tables

- `players_import`: temporary landing table for the player CSV.
- `matches_import`: temporary landing table for the annual match CSV files.

These tables allow source data to be imported before converting values to PostgreSQL data types.

### Structured tables

- `players`: player identifiers and biographical information, including name, playing hand, date of birth, country code, height, and Wikidata identifier.
- `tournaments`: tournament metadata, including name, surface, level, draw size, and indoor information when available.
- `matches`: one record per match, including tournament reference, date, round, winner, loser, rankings, score, duration, and available serve statistics.

The `matches` table references `players` and `tournaments` through foreign keys. A uniqueness constraint on `(tournament_id, match_num)` is used to prevent duplicate match records when those fields are populated.

## Import workflow

Run the scripts in the following order.

1. `01_create_atp_schema.sql` creates the staging tables and structured tables.
2. Import the player CSV into `players_import`.
3. Import the selected annual match CSV files into `matches_import`.
4. `02_insert_players.sql` transforms and inserts player records into `players`.
5. `03_insert_matches.sql` inserts tournament metadata into `tournaments`, then transforms and inserts match records into `matches`.

## Data quality and modelling considerations

The database is a historical source, not a pre-match feature table. Match outcomes and match statistics are observed after each match has finished.

For prediction, features are constructed separately in Python and must use only information available before the match being predicted. Historical statistics must be calculated using earlier matches, with same-day matches excluded when exact match times are unavailable.

Missing statistics are retained as missing values or handled during feature engineering; they must not be interpreted as zero unless that meaning is supported by the source.

Tournament attributes and player identifiers should be checked for consistency, and unmatched foreign keys or duplicate records should be investigated during data-quality checks.

## MCP extension

The Match Charting Project (MCP) is an additional experimental source used to investigate player-style features. Its tables and import scripts are kept separately under `sql/mcp/` because MCP is not required to create the core ATP database or run V1.

## Reproducibility

Record the source file years, download date, import procedure, database version, and any cleaning decisions used to build a dataset. Do not commit database passwords, `.env` files, or large raw data files to GitHub.
