DELETE FROM mcp_serve_basics_import a
USING mcp_serve_basics_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.player = b.player
  AND a.row = b.row;

DELETE FROM mcp_serve_direction_import a
USING mcp_serve_direction_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.player = b.player
  AND a.row = b.row;

DELETE FROM mcp_shot_direction_import a
USING mcp_shot_direction_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.player = b.player
  AND a.row = b.row;

DELETE FROM mcp_shot_types_import a
USING mcp_shot_types_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.player = b.player
  AND a.row = b.row;

DELETE FROM mcp_return_depth_import a
USING mcp_return_depth_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.player = b.player
  AND a.row = b.row;

DELETE FROM mcp_rally_import a
USING mcp_rally_import b
WHERE a.ctid > b.ctid
  AND a.match_id = b.match_id
  AND a.server = b.server
  AND a.returner = b.returner
  AND a.row = b.row;