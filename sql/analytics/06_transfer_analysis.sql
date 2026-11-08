-- CASE 06. TRANSFER MARKET ANALYSIS
-- Business question:
-- Which incoming transfers generated the largest recorded transfer fees,
-- and which clubs were involved in the move?
--
-- Source:
-- PlayerTeams contains player-team contract periods, transfer type and fee.
-- The self-join links the previous club spell to the next club spell for the
-- same player when the previous contract ended on the new contract start date.
--
-- RESULT:
-- A transfer list with player, previous club, new club, transfer date and fee.
--
-- INTERPRETATION:
-- The result can be used to review transfer spending and the distribution of
-- fees across clubs. Fee values depend on the completeness and conventions of
-- the source data; NULL fees are excluded and should not be interpreted as
-- zero-cost transfers.

-- 6A. Highest incoming transfer fees
SELECT
    ROW_NUMBER() OVER (ORDER BY incoming.fee_in DESC) AS fee_rank,
    p.player_name AS player,
    previous_team.team_name AS from_club,
    new_team.team_name AS to_club,
    incoming.contract_start AS transfer_date,
    incoming.fee_in AS fee_million_eur
FROM PlayerTeams AS incoming
JOIN Players AS p
    ON p.player_id = incoming.player_id
JOIN Teams AS new_team
    ON new_team.team_id = incoming.team_id
JOIN PlayerTeams AS previous
    ON previous.player_id = incoming.player_id
   AND previous.contract_end = incoming.contract_start
   AND previous.team_id <> incoming.team_id
JOIN Teams AS previous_team
    ON previous_team.team_id = previous.team_id
WHERE incoming.transfer_type_in = 'transfer'
  AND incoming.fee_in IS NOT NULL
ORDER BY incoming.fee_in DESC
LIMIT 25;

-- 6B. Transfer spending by destination club
WITH incoming_transfers AS (
    SELECT
        incoming.player_id,
        incoming.team_id,
        incoming.fee_in
    FROM PlayerTeams AS incoming
    WHERE incoming.transfer_type_in = 'transfer'
      AND incoming.fee_in IS NOT NULL
)
SELECT
    t.team_name,
    COUNT(*) AS transfers_in,
    ROUND(SUM(it.fee_in), 2) AS total_spent_million_eur,
    ROUND(AVG(it.fee_in), 2) AS avg_fee_million_eur
FROM incoming_transfers AS it
JOIN Teams AS t
    ON t.team_id = it.team_id
GROUP BY it.team_id, t.team_name
ORDER BY total_spent_million_eur DESC;
