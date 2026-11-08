-- INDEX DEFINITIONS
-- Extracted from the supplied rpl.db database.
-- DDL only: no personal/raw match data is included.

CREATE INDEX idx_matches_season_round ON Matches(season, match_round);

CREATE INDEX idx_playerstats_match_id ON PlayerStats(match_id);

CREATE INDEX idx_playerstats_player_id ON PlayerStats(player_id);

CREATE INDEX idx_playerstats_team_id ON PlayerStats(team_id);

CREATE INDEX idx_playerteams_player_team_contract ON PlayerTeams(player_id, team_id, contract_start, contract_end);

