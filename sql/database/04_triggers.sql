-- TRIGGER DEFINITIONS
-- Extracted from the supplied rpl.db database.
-- DDL only: no personal/raw match data is included.

CREATE TRIGGER check_contract_before_insert
BEFORE INSERT ON PlayerStats
FOR EACH ROW
BEGIN
    SELECT
        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM PlayerTeams pt
                JOIN Matches m ON m.match_id = NEW.match_id
                WHERE pt.player_id = NEW.player_id
                  AND pt.team_id = NEW.team_id
                  AND pt.contract_start <= m.match_date
                  AND (pt.contract_end >= m.match_date OR pt.contract_end IS NULL)
            )
            THEN RAISE(ABORT, 'Ошибка: игрок не находится на контракте с данной командой на дату матча')
        END;
END;

CREATE TRIGGER trg_cities_delete
AFTER DELETE ON Cities
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'Cities',
        'DELETE',
        OLD.city_id,
        json_object(
            'city_id', OLD.city_id,
            'city_name', OLD.city_name,
            'region_name', OLD.region_name,
            'country_name', OLD.country_name,
            'population', OLD.population,
            'area', OLD.area,
            'founded', OLD.founded,
            'capital', OLD.capital
        )
    );
END;

CREATE TRIGGER trg_cities_insert
AFTER INSERT ON Cities
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'Cities',
        'INSERT',
        NEW.city_id,
        json_object(
            'city_id', NEW.city_id,
            'city_name', NEW.city_name,
            'region_name', NEW.region_name,
            'country_name', NEW.country_name,
            'population', NEW.population,
            'area', NEW.area,
            'founded', NEW.founded,
            'capital', NEW.capital
        )
    );
END;

CREATE TRIGGER trg_cities_update
AFTER UPDATE ON Cities
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Cities',
        'UPDATE',
        NEW.city_id,
        json_object(
            'city_id', OLD.city_id,
            'city_name', OLD.city_name,
            'region_name', OLD.region_name,
            'country_name', OLD.country_name,
            'population', OLD.population,
            'area', OLD.area,
            'founded', OLD.founded,
            'capital', OLD.capital
        ),
        json_object(
            'city_id', NEW.city_id,
            'city_name', NEW.city_name,
            'region_name', NEW.region_name,
            'country_name', NEW.country_name,
            'population', NEW.population,
            'area', NEW.area,
            'founded', NEW.founded,
            'capital', NEW.capital
        )
    );
END;

CREATE TRIGGER trg_coaches_delete
AFTER DELETE ON Coaches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Coaches',
        'DELETE',
        OLD.coach_id,
        json_object(
            'coach_id', OLD.coach_id,
            'coach_name', OLD.coach_name,
            'coach_dob', OLD.coach_dob,
            'coach_national', OLD.coach_national,
            'city_id', OLD.city_id
        ),
        NULL
    );
END;

CREATE TRIGGER trg_coaches_insert
AFTER INSERT ON Coaches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Coaches',
        'INSERT',
        NEW.coach_id,
        NULL,
        json_object(
            'coach_id', NEW.coach_id,
            'coach_name', NEW.coach_name,
            'coach_dob', NEW.coach_dob,
            'coach_national', NEW.coach_national,
            'city_id', NEW.city_id
        )
    );
END;

CREATE TRIGGER trg_coaches_update
AFTER UPDATE ON Coaches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Coaches',
        'UPDATE',
        NEW.coach_id,
        json_object(
            'coach_id', OLD.coach_id,
            'coach_name', OLD.coach_name,
            'coach_dob', OLD.coach_dob,
            'coach_national', OLD.coach_national,
            'city_id', OLD.city_id
        ),
        json_object(
            'coach_id', NEW.coach_id,
            'coach_name', NEW.coach_name,
            'coach_dob', NEW.coach_dob,
            'coach_national', NEW.coach_national,
            'city_id', NEW.city_id
        )
    );
END;

CREATE TRIGGER trg_coachteams_delete
AFTER DELETE ON CoachTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'CoachTeams',
        'DELETE',
        OLD.coach_team_id,
        json_object(
            'coach_team_id', OLD.coach_team_id,
            'coach_id', OLD.coach_id,
            'team_id', OLD.team_id,
            'contract_start', OLD.contract_start,
            'contract_end', OLD.contract_end
        ),
        NULL
    );
END;

CREATE TRIGGER trg_coachteams_insert
AFTER INSERT ON CoachTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'CoachTeams',
        'INSERT',
        NEW.coach_team_id,
        NULL,
        json_object(
            'coach_team_id', NEW.coach_team_id,
            'coach_id', NEW.coach_id,
            'team_id', NEW.team_id,
            'contract_start', NEW.contract_start,
            'contract_end', NEW.contract_end
        )
    );
END;

CREATE TRIGGER trg_coachteams_update
AFTER UPDATE ON CoachTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'CoachTeams',
        'UPDATE',
        NEW.coach_team_id,
        json_object(
            'coach_team_id', OLD.coach_team_id,
            'coach_id', OLD.coach_id,
            'team_id', OLD.team_id,
            'contract_start', OLD.contract_start,
            'contract_end', OLD.contract_end
        ),
        json_object(
            'coach_team_id', NEW.coach_team_id,
            'coach_id', NEW.coach_id,
            'team_id', NEW.team_id,
            'contract_start', NEW.contract_start,
            'contract_end', NEW.contract_end
        )
    );
END;

