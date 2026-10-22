-- PROJET TENNIS ATP
-- CREATION TABLE

-- 1. TABLE PLAYERS

CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,

    first_name TEXT,
    last_name TEXT,

    hand CHAR(1),

    birth_date DATE,

    country_code CHAR(3),

    height INTEGER,

    wikidata_id TEXT);


-- 2. TABLE PLAYERS_IMPORT
-- Cette table reçoit le CSV des joueurs tel quel.

CREATE TABLE players_import (
    player_id INTEGER,
    first_name TEXT,
    last_name TEXT,

    hand CHAR(1),

    birth_date TEXT,

    country_code CHAR(3),

    height INTEGER,

    wikidata_id TEXT);


-- 3. TABLE TOURNAMENTS

CREATE TABLE tournaments (
    tournament_id TEXT PRIMARY KEY,

    tournament_name TEXT,

    surface TEXT,

    tournament_level CHAR(1),

    draw_size INTEGER,

    indoor BOOLEAN);


-- 4. TABLE MATCHES_IMPORT

CREATE TABLE matches_import (

    tourney_id TEXT,
    tourney_name TEXT,
    surface TEXT,
    draw_size TEXT,
    tourney_level TEXT,
    tourney_date TEXT,
    match_num TEXT,

    winner_id TEXT,
    winner_seed TEXT,
    winner_entry TEXT,
    winner_name TEXT,
    winner_hand TEXT,
    winner_ht TEXT,
    winner_ioc TEXT,
    winner_age TEXT,

    loser_id TEXT,
    loser_seed TEXT,
    loser_entry TEXT,
    loser_name TEXT,
    loser_hand TEXT,
    loser_ht TEXT,
    loser_ioc TEXT,
    loser_age TEXT,

    score TEXT,
    best_of TEXT,
    round TEXT,
    minutes TEXT,

    w_ace TEXT,
    w_df TEXT,
    w_svpt TEXT,
    w_1stIn TEXT,
    w_1stWon TEXT,
    w_2ndWon TEXT,
    w_SvGms TEXT,
    w_bpSaved TEXT,
    w_bpFaced TEXT,

    l_ace TEXT,
    l_df TEXT,
    l_svpt TEXT,
    l_1stIn TEXT,
    l_1stWon TEXT,
    l_2ndWon TEXT,
    l_SvGms TEXT,
    l_bpSaved TEXT,
    l_bpFaced TEXT,

    winner_rank TEXT,
    winner_rank_points TEXT,
    loser_rank TEXT,
    loser_rank_points TEXT);


-- 5. TABLE MATCHES

CREATE TABLE matches (

    match_id BIGSERIAL PRIMARY KEY,

    tournament_id TEXT NOT NULL,

    tournament_date DATE,

    match_num INTEGER,

    winner_id INTEGER,
    loser_id INTEGER,

    winner_seed INTEGER,
    loser_seed INTEGER,

    winner_entry TEXT,
    loser_entry TEXT,

    winner_age NUMERIC(5,2),
    loser_age NUMERIC(5,2),

    score TEXT,

    best_of INTEGER,

    round TEXT,

    minutes INTEGER,

    winner_ace INTEGER,
    winner_df INTEGER,
    winner_svpt INTEGER,
    winner_1st_in INTEGER,
    winner_1st_won INTEGER,
    winner_2nd_won INTEGER,
    winner_sv_gms INTEGER,
    winner_bp_saved INTEGER,
    winner_bp_faced INTEGER,

    loser_ace INTEGER,
    loser_df INTEGER,
    loser_svpt INTEGER,
    loser_1st_in INTEGER,
    loser_1st_won INTEGER,
    loser_2nd_won INTEGER,
    loser_sv_gms INTEGER,
    loser_bp_saved INTEGER,
    loser_bp_faced INTEGER,

    winner_rank INTEGER,
    winner_rank_points INTEGER,

    loser_rank INTEGER,
    loser_rank_points INTEGER,

-- ========================================================
-- PROTECTION CONTRE LES DOUBLONSUn match est identifié par :
CONSTRAINT unique_match
UNIQUE (tournament_id, match_num));

-- 6. CLES ETRANGERES
-- Le gagnant doit exister dans players

ALTER TABLE matches
ADD CONSTRAINT fk_matches_winner
FOREIGN KEY (winner_id)
REFERENCES players(player_id);
-- Le perdant doit exister dans players
ALTER TABLE matches
ADD CONSTRAINT fk_matches_loser
FOREIGN KEY (loser_id)
REFERENCES players(player_id);


-- Le tournoi doit exister dans tournaments

ALTER TABLE matches
ADD CONSTRAINT fk_matches_tournament
FOREIGN KEY (tournament_id)
REFERENCES tournaments(tournament_id);


-- 7. INDEX

CREATE INDEX idx_matches_winner
ON matches(winner_id);

CREATE INDEX idx_matches_loser
ON matches(loser_id);

CREATE INDEX idx_matches_tournament
ON matches(tournament_id);

CREATE INDEX idx_matches_date
ON matches(tournament_date);

-- FIN
