TRUNCATE TABLE mcp_match_player_stats;

INSERT INTO mcp_match_player_stats (
    match_id,
    player,
    serve_pts,
    serve_pts_won,
    aces,
    unreturned_serves,
    forced_errors,
    pts_won_lte_3_shots,
    serve_wide,
    serve_body,
    serve_t)
SELECT DISTINCT
    match_id,
    player,
    pts,
    pts_won,
    aces,
    unret,
    forced_err,
    pts_won_lte_3_shots,
    wide,
    body,
    t
FROM mcp_serve_basics_import
WHERE row = 'Total';

UPDATE mcp_match_player_stats AS m
SET
    deuce_wide = s.deuce_wide,
    deuce_middle = s.deuce_middle,
    deuce_t = s.deuce_t,
    ad_wide = s.ad_wide,
    ad_middle = s.ad_middle,
    ad_t = s.ad_t,
    serve_error_net = s.err_net,
    serve_error_wide = s.err_wide,
    serve_error_deep = s.err_deep,
    serve_error_wide_deep = s.err_wide_deep,
    serve_error_foot = s.err_foot,
    serve_error_unknown = s.err_unknown
FROM mcp_serve_direction_import AS s
WHERE
    s.row = 'Total'
    AND m.match_id = s.match_id
    AND m.player = s.player;

UPDATE mcp_match_player_stats AS m
SET
    shots_crosscourt = s.crosscourt,
    shots_down_middle = s.down_middle,
    shots_down_the_line = s.down_the_line,
    shots_inside_out = s.inside_out,
    shots_inside_in = s.inside_in
FROM mcp_shot_direction_import AS s
WHERE
    s.row = 'Total'
    AND m.match_id = s.match_id
    AND m.player = s.player;

UPDATE mcp_match_player_stats AS m
SET
    shots = s.shots,
    points_ending = s.pt_ending,
    winners = s.winners,
    induced_forced = s.induced_forced,
    unforced = s.unforced,
    serve_return_shots = s.serve_return,
    shots_in_points_won = s.shots_in_pts_won,
    shots_in_points_lost = s.shots_in_pts_lost
FROM mcp_shot_types_import AS s
WHERE
    s.row = 'Total'
    AND m.match_id = s.match_id
    AND m.player = s.player;

UPDATE mcp_match_player_stats AS m
SET
    returnable = r.returnable,
    return_shallow = r.shallow,
    return_deep = r.deep,
    return_very_deep = r.very_deep,
    return_unforced = r.unforced,
    return_error_net = r.err_net,
    return_error_deep = r.err_deep,
    return_error_wide = r.err_wide,
    return_error_wide_deep = r.err_wide_deep
FROM mcp_return_depth_import AS r
WHERE
    r.row = 'Total'
    AND m.match_id = r.match_id
    AND m.player = r.player;

-- Rajout de Rally
--ALTER TABLE mcp_match_player_stats
--ADD COLUMN rally_pts INTEGER,
--ADD COLUMN rally_pts_won INTEGER,
--ADD COLUMN rally_winners INTEGER,
--ADD COLUMN rally_forced INTEGER,
--ADD COLUMN rally_unforced INTEGER;

WITH rally_player_stats AS (

    -- Joueur qui sert = PL1
    SELECT
        match_id,
        server AS player,
        pts AS rally_pts,
        pl1_won AS rally_pts_won,
        pl1_winners AS rally_winners,
        pl1_forced AS rally_forced,
        pl1_unforced AS rally_unforced
    FROM mcp_rally_import
    WHERE row = 'Total'

    UNION ALL

    -- Joueur qui retourne = PL2
    SELECT
        match_id,
        returner AS player,
        pts AS rally_pts,
        pl2_won AS rally_pts_won,
        pl2_winners AS rally_winners,
        pl2_forced AS rally_forced,
        pl2_unforced AS rally_unforced
    FROM mcp_rally_import
    WHERE row = 'Total'
)

UPDATE mcp_match_player_stats AS m
SET
    rally_pts = r.rally_pts,
    rally_pts_won = r.rally_pts_won,
    rally_winners = r.rally_winners,
    rally_forced = r.rally_forced,
    rally_unforced = r.rally_unforced
FROM rally_player_stats AS r
WHERE
    m.match_id = r.match_id
    AND m.player = r.player;
