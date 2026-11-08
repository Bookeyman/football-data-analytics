-- CASE 05. GOAL CONTRIBUTION AND ATTACKING STRUCTURE
-- Business question:
-- Where do a team's goals come from, and which players are involved in decisive
-- attacking actions?
--
-- Sources:
-- V_TM_ScorerDuos: scorer + assister combinations.
-- V_TM_SuperSubs: goals and assists recorded by substitute appearances.
-- V_TM_WinningGoals: goals identified as decisive winning goals.
-- V_TM_GoalDistributionPositions: team goals grouped by player position.
--
-- RESULT:
-- Four complementary result sets: most productive scorer-assister pairs,
-- substitute contributions, winning goals by player, and goal distribution
-- across defensive, midfield and forward positions.
--
-- INTERPRETATION:
-- Scorer-assister pairs reveal recurring combinations rather than only
-- individual totals. Substitute output helps assess bench impact. Winning goals
-- highlight players involved in decisive moments. Positional distribution
-- shows whether a team relies mainly on forwards or receives meaningful
-- scoring support from midfielders and defenders.

-- 5A. Most productive scorer-assister combinations
SELECT
    Club,
    Scorer,
    Provider,
    Goals
FROM V_TM_ScorerDuos
ORDER BY Goals DESC
LIMIT 20;

-- 5B. Goal contributions by substitutes
SELECT
    Player,
    Club,
    M AS substitute_appearances,
    Mn AS minutes_as_substitute,
    G AS goals,
    A AS assists,
    G + A AS goal_contributions
FROM V_TM_SuperSubs
ORDER BY goal_contributions DESC, goals DESC
LIMIT 20;

-- 5C. Players with the most winning goals
SELECT
    Player,
    Club,
    Goals AS total_goals,
    "Winning goals"
FROM V_TM_WinningGoals
ORDER BY "Winning goals" DESC, total_goals DESC
LIMIT 20;

-- 5D. Team goal distribution by position
SELECT
    Club,
    Defender,
    Midfielder,
    Forward,
    Total,
    ROUND(100.0 * Defender / NULLIF(Total, 0), 1) AS defender_share_pct,
    ROUND(100.0 * Midfielder / NULLIF(Total, 0), 1) AS midfielder_share_pct,
    ROUND(100.0 * Forward / NULLIF(Total, 0), 1) AS forward_share_pct
FROM V_TM_GoalDistributionPositions
ORDER BY Total DESC;