CREATE TRIGGER trg_goalkeeperstats_delete
AFTER DELETE ON GoalkeeperStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES ('GoalkeeperStats', 'DELETE', OLD.goalkeeper_stat_id, json_object(
        'goalkeeper_stat_id', OLD.goalkeeper_stat_id,
        'player_stat_id', OLD.player_stat_id,
        'saves', OLD.saves,
        'punches', OLD.punches,
        'runs_out', OLD.runs_out,
        'runs_out_succ', OLD.runs_out_succ,
        'high_claims', OLD.high_claims,
        'saves_f_inside_box', OLD.saves_f_inside_box,
        'errors_lead_to_shot', OLD.errors_lead_to_shot,
        'errors_lead_to_goal', OLD.errors_lead_to_goal,
        'penalties_saved', OLD.penalties_saved,
        
        'penalties_missed', OLD.penalties_missed,
        'penalties_total', OLD.penalties_total
    ));
END;

CREATE TRIGGER trg_goalkeeperstats_insert
AFTER INSERT ON GoalkeeperStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES ('GoalkeeperStats', 'INSERT', NEW.goalkeeper_stat_id, json_object(
        'goalkeeper_stat_id', NEW.goalkeeper_stat_id,
        'player_stat_id', NEW.player_stat_id,
        'saves', NEW.saves,
        'punches', NEW.punches,
        'runs_out', NEW.runs_out,
        'runs_out_succ', NEW.runs_out_succ,
        'high_claims', NEW.high_claims,
        'saves_f_inside_box', NEW.saves_f_inside_box,
        'errors_lead_to_shot', NEW.errors_lead_to_shot,
        'errors_lead_to_goal', NEW.errors_lead_to_goal,
        'penalties_saved', NEW.penalties_saved,

        'penalties_missed', NEW.penalties_missed,
        'penalties_total', NEW.penalties_total
    ));
END;

CREATE TRIGGER trg_goalkeeperstats_update
AFTER UPDATE ON GoalkeeperStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES ('GoalkeeperStats', 'UPDATE', NEW.goalkeeper_stat_id,
        json_object( -- old_values
            'goalkeeper_stat_id', OLD.goalkeeper_stat_id,
            'player_stat_id', OLD.player_stat_id,
            'saves', OLD.saves,
            'punches', OLD.punches,
            'runs_out', OLD.runs_out,
            'runs_out_succ', OLD.runs_out_succ,
            'high_claims', OLD.high_claims,
            'saves_f_inside_box', OLD.saves_f_inside_box,
            'errors_lead_to_shot', OLD.errors_lead_to_shot,
            'errors_lead_to_goal', OLD.errors_lead_to_goal,
            'penalties_saved', OLD.penalties_saved,

            'penalties_missed', OLD.penalties_missed,
            'penalties_total', OLD.penalties_total
        ),
        json_object( -- new_values
            'goalkeeper_stat_id', NEW.goalkeeper_stat_id,
            'player_stat_id', NEW.player_stat_id,
            'saves', NEW.saves,
            'punches', NEW.punches,
            'runs_out', NEW.runs_out,
            'runs_out_succ', NEW.runs_out_succ,
            'high_claims', NEW.high_claims,
            'saves_f_inside_box', NEW.saves_f_inside_box,
            'errors_lead_to_shot', NEW.errors_lead_to_shot,
            'errors_lead_to_goal', NEW.errors_lead_to_goal,
            'penalties_saved', NEW.penalties_saved,
   
            'penalties_missed', NEW.penalties_missed,
            'penalties_total', NEW.penalties_total
        )
    );
END;

CREATE TRIGGER trg_matches_delete
AFTER DELETE ON Matches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'Matches',
        'DELETE',
        OLD.match_id,
        json_object(
            'match_id', OLD.match_id,
            'team1_id', OLD.team1_id,
            'team2_id', OLD.team2_id,
            'match_name', OLD.match_name,
            'match_date', OLD.match_date,
            'match_time', OLD.match_time,
            'season', OLD.season,
            'referee_id', OLD.referee_id,
			'stadium_id', OLD.stadium_id,
            'match_attendance', OLD.match_attendance,
            'match_round', OLD.match_round,
            'temperature', OLD.temperature,
            'wind_speed', OLD.wind_speed,
            'air_humidity', OLD.air_humidity
        )
    );
END;

CREATE TRIGGER trg_matches_insert
AFTER INSERT ON Matches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'Matches',
        'INSERT',
        NEW.match_id,
        json_object(
            'match_id', NEW.match_id,
            'team1_id', NEW.team1_id,
            'team2_id', NEW.team2_id,
            'match_name', NEW.match_name,
            'match_date', NEW.match_date,
            'match_time', NEW.match_time,
            'season', NEW.season,
            'referee_id', NEW.referee_id,
			'stadium_id', NEW.stadium_id,
            'match_attendance', NEW.match_attendance,
            'match_round', NEW.match_round,
            'temperature', NEW.temperature,
            'wind_speed', NEW.wind_speed,
            'air_humidity', NEW.air_humidity
        )
    );
END;

CREATE TRIGGER trg_matches_update
AFTER UPDATE ON Matches
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Matches',
        'UPDATE',
        NEW.match_id,
        json_object(
            'match_id', OLD.match_id,
            'team1_id', OLD.team1_id,
            'team2_id', OLD.team2_id,
            'match_name', OLD.match_name,
            'match_date', OLD.match_date,
            'match_time', OLD.match_time,
            'season', OLD.season,
            'referee_id', OLD.referee_id,
			'stadium_id', OLD.stadium_id,
            'match_attendance', OLD.match_attendance,
            'match_round', OLD.match_round,
            'temperature', OLD.temperature,
            'wind_speed', OLD.wind_speed,
            'air_humidity', OLD.air_humidity
        ),
        json_object(
            'match_id', NEW.match_id,
            'team1_id', NEW.team1_id,
            'team2_id', NEW.team2_id,
            'match_name', NEW.match_name,
            'match_date', NEW.match_date,
            'match_time', NEW.match_time,
            'season', NEW.season,
            'referee_id', NEW.referee_id,
			'stadium_id', NEW.stadium_id,
            'match_attendance', NEW.match_attendance,
            'match_round', NEW.match_round,
            'temperature', NEW.temperature,
            'wind_speed', NEW.wind_speed,
            'air_humidity', NEW.air_humidity
        )
    );
