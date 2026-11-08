-- CASE 02. PLAYER PERFORMANCE RANKING
-- Business question:
-- Which players have the strongest overall season performance, after excluding
-- players with a small amount of playing time?
--
-- Source:
-- V_AVG aggregates player statistics for the latest season and applies a
-- playing-time threshold. It also calculates average rating, goal contributions,
-- per-match attacking/defensive indicators and position information.
--
-- RESULT:
-- One row per eligible player, ordered by average rating. The output includes
-- appearances, minutes, goals, assists, goals + assists, rating and selected
-- performance indicators.
--
-- INTERPRETATION:
-- The minutes filter makes the comparison more meaningful by reducing the
-- influence of players with only a few appearances. Rating should not be used
-- alone: compare it with goal contributions, chance creation, passing and
-- defensive indicators, taking the player's position into account.
--
-- 2A. Top 20 eligible players by average rating
SELECT
    "#" AS rating_rank,
    player_name,
    popular_positions,
    matches,
    minutes,
    goals,
    assists,
    "g+a" AS goal_contributions,
    avg_rating,
    shots,
    on_target,
    key_passes,
    passes_acc,
    pr_passes,
    dribbles,
    pr_drib,
    tackles,
    interceptions
FROM V_AVG
ORDER BY avg_rating DESC
LIMIT 20;

-- 2B. Players with the highest direct goal contribution
SELECT
    player_name,
    popular_positions,
    matches,
    minutes,
    goals,
    assists,
    "g+a" AS goal_contributions,
    ROUND(1.0 * ("g+a") * 90 / NULLIF(minutes, 0), 2) AS goal_contributions_per_90
FROM V_AVG
ORDER BY goal_contributions_per_90 DESC
LIMIT 15;
