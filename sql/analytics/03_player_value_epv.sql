-- CASE 03. PLAYER VALUE CONTRIBUTION (EPV)
-- Business question:
-- Which players contribute most to possession value, and through which phase:
-- ball carrying, open play or set pieces?
--
-- Source:
-- V_RatingEPV combines xGLab EPV events with player minutes for the latest
-- season and expresses the values per 90 minutes.
--
-- RESULT:
-- One row per eligible player with total EPV per 90 and a breakdown into
-- carrying, open play and set pieces.
--
-- INTERPRETATION:
-- Use total_90 to shortlist players with a high recorded EPV contribution.
-- Use the component columns to understand where that contribution comes from.
-- Compare players in similar positions and with sufficient minutes.
-- EPV is a model-based metric: interpret it according to the provider's
-- methodology, and do not treat it as a direct replacement for goals or assists.

-- 3A. Highest EPV contribution per 90
SELECT
    player_name,
    player_position,
    team_name,
    total_minutes,
    total_90,
    carry_90,
    open_play_90,
    set_piece_90
FROM V_RatingEPV
ORDER BY total_90 DESC
LIMIT 20;

-- 3B. Players whose EPV contribution is primarily from ball carrying
SELECT
    player_name,
    player_position,
    team_name,
    total_minutes,
    carry_90,
    open_play_90,
    set_piece_90,
    total_90,
    ROUND(100.0 * carry_90 / NULLIF(total_90, 0), 1) AS carrying_share_pct
FROM V_RatingEPV
WHERE total_90 > 0
ORDER BY carrying_share_pct DESC
LIMIT 15;