END;

CREATE TRIGGER trg_matchstats_delete
AFTER DELETE ON MatchStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'MatchStats',
        'DELETE',
        OLD.match_stats_id,
        json_object(
            'match_stats_id', OLD.match_stats_id,
            'match_id', OLD.match_id,
            'team_id', OLD.team_id,
            'goals', OLD.goals,
            'xg', OLD.xg,
            'ppda', OLD.ppda,
            'deep', OLD.deep,
            'corners', OLD.corners,
            'yellow_cards', OLD.yellow_cards,
            'red_cards', OLD.red_cards,
            'offsides', OLD.offsides,
            'fouls', OLD.fouls,
            'saves', OLD.saves,
            'possession', OLD.possession,
            'shots', OLD.shots,
            'shots_on_target', OLD.shots_on_target,
            'hit_woodwork', OLD.hit_woodwork,
            'shots_off_target', OLD.shots_off_target,
            'blocked_shots', OLD.blocked_shots,
            'shots_inside_box', OLD.shots_inside_box,
            'shots_outside_box', OLD.shots_outside_box,
            'passes', OLD.passes,
            'accurate_passes', OLD.accurate_passes,
            'final_third_phase', OLD.final_third_phase,
            'accurate_final_third_phase', OLD.accurate_final_third_phase,
            'long_balls', OLD.long_balls,
            'accurate_long_balls', OLD.accurate_long_balls,
            'crosses', OLD.crosses,
            'accurate_crosses', OLD.accurate_crosses,
            'ground_duels', OLD.ground_duels,
            'ground_duels_won', OLD.ground_duels_won,
            'aerial_duels', OLD.aerial_duels,
            'aerial_duels_won', OLD.aerial_duels_won,
            'dribbles', OLD.dribbles,
            'dribbles_succ', OLD.dribbles_succ
        )
    );
END;

CREATE TRIGGER trg_matchstats_insert
AFTER INSERT ON MatchStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'MatchStats',
        'INSERT',
        NEW.match_stats_id,
        json_object(
            'match_stats_id', NEW.match_stats_id,
            'match_id', NEW.match_id,
            'team_id', NEW.team_id,
            'goals', NEW.goals,
            'xg', NEW.xg,
            'ppda', NEW.ppda,
            'deep', NEW.deep,
            'corners', NEW.corners,
            'yellow_cards', NEW.yellow_cards,
            'red_cards', NEW.red_cards,
            'offsides', NEW.offsides,
            'fouls', NEW.fouls,
            'saves', NEW.saves,
            'possession', NEW.possession,
            'shots', NEW.shots,
            'shots_on_target', NEW.shots_on_target,
            'hit_woodwork', NEW.hit_woodwork,
            'shots_off_target', NEW.shots_off_target,
            'blocked_shots', NEW.blocked_shots,
            'shots_inside_box', NEW.shots_inside_box,
            'shots_outside_box', NEW.shots_outside_box,
            'passes', NEW.passes,
            'accurate_passes', NEW.accurate_passes,
            'final_third_phase', NEW.final_third_phase,
            'accurate_final_third_phase', NEW.accurate_final_third_phase,
            'long_balls', NEW.long_balls,
            'accurate_long_balls', NEW.accurate_long_balls,
            'crosses', NEW.crosses,
            'accurate_crosses', NEW.accurate_crosses,
            'ground_duels', NEW.ground_duels,
            'ground_duels_won', NEW.ground_duels_won,
            'aerial_duels', NEW.aerial_duels,
            'aerial_duels_won', NEW.aerial_duels_won,
            'dribbles', NEW.dribbles,
            'dribbles_succ', NEW.dribbles_succ
        )
    );
END;

