DROP TABLE IF EXISTS mcp_matches_import;
CREATE TABLE mcp_matches_import (
    match_id TEXT,
    player_1 TEXT,
    player_2 TEXT,
    player_1_hand TEXT,
    player_2_hand TEXT,
    date TEXT,
    tournament TEXT,
    round TEXT,
    time TEXT,
    court TEXT,
    surface TEXT,
    umpire TEXT,
    best_of TEXT,
    final_tb TEXT,
    charted_by TEXT);

DROP TABLE IF EXISTS mcp_matches;

CREATE TABLE mcp_matches (
    match_id TEXT PRIMARY KEY,
    player_1 TEXT NOT NULL,
    player_2 TEXT NOT NULL,
    player_1_hand TEXT,
    player_2_hand TEXT,
    match_date DATE NOT NULL,
    tournament TEXT NOT NULL,
    round TEXT,
    time TEXT,
    court TEXT,
    surface TEXT NOT NULL,
    umpire TEXT,
    best_of INTEGER,
    final_tb TEXT,
    charted_by TEXT);

DROP TABLE IF EXISTS mcp_serve_basics_import;
CREATE TABLE mcp_serve_basics_import (
    match_id TEXT,
    player TEXT,
    row TEXT,
    pts INTEGER,
    pts_won INTEGER,
    aces INTEGER,
    unret INTEGER,
    forced_err INTEGER,
    pts_won_lte_3_shots INTEGER,
    wide INTEGER,
    body INTEGER,
    t INTEGER);

DROP TABLE IF EXISTS mcp_serve_direction_import;

CREATE TABLE mcp_serve_direction_import (
    match_id TEXT,
    player TEXT,
    row TEXT,
    deuce_wide INTEGER,
    deuce_middle INTEGER,
    deuce_t INTEGER,
    ad_wide INTEGER,
    ad_middle INTEGER,
    ad_t INTEGER,
    err_net INTEGER,
    err_wide INTEGER,
    err_deep INTEGER,
    err_wide_deep INTEGER,
    err_foot INTEGER,
    err_unknown INTEGER);

DROP TABLE IF EXISTS mcp_shot_direction_import;

CREATE TABLE mcp_shot_direction_import (
    match_id TEXT,
    player TEXT,
    row TEXT,
    crosscourt INTEGER,
    down_middle INTEGER,
    down_the_line INTEGER,
    inside_out INTEGER,
    inside_in INTEGER);

DROP TABLE IF EXISTS mcp_shot_types_import;

CREATE TABLE mcp_shot_types_import (
    match_id TEXT,
    player TEXT,
    row TEXT,
    shots INTEGER,
    pt_ending INTEGER,
    winners INTEGER,
    induced_forced INTEGER,
    unforced INTEGER,
    serve_return INTEGER,
    shots_in_pts_won INTEGER,
    shots_in_pts_lost INTEGER);

DROP TABLE IF EXISTS mcp_return_depth_import;

CREATE TABLE mcp_return_depth_import (
    match_id TEXT,
    player TEXT,
    row TEXT,
    returnable INTEGER,
    shallow INTEGER,
    deep INTEGER,
    very_deep INTEGER,
    unforced INTEGER,
    err_net INTEGER,
    err_deep INTEGER,
    err_wide INTEGER,
    err_wide_deep INTEGER);

DROP TABLE IF EXISTS mcp_rally_import;

CREATE TABLE mcp_rally_import (
    match_id TEXT,
    server TEXT,
    returner TEXT,
    row TEXT,
    pts INTEGER,
    pl1_won INTEGER,
    pl1_winners INTEGER,
    pl1_forced INTEGER,
    pl1_unforced INTEGER,
    pl2_won INTEGER,
    pl2_winners INTEGER,
    pl2_forced INTEGER,
    pl2_unforced INTEGER
);

DROP TABLE IF EXISTS mcp_match_player_stats;

CREATE TABLE mcp_match_player_stats (
    match_id TEXT NOT NULL,
    player TEXT NOT NULL,

    -- Serve basics
    serve_pts INTEGER,
    serve_pts_won INTEGER,
    aces INTEGER,
    unreturned_serves INTEGER,
    forced_errors INTEGER,
    pts_won_lte_3_shots INTEGER,
    serve_wide INTEGER,
    serve_body INTEGER,
    serve_t INTEGER,

    -- Serve direction
    deuce_wide INTEGER,
    deuce_middle INTEGER,
    deuce_t INTEGER,
    ad_wide INTEGER,
    ad_middle INTEGER,
    ad_t INTEGER,
    serve_error_net INTEGER,
    serve_error_wide INTEGER,
    serve_error_deep INTEGER,
    serve_error_wide_deep INTEGER,
    serve_error_foot INTEGER,
    serve_error_unknown INTEGER,

    -- Shot direction
    shots_crosscourt INTEGER,
    shots_down_middle INTEGER,
    shots_down_the_line INTEGER,
    shots_inside_out INTEGER,
    shots_inside_in INTEGER,

    -- Shot types
    shots INTEGER,
    points_ending INTEGER,
    winners INTEGER,
    induced_forced INTEGER,
    unforced INTEGER,
    serve_return_shots INTEGER,
    shots_in_points_won INTEGER,
    shots_in_points_lost INTEGER,

    -- Return depth
    returnable INTEGER,
    return_shallow INTEGER,
    return_deep INTEGER,
    return_very_deep INTEGER,
    return_unforced INTEGER,
    return_error_net INTEGER,
    return_error_deep INTEGER,
    return_error_wide INTEGER,
    return_error_wide_deep INTEGER,

    PRIMARY KEY (match_id, player));