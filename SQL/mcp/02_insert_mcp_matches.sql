INSERT INTO mcp_matches (
    match_id,
    player_1,
    player_2,
    player_1_hand,
    player_2_hand,
    match_date,
    tournament,
    round,
    time,
    court,
    surface,
    umpire,
    best_of,
    final_tb,
    charted_by
)
SELECT
    match_id,
    player_1,
    player_2,
    player_1_hand,
    player_2_hand,
    TO_DATE(date, 'YYYYMMDD'),
    tournament,
    round,
    time,
    court,
    surface,
    umpire,
    NULLIF(best_of, '')::INTEGER,
    final_tb,
    charted_by
FROM mcp_matches_import
WHERE date ~ '^[0-9]{8}';