CREATE TRIGGER trg_matchstats_update
AFTER UPDATE ON MatchStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'MatchStats',
        'UPDATE',
        NEW.match_stats_id,
        json_object(
            'match_stats_id', OLD.match_stats_id,
            'match_id', OLD.match_id,
            'team_id', OLD.team_id,
            'goals', OLD.goals,
            'xg', OLD.xg,
            'ppda', OLD.ppda,
            'deep', OLD.deep,
            'corners', OLD.corners,
            'yellow_cards', OLD.yellow_cards,
            'red_cards', OLD.red_cards,
            'offsides', OLD.offsides,
            'fouls', OLD.fouls,
            'saves', OLD.saves,
            'possession', OLD.possession,
            'shots', OLD.shots,
            'shots_on_target', OLD.shots_on_target,
            'hit_woodwork', OLD.hit_woodwork,
            'shots_off_target', OLD.shots_off_target,
            'blocked_shots', OLD.blocked_shots,
            'shots_inside_box', OLD.shots_inside_box,
            'shots_outside_box', OLD.shots_outside_box,
            'passes', OLD.passes,
            'accurate_passes', OLD.accurate_passes,
            'final_third_phase', OLD.final_third_phase,
            'accurate_final_third_phase', OLD.accurate_final_third_phase,
            'long_balls', OLD.long_balls,
            'accurate_long_balls', OLD.accurate_long_balls,
            'crosses', OLD.crosses,
            'accurate_crosses', OLD.accurate_crosses,
            'ground_duels', OLD.ground_duels,
            'ground_duels_won', OLD.ground_duels_won,
            'aerial_duels', OLD.aerial_duels,
            'aerial_duels_won', OLD.aerial_duels_won,
            'dribbles', OLD.dribbles,
            'dribbles_succ', OLD.dribbles_succ
        ),
        json_object(
            'match_stats_id', NEW.match_stats_id,
            'match_id', NEW.match_id,
            'team_id', NEW.team_id,
            'goals', NEW.goals,
            'xg', NEW.xg,
            'ppda', NEW.ppda,
            'deep', NEW.deep,
            'corners', NEW.corners,
            'yellow_cards', NEW.yellow_cards,
            'red_cards', NEW.red_cards,
            'offsides', NEW.offsides,
            'fouls', NEW.fouls,
            'saves', NEW.saves,
            'possession', NEW.possession,
            'shots', NEW.shots,
            'shots_on_target', NEW.shots_on_target,
            'hit_woodwork', NEW.hit_woodwork,
            'shots_off_target', NEW.shots_off_target,
            'blocked_shots', NEW.blocked_shots,
            'shots_inside_box', NEW.shots_inside_box,
            'shots_outside_box', NEW.shots_outside_box,
            'passes', NEW.passes,
            'accurate_passes', NEW.accurate_passes,
            'final_third_phase', NEW.final_third_phase,
            'accurate_final_third_phase', NEW.accurate_final_third_phase,
            'long_balls', NEW.long_balls,
            'accurate_long_balls', NEW.accurate_long_balls,
            'crosses', NEW.crosses,
            'accurate_crosses', NEW.accurate_crosses,
            'ground_duels', NEW.ground_duels,
            'ground_duels_won', NEW.ground_duels_won,
            'aerial_duels', NEW.aerial_duels,
            'aerial_duels_won', NEW.aerial_duels_won,
            'dribbles', NEW.dribbles,
            'dribbles_succ', NEW.dribbles_succ
        )
    );
END;

CREATE TRIGGER trg_playeractions_delete
AFTER DELETE ON PlayerActions
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'PlayerActions',
        'DELETE',
        OLD.action_id,
        json_object(
            'action_id', OLD.action_id,
            'match_id', OLD.match_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'action_type', OLD.action_type,
            'action_minute', OLD.action_minute,
            'assist_by', OLD.assist_by,
            'pre_assist_by', OLD.pre_assist_by,
            'action_details', OLD.action_details
        )
    );
END;

CREATE TRIGGER trg_playeractions_insert
AFTER INSERT ON PlayerActions
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'PlayerActions',
        'INSERT',
        NEW.action_id,
        json_object(
            'action_id', NEW.action_id,
            'match_id', NEW.match_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'action_type', NEW.action_type,
            'action_minute', NEW.action_minute,
            'assist_by', NEW.assist_by,
            'pre_assist_by', NEW.pre_assist_by,
            'action_details', NEW.action_details
        )
    );
END;

CREATE TRIGGER trg_playeractions_update
AFTER UPDATE ON PlayerActions
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'PlayerActions',
        'UPDATE',
        NEW.action_id,
        json_object(
            'action_id', OLD.action_id,
            'match_id', OLD.match_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'action_type', OLD.action_type,
            'action_minute', OLD.action_minute,
            'assist_by', OLD.assist_by,
            'pre_assist_by', OLD.pre_assist_by,
            'action_details', OLD.action_details
        ),
        json_object(
            'action_id', NEW.action_id,
            'match_id', NEW.match_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'action_type', NEW.action_type,
            'action_minute', NEW.action_minute,
            'assist_by', NEW.assist_by,
            'pre_assist_by', NEW.pre_assist_by,
            'action_details', NEW.action_details
        )
    );
END;

CREATE TRIGGER trg_players_delete
AFTER DELETE ON Players
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Players',
        'DELETE',
        OLD.player_id,
        json_object(
            'player_id', OLD.player_id,
            'player_number', OLD.player_number,
            'player_name', OLD.player_name,
            'player_dob', OLD.player_dob,
            'player_position', OLD.player_position,
            'player_national', OLD.player_national,
            'city_id', OLD.city_id,
            'school', OLD.school,
            'player_height', OLD.player_height,
            'player_foot', OLD.player_foot,
            'player_value', OLD.player_value
        ),
        NULL
    );
END;

CREATE TRIGGER trg_players_insert
AFTER INSERT ON Players
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Players',
        'INSERT',
        NEW.player_id,
        NULL,
        json_object(
            'player_id', NEW.player_id,
            'player_number', NEW.player_number,
            'player_name', NEW.player_name,
            'player_dob', NEW.player_dob,
            'player_position', NEW.player_position,
            'player_national', NEW.player_national,
            'city_id', NEW.city_id,
            'school', NEW.school,
            'player_height', NEW.player_height,
            'player_foot', NEW.player_foot,
            'player_value', NEW.player_value
        )
    );
END;

CREATE TRIGGER trg_players_update
AFTER UPDATE ON Players
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Players',
        'UPDATE',
        NEW.player_id,
        json_object(
            'player_id', OLD.player_id,
            'player_number', OLD.player_number,
            'player_name', OLD.player_name,
            'player_dob', OLD.player_dob,
            'player_position', OLD.player_position,
            'player_national', OLD.player_national,
            'city_id', OLD.city_id,
            'school', OLD.school,
            'player_height', OLD.player_height,
            'player_foot', OLD.player_foot,
            'player_value', OLD.player_value
        ),
        json_object(
            'player_id', NEW.player_id,
            'player_number', NEW.player_number,
            'player_name', NEW.player_name,
            'player_dob', NEW.player_dob,
            'player_position', NEW.player_position,
            'player_national', NEW.player_national,
            'city_id', NEW.city_id,
            'school', NEW.school,
            'player_height', NEW.player_height,
            'player_foot', NEW.player_foot,
            'player_value', NEW.player_value
        )
    );
