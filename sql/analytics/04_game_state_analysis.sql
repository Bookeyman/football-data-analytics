-- CASE 04. PERFORMANCE AFTER TAKING THE LEAD OR FALLING BEHIND
-- Business question:
-- Which teams respond well after conceding the opening advantage, and which
-- teams convert a lead into points consistently?
--
-- Sources:
-- V_TM_PoinAfterFallingBehind: matches in which a team was behind at some point.
-- V_TM_PoinAfterTakinkLead: matches in which a team led at some point.
--
-- RESULT:
-- One row per team. The query combines the number of matches in each game
-- state, wins/draws/losses and points earned in those situations.
--
-- INTERPRETATION:
-- Points after falling behind indicate resilience, but should be read together
-- with the number of such matches. Points after taking the lead show how often
-- a team protects or improves its advantage. A high number of dropped points
-- after leading can indicate game-management issues.
--
-- 4A. Compare both game states
SELECT
    behind.Club AS team,
    behind.Deficits AS matches_trailed,
    behind.Wins AS wins_after_trailing,
    behind.Draws AS draws_after_trailing,
    behind.Losses AS losses_after_trailing,
    behind.Points AS points_after_trailing,
    ROUND(1.0 * behind.Points / NULLIF(behind.Deficits, 0), 2)
        AS points_per_match_after_trailing,
    led."Times leading" AS matches_led,
    led.Wins AS wins_after_leading,
    led.Draws AS draws_after_leading,
    led.Losses AS losses_after_leading,
    led.Points AS points_after_leading,
    ROUND(1.0 * led.Points / NULLIF(led."Times leading", 0), 2)
        AS points_per_match_after_leading
FROM V_TM_PoinAfterFallingBehind AS behind
LEFT JOIN V_TM_PoinAfterTakinkLead AS led
    ON led.Club = behind.Club
ORDER BY points_per_match_after_trailing DESC,
         points_per_match_after_leading DESC;

-- 4B. Teams that earned the most points after falling behind
SELECT
    Club,
    Deficits AS matches_trailed,
    Wins,
    Draws,
    Losses,
    Points,
    ROUND(1.0 * Points / NULLIF(Deficits, 0), 2) AS points_per_match
FROM V_TM_PoinAfterFallingBehind
ORDER BY Points DESC, points_per_match DESC
LIMIT 10;
