-- CASE 01. TEAM PERFORMANCE
-- Business question:
-- Which teams combine strong results with effective attacking and defensive output?
--
-- Source:
-- V_Table: season standings, points, goals and recent form.
-- MatchStats + Matches: supporting team efficiency metrics.
--
-- RESULT:
-- Query 1 returns the ordered league table with rank, matches, W/D/L,
-- goal difference, points and form.
-- Query 2 returns one row per team with average goals, xG, shots,
-- shots-on-target rate and possession per match.
--
-- INTERPRETATION:
-- Compare goals with xG to identify teams outperforming or underperforming
-- their chance quality. Compare goals conceded and opponent shots/xG to assess
-- defensive performance. Use the table and form together: points show season
-- outcome, form shows the sequence of results.
--
-- NOTE:
-- V_Table is defined in sql/database/03_views.sql. Its season filter should
-- use the latest season in the database (MAX(season)); see the updated view.

-- 1A. League table
SELECT
    ROW_NUMBER() OVER (
        ORDER BY points DESC, wins DESC
    ) AS place,
    team_name,
    matches,
    wins,
    draws,
    losses,
    goals,
    points,
    "Форма" AS recent_form
FROM V_Table
ORDER BY place;

-- 1B. Team attacking and defensive efficiency (latest season)
WITH team_match_metrics AS (
    SELECT
        ms.team_id,
        t.team_name,
        m.season,
        ms.goals,
        COALESCE(ms.xg, 0) AS xg,
        COALESCE(ms.shots, 0) AS shots,
        COALESCE(ms.shots_on_target, 0) AS shots_on_target,
        COALESCE(ms.possession, 0) AS possession
    FROM MatchStats AS ms
    JOIN Matches AS m
        ON m.match_id = ms.match_id
    JOIN Teams AS t
        ON t.team_id = ms.team_id
    WHERE m.season = (SELECT MAX(season) FROM Matches)
)
SELECT
    team_name,
    COUNT(*) AS matches,
    ROUND(AVG(goals), 2) AS avg_goals,
    ROUND(AVG(xg), 2) AS avg_xg,
    ROUND(AVG(goals - xg), 2) AS avg_goals_minus_xg,
    ROUND(AVG(shots), 2) AS avg_shots,
    ROUND(
        100.0 * SUM(shots_on_target) / NULLIF(SUM(shots), 0),
        1
    ) AS shots_on_target_pct,
    ROUND(AVG(possession), 1) AS avg_possession_pct
FROM team_match_metrics
GROUP BY team_id, team_name
ORDER BY avg_goals DESC, avg_xg DESC;