END;

CREATE TRIGGER trg_playerstats_delete
AFTER DELETE ON PlayerStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'PlayerStats',
        'DELETE',
        OLD.player_stat_id,
        json_object(
            'player_stat_id', OLD.player_stat_id,
            'match_id', OLD.match_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'minutes_played', OLD.minutes_played,
            'goals', OLD.goals,
            'assists', OLD.assists,
            'yellow_card', OLD.yellow_card,
            'second_yellow_card', OLD.second_yellow_card,
            'red_card', OLD.red_card,
            'xg', OLD.xg,
            'xa', OLD.xa,
            'xGChain', OLD.xGChain,
            'xGBuildup', OLD.xGBuildup,
            'clearances', OLD.clearances,
            'blocked_shots', OLD.blocked_shots,
            'interceptions', OLD.interceptions,
            'total_tackles', OLD.total_tackles,
            'dribbled_past', OLD.dribbled_past,
            'ground_duels', OLD.ground_duels,
            'ground_duels_won', OLD.ground_duels_won,
            'aerial_duels', OLD.aerial_duels,
            'aerial_duels_won', OLD.aerial_duels_won,
            'possession_lost', OLD.possession_lost,
            'fouls', OLD.fouls,
            'was_fouled', OLD.was_fouled,
            'touches', OLD.touches,
            'passes_total', OLD.passes_total,
            'passes_accurate', OLD.passes_accurate,
            'key_passes', OLD.key_passes,
            'crosses_total', OLD.crosses_total,
            'crosses_accurate', OLD.crosses_accurate,
            'long_balls_total', OLD.long_balls_total,
            'long_balls_accurate', OLD.long_balls_accurate,
            'shots_on_target', OLD.shots_on_target,
            'shots_off_target', OLD.shots_off_target,
            'shots_blocked', OLD.shots_blocked,
            'dribble_att', OLD.dribble_att,
            'dribble_succ', OLD.dribble_succ,
            'starting_player', OLD.starting_player,
            'position_on_field', OLD.position_on_field,
            'rating', OLD.rating
        )
    );
END;

CREATE TRIGGER trg_playerstats_insert
AFTER INSERT ON PlayerStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'PlayerStats',
        'INSERT',
        NEW.player_stat_id,
        json_object(
            'player_stat_id', NEW.player_stat_id,
            'match_id', NEW.match_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'minutes_played', NEW.minutes_played,
            'goals', NEW.goals,
            'assists', NEW.assists,
            'yellow_card', NEW.yellow_card,
            'second_yellow_card', NEW.second_yellow_card,
            'red_card', NEW.red_card,
            'xg', NEW.xg,
            'xa', NEW.xa,
            'xGChain', NEW.xGChain,
            'xGBuildup', NEW.xGBuildup,
            'clearances', NEW.clearances,
            'blocked_shots', NEW.blocked_shots,
            'interceptions', NEW.interceptions,
            'total_tackles', NEW.total_tackles,
			'tackles_won', NEW.tackles_won,
            'dribbled_past', NEW.dribbled_past,
            'ground_duels', NEW.ground_duels,
            'ground_duels_won', NEW.ground_duels_won,
            'aerial_duels', NEW.aerial_duels,
            'aerial_duels_won', NEW.aerial_duels_won,
            'possession_lost', NEW.possession_lost,
            'fouls', NEW.fouls,
            'was_fouled', NEW.was_fouled,
            'touches', NEW.touches,
			'touches_unsuc', NEW.touches_unsuc,
            'passes_total', NEW.passes_total,
            'passes_accurate', NEW.passes_accurate,
			'passes_in_opp_total', NEW.passes_in_opp_total,
			'passes_in_opp_accurate', NEW.passes_in_opp_accurate,
			'passes_in_own_total', NEW.passes_in_own_total,
			'passes_in_own_accurate', NEW.passes_in_own_accurate,
            'key_passes', NEW.key_passes,
            'crosses_total', NEW.crosses_total,
            'crosses_accurate', NEW.crosses_accurate,
            'long_balls_total', NEW.long_balls_total,
            'long_balls_accurate', NEW.long_balls_accurate,
            'shots_on_target', NEW.shots_on_target,
            'shots_off_target', NEW.shots_off_target,
            'shots_blocked', NEW.shots_blocked,
            'dribble_att', NEW.dribble_att,
            'dribble_succ', NEW.dribble_succ,
            'starting_player', NEW.starting_player,
            'position_on_field', NEW.position_on_field,
            'rating', NEW.rating,
			'distance_covered', NEW.distance_covered,
			'top_speed', NEW.top_speed,
			'number_of_sprints', NEW.number_of_sprints,
			'running', NEW.running,
			'high_speed_running', NEW.high_speed_running,
			'sprinting', NEW.sprinting,
			'total_carrying_distance', NEW.total_carrying_distance,
			'carries', NEW.carries,
			'progressive_carries', NEW.progressive_carries,
			'total_progression', NEW.total_progression,
			'progressive_carrying_distance', NEW.progressive_carrying_distance,
			'longest_progressive_carry', NEW.longest_progressive_carry
			
        )
    );
END;

