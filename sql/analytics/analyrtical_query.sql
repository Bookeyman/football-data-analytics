WITH Ss AS (
  SELECT 2027 AS s
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
order by p1.fee_in desc