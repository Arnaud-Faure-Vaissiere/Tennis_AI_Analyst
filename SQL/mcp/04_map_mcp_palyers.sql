CREATE EXTENSION IF NOT EXISTS unaccent;

DROP TABLE IF EXISTS mcp_player_map;

CREATE TABLE mcp_player_map (
    mcp_player_name TEXT PRIMARY KEY, player_id INTEGER, mapping_method TEXT);

INSERT INTO mcp_player_map (mcp_player_name)
SELECT DISTINCT player
FROM mcp_match_player_stats
UNION
SELECT DISTINCT player_1
FROM mcp_matches
UNION
SELECT DISTINCT player_2
FROM mcp_matches;

-- Mapping des noms
UPDATE mcp_player_map AS m
SET player_id = p.player_id, mapping_method = 'exact_normalized'
FROM players AS p
WHERE LOWER(REGEXP_REPLACE(unaccent(TRIM(m.mcp_player_name)),
            '\s+',' ','g'))
    =LOWER(REGEXP_REPLACE(unaccent(TRIM(p.first_name || ' ' || p.last_name)),
            '\s+',' ','g'));

UPDATE mcp_player_map
SET player_id = 106238,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Andres Artunedo';

UPDATE mcp_player_map
SET player_id = 100486,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Christophe Roger Vasselin';

UPDATE mcp_player_map
SET player_id = 104273,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Edouard Roger Vasselin';

UPDATE mcp_player_map
SET player_id = 105015,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Franco Skugor';

UPDATE mcp_player_map
SET player_id = 104542,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Jo Wilfried Tsonga';

UPDATE mcp_player_map
SET player_id = 144642,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Marcelo Tomas Barrios Vera';

UPDATE mcp_player_map
SET player_id = 105032,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Samuel Groth';

UPDATE mcp_player_map
SET player_id = 207736,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Arklon Huertas Del Pino';

UPDATE mcp_player_map
SET player_id = 202297,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Dan Martin';

UPDATE mcp_player_map
SET player_id = 210150,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Jakub Mensik';

UPDATE mcp_player_map
SET player_id = 209992,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Juncheng Shang';

UPDATE mcp_player_map
SET player_id = 212021,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Martin Landaluce';

UPDATE mcp_player_map
SET player_id = 209263,
    mapping_method = 'manual'
WHERE mcp_player_name = 'Matteo Gigante';

UPDATE mcp_player_map
SET mapping_method = 'unresolved_not_in_matches_2010_2026'
WHERE mcp_player_name IN (
    'Mark Kevin Goellner',
    'Bill Scanlon',
    'Bruno Kuzuhara',
    'Chris Lewis',
    'Kelly Evernden',
    'Manuel Orantes',
    'Mark Edmondson',
    'Tim Wilkison',
    'Wojtek Fibak');