CREATE TRIGGER trg_playerstats_update
AFTER UPDATE ON PlayerStats
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'PlayerStats',
        'UPDATE',
        NEW.player_stat_id,
        json_object(
            'player_stat_id', OLD.player_stat_id,
            'match_id', OLD.match_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'minutes_played', OLD.minutes_played,
            'goals', OLD.goals,
            'assists', OLD.assists,
            'yellow_card', OLD.yellow_card,
            'second_yellow_card', OLD.second_yellow_card,
            'red_card', OLD.red_card,
            'xg', OLD.xg,
            'xa', OLD.xa,
            'xGChain', OLD.xGChain,
            'xGBuildup', OLD.xGBuildup,
            'clearances', OLD.clearances,
            'blocked_shots', OLD.blocked_shots,
            'interceptions', OLD.interceptions,
            'total_tackles', OLD.total_tackles,
			'tackles_won', OLD.tackles_won,
            'dribbled_past', OLD.dribbled_past,
            'ground_duels', OLD.ground_duels,
            'ground_duels_won', OLD.ground_duels_won,
            'aerial_duels', OLD.aerial_duels,
            'aerial_duels_won', OLD.aerial_duels_won,
            'possession_lost', OLD.possession_lost,
            'fouls', OLD.fouls,
            'was_fouled', OLD.was_fouled,
            'touches', OLD.touches,
			'touches_unsuc', OLD.touches_unsuc,
            'passes_total', OLD.passes_total,
            'passes_accurate', OLD.passes_accurate,
			'passes_in_opp_total', OLD.passes_in_opp_total,
			'passes_in_opp_accurate', OLD.passes_in_opp_accurate,
			'passes_in_own_total', OLD.passes_in_own_total,
			'passes_in_own_accurate', OLD.passes_in_own_accurate,
            'key_passes', OLD.key_passes,
            'crosses_total', OLD.crosses_total,
            'crosses_accurate', OLD.crosses_accurate,
            'long_balls_total', OLD.long_balls_total,
            'long_balls_accurate', OLD.long_balls_accurate,
            'shots_on_target', OLD.shots_on_target,
            'shots_off_target', OLD.shots_off_target,
            'shots_blocked', OLD.shots_blocked,
            'dribble_att', OLD.dribble_att,
            'dribble_succ', OLD.dribble_succ,
            'starting_player', OLD.starting_player,
            'position_on_field', OLD.position_on_field,
            'rating', OLD.rating,
			'distance_covered', OLD.distance_covered,
			'top_speed', OLD.top_speed,
			'number_of_sprints', OLD.number_of_sprints,
			'running', OLD.running,
			'high_speed_running', OLD.high_speed_running,
			'sprinting', OLD.sprinting,
			'total_carrying_distance', OLD.total_carrying_distance,
			'carries', OLD.carries,
			'progressive_carries', OLD.progressive_carries,
			'total_progression', OLD.total_progression,
			'progressive_carrying_distance', OLD.progressive_carrying_distance,
			'longest_progressive_carry', OLD.longest_progressive_carry
        ),
        json_object(
            'player_stat_id', NEW.player_stat_id,
            'match_id', NEW.match_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'minutes_played', NEW.minutes_played,
            'goals', NEW.goals,
            'assists', NEW.assists,
            'yellow_card', NEW.yellow_card,
            'second_yellow_card', NEW.second_yellow_card,
            'red_card', NEW.red_card,
            'xg', NEW.xg,
            'xa', NEW.xa,
            'xGChain', NEW.xGChain,
            'xGBuildup', NEW.xGBuildup,
            'clearances', NEW.clearances,
            'blocked_shots', NEW.blocked_shots,
            'interceptions', NEW.interceptions,
            'total_tackles', NEW.total_tackles,
			'tackles_won', NEW.tackles_won,
            'dribbled_past', NEW.dribbled_past,
            'ground_duels', NEW.ground_duels,
            'ground_duels_won', NEW.ground_duels_won,
            'aerial_duels', NEW.aerial_duels,
            'aerial_duels_won', NEW.aerial_duels_won,
            'possession_lost', NEW.possession_lost,
            'fouls', NEW.fouls,
            'was_fouled', NEW.was_fouled,
            'touches', NEW.touches,
			'touches_unsuc', NEW.touches_unsuc,
            'passes_total', NEW.passes_total,
            'passes_accurate', NEW.passes_accurate,
			'passes_in_opp_total', NEW.passes_in_opp_total,
			'passes_in_opp_accurate', NEW.passes_in_opp_accurate,
			'passes_in_own_total', NEW.passes_in_own_total,
			'passes_in_own_accurate', NEW.passes_in_own_accurate,
            'key_passes', NEW.key_passes,
            'crosses_total', NEW.crosses_total,
            'crosses_accurate', NEW.crosses_accurate,
            'long_balls_total', NEW.long_balls_total,
            'long_balls_accurate', NEW.long_balls_accurate,
            'shots_on_target', NEW.shots_on_target,
            'shots_off_target', NEW.shots_off_target,
            'shots_blocked', NEW.shots_blocked,
            'dribble_att', NEW.dribble_att,
            'dribble_succ', NEW.dribble_succ,
            'starting_player', NEW.starting_player,
            'position_on_field', NEW.position_on_field,
            'rating', NEW.rating,
			'distance_covered', NEW.distance_covered,
			'top_speed', NEW.top_speed,
			'number_of_sprints', NEW.number_of_sprints,
			'running', NEW.running,
			'high_speed_running', NEW.high_speed_running,
			'sprinting', NEW.sprinting,
			'total_carrying_distance', NEW.total_carrying_distance,
			'carries', NEW.carries,
			'progressive_carries', NEW.progressive_carries,
			'total_progression', NEW.total_progression,
			'progressive_carrying_distance', NEW.progressive_carrying_distance,
			'longest_progressive_carry', NEW.longest_progressive_carry
        )
    );
END;

