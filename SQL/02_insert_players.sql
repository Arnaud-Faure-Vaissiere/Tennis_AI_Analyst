-- IMPORT DES JOUEURS

INSERT INTO players (
    player_id,
    first_name,
    last_name,
    hand,
    birth_date,
    country_code,
    height,
    wikidata_id
)

SELECT
    player_id,
    first_name,
    last_name,
    hand,
    TO_DATE(birth_date, 'YYYYMMDD'),
    country_code,
    height,
    wikidata_id

FROM players_import

ON CONFLICT (player_id) DO NOTHING;

SELECT COUNT(*)
FROM players; -- 66 000 joueurs 

SELECT MIN(birth_date), MAX(birth_date) -- 1834 , 2023
FROM players ;