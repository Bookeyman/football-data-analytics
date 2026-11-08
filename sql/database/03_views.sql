-- VIEW DEFINITIONS
-- Extracted from the supplied rpl.db database.
-- DDL only: no personal/raw match data is included.

CREATE VIEW V_AVG AS
WITH Seas AS(
SELECT max(season) s FROM Matches),
 EligiblePlayers AS (
    -- ЭТАП 1: Находим игроков с >500 минутами и СЧИТАЕМ ПРАВИЛЬНЫЙ средний рейтинг
    -- Группируем по игроку, чтобы получить данные за все его матчи
    SELECT
        ps.player_id,
        p.player_name, 
  		p.player_dob,
        count(*) AS matches,
        SUM(ps.minutes_played) AS minutes,
        AVG(ps.rating) AS final_avg_rating, -- Средний рейтинг за ВСЕ матчи игрока
  		SUM(ps.goals) AS goals,
  		SUM(ps.assists) assists,
   		AVG(ps.shots_on_target)+AVG(ps.shots_off_target)+AVG(ps.shots_blocked) shots,
     	AVG(ps.shots_on_target) on_target,
 		AVG(ps.dribble_succ) dribbles,
		SUM(dribble_succ) * 1.0 / SUM(dribble_att) * 100 pr_drib,
    	AVG(ps.passes_accurate) passes_acc,
		SUM(passes_accurate) * 1.0 / SUM(passes_total) * 100 pr_passes,
      	AVG(ps.crosses_accurate) crosses_acc,
  		AVG(ps.key_passes) key_passes,
  		AVG(ps.clearances) clearances,
   		AVG(ps.total_tackles) tackles,
  		AVG(ps.interceptions) interceptions,
  		AVG(ps.ground_duels_won) ground,
  		SUM(ground_duels_won) * 1.0 / SUM(ground_duels) * 100 pr_ground,
    	AVG(ps.aerial_duels_won) aerial,
  		SUM(aerial_duels_won) * 1.0 / SUM(aerial_duels) * 100 pr_aerial,
		COUNT(*) OVER() cnt
    FROM PlayerStats ps
    JOIN Players p ON ps.player_id = p.player_id
    JOIN Teams t ON ps.team_id = t.team_id
    JOIN Matches m ON ps.match_id = m.match_id
    WHERE m.season = (SELECT s FROM Seas)
    GROUP BY ps.player_id, p.player_name, p.player_dob
    HAVING SUM(ps.minutes_played) > (SELECT max(match_round)*35 FROM PlayerStats NATURAL join Matches where season = (SELECT s FROM Seas))
),
PositionStats AS (
    -- ЭТАП 2: Считаем количество игр на КАЖДОЙ позиции для КАЖДОГО игрока
    -- Это отдельный расчет, чтобы избежать ошибки с COUNT()
    SELECT
        ps.player_id,
        ps.position_on_field,
        COUNT(*) AS games_on_position
    FROM PlayerStats ps
    JOIN Matches m ON ps.match_id = m.match_id
    WHERE m.season =  (SELECT s FROM Seas)
    GROUP BY ps.player_id, ps.position_on_field -- Группируем по игроку И позиции!
)
-- ЭТАП 3: Финальная сборка, фильтрация и вывод
SELECT
	RANK() over(order by final_avg_rating desc) '#',
    ep.player_name,
    player_dob,
	(SELECT GROUP_CONCAT(position_data, ', ') FROM (
    SELECT ps_inner.position_on_field || ' (' || ps_inner.games_on_position || ')' AS position_data
    FROM PositionStats ps_inner
    WHERE ps_inner.player_id = ep.player_id
      AND ps_inner.games_on_position > (SELECT max(match_round)/7 FROM PlayerStats NATURAL join Matches where season =(SELECT s FROM Seas))
    ORDER BY ps_inner.games_on_position DESC
)) AS popular_positions,
    matches,
    minutes,
    goals,
    assists,
    goals+assists 'g+a',
    ROUND(ep.final_avg_rating, 2) AS avg_rating, -- Берем рейтинг из ЭТАПА 1
    ROUND(shots, 1) || case when (RANK() over(order by shots desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by shots desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by shots desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by shots desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS shots,
    ROUND(on_target, 1) || case when (RANK() over(order by on_target desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by on_target desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by on_target desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by on_target desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS on_target,
    ROUND(key_passes, 1) || case when (RANK() over(order by key_passes desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by key_passes desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by key_passes desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by key_passes desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS key_passes,
     ROUND(passes_acc, 1) || case when (RANK() over(order by passes_acc desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by passes_acc desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by passes_acc desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by passes_acc desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS passes_acc,  
     ROUND(pr_passes, 1) || case when (RANK() over(order by pr_passes desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by pr_passes desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by pr_passes desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by pr_passes desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS pr_passes,  
    ROUND(crosses_acc, 1) || case when (RANK() over(order by crosses_acc desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by crosses_acc desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by crosses_acc desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by crosses_acc desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS crosses_acc,
    ROUND(dribbles, 1) || case when (RANK() over(order by dribbles desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by dribbles desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by dribbles desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by dribbles desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS dribbles,
    ROUND(pr_drib, 1) || case when (RANK() over(order by pr_drib desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by pr_drib desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by pr_drib desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by pr_drib desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS pr_drib,
    ROUND(ground, 1) || case when (RANK() over(order by ground desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by ground desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by ground desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by ground desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS ground,
    ROUND(pr_ground, 1) || case when (RANK() over(order by pr_ground desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by pr_ground desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by pr_ground desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by pr_ground desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS pr_ground,
    ROUND(aerial, 1) || case when (RANK() over(order by aerial desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by aerial desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by aerial desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by aerial desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS aerial,
    ROUND(pr_aerial, 1) || case when (RANK() over(order by pr_aerial desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by pr_aerial desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by pr_aerial desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by pr_aerial desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS pr_aerial,
    ROUND(tackles, 1) || case when (RANK() over(order by tackles desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by tackles desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by tackles desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by tackles desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS tackles,
    ROUND(interceptions, 1) || case when (RANK() over(order by interceptions desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by interceptions desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by interceptions desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by interceptions desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS interceptions,
    ROUND(clearances, 1) || case when (RANK() over(order by clearances desc) * 100.0 / cnt) < 5 then '(S)'
					 when (RANK() over(order by clearances desc) * 100.0 / cnt) between 5 and 10 then '(A)'
					 when (RANK() over(order by clearances desc) * 100.0 / cnt) between 10 and 35 then '(B)'
					 when (RANK() over(order by clearances desc) * 100.0 / cnt) between 35 and 66 then '(C)'
					 else '(D)'
					 end AS clearances
FROM EligiblePlayers ep -- Работаем только с игроками из ЭТАПА 1
-- Соединяем с данными о позициях из ЭТАПА 2
JOIN PositionStats ps ON ep.player_id = ps.player_id
WHERE ps.games_on_position > (SELECT max(match_round)/7 FROM PlayerStats NATURAL join Matches where season = (SELECT s FROM Seas))
GROUP BY ep.player_id
ORDER BY avg_rating DESC;

CREATE VIEW V_CoachStats
AS 
WITH 
-- 1. Базовая статистика команд (оставлена для справки или H2H)
TeamStats AS (
  SELECT
    t.team_id,
    COUNT(*) AS matches,
    SUM(CASE WHEN ms1.goals > ms2.goals THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ms1.goals = ms2.goals THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ms1.goals < ms2.goals THEN 1 ELSE 0 END) AS losses,
    SUM(ms1.goals) AS goals_for,
    SUM(ms2.goals) AS goals_against,
    SUM(
      CASE
        WHEN ms1.goals > ms2.goals THEN 3
        WHEN ms1.goals = ms2.goals THEN 1
        ELSE 0
      END
    ) AS points
  FROM Teams AS t
  JOIN "MatchStats" AS ms1 ON t.team_id = ms1.team_id
  JOIN "MatchStats" AS ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id <> ms2.team_id
  JOIN Matches AS m ON ms1.match_id = m.match_id
  GROUP BY t.team_id
),

-- 2. Находим тренера, который был у руля команды в день конкретного матча
ActiveAssignments AS (
    SELECT 
        ct.coach_id,
        c.coach_name,
        ct.team_id,
        m.match_id,
        -- Проверяем пересечение периода контракта с датой матча
        CASE 
            -- Если контракт еще не закрыт (текущий тренер)
            WHEN ct.contract_end IS NULL 
                 AND m.match_date >= ct.contract_start THEN 1
            -- Если матч прошел внутри периода контракта
            WHEN ct.contract_end IS NOT NULL 
                 AND m.match_date BETWEEN ct.contract_start AND ct.contract_end THEN 1
            ELSE 0
        END AS is_active_during_match
    FROM CoachTeams ct
    JOIN Coaches c ON ct.coach_id = c.coach_id
    -- Соединяем со всеми матчами сезона, чтобы проверить участие команды
    JOIN Matches m ON (m.team1_id = ct.team_id OR m.team2_id = ct.team_id)
),

-- 3. Фильтруем только валидные назначения и собираем статистику по ним
CoachSeasonStats AS (
    SELECT 
        aa.coach_id,
        aa.coach_name,
		ms1.team_id,
        COUNT(DISTINCT aa.match_id) AS matches,
        SUM(CASE WHEN ms1.goals > ms2.goals THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN ms1.goals = ms2.goals THEN 1 ELSE 0 END) AS draws,
        SUM(CASE WHEN ms1.goals < ms2.goals THEN 1 ELSE 0 END) AS losses,
        SUM(ms1.goals) AS goals_for,
        SUM(ms2.goals) AS goals_against,
        SUM(
            CASE
                WHEN ms1.goals > ms2.goals THEN 3
                WHEN ms1.goals = ms2.goals THEN 1
                ELSE 0
            END
        ) AS points
    FROM ActiveAssignments aa
    JOIN "MatchStats" ms1 ON aa.match_id = ms1.match_id AND aa.team_id = ms1.team_id
    JOIN "MatchStats" ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id <> ms2.team_id
    WHERE aa.is_active_during_match = 1
    GROUP BY aa.coach_id, aa.coach_name, ms1.team_id
)

SELECT 
    css.coach_name,
	team_name,
    css.matches,
    css.wins,
    css.draws,
    css.losses,
    css.goals_for || ':' || css.goals_against AS goals,
    css.points,
	round(css.points  * 1.0  /   css.matches ,2) point_per_mathes
FROM CoachSeasonStats css NATURAL JOIN Teams
ORDER BY 
    point_per_mathes DESC,
    css.points DESC,
    css.wins DESC,
    (css.goals_for - css.goals_against) DESC,
    css.goals_for DESC;

CREATE VIEW V_DomesticTransfers AS
-- Внутренние трансферы в лиге
SELECT 
row_number() over(order by p1.fee_in  desc) '№',
player_name Игрок, t2.team_name Из, t1.team_name В, p1.fee_in ||' млн €' Цена, p1.contract_start Дата,
CASE WHEN p1.contract_start between '2024-05-30' and '2024-09-30' then 'Лето 2024'
	 WHEN p1.contract_start between '2024-10-30' and '2025-02-28' then 'Зима 2025'
     WHEN p1.contract_start between '2025-05-30' and '2025-09-30' then 'Лето 2025'
  	 WHEN p1.contract_start between '2025-10-30' and '2026-02-28' then 'Зима 2026'
     WHEN p1.contract_start between '2026-05-30' and '2026-09-30' then 'Лето 2026'
     end AS 'Окно'
FROM PlayerTeams p1 NATURAL JOIN Players
JOIN PlayerTeams p2 on p1.player_id = p2.player_id and p1.contract_start = p2.contract_end and p1.team_id != p2.team_id
join Teams t1 on t1.team_id = p1.team_id join Teams t2 on t2.team_id = p2.team_id 
where p1.transfer_type_in = 'transfer'
order by p1.fee_in desc;

CREATE VIEW V_GoalStats AS
WITH Seas AS(
SELECT max(season)  s FROM Matches),
goals_cte AS (
    SELECT 
        player_id,
        COUNT(*) AS goals
    FROM PlayerActions  NATURAL JOIN Matches
    WHERE 
        action_type = 'Goal' 
        AND season = (SELECT s FROM Seas)
        AND action_details NOT LIKE 'Own%'
    GROUP BY player_id
),
assists_cte AS (
    SELECT 
        assist_by AS player_id,
        COUNT(*) AS assist
    FROM PlayerActions  NATURAL JOIN Matches
    WHERE 
        action_type = 'Goal' 
        AND season = (SELECT s FROM Seas)
        AND assist_by IS NOT NULL
    GROUP BY assist_by
),
preassists_cte AS (
    SELECT 
        pre_assist_by AS player_id,
        COUNT(*) AS preassist
    FROM PlayerActions  NATURAL JOIN Matches
    WHERE 
        action_type = 'Goal' 
        AND season = (SELECT s FROM Seas)
        AND pre_assist_by IS NOT NULL
    GROUP BY pre_assist_by
),
-- Определяем единственную актуальную команду для каждого игрока
player_current_team AS (
    SELECT 
        player_id,
        team_name
    FROM (
        SELECT 
            pt.player_id,
            t.team_name,
            ROW_NUMBER() OVER (PARTITION BY pt.player_id ORDER BY COALESCE(pt.contract_end, '9999-12-31') DESC) as rn
        FROM PlayerTeams pt
        JOIN Teams t ON pt.team_id = t.team_id
    ) ranked_teams
    WHERE rn = 1
)
SELECT 
    p.player_name,
    pct.team_name,
    COALESCE(g.goals, 0) AS goals,
    COALESCE(a.assist, 0) AS assist,
    COALESCE(pa.preassist, 0) AS preassist
FROM Players p
LEFT JOIN player_current_team pct ON p.player_id = pct.player_id
LEFT JOIN goals_cte g ON p.player_id = g.player_id
LEFT JOIN assists_cte a ON p.player_id = a.player_id
LEFT JOIN preassists_cte pa ON p.player_id = pa.player_id
WHERE 
    COALESCE(g.goals, 0) > 0 
    OR COALESCE(a.assist, 0) > 0 
    OR COALESCE(pa.preassist, 0) > 0
ORDER BY 
    goals DESC, 
    assist DESC, 
    preassist DESC;

CREATE VIEW V_RatingEPV AS
SELECT 
    p.player_name,
	p.player_position,
    COALESCE(current_team.team_name, last_team.team_name) AS team_name,
    SUM(ps.minutes_played) AS total_minutes,
    ROUND(SUM(
        COALESCE(x.epv_carry_n, 0) + 
        COALESCE(x.epv_carry_p, 0) +
        COALESCE(x.epv_open_play_acc_n, 0) + 
        COALESCE(x.epv_open_play_acc_p, 0) + 
        COALESCE(x.epv_open_play_inacc_intercept, 0) + 
        COALESCE(x.epv_open_play_inacc_offside, 0) + 
        COALESCE(x.epv_open_play_inacc_out, 0) + 
        COALESCE(x.epv_set_piece_corner_acc_n, 0) + 
        COALESCE(x.epv_set_piece_corner_acc_p, 0) + 
        COALESCE(x.epv_set_piece_corner_inacc, 0) + 
        COALESCE(x.epv_set_piece_freekick_acc_n, 0) + 
        COALESCE(x.epv_set_piece_freekick_acc_p, 0) + 
        COALESCE(x.epv_set_piece_freekick_inacc, 0) + 
        COALESCE(x.epv_set_piece_throw_inacc, 0) + 
        COALESCE(x.epv_set_piece_throw_acc_n, 0) + 
        COALESCE(x.epv_set_piece_throw_acc_p, 0)
    ) / NULLIF(SUM(ps.minutes_played), 0) * 90, 3) AS total_90,
    ROUND(SUM(
        COALESCE(x.epv_carry_n, 0) + 
        COALESCE(x.epv_carry_p, 0) 
    ) / NULLIF(SUM(ps.minutes_played), 0) * 90, 3) AS carry_90,
    ROUND(SUM(
        COALESCE(x.epv_open_play_acc_n, 0) + 
        COALESCE(x.epv_open_play_acc_p, 0) + 
        COALESCE(x.epv_open_play_inacc_intercept, 0) + 
        COALESCE(x.epv_open_play_inacc_offside, 0) + 
        COALESCE(x.epv_open_play_inacc_out, 0)
    ) / NULLIF(SUM(ps.minutes_played), 0) * 90, 3) AS open_play_90,
    ROUND(SUM(
        COALESCE(x.epv_set_piece_corner_acc_n, 0) + 
        COALESCE(x.epv_set_piece_corner_acc_p, 0) + 
        COALESCE(x.epv_set_piece_corner_inacc, 0) + 
        COALESCE(x.epv_set_piece_freekick_acc_n, 0) + 
        COALESCE(x.epv_set_piece_freekick_acc_p, 0) + 
        COALESCE(x.epv_set_piece_freekick_inacc, 0) + 
        COALESCE(x.epv_set_piece_throw_inacc, 0) + 
        COALESCE(x.epv_set_piece_throw_acc_n, 0) + 
        COALESCE(x.epv_set_piece_throw_acc_p, 0)
    ) / NULLIF(SUM(ps.minutes_played), 0) * 90, 3) AS set_piece_90
FROM 
    Players p
JOIN 
    PlayerStats ps ON p.player_id = ps.player_id
JOIN 
    xGLab x ON ps.player_stat_id = x.player_stat_id
JOIN 
    Matches m ON ps.match_id = m.match_id 
LEFT JOIN (
    SELECT 
        pt.player_id,
        t.team_name
    FROM 
        PlayerTeams pt
    JOIN 
        Teams t ON pt.team_id = t.team_id
    WHERE 
        pt.contract_end IS NULL
) AS current_team ON p.player_id = current_team.player_id
LEFT JOIN (
    SELECT 
        pt.player_id,
        t.team_name
    FROM 
        PlayerTeams pt
    JOIN 
        Teams t ON pt.team_id = t.team_id
    WHERE 
        pt.contract_end IS NOT NULL
    ORDER BY 
        pt.contract_end DESC
) AS last_team ON p.player_id = last_team.player_id
WHERE 
    m.season = (SELECT max(season) FROM Matches)
GROUP BY 
    p.player_name
HAVING 
    SUM(ps.minutes_played) > 500
ORDER BY 
 total_90 DESC;

CREATE VIEW V_TM_Countries AS

SELECT 
player_national Country, 
count(DISTINCT player_id) Player, 
count(*) MAtches, 
sum(goals) Goals
from PlayerStats NATURAL JOIN Players NATURAL JOIN Matches
where season = (SELECT max(season) FROM Matches)
GROUP BY player_national
ORDER BY 4 DESC;

CREATE VIEW V_TM_FairPlay as

SELECT 
team_name Club,
SUM(yellow_card) YC,
SUM(second_yellow_card) '2YC',
SUM(red_card) RC,
SUM(yellow_card) + SUM (second_yellow_card) * 3 + SUM(red_card) * 5 Points
FROM PlayerStats NATURAL JOIN Teams NATURAL JOIN Matches
WHERE season = (SELECT max(season) FROM Matches)
GROUP BY 1
ORDER BY 5;

CREATE VIEW V_TM_GoalDistributionPositions AS

WITH CurrentSeason AS (
    -- Определяем целевой сезон
   SELECT max(season) FROM Matches AS season_year
),
TeamPlayerGoalsInSeason AS (
    -- Шаг 1: Агрегируем голы игроков по позициям для каждой команды за сезон 2026
    SELECT
        ps.team_id,
        SUM(CASE
                WHEN ps.position_on_field LIKE '%B' THEN ps.goals
                ELSE 0
            END) AS total_goals_defenders,
        SUM(CASE
                WHEN ps.position_on_field LIKE '%M' THEN ps.goals
                ELSE 0
            END) AS total_goals_midfielders,
        SUM(CASE
                WHEN ps.position_on_field LIKE '%W' OR ps.position_on_field LIKE '%T' OR ps.position_on_field LIKE '%F' THEN ps.goals
                ELSE 0
            END) AS total_goals_forwards
    FROM PlayerStats ps
    JOIN Matches m ON ps.match_id = m.match_id
    WHERE season = (SELECT max(season) FROM Matches)
    GROUP BY ps.team_id
),
TeamOverallGoalsInSeason AS (
    -- Шаг 2: Агрегируем общие голы каждой команды за сезон 2026 из MatchStats
    SELECT
        ms.team_id,
        SUM(ms.goals) AS total_overall_goals
    FROM MatchStats ms
    JOIN Matches m ON ms.match_id = m.match_id
    WHERE season = (SELECT max(season) FROM Matches)
    GROUP BY ms.team_id
)
-- Шаг 3: Объединяем результаты и выводим
SELECT
    t.team_name AS "Club",
    COALESCE(tpg.total_goals_defenders, 0) AS "Defender",
    COALESCE(tpg.total_goals_midfielders, 0) AS "Midfielder",
    COALESCE(tpg.total_goals_forwards, 0) AS "Forward",
    COALESCE(tog.total_overall_goals, 0) AS "Total"
FROM Teams t
LEFT JOIN TeamPlayerGoalsInSeason tpg ON t.team_id = tpg.team_id
LEFT JOIN TeamOverallGoalsInSeason tog ON t.team_id = tog.team_id
WHERE total > 0
ORDER BY "Total" DESC;

CREATE VIEW V_TM_GoalDistributionType AS

WITH CurrentSeason AS (
    -- Определяем целевой сезон
    SELECT max(season) FROM Matches AS season_year
),
TeamGoalsByType AS (
    -- Шаг 1: Агрегируем голы по типам (action_details) для каждой команды за сезон 2026
    SELECT
        pa.team_id,
        SUM(CASE
                WHEN pa.action_details LIKE 'Right%' THEN 1
                ELSE 0
            END) AS goals_right_footed,
        SUM(CASE
                WHEN pa.action_details LIKE 'Left%' THEN 1
                ELSE 0
            END) AS goals_left_footed,
        SUM(CASE
                WHEN pa.action_details = 'Head' THEN 1
                ELSE 0
            END) AS goals_header,
        SUM(CASE
                WHEN pa.action_details LIKE 'Pen%' THEN 1
                ELSE 0
            END) AS goals_penalty,
        SUM(CASE
                WHEN pa.action_details LIKE 'Free%' THEN 1
                ELSE 0
            END) AS goals_freekick,
        SUM(CASE
                WHEN pa.action_details LIKE 'Own%' THEN 1
                ELSE 0
            END) AS goals_own,			
        COUNT(pa.action_id) AS total_goals_count -- Общее количество голов
    FROM PlayerActions pa
    JOIN Matches m ON pa.match_id = m.match_id  
    WHERE pa.action_type = 'Goal' -- Считаем только строки, где action_type = 'Goal'
	and season = (SELECT max(season) FROM Matches)
    GROUP BY pa.team_id
)
-- Шаг 2: Объединяем результаты с названиями команд
SELECT
    t.team_name AS "Club",
    COALESCE(tgt.goals_right_footed, 0) AS "Right-footed",
    COALESCE(tgt.goals_left_footed, 0) AS "Left-footed",
    COALESCE(tgt.goals_header, 0) AS "Header",
    COALESCE(tgt.goals_penalty, 0) AS "Penalty",
    COALESCE(tgt.goals_freekick, 0) AS "Freekick",
	COALESCE(tgt.goals_own, 0) AS "Own goals",
    COALESCE(tgt.total_goals_count, 0) AS "Total"
FROM Teams t
LEFT JOIN TeamGoalsByType tgt ON t.team_id = tgt.team_id
WHERE Total > 0
ORDER BY "Total" DESC;

CREATE VIEW V_TM_GoalProportion AS

WITH CurrentSeason AS (
    -- Определяем целевой сезон
    SELECT max(season) FROM Matches AS season_year
),
TeamTotalGoals AS (
    -- Шаг 1: Суммируем все головы команды за сезон (по всем игрокам команды)
    SELECT
        ms.team_id,
        SUM(ms.goals) AS total_team_goals
    FROM MatchStats ms
    JOIN Matches m ON ms.match_id = m.match_id
    WHERE season = (SELECT max(season) FROM Matches)
    GROUP BY ms.team_id
),
PlayerStatsAggregated AS (
    -- Шаг 2: Суммируем головы каждого игрока за сезон и связываем с командой
    SELECT
        ps.player_id,
        ps.team_id,
        SUM(ps.goals) AS player_goals
    FROM PlayerStats ps
    JOIN Matches m ON ps.match_id = m.match_id
    WHERE season = (SELECT max(season) FROM Matches)
    GROUP BY ps.player_id, ps.team_id
)
-- Шаг 3: Объединяем данные и рассчитываем процент
SELECT
    p.player_name AS Player,
    t.team_name AS Club,
    ttg.total_team_goals AS TeamGoals,
    psa.player_goals AS PlayerGoals,
    CASE 
        WHEN ttg.total_team_goals = 0 THEN 0 
        ELSE ROUND(CAST(psa.player_goals AS REAL) / ttg.total_team_goals * 100, 1) 
    END AS Percent
FROM PlayerStatsAggregated psa
JOIN TeamTotalGoals ttg ON psa.team_id = ttg.team_id
JOIN Players p ON psa.player_id = p.player_id  -- Предполагаем таблицу Players с player_name
JOIN Teams t ON psa.team_id = t.team_id
ORDER BY Percent DESC, psa.player_goals DESC;

CREATE VIEW V_TM_PoinAfterFallingBehind AS

WITH GoalEvents AS (
    -- 1. Собираем все голы и определяем пары соперников
    SELECT 
        pa.match_id,
        pa.team_id AS scoring_team_id,
        pa.action_minute,
        pa.action_id,
        ms1.team_id AS team_a,
        ms2.team_id AS team_b
    FROM PlayerActions pa
	JOIN matches m on m.match_id = pa.match_id
    JOIN MatchStats ms1 ON pa.match_id = ms1.match_id
    JOIN MatchStats ms2 ON pa.match_id = ms2.match_id AND ms1.team_id < ms2.team_id
    WHERE pa.action_type = 'Goal' and m.season = (SELECT max(season) FROM Matches)
),
ScoreFlow AS (
    -- 2. Считаем текущий счет после каждого гола (running total)
    SELECT 
        match_id,
        team_a,
        team_b,
        SUM(CASE WHEN scoring_team_id = team_a THEN 1 ELSE 0 END) 
            OVER (PARTITION BY match_id ORDER BY action_minute, action_id) AS score_a,
        SUM(CASE WHEN scoring_team_id = team_b THEN 1 ELSE 0 END) 
            OVER (PARTITION BY match_id ORDER BY action_minute, action_id) AS score_b
    FROM GoalEvents
),
TeamsThatTrailed AS (
    -- 3. Определяем матчи, в которых команда ПРОИГРЫВАЛА (была позади в счете)
    SELECT DISTINCT match_id, team_id
    FROM (
        SELECT match_id, team_a AS team_id FROM ScoreFlow WHERE score_a < score_b
        UNION
        SELECT match_id, team_b AS team_id FROM ScoreFlow WHERE score_b < score_a
    )
),
FinalStats AS (
    -- 4. Сопоставляем с финальными результатами из MatchStats
    SELECT 
        tt.team_id,
        t.team_name,
        CASE 
            WHEN ms_own.goals > ms_opp.goals THEN 3 
            WHEN ms_own.goals = ms_opp.goals THEN 1 
            ELSE 0 
        END AS match_points,
        CASE WHEN ms_own.goals > ms_opp.goals THEN 1 ELSE 0 END AS is_win,
        CASE WHEN ms_own.goals = ms_opp.goals THEN 1 ELSE 0 END AS is_draw,
        CASE WHEN ms_own.goals < ms_opp.goals THEN 1 ELSE 0 END AS is_loss
    FROM TeamsThatTrailed tt
    JOIN Teams t ON tt.team_id = t.team_id
    JOIN MatchStats ms_own ON tt.match_id = ms_own.match_id AND tt.team_id = ms_own.team_id
    JOIN MatchStats ms_opp ON tt.match_id = ms_opp.match_id AND tt.team_id <> ms_opp.team_id
)
-- 5. Итоговая агрегация
SELECT 
    team_name Club,
    COUNT(*) AS Deficits, -- Кол-во матчей, где проигрывали по ходу встречи
    SUM(is_win) AS Wins,      -- Волевые победы
    SUM(is_draw) AS Draws,
    SUM(is_loss) AS Losses,
    SUM(match_points) AS Points
FROM FinalStats
GROUP BY team_id, team_name
ORDER BY Points DESC, Wins DESC;

CREATE VIEW V_TM_PoinAfterTakinkLead AS

WITH GoalEvents AS (
    -- 1. Выбираем все голы и определяем, кто с кем играл
    SELECT 
        pa.match_id,
        pa.team_id AS scoring_team_id,
        pa.action_minute,
        pa.action_id,
        ms1.team_id AS team_a,
        ms2.team_id AS team_b
    FROM PlayerActions pa
	JOIN matches m on pa.match_id = m.match_id
    JOIN MatchStats ms1 ON pa.match_id = ms1.match_id
    JOIN MatchStats ms2 ON pa.match_id = ms2.match_id AND ms1.team_id < ms2.team_id
    WHERE pa.action_type = 'Goal' and m.season = (SELECT max(season) FROM Matches)
),
ScoreFlow AS (
    -- 2. Считаем счет матча после каждого забитого гола
    SELECT 
        match_id,
        team_a,
        team_b,
        SUM(CASE WHEN scoring_team_id = team_a THEN 1 ELSE 0 END) 
            OVER (PARTITION BY match_id ORDER BY action_minute, action_id) AS score_a,
        SUM(CASE WHEN scoring_team_id = team_b THEN 1 ELSE 0 END) 
            OVER (PARTITION BY match_id ORDER BY action_minute, action_id) AS score_b
    FROM GoalEvents
),
TeamsThatLed AS (
    -- 3. Определяем уникальные пары (матч, команда), где команда вела в счете
    SELECT DISTINCT match_id, team_id
    FROM (
        SELECT match_id, team_a AS team_id FROM ScoreFlow WHERE score_a > score_b
        UNION
        SELECT match_id, team_b AS team_id FROM ScoreFlow WHERE score_b > score_a
    )
),
FinalStats AS (
    -- 4. Сопоставляем эти матчи с финальными результатами из MatchStats
    SELECT 
        tl.team_id,
        t.team_name,
        CASE 
            WHEN ms_own.goals > ms_opp.goals THEN 3 
            WHEN ms_own.goals = ms_opp.goals THEN 1 
            ELSE 0 
        END AS match_points,
        CASE WHEN ms_own.goals > ms_opp.goals THEN 1 ELSE 0 END AS is_win,
        CASE WHEN ms_own.goals = ms_opp.goals THEN 1 ELSE 0 END AS is_draw,
        CASE WHEN ms_own.goals < ms_opp.goals THEN 1 ELSE 0 END AS is_loss
    FROM TeamsThatLed tl
    JOIN Teams t ON tl.team_id = t.team_id
    JOIN MatchStats ms_own ON tl.match_id = ms_own.match_id AND tl.team_id = ms_own.team_id
    JOIN MatchStats ms_opp ON tl.match_id = ms_opp.match_id AND tl.team_id <> ms_opp.team_id
)
-- 5. Группируем и выводим итоговую таблицу
SELECT 
    team_name Club,
    COUNT(*) AS 'Times leading',
    SUM(is_win) AS Wins,
    SUM(is_draw) AS Draws,
    SUM(is_loss) AS Losses,
    SUM(match_points) AS Points
FROM FinalStats
GROUP BY team_id, team_name
ORDER BY Points DESC, Wins DESC;

CREATE VIEW V_TM_ScorerDuos AS

SELECT
 ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) as N,
 team_name Club,
    p.player_name AS Scorer,
    p2.player_name AS Provider,
    COUNT(*) AS Goals
FROM PlayerActions a
JOIN Players p ON a.player_id = p.player_id
LEFT JOIN Players p2 ON a.assist_by = p2.player_id
JOIN Teams t ON t.team_id = a.team_id
JOIN Matches m ON m.match_id = a.match_id
WHERE a.assist_by IS NOT NULL and season = (SELECT max(season) FROM Matches)
GROUP BY p.player_name, p2.player_name, a.team_id
ORDER BY Goals DESC;

CREATE VIEW V_TM_Series AS

WITH TeamMatchResults AS (
    -- 1. Собираем результаты всех матчей, нумеруем их от новых к старым (rn=1 — последний матч)
    SELECT 
        t.team_name,
        ms1.team_id,
        m.match_date,
        m.match_id,
        CASE WHEN ms1.goals > ms2.goals THEN 1 ELSE 0 END AS is_win,
        CASE WHEN ms1.goals >= ms2.goals THEN 1 ELSE 0 END AS is_unbeaten,
        CASE WHEN ms1.goals <= ms2.goals THEN 1 ELSE 0 END AS is_winless,
        CASE WHEN ms1.goals < ms2.goals THEN 1 ELSE 0 END AS is_loss,
        CASE WHEN ms2.goals = 0 THEN 1 ELSE 0 END AS is_clean_sheet,
        ROW_NUMBER() OVER (PARTITION BY ms1.team_id ORDER BY m.match_date DESC, m.match_id DESC) as rn
    FROM MatchStats ms1
    JOIN MatchStats ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id <> ms2.team_id
    JOIN Matches m ON ms1.match_id = m.match_id
    JOIN Teams t ON ms1.team_id = t.team_id
    WHERE m.season = (SELECT max(season) FROM Matches)
),
SeriesBreakers AS (
    -- 2. Для каждого типа серии находим номер самого первого матча (с конца), который её ПРЕРВАЛ
    SELECT 
        team_id,
        team_name,
        MIN(CASE WHEN is_win = 0 THEN rn END) as first_non_win,
        MIN(CASE WHEN is_unbeaten = 0 THEN rn END) as first_defeat,
        MIN(CASE WHEN is_winless = 0 THEN rn END) as first_win,
        MIN(CASE WHEN is_loss = 0 THEN rn END) as first_non_loss,
        MIN(CASE WHEN is_clean_sheet = 0 THEN rn END) as first_conceded,
        MAX(rn) as total_matches -- на случай, если серия еще не прерывалась
    FROM TeamMatchResults
    GROUP BY team_id, team_name
)
-- 3. Вычитаем 1 из номера "прерывателя", чтобы получить количество матчей в текущей серии
SELECT 
    team_name Club,
    COALESCE(first_non_win - 1, total_matches) as Wins,
    COALESCE(first_defeat - 1, total_matches) as Undefeated,
    COALESCE(first_win - 1, total_matches) as Victoryless,
    COALESCE(first_non_loss - 1, total_matches) as Losses,
    COALESCE(first_conceded - 1, total_matches) as Shutouts
FROM SeriesBreakers
ORDER BY Wins DESC, Undefeated DESC;

CREATE VIEW V_TM_SpecialTalent AS

WITH CurrentSeason AS (
    -- Определяем целевой сезон
    SELECT 2026 AS season_year
),
TeamStatsPerMatch AS (
    -- Шаг 1: Собираем статистику по каждой команде в каждом матче
    -- Фильтруем матчи только по тем, где тренер был/есть у команды (по датам контракта)
    SELECT
        ps.team_id,
        ps.match_id,
        ct.coach_id,  -- Добавлено для группировки по тренеру
        SUM(ps.goals) AS goals_in_match,
  		SUM(ps.assists) AS assists_in_match,
        SUM(CASE WHEN ps.position_on_field = 'Sub' THEN ps.goals ELSE 0 END) AS sub_goals_in_match,
	    SUM(CASE WHEN ps.position_on_field = 'Sub' THEN ps.assists ELSE 0 END) AS sub_assists_in_match,
        COUNT(CASE WHEN ps.position_on_field = 'Sub' THEN 1 END) AS sub_appearances_in_match
    FROM PlayerStats ps
    JOIN Matches m ON ps.match_id = m.match_id
    JOIN CoachTeams ct ON ps.team_id = ct.team_id 
        AND m.match_date >= ct.contract_start 
        AND (m.match_date <= ct.contract_end OR ct.contract_end IS NULL)  -- Фильтр: матчи в периоде контракта, включая активные (NULL)
	WHERE season = (SELECT max(season) FROM Matches)
    GROUP BY ps.team_id, ps.match_id, ct.coach_id
),
TeamSeasonAggregated AS (
    -- Шаг 2: Суммируем статистику за сезон по тренеру и команде
    SELECT
        coach_id,
        team_id,
        COUNT(match_id) AS M,          -- Количество матчей (только те, что тренер провел)
        SUM(goals_in_match) AS Gl,     -- Всего голов команды (Gl)
  		SUM(assists_in_match) AS Ga,
        SUM(sub_goals_in_match) AS G,  -- Голы запасных (G)
  		SUM(sub_assists_in_match) AS A,
        SUM(sub_appearances_in_match) AS S -- Количество выходов на замену (S)
    FROM TeamStatsPerMatch
    GROUP BY coach_id, team_id
)
-- Шаг 3: Объединяем с тренерами и названиями команд
SELECT
    c.coach_name AS Coach,
    t.team_name AS Team,
    ts.M,
    ts.S,
    ts.G,
    G + A 'Involved in goals'
FROM TeamSeasonAggregated ts
JOIN Teams t ON ts.team_id = t.team_id
JOIN Coaches c ON ts.coach_id = c.coach_id
ORDER BY G DESC, ts.S;

CREATE VIEW V_TM_SuperSubs AS

SELECT 
player_name Player, 
team_name Club, 
COUNT(*) M, 
SUM(minutes_played) Mn, 
SUM(goals) G, 
SUM(assists) A 
FROM PlayerStats
JOIN Players on Players.player_id = PlayerStats.player_id
JOIN Teams on Teams.team_id = PlayerStats.team_id
JOIN Matches on Matches.match_id = PlayerStats.match_id
WHERE position_on_field = 'Sub' AND season = (SELECT max(season) FROM Matches)
GROUP BY 1, 2
ORDER BY 5 DESC, 6 DESC, 3;

CREATE VIEW V_TM_TableWithForeignerGoals AS

WITH AllMatches AS (
  -- CTE для получения всех матчей и команд сезона 2026
  SELECT m.match_id, ms.team_id
  FROM Matches m
  JOIN MatchStats ms ON m.match_id = ms.match_id
  WHERE m.season = (SELECT max(season) FROM Matches)
),
NationalGoals AS (
  -- CTE для суммирования голов, забитых только национальными игроками, по каждому матчу и команде.
  -- Если национальных голов нет, будет 0.
  SELECT
    am.match_id,
    am.team_id,
    COALESCE(SUM(
      CASE
        -- Суммируем голы только если игрок национальный или его национальность не определена (подразумевается "домашний")
        WHEN p.player_national NOT IN ('Russia') OR p.player_national IS NULL
        THEN ps.goals
        ELSE 0
      END
    ), 0) AS english_goals
  FROM AllMatches am
  LEFT JOIN PlayerStats ps ON am.match_id = ps.match_id AND am.team_id = ps.team_id
  LEFT JOIN Players p ON ps.player_id = p.player_id
  -- !!! Условие WHERE p.player_national ... удалено отсюда, чтобы не фильтровать матчи !!!
  GROUP BY am.match_id, am.team_id
),
TeamStats AS (
  -- Статистика команд на основе голов национальных игроков
  SELECT
    t.team_id,
    t.team_name,
    COUNT(ng1.match_id) AS matches, -- Теперь ng1 будет содержать все матчи, поэтому подсчет будет верным
    SUM(CASE WHEN ng1.english_goals > ng2.english_goals THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ng1.english_goals = ng2.english_goals THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ng1.english_goals < ng2.english_goals THEN 1 ELSE 0 END) AS losses,
    SUM(ng1.english_goals) AS goals_for,
    SUM(ng2.english_goals) AS goals_against,
    SUM(
      CASE
        WHEN ng1.english_goals > ng2.english_goals THEN 3
        WHEN ng1.english_goals = ng2.english_goals THEN 1
        ELSE 0
      END
    ) AS points
  FROM Teams t
  LEFT JOIN NationalGoals ng1 ON t.team_id = ng1.team_id  -- Голы команды (LEFT JOIN, чтобы включить команды без матчей)
  LEFT JOIN NationalGoals ng2 ON ng1.match_id = ng2.match_id AND ng1.team_id <> ng2.team_id  -- Голы соперника
  GROUP BY t.team_id, t.team_name
),
HeadToHeadNationalGoals AS (
  -- Исправлено: теперь использует NationalGoals для подсчета голов в личных встречах для tie-breaker
  SELECT
    ng1.team_id AS team_id,
    SUM(ng1.english_goals) AS h2h_national_goals -- Используем english_goals
  FROM NationalGoals ng1
  JOIN NationalGoals ng2 ON ng1.match_id = ng2.match_id AND ng1.team_id <> ng2.team_id
  JOIN TeamStats ts1 ON ng1.team_id = ts1.team_id
  JOIN TeamStats ts2 ON ng2.team_id = ts2.team_id
  WHERE ts1.points = ts2.points -- Фильтр: только матчи с соперниками с равными очками
  GROUP BY ng1.team_id
)

-- Финальный вывод турнирной таблицы
SELECT
  ts.team_name,
  ts.matches,
  ts.wins,
  ts.draws,
  ts.losses,
  ts.goals_for || ':' || ts.goals_against AS goals,
  ts.points
FROM TeamStats ts
LEFT JOIN HeadToHeadNationalGoals h2h ON ts.team_id = h2h.team_id -- Изменено на HeadToHeadNationalGoals
-- 'goals' (goals_for || ':' || goals_against) никогда не будет NULL, т.к. goals_for и goals_against всегда числовые.
-- Поэтому WHERE goals is NOT NULL можно удалить, или оставить, это не повлияет.
WHERE goals is NOT NULL 
ORDER BY
  ts.points DESC,
  COALESCE(h2h.h2h_national_goals, 0) DESC,  -- Изменено на h2h_national_goals
  ts.wins DESC,
  (ts.goals_for - ts.goals_against) DESC,
  ts.goals_for DESC;

CREATE VIEW V_TM_TableWithNationalGoals AS

WITH AllMatches AS (
  -- CTE для получения всех матчей и команд сезона 2026
  SELECT m.match_id, ms.team_id
  FROM Matches m
  JOIN MatchStats ms ON m.match_id = ms.match_id
  WHERE m.season = (SELECT max(season) FROM Matches)
),
NationalGoals AS (
  -- CTE для суммирования голов, забитых только национальными игроками, по каждому матчу и команде.
  -- Если национальных голов нет, будет 0.
  SELECT
    am.match_id,
    am.team_id,
    COALESCE(SUM(
      CASE
        -- Суммируем голы только если игрок национальный или его национальность не определена (подразумевается "домашний")
        WHEN p.player_national IN ('Russia') OR p.player_national IS NULL
        THEN ps.goals
        ELSE 0
      END
    ), 0) AS english_goals
  FROM AllMatches am
  LEFT JOIN PlayerStats ps ON am.match_id = ps.match_id AND am.team_id = ps.team_id
  LEFT JOIN Players p ON ps.player_id = p.player_id
  -- !!! Условие WHERE p.player_national ... удалено отсюда, чтобы не фильтровать матчи !!!
  GROUP BY am.match_id, am.team_id
),
TeamStats AS (
  -- Статистика команд на основе голов национальных игроков
  SELECT
    t.team_id,
    t.team_name,
    COUNT(ng1.match_id) AS matches, -- Теперь ng1 будет содержать все матчи, поэтому подсчет будет верным
    SUM(CASE WHEN ng1.english_goals > ng2.english_goals THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ng1.english_goals = ng2.english_goals THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ng1.english_goals < ng2.english_goals THEN 1 ELSE 0 END) AS losses,
    SUM(ng1.english_goals) AS goals_for,
    SUM(ng2.english_goals) AS goals_against,
    SUM(
      CASE
        WHEN ng1.english_goals > ng2.english_goals THEN 3
        WHEN ng1.english_goals = ng2.english_goals THEN 1
        ELSE 0
      END
    ) AS points
  FROM Teams t
  LEFT JOIN NationalGoals ng1 ON t.team_id = ng1.team_id  -- Голы команды (LEFT JOIN, чтобы включить команды без матчей)
  LEFT JOIN NationalGoals ng2 ON ng1.match_id = ng2.match_id AND ng1.team_id <> ng2.team_id  -- Голы соперника
  GROUP BY t.team_id, t.team_name
),
HeadToHeadNationalGoals AS (
  -- Исправлено: теперь использует NationalGoals для подсчета голов в личных встречах для tie-breaker
  SELECT
    ng1.team_id AS team_id,
    SUM(ng1.english_goals) AS h2h_national_goals -- Используем english_goals
  FROM NationalGoals ng1
  JOIN NationalGoals ng2 ON ng1.match_id = ng2.match_id AND ng1.team_id <> ng2.team_id
  JOIN TeamStats ts1 ON ng1.team_id = ts1.team_id
  JOIN TeamStats ts2 ON ng2.team_id = ts2.team_id
  WHERE ts1.points = ts2.points -- Фильтр: только матчи с соперниками с равными очками
  GROUP BY ng1.team_id
)

-- Финальный вывод турнирной таблицы
SELECT
  ts.team_name,
  ts.matches,
  ts.wins,
  ts.draws,
  ts.losses,
  ts.goals_for || ':' || ts.goals_against AS goals,
  ts.points
FROM TeamStats ts
LEFT JOIN HeadToHeadNationalGoals h2h ON ts.team_id = h2h.team_id -- Изменено на HeadToHeadNationalGoals
-- 'goals' (goals_for || ':' || goals_against) никогда не будет NULL, т.к. goals_for и goals_against всегда числовые.
-- Поэтому WHERE goals is NOT NULL можно удалить, или оставить, это не повлияет.
WHERE goals is NOT NULL
ORDER BY
  ts.points DESC,
  COALESCE(h2h.h2h_national_goals, 0) DESC,  -- Изменено на h2h_national_goals
  ts.wins DESC,
  (ts.goals_for - ts.goals_against) DESC,
  ts.goals_for DESC;

CREATE VIEW V_TM_TopTrios as

WITH PlayerGoalsByTeam AS (
    -- Шаг 1: Суммируем голы каждого игрока для каждой команды
    -- Если игрок мог играть за разные команды в течение сезона,
    -- это учтет его голы только за одну конкретную команду.
    SELECT
        ps.team_id,
        ps.player_id,
        p.player_name,
        SUM(ps.goals) AS total_goals_for_team
    FROM PlayerStats ps
	NATURAL JOIN Matches
    JOIN Players p ON ps.player_id = p.player_id
    WHERE ps.goals > 0 -- Исключаем игроков без голов для производительности, если их много
	AND season = (SELECT max(season) FROM Matches)
    GROUP BY ps.team_id, ps.player_id, p.player_name
),
RankedPlayers AS (
    -- Шаг 2: Ранжируем игроков внутри каждой команды по количеству забитых мячей
    SELECT
        pgbt.team_id,
        pgbt.player_id,
        pgbt.player_name,
        pgbt.total_goals_for_team,
        ROW_NUMBER() OVER (PARTITION BY pgbt.team_id ORDER BY pgbt.total_goals_for_team DESC) AS rn
    FROM PlayerGoalsByTeam pgbt
),
TopTwoScorers AS (
    -- Шаг 3: Выбираем только трёх лучших бомбардиров для каждой команды
    SELECT
        team_id,
        player_id,
        player_name,
        total_goals_for_team
    FROM RankedPlayers
    WHERE rn <= 3
)
-- Шаг 4, 5, 6: Собираем финальный результат
SELECT
    t.team_name AS "Club",
    GROUP_CONCAT(tts.player_name || ' (' || tts.total_goals_for_team || ' голов)', ', ') AS "Trio / Goals",
    SUM(tts.total_goals_for_team) AS "Trio goals"
FROM TopTwoScorers tts
JOIN Teams t ON tts.team_id = t.team_id
GROUP BY t.team_name -- Группируем по команде, чтобы собрать двух игроков в одну строку
ORDER BY "Trio goals" DESC;

CREATE VIEW V_TM_WinningGoals AS

WITH FinalScores AS (
    -- Финальный счет матча и определение победителя/проигравшего
    SELECT
        ms1.match_id,
        ms1.team_id AS winning_team,
        ms1.goals AS winning_score,
        ms2.team_id AS losing_team,
        ms2.goals AS losing_score
    FROM MatchStats ms1
    JOIN MatchStats ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id != ms2.team_id
    WHERE ms1.goals > ms2.goals
),
GoalsWithSequence AS (
    -- Номер каждого гола команды в конкретном матче (включая автоголы для верного счета)
    SELECT
        pa.match_id,
        pa.player_id,
        pa.team_id,
        pa.action_details,
        ROW_NUMBER() OVER (PARTITION BY pa.match_id, pa.team_id ORDER BY pa.action_minute, pa.action_id) AS goal_sequence_in_match
    FROM PlayerActions pa
    JOIN Matches m ON pa.match_id = m.match_id
    WHERE pa.action_type = 'Goal' AND m.season = (SELECT max(season) FROM Matches)
),
WinningGoalsMarked AS (
    -- Помечаем гол как победный, если его порядковый номер равен (счет_соперника + 1)
    SELECT
        gws.match_id,
        gws.player_id,
        gws.team_id,
        CASE
            WHEN fs.winning_team = gws.team_id
              AND gws.goal_sequence_in_match = (fs.losing_score + 1)
              AND (gws.action_details NOT LIKE 'Own%' OR gws.action_details IS NULL)
            THEN 1
            ELSE 0
        END AS is_winning_goal
    FROM GoalsWithSequence gws
    JOIN FinalScores fs ON gws.match_id = fs.match_id
),
PlayerTotalGoals AS (
    -- Сумма голов игрока строго по командам за сезон 2026
    SELECT
        ps.player_id,
        ps.team_id,
        SUM(ps.goals) AS total_goals_sum
    FROM PlayerStats ps
    JOIN Matches m ON ps.match_id = m.match_id
    WHERE m.season = (SELECT max(season) FROM Matches)
    GROUP BY ps.player_id, ps.team_id
)
-- Итоговый вывод
SELECT
    p.player_name AS Player,
    t.team_name AS Club,
    COALESCE(ptg.total_goals_sum, 0) AS "Goals",
    SUM(COALESCE(wgm.is_winning_goal, 0)) AS "Winning goals"
FROM Players p
JOIN PlayerTotalGoals ptg ON p.player_id = ptg.player_id
JOIN Teams t ON ptg.team_id = t.team_id
-- КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: соединяем и по игроку, и по команде
LEFT JOIN WinningGoalsMarked wgm ON ptg.player_id = wgm.player_id AND ptg.team_id = wgm.team_id
GROUP BY p.player_id, p.player_name, t.team_id, t.team_name
HAVING SUM(wgm.is_winning_goal) > 0
ORDER BY 4 DESC, 3 DESC;

CREATE VIEW V_Table AS

WITH Ss AS (
  SELECT MAX(season) AS s FROM Matches
),
TeamStats AS (
  SELECT
    t.team_id,
    t.team_name,
    COUNT(*) AS matches,
    SUM(CASE WHEN ms1.goals > ms2.goals THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN ms1.goals = ms2.goals THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN ms1.goals < ms2.goals THEN 1 ELSE 0 END) AS losses,
    SUM(ms1.goals) AS goals_for,
    SUM(ms2.goals) AS goals_against,
    SUM(
      CASE
        WHEN ms1.goals > ms2.goals THEN 3
        WHEN ms1.goals = ms2.goals THEN 1
        ELSE 0
      END
    ) AS points
  FROM Teams AS t
  JOIN "MatchStats" AS ms1 ON t.team_id = ms1.team_id
  JOIN "MatchStats" AS ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id <> ms2.team_id
  JOIN Matches AS m ON ms1.match_id = m.match_id
  WHERE m.season = (SELECT s FROM Ss)
  GROUP BY t.team_id, t.team_name
),
HeadToHeadGoals AS (
  SELECT
    ms1.team_id AS team_id,
    SUM(ms1.goals) AS h2h_goals
  FROM "MatchStats" ms1
  JOIN "MatchStats" ms2 ON ms1.match_id = ms2.match_id AND ms1.team_id <> ms2.team_id
  JOIN Matches m ON ms1.match_id = m.match_id
  JOIN TeamStats ts1 ON ms1.team_id = ts1.team_id
  JOIN TeamStats ts2 ON ms2.team_id = ts2.team_id
  WHERE m.season = (SELECT s FROM Ss) AND ts1.points = ts2.points
  GROUP BY ms1.team_id
),
OrderedMatches AS (
  SELECT 
    t.team_name,
    CASE 
      WHEN ms1.goals > ms2.goals THEN '🟢'
      WHEN ms1.goals = ms2.goals THEN '🟡'
      ELSE '🔴'
    END AS result_icon
  FROM MatchStats ms1
  JOIN MatchStats ms2 
    ON ms1.match_id = ms2.match_id 
   AND ms1.team_id <> ms2.team_id
  JOIN Matches m 
    ON ms1.match_id = m.match_id
  JOIN Teams t 
    ON ms1.team_id = t.team_id
  WHERE m.season = (SELECT s FROM Ss)
  ORDER BY m.match_date ASC, m.match_time ASC, m.match_round ASC, m.match_id ASC
),
TeamForm AS (
  SELECT 
    team_name,
    GROUP_CONCAT(result_icon, '') AS form
  FROM OrderedMatches
  GROUP BY team_name
)

SELECT
  ts.team_name,
  ts.matches,
  ts.wins,
  ts.draws,
  ts.losses,
  ts.goals_for || ':' || ts.goals_against AS goals,
  ts.points,
  COALESCE(tf.form, '') AS "Форма"
FROM TeamStats ts
LEFT JOIN HeadToHeadGoals h2h ON ts.team_id = h2h.team_id
LEFT JOIN TeamForm tf ON ts.team_name = tf.team_name
ORDER BY
  ts.points DESC,
  COALESCE(h2h.h2h_goals, 0) DESC,
  ts.wins DESC,
  (ts.goals_for - ts.goals_against) DESC,
  ts.goals_for DESC;