CREATE TRIGGER trg_playerteams_delete
AFTER DELETE ON PlayerTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES (
        'PlayerTeams',
        'DELETE',
        OLD.player_team_id,
        json_object(
            'player_team_id', OLD.player_team_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'contract_start', OLD.contract_start,
			'transfer_type_in', OLD.transfer_type_in,
			'fee_in', OLD.fee_in,
            'contract_end', OLD.contract_end,
			'transfer_type_out', OLD.transfer_type_out,
			'fee_out', OLD.fee_out
        )
    );
END;

CREATE TRIGGER trg_playerteams_insert
AFTER INSERT ON PlayerTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES (
        'PlayerTeams',
        'INSERT',
        NEW.player_team_id,
        json_object(
            'player_team_id', NEW.player_team_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'contract_start', NEW.contract_start,
			'transfer_type_in', NEW.transfer_type_in,
			'fee_in', NEW.fee_in,
            'contract_end', NEW.contract_end,
			'transfer_type_out', NEW.transfer_type_out,
			'fee_out', NEW.fee_out
        )
    );
END;

CREATE TRIGGER trg_playerteams_no_overlap
BEFORE INSERT ON PlayerTeams
FOR EACH ROW
BEGIN
  SELECT
    CASE
      WHEN EXISTS (
        SELECT 1 FROM PlayerTeams
        WHERE player_id = NEW.player_id
          AND team_id = NEW.team_id
          AND NOT (
            NEW.contract_end < contract_start OR NEW.contract_start > contract_end
          )
      )
      THEN RAISE(ABORT, 'Период контракта совпадает с существующим контрактом для этого игрока и команды')
    END;
END;

CREATE TRIGGER trg_playerteams_no_overlap_update
BEFORE UPDATE ON PlayerTeams
FOR EACH ROW
BEGIN
  SELECT
    CASE
      WHEN EXISTS (
        SELECT 1 FROM PlayerTeams
        WHERE player_id = NEW.player_id
          AND team_id = NEW.team_id
          AND rowid != OLD.rowid
          AND NOT (
            NEW.contract_end < contract_start OR NEW.contract_start > contract_end
          )
      )
      THEN RAISE(ABORT, 'Период контракта совпадает с существующим контрактом для этого игрока и команды')
    END;
END;

CREATE TRIGGER trg_playerteams_update
AFTER UPDATE ON PlayerTeams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'PlayerTeams',
        'UPDATE',
        NEW.player_team_id, -- Используем NEW, так как player_team_id, как правило, не меняется при обновлении
        json_object(
            'player_team_id', OLD.player_team_id,
            'player_id', OLD.player_id,
            'team_id', OLD.team_id,
            'contract_start', OLD.contract_start,
			'transfer_type_in', OLD.transfer_type_in,
			'fee_in', OLD.fee_in,
            'contract_end', OLD.contract_end,
			'transfer_type_out', OLD.transfer_type_out,
			'fee_out', OLD.fee_out
        ),
        json_object(
            'player_team_id', NEW.player_team_id,
            'player_id', NEW.player_id,
            'team_id', NEW.team_id,
            'contract_start', NEW.contract_start,
			'transfer_type_in', NEW.transfer_type_in,
			'fee_in', NEW.fee_in,
            'contract_end', NEW.contract_end,
			'transfer_type_out', NEW.transfer_type_out,
			'fee_out', NEW.fee_out
        )
    );
END;

CREATE TRIGGER trg_teams_delete
AFTER DELETE ON Teams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Teams',
        'DELETE',
        OLD.team_id,
        json_object(
            'team_id', OLD.team_id,
            'team_name', OLD.team_name,
            'team_city', OLD."city_id",
            'team_coach', OLD."team_president",
            'team_foundation_year', OLD.team_foundation_year
        ),
        NULL
    );
END;

CREATE TRIGGER trg_teams_insert
AFTER INSERT ON Teams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Teams',
        'INSERT',
        NEW.team_id,
        NULL,
        json_object(
            'team_id', NEW.team_id,
            'team_name', NEW.team_name,
            'team_city', NEW."city_id",
            'team_coach', NEW."team_president",
            'team_foundation_year', NEW.team_foundation_year
        )
    );
END;

CREATE TRIGGER trg_teams_update
AFTER UPDATE ON Teams
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES (
        'Teams',
        'UPDATE',
        NEW.team_id,
        json_object(
            'team_id', OLD.team_id,
            'team_name', OLD.team_name,
            'team_city', OLD."city_id",
            'team_coach', OLD."team_president",
            'team_foundation_year', OLD.team_foundation_year
        ),
        json_object(
            'team_id', NEW.team_id,
            'team_name', NEW.team_name,
            'team_city', NEW."city_id",
            'team_coach', NEW."team_president",
            'team_foundation_year', NEW.team_foundation_year
        )
    );
END;

CREATE TRIGGER trg_xglab_delete
AFTER DELETE ON xGLab
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values)
    VALUES ('xGLab', 'DELETE', OLD.xglab_id, json_object(
        'xglab_id', OLD.xglab_id,
        'player_stat_id', OLD.player_stat_id,
        'epv_carry_n', OLD.epv_carry_n,
        'epv_carry_p', OLD.epv_carry_p,
        'epv_open_play_acc_n', OLD.epv_open_play_acc_n,
        'epv_open_play_acc_p', OLD.epv_open_play_acc_p,
        'epv_open_play_inacc_intercept', OLD.epv_open_play_inacc_intercept,
        'epv_open_play_inacc_offside', OLD.epv_open_play_inacc_offside,
        'epv_open_play_inacc_out', OLD.epv_open_play_inacc_out,
        'epv_set_piece_corner_acc_n', OLD.epv_set_piece_corner_acc_n,
        'epv_set_piece_corner_acc_p', OLD.epv_set_piece_corner_acc_p,
        'epv_set_piece_corner_inacc', OLD.epv_set_piece_corner_inacc,
        'epv_set_piece_freekick_acc_n', OLD.epv_set_piece_freekick_acc_n,
        'epv_set_piece_freekick_acc_p', OLD.epv_set_piece_freekick_acc_p,
        'epv_set_piece_freekick_inacc', OLD.epv_set_piece_freekick_inacc,
        'epv_set_piece_throw_acc_n', OLD.epv_set_piece_throw_acc_n,
        'epv_set_piece_throw_acc_p', OLD.epv_set_piece_throw_acc_p,
        'epv_set_piece_throw_inacc', OLD.epv_set_piece_throw_inacc
    ));
