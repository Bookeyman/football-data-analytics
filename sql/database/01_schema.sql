-- TABLE DEFINITIONS
-- Extracted from the supplied rpl.db database.
-- DDL only: no personal/raw match data is included.

CREATE TABLE "Cities" (
	"city_id"	INTEGER NOT NULL UNIQUE,
	"city_name"	TEXT NOT NULL UNIQUE,
	"region_name"	TEXT,
	"country_name"	TEXT,
	"population"	INTEGER,
	"area"	INTEGER,
	"founded"	INTEGER,
	"capital"	BOOLEAN,
	PRIMARY KEY("city_id" AUTOINCREMENT)
);

CREATE TABLE CoachTeams (
    coach_team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    coach_id INTEGER,
    team_id INTEGER,
    contract_start DATE,
    contract_end DATE,
    FOREIGN KEY(coach_id) REFERENCES Coaches(coach_id),
    FOREIGN KEY(team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Coaches (
    coach_id INTEGER PRIMARY KEY AUTOINCREMENT,
    coach_name TEXT UNIQUE,
    coach_dob DATE,
    coach_national TEXT,
    city_id INTEGER,
    FOREIGN KEY(city_id) REFERENCES Cities(city_id)
);

CREATE TABLE "GoalkeeperStats" (
	"goalkeeper_stat_id"	INTEGER,
	"player_stat_id"	INTEGER,
	"saves"	INTEGER,
	"punches"	INTEGER,
	"runs_out"	INTEGER,
	"runs_out_succ"	INTEGER,
	"high_claims"	INTEGER,
	"saves_f_inside_box"	INTEGER,
	"errors_lead_to_shot"	INTEGER,
	"errors_lead_to_goal"	INTEGER,
	"penalties_saved"	INTEGER,
	"penalties_missed"	INTEGER,
	"penalties_total"	INTEGER,
	PRIMARY KEY("goalkeeper_stat_id"),
	FOREIGN KEY("player_stat_id") REFERENCES "PlayerStats"("player_stat_id")
);

CREATE TABLE "MatchStats" (
	"match_stats_id"	INTEGER,
	"match_id"	INTEGER,
	"team_id"	INTEGER,
	"goals"	INTEGER,
	"xg"	REAL,
	"ppda"	INTEGER,
	"deep"	INTEGER,
	"corners"	INTEGER,
	"yellow_cards"	INTEGER,
	"red_cards"	INTEGER,
	"offsides"	INTEGER,
	"fouls"	INTEGER,
	"saves"	INTEGER,
	"possession"	INTEGER,
	"shots"	INTEGER,
	"shots_on_target"	INTEGER,
	"hit_woodwork"	INTEGER,
	"shots_off_target"	INTEGER,
	"blocked_shots"	INTEGER,
	"shots_inside_box"	INTEGER,
	"shots_outside_box"	INTEGER,
	"passes"	INTEGER,
	"accurate_passes"	INTEGER,
	"final_third_phase"	INTEGER,
	"accurate_final_third_phase"	INTEGER,
	"long_balls"	INTEGER,
	"accurate_long_balls"	INTEGER,
	"crosses"	INTEGER,
	"accurate_crosses"	INTEGER,
	"ground_duels"	INTEGER,
	"ground_duels_won"	INTEGER,
	"aerial_duels"	INTEGER,
	"aerial_duels_won"	INTEGER,
	"dribbles"	INTEGER,
	"dribbles_succ"	INTEGER,
	"throw_ins"	INTEGER,
	"through_balls"	INTEGER,
	"distance_covered"	REAL,
	"number_of_sprints"	INTEGER,
	"touches_in_opp_box"	INTEGER,
	"final_third_entries"	INTEGER,
	"fouled_in_final_third"	INTEGER,
	PRIMARY KEY("match_stats_id" AUTOINCREMENT),
	FOREIGN KEY("match_id") REFERENCES "Matches"("match_id"),
	FOREIGN KEY("team_id") REFERENCES "Teams"("team_id")
);

CREATE TABLE "Matches" (
	"match_id"	INTEGER,
	"team1_id"	INTEGER,
	"team2_id"	INTEGER,
	"match_name"	TEXT,
	"match_date"	DATE,
	"match_time"	TIME,
	"season"	INTEGER,
	"referee_id"	TEXT,
	"stadium_id"	INTEGER,
	"match_attendance"	INTEGER,
	"match_round"	INTEGER,
	"temperature"	INTEGER,
	"wind_speed"	REAL,
	"air_humidity"	INTEGER,
	PRIMARY KEY("match_id" AUTOINCREMENT),
	FOREIGN KEY("referee_id") REFERENCES "Referees"("referee_id"),
	FOREIGN KEY("stadium_id") REFERENCES "Stadiums"("stadium_id"),
	FOREIGN KEY("team1_id") REFERENCES "Teams"("team_id"),
	FOREIGN KEY("team2_id") REFERENCES "Teams"("team_id")
);

CREATE TABLE "PlayerActions" (
    "action_id" INTEGER,
    "match_id" INTEGER,
    "player_id" INTEGER,
    "team_id" INTEGER,
    "action_type" TEXT,
    "action_minute" INTEGER,
    "assist_by" INTEGER,
    "pre_assist_by" INTEGER,
    "action_details" TEXT,
    PRIMARY KEY("action_id" AUTOINCREMENT),
    FOREIGN KEY("assist_by") REFERENCES "Players"("player_id"),
    FOREIGN KEY("pre_assist_by") REFERENCES "Players"("player_id"),
    FOREIGN KEY("match_id") REFERENCES "Matches"("match_id"),
    FOREIGN KEY("player_id") REFERENCES "Players"("player_id"),
    FOREIGN KEY("team_id") REFERENCES "Teams"("team_id")
);

CREATE TABLE "PlayerStats" (
	"player_stat_id"	INTEGER,
	"match_id"	INTEGER,
	"player_id"	INTEGER,
	"team_id"	INTEGER,
	"minutes_played"	INTEGER,
	"goals"	INTEGER,
	"assists"	INTEGER,
	"yellow_card"	BOOLEAN,
	"second_yellow_card"	BOOLEAN,
	"red_card"	BOOLEAN,
	"xg"	INTEGER,
	"xa"	INTEGER,
	"xGChain"	INTEGER,
	"xGBuildup"	INTEGER,
	"clearances"	INTEGER,
	"recovery"	INTEGER,
	"blocked_shots"	INTEGER,
	"interceptions"	INTEGER,
	"total_tackles"	INTEGER,
	"tackles_won"	INTEGER,
	"dribbled_past"	INTEGER,
	"ground_duels"	INTEGER,
	"ground_duels_won"	INTEGER,
	"aerial_duels"	INTEGER,
	"aerial_duels_won"	INTEGER,
	"possession_lost"	INTEGER,
	"fouls"	INTEGER,
	"was_fouled"	INTEGER,
	"touches"	INTEGER,
	"touches_unsuc"	INTEGER,
	"passes_total"	INTEGER,
	"passes_accurate"	INTEGER,
	"passes_in_opp_total"	INTEGER,
	"passes_in_opp_accurate"	INTEGER,
	"passes_in_own_total"	INTEGER,
	"passes_in_own_accurate"	INTEGER,
	"key_passes"	INTEGER,
	"crosses_total"	INTEGER,
	"crosses_accurate"	INTEGER,
	"long_balls_total"	INTEGER,
	"long_balls_accurate"	INTEGER,
	"shots_on_target"	INTEGER,
	"shots_off_target"	INTEGER,
	"shots_blocked"	INTEGER,
	"dribble_att"	INTEGER,
	"dribble_succ"	INTEGER,
	"starting_player"	INTEGER,
	"position_on_field"	TEXT,
	"rating"	REAL,
	"big_chances_created"	INTEGER,
	"big_chances_missed"	INTEGER,
	"offsides"	INTEGER,
	"hit_woodwork"	INTEGER,
	"clearance_off_line"	INTEGER,
	"own_goals"	INTEGER,
	"errors_lead_to_shot"	INTEGER,
	"errors_lead_to_goal"	INTEGER,
	"penalty_won"	INTEGER,
	"penalty_committed"	INTEGER,
	"penalty_realized"	INTEGER,
	"penalty_unrealized"	INTEGER,
	"distance_covered"	REAL,
	"top_speed"	REAL,
	"number_of_sprints"	INTEGER,
	"running"	REAL,
	"high_speed_running"	REAL,
	"sprinting"	REAL,
	"total_carrying_distance"	REAL,
	"carries"	INTEGER,
	"progressive_carries"	INTEGER,
	"total_progression"	REAL,
	"progressive_carrying_distance"	REAL,
	"longest_progressive_carry"	REAL,
	PRIMARY KEY("player_stat_id" AUTOINCREMENT),
	FOREIGN KEY("match_id") REFERENCES "Matches"("match_id"),
	FOREIGN KEY("player_id") REFERENCES "Players"("player_id"),
	FOREIGN KEY("team_id") REFERENCES "Teams"("team_id"),
	CHECK("minutes_played" < 120)
);

CREATE TABLE "PlayerTeams" (
	"player_team_id"	INTEGER,
	"player_id"	INTEGER,
	"team_id"	INTEGER,
	"contract_start"	DATE,
	"transfer_type_in"	TEXT,
	"fee_in"	REAL,
	"contract_end"	DATE,
	"transfer_type_out"	TEXT,
	"fee_out"	REAL,
	PRIMARY KEY("player_team_id" AUTOINCREMENT),
	FOREIGN KEY("player_id") REFERENCES "Players"("player_id"),
	FOREIGN KEY("team_id") REFERENCES "Teams"("team_id")
);

CREATE TABLE "Players" (
	"player_id"	INTEGER,
	"player_number"	INTEGER,
	"player_name"	TEXT UNIQUE,
	"player_dob"	DATE,
	"player_position"	TEXT,
	"player_national"	TEXT,
	"city_id"	INTEGER,
	"school"	TEXT,
	"player_height"	INTEGER,
	"player_foot"	TEXT,
	"player_value"	REAL, 'sofascore_name' TEXT, 'xglab_name' TEXT,
	PRIMARY KEY("player_id" AUTOINCREMENT),
	FOREIGN KEY("city_id") REFERENCES "Cities"("city_id")
);

CREATE TABLE "Referees" (
	"referee_id"	INTEGER,
	"referee_name"	TEXT UNIQUE,
	"referee_dob"	DATE,
	"city_id"	INTEGER,
	"referee_debut"	DATE,
	PRIMARY KEY("referee_id" AUTOINCREMENT),
	FOREIGN KEY("city_id") REFERENCES "Cities"("city_id")
);

CREATE TABLE "Stadiums" (
	"stadium_id"	INTEGER,
	"stadium_name"	TEXT UNIQUE,
	"city_id" INTEGER,
	"capacity"  INTEGER,
	"built"  INTEGER,
	"undersoil_heating" BOOLEAN,
	"running_track" BOOLEAN,
	"surface"	TEXT,
	"pitch_size"	TEXT,
	"address"	TEXT, latitude DOUBLE, longitude DOUBLE,
	PRIMARY KEY("stadium_id" AUTOINCREMENT),
	FOREIGN KEY("city_id") REFERENCES "Cities"("city_id")
);

CREATE TABLE "Standings" (
    "standing_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "season" INTEGER NOT NULL, 
    "team_id" INTEGER NOT NULL,
    "place" INTEGER ,
    FOREIGN KEY ("team_id") REFERENCES "Teams"("team_id")
);

CREATE TABLE "Teams" (
	"team_id"	INTEGER,
	"team_name"	TEXT,
	"team_president"	TEXT,
	"team_foundation_year"	INTEGER,
	"city_id"	INTEGER,
	"league_level"	INTEGER, pop_tg INTEGER, pop_yt INTEGER, pop_ig INTEGER,
	PRIMARY KEY("team_id" AUTOINCREMENT),
	FOREIGN KEY("city_id") REFERENCES "Cities"("city_id")
);

CREATE TABLE audit_log (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    row_id INTEGER, -- ID изменённой записи
    old_values TEXT, -- JSON с предыдущими значениями (при UPDATE и DELETE)
    new_values TEXT  -- JSON с новыми значениями (при INSERT и UPDATE)
);

CREATE TABLE "xGLab" (
	"xglab_id"	INTEGER,
	"player_stat_id"	INTEGER,
	"epv_carry_n"	REAL,
	"epv_carry_p"	REAL,
	"epv_open_play_acc_n"	REAL,
	"epv_open_play_acc_p"	REAL,
	"epv_open_play_inacc_intercept"	REAL,
	"epv_open_play_inacc_offside"	REAL,
	"epv_open_play_inacc_out"	REAL,
	"epv_set_piece_corner_acc_n"	REAL,
	"epv_set_piece_corner_acc_p"	REAL,
	"epv_set_piece_corner_inacc"	REAL,
	"epv_set_piece_freekick_acc_n"	REAL,
	"epv_set_piece_freekick_acc_p"	REAL,
	"epv_set_piece_freekick_inacc"	REAL,
	"epv_set_piece_throw_acc_n"	REAL,
	"epv_set_piece_throw_acc_p"	REAL,
	"epv_set_piece_throw_inacc"	REAL,
	PRIMARY KEY("xglab_id"),
	FOREIGN KEY("player_stat_id") REFERENCES "PlayerStats"("player_stat_id")
);

