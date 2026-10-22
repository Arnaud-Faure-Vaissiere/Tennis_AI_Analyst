-- 03 - IMPORT D'UN CSV DE MATCHS
-- AJOUT DES TOURNOIS

INSERT INTO tournaments ( tournament_id,
    tournament_name, surface, tournament_level,
    draw_size,indoor)

SELECT DISTINCT
    tourney_id, tourney_name, surface, tourney_level,
    NULLIF(draw_size, '')::INTEGER,
    NULL::BOOLEAN
FROM matches_import

WHERE tourney_id IS NOT NULL
  AND tourney_id <> ''

ON CONFLICT (tournament_id)
DO NOTHING;

-- AJOUT DES MATCHS

INSERT INTO matches (
tournament_id,tournament_date,match_num,
winner_id,loser_id,winner_seed,loser_seed,

    winner_entry,loser_entry,winner_age,loser_age,
    score,best_of,round, minutes,
    winner_ace, winner_df,winner_svpt,
    winner_1st_in,winner_1st_won,winner_2nd_won,
    winner_sv_gms,winner_bp_saved,winner_bp_faced,
    loser_ace,loser_df,loser_svpt,loser_1st_in,loser_1st_won,
    loser_2nd_won,loser_sv_gms,loser_bp_saved,loser_bp_faced,

    winner_rank,winner_rank_points,loser_rank,loser_rank_points)

SELECT

    tourney_id, TO_DATE(tourney_date, 'YYYYMMDD'),
    NULLIF(match_num, '')::INTEGER,


    NULLIF(winner_id, '')::INTEGER, NULLIF(loser_id, '')::INTEGER,


    NULLIF(winner_seed, '')::INTEGER, NULLIF(loser_seed, '')::INTEGER,


    NULLIF(winner_entry, ''), NULLIF(loser_entry, ''),


    NULLIF(winner_age, '')::NUMERIC(5,2),NULLIF(loser_age, '')::NUMERIC(5,2),


    score, NULLIF(best_of, '')::INTEGER,

    round, NULLIF(minutes, '')::INTEGER,


    NULLIF(w_ace, '')::INTEGER, NULLIF(w_df, '')::INTEGER,

    NULLIF(w_svpt, '')::INTEGER, NULLIF(w_1stIn, '')::INTEGER,

    NULLIF(w_1stWon, '')::INTEGER, NULLIF(w_2ndWon, '')::INTEGER,

    NULLIF(w_SvGms, '')::INTEGER, NULLIF(w_bpSaved, '')::INTEGER,

    NULLIF(w_bpFaced, '')::INTEGER, NULLIF(l_ace, '')::INTEGER,

    NULLIF(l_df, '')::INTEGER, NULLIF(l_svpt, '')::INTEGER,

    NULLIF(l_1stIn, '')::INTEGER, NULLIF(l_1stWon, '')::INTEGER,

    NULLIF(l_2ndWon, '')::INTEGER, NULLIF(l_SvGms, '')::INTEGER,

    NULLIF(l_bpSaved, '')::INTEGER, NULLIF(l_bpFaced, '')::INTEGER,


    NULLIF(winner_rank, '')::INTEGER, NULLIF(winner_rank_points, '')::INTEGER,


    NULLIF(loser_rank, '')::INTEGER, NULLIF(loser_rank_points, '')::INTEGER

FROM matches_import

WHERE tourney_id IS NOT NULL
  AND tourney_id <> '';


ON CONFLICT (tournament_id, match_num)
DO NOTHING;