END;

CREATE TRIGGER trg_xglab_insert
AFTER INSERT ON xGLab
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, new_values)
    VALUES ('xGLab', 'INSERT', NEW.xglab_id, json_object(
        'xglab_id', NEW.xglab_id,
        'player_stat_id', NEW.player_stat_id,
        'epv_carry_n', NEW.epv_carry_n,
        'epv_carry_p', NEW.epv_carry_p,
        'epv_open_play_acc_n', NEW.epv_open_play_acc_n,
        'epv_open_play_acc_p', NEW.epv_open_play_acc_p,
        'epv_open_play_inacc_intercept', NEW.epv_open_play_inacc_intercept,
        'epv_open_play_inacc_offside', NEW.epv_open_play_inacc_offside,
        'epv_open_play_inacc_out', NEW.epv_open_play_inacc_out,
        'epv_set_piece_corner_acc_n', NEW.epv_set_piece_corner_acc_n,
        'epv_set_piece_corner_acc_p', NEW.epv_set_piece_corner_acc_p,
        'epv_set_piece_corner_inacc', NEW.epv_set_piece_corner_inacc,
        'epv_set_piece_freekick_acc_n', NEW.epv_set_piece_freekick_acc_n,
        'epv_set_piece_freekick_acc_p', NEW.epv_set_piece_freekick_acc_p,
        'epv_set_piece_freekick_inacc', NEW.epv_set_piece_freekick_inacc,
        'epv_set_piece_throw_acc_n', NEW.epv_set_piece_throw_acc_n,
        'epv_set_piece_throw_acc_p', NEW.epv_set_piece_throw_acc_p,
        'epv_set_piece_throw_inacc', NEW.epv_set_piece_throw_inacc
    ));
END;

CREATE TRIGGER trg_xglab_update
AFTER UPDATE ON xGLab
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_values, new_values)
    VALUES ('xGLab', 'UPDATE', NEW.xglab_id,
        json_object( -- old_values
            'xglab_id', OLD.xglab_id,
            'player_stat_id', OLD.player_stat_id,           
            'epv_carry_n', OLD.epv_carry_n,
            'epv_carry_p', OLD.epv_carry_p,
            'epv_open_play_acc_n', OLD.epv_open_play_acc_n,
            'epv_open_play_acc_p', OLD.epv_open_play_acc_p,
            'epv_open_play_inacc_intercept', OLD.epv_open_play_inacc_intercept,
            'epv_open_play_inacc_offside', OLD.epv_open_play_inacc_offside,
            'epv_open_play_inacc_out', OLD.epv_open_play_inacc_out,
            'epv_set_piece_corner_acc_n', OLD.epv_set_piece_corner_acc_n,
            'epv_set_piece_corner_acc_p', OLD.epv_set_piece_corner_acc_p,
            'epv_set_piece_corner_inacc', OLD.epv_set_piece_corner_inacc,
            'epv_set_piece_freekick_acc_n', OLD.epv_set_piece_freekick_acc_n,
            'epv_set_piece_freekick_acc_p', OLD.epv_set_piece_freekick_acc_p,
            'epv_set_piece_freekick_inacc', OLD.epv_set_piece_freekick_inacc,
            'epv_set_piece_throw_acc_n', OLD.epv_set_piece_throw_acc_n,
            'epv_set_piece_throw_acc_p', OLD.epv_set_piece_throw_acc_p,
            'epv_set_piece_throw_inacc', OLD.epv_set_piece_throw_inacc
        ),
        json_object( -- new_values
            'xglab_id', NEW.xglab_id,
            'player_stat_id', NEW.player_stat_id,         
            'epv_carry_n', NEW.epv_carry_n,
            'epv_carry_p', NEW.epv_carry_p,
            'epv_open_play_acc_n', NEW.epv_open_play_acc_n,
            'epv_open_play_acc_p', NEW.epv_open_play_acc_p,
            'epv_open_play_inacc_intercept', NEW.epv_open_play_inacc_intercept,
            'epv_open_play_inacc_offside', NEW.epv_open_play_inacc_offside,
            'epv_open_play_inacc_out', NEW.epv_open_play_inacc_out,
            'epv_set_piece_corner_acc_n', NEW.epv_set_piece_corner_acc_n,
            'epv_set_piece_corner_acc_p', NEW.epv_set_piece_corner_acc_p,
            'epv_set_piece_corner_inacc', NEW.epv_set_piece_corner_inacc,
            'epv_set_piece_freekick_acc_n', NEW.epv_set_piece_freekick_acc_n,
            'epv_set_piece_freekick_acc_p', NEW.epv_set_piece_freekick_acc_p,
            'epv_set_piece_freekick_inacc', NEW.epv_set_piece_freekick_inacc,
            'epv_set_piece_throw_acc_n', NEW.epv_set_piece_throw_acc_n,
            'epv_set_piece_throw_acc_p', NEW.epv_set_piece_throw_acc_p,
            'epv_set_piece_throw_inacc', NEW.epv_set_piece_throw_inacc
        )
    );
END;

