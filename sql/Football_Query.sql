--- Market Analysis
WITH CTE AS(
SELECT
	SUM(a.minutes_played) AS total_minutes_plays,
	SUM(a.goals) AS total_goals,
	SUM(a.assists) AS total_assists,
	SUM(a.yellow_cards) AS total_yellow,
	SUM(a.red_cards) AS total_red,
	p.player_id,
	p.name AS player_name,
	DATEDIFF(year, p.date_of_birth, '2016-05-29') AS ages, 
	p.sub_position,
	p.foot,
	c.name AS club_name
FROM
	appearances a
	JOIN players p ON a.player_id = p.player_id
	JOIN clubs c ON a.player_club_id = c.club_id
GROUP BY
	p.player_id,
	p.name,
	DATEDIFF(year, p.date_of_birth, '2016-05-29'), 
	p.sub_position,
	p.foot,
	c.name
),
CTE2 AS(
SELECT
	*,
	((CAST(total_goals AS FLOAT) + total_assists)/total_minutes_plays)*90 AS ga_90
FROM
	CTE
ORDER BY
	total_goals DESC, 
	total_assists DESC
OFFSET 0 ROWS FETCH NEXT 200 ROWS ONLY
),
CTE3 AS(
SELECT
	player_id,
	date,
	market_value_in_eur
FROM
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY date DESC) AS rn
	FROM
		player_valuations
	WHERE
		date BETWEEN '2015-01-01' AND (SELECT MAX(date) FROM games)) AS subquery
WHERE
	rn = 1
)
SELECT
	c2.total_goals,
	c2.total_assists,
	c2.ga_90,
	c2.player_id,
	c2.player_name,
	c2.ages,
	c2.sub_position,
	c2.foot,
	c2.club_name,
	c3.market_value_in_eur
FROM
	CTE2 c2
	JOIN CTE3 c3 ON c2.player_id = c3.player_id
WHERE
	c2.sub_position LIKE 'Right Winger'
ORDER BY
	c2.total_goals DESC,
	c2.total_assists DESC,
	c3.market_value_in_eur;


--- Dembélé Info
WITH player_values AS(
SELECT
	player_id,
	date,
	market_value_in_eur
FROM
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY date DESC) AS rn
	FROM
		player_valuations
	WHERE
		date BETWEEN '2015-01-01' AND (SELECT MAX(date) FROM games)) AS subquery
WHERE
	rn = 1
)
SELECT DISTINCT
	p.name AS player_name, 
	p.date_of_birth,
	p.height_in_cm,
	p.sub_position,
	p.country_of_citizenship,
	c.name AS club_name, 
	pv.market_value_in_eur
FROM
	game_lineups gl
	JOIN players p ON gl.player_id = p.player_id
	JOIN clubs c ON gl.club_id = c.club_id
	JOIN player_values pv ON pv.player_id = p.player_id
WHERE
	p.player_id = 288230

--- Dembélé Goal Types

SELECT
	player_id, 
	goal_types,
	COUNT(*) AS goal_type_count
FROM
	game_events
WHERE
	player_id = 288230 AND
	type LIKE 'Goals'
GROUP BY
	player_id, 
	goal_types
ORDER BY
	player_id

--- Dembélé Assist Types

SELECT
	player_assist_id, 
	assist_types,
	COUNT(*) AS assist_type_count
FROM
	game_events
WHERE
	player_assist_id = 288230 AND
	type LIKE 'Goals'
GROUP BY
	player_assist_id, 
	assist_types
ORDER BY
	player_assist_id

--- Dembélé Tactical Formations

WITH home_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.home_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.home_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
),

away_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.away_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.away_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
)

SELECT 
    player_id,
    player_name,
    position,
    formation,
    SUM(formation_count) AS total_formation_count
FROM (
    SELECT 
        player_id,
        player_name,
        position,
        away_club_formation AS formation,
        formation_count
    FROM away_formations

    UNION ALL

    SELECT 
        player_id,
        player_name,
        position,
        home_club_formation AS formation,
        formation_count
    FROM home_formations
) AS combined
GROUP BY 
    player_id,
    player_name,
    position,
    formation
HAVING
	player_id = 288230
ORDER BY 
    player_id, player_name, position, formation;


--- Ziyech Info

WITH player_values AS(
SELECT
	player_id,
	date,
	market_value_in_eur
FROM
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY date DESC) AS rn
	FROM
		player_valuations
	WHERE
		date BETWEEN '2015-01-01' AND (SELECT MAX(date) FROM games)) AS subquery
WHERE
	rn = 1
)
SELECT DISTINCT
	p.name AS player_name, 
	p.date_of_birth,
	p.height_in_cm,
	p.sub_position,
	p.country_of_citizenship,
	c.name AS club_name, 
	pv.market_value_in_eur
FROM
	game_lineups gl
	JOIN players p ON gl.player_id = p.player_id
	JOIN clubs c ON gl.club_id = c.club_id
	JOIN player_values pv ON pv.player_id = p.player_id
WHERE
	p.player_id = 217111

--- Ziyech Goal Types

SELECT
	player_id, 
	goal_types,
	COUNT(*) AS goal_type_count
FROM
	game_events
WHERE
	player_id = 217111 AND
	type LIKE 'Goals'
GROUP BY
	player_id, 
	goal_types
ORDER BY
	player_id

--- Ziyech Assist Types

SELECT
	player_assist_id, 
	assist_types,
	COUNT(*) AS assist_type_count
FROM
	game_events
WHERE
	player_assist_id = 217111 AND
	type LIKE 'Goals'
GROUP BY
	player_assist_id, 
	assist_types
ORDER BY
	player_assist_id

--- Ziyech Tactical Formations

WITH home_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.home_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.home_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
),

away_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.away_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.away_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
)

SELECT 
    player_id,
    player_name,
    position,
    formation,
    SUM(formation_count) AS total_formation_count
FROM (
    SELECT 
        player_id,
        player_name,
        position,
        away_club_formation AS formation,
        formation_count
    FROM away_formations

    UNION ALL

    SELECT 
        player_id,
        player_name,
        position,
        home_club_formation AS formation,
        formation_count
    FROM home_formations
) AS combined
GROUP BY 
    player_id,
    player_name,
    position,
    formation
HAVING
	player_id = 217111
ORDER BY 
    player_id, player_name, position, formation;

--- Mahrez Info

WITH player_values AS(
SELECT
	player_id,
	date,
	market_value_in_eur
FROM
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY date DESC) AS rn
	FROM
		player_valuations
	WHERE
		date BETWEEN '2015-01-01' AND (SELECT MAX(date) FROM games)) AS subquery
WHERE
	rn = 1
)
SELECT DISTINCT
	p.name AS player_name, 
	p.date_of_birth,
	p.height_in_cm,
	p.sub_position,
	p.country_of_citizenship,
	c.name AS club_name, 
	pv.market_value_in_eur
FROM
	game_lineups gl
	JOIN players p ON gl.player_id = p.player_id
	JOIN clubs c ON gl.club_id = c.club_id
	JOIN player_values pv ON pv.player_id = p.player_id
WHERE
	p.player_id = 171424

--- Mahrez Goal Types

SELECT
	player_id, 
	goal_types,
	COUNT(*) AS goal_type_count
FROM
	game_events
WHERE
	player_id = 171424 AND
	type LIKE 'Goals'
GROUP BY
	player_id, 
	goal_types
ORDER BY
	player_id

--- Mahrez Assist Types

SELECT
	player_assist_id, 
	assist_types,
	COUNT(*) AS assist_type_count
FROM
	game_events
WHERE
	player_assist_id = 171424 AND
	type LIKE 'Goals'
GROUP BY
	player_assist_id, 
	assist_types
ORDER BY
	player_assist_id

--- Mahrez Tactical Formation

WITH home_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.home_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.home_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
),

away_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.away_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.away_club_formation
HAVING
	p.player_id IN (217111, 171424, 148455, 288230)
)

SELECT 
    player_id,
    player_name,
    position,
    formation,
    SUM(formation_count) AS total_formation_count
FROM (
    SELECT 
        player_id,
        player_name,
        position,
        away_club_formation AS formation,
        formation_count
    FROM away_formations

    UNION ALL

    SELECT 
        player_id,
        player_name,
        position,
        home_club_formation AS formation,
        formation_count
    FROM home_formations
) AS combined
GROUP BY 
    player_id,
    player_name,
    position,
    formation
HAVING
	player_id = 171424
ORDER BY 
    player_id, player_name, position, formation;


--- Summary Data for Final Comparision

WITH CTE AS(
SELECT
	SUM(a.minutes_played) AS total_minutes_plays,
	SUM(a.goals) AS total_goals,
	SUM(a.assists) AS total_assists,
	SUM(a.yellow_cards) AS total_yellow,
	SUM(a.red_cards) AS total_red,
	p.player_id,
	p.name AS player_name,
	DATEDIFF(year, p.date_of_birth, '2016-05-29') AS ages, 
	p.sub_position,
	p.foot,
	c.name AS club_name
FROM
	appearances a
	JOIN players p ON a.player_id = p.player_id
	JOIN clubs c ON a.player_club_id = c.club_id
GROUP BY
	p.player_id,
	p.name,
	DATEDIFF(year, p.date_of_birth, '2016-05-29'), 
	p.sub_position,
	p.foot,
	c.name
),
CTE2 AS(
SELECT
	*,
	((CAST(total_goals AS FLOAT) + total_assists)/total_minutes_plays)*90 AS ga_90
FROM
	CTE
ORDER BY
	total_goals DESC, 
	total_assists DESC
OFFSET 0 ROWS FETCH NEXT 200 ROWS ONLY
),
CTE3 AS(
SELECT
	player_id,
	date,
	market_value_in_eur
FROM
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY date DESC) AS rn
	FROM
		player_valuations
	WHERE
		date BETWEEN '2015-01-01' AND (SELECT MAX(date) FROM games)) AS subquery
WHERE
	rn = 1
)
SELECT
	c2.player_id,
	c2.player_name,
	c2.ages,
    c2.ga_90
FROM
	CTE2 c2
WHERE
	c2.sub_position LIKE 'Right Winger'

--- Goal Data for Final Comparision

SELECT
	player_id, 
	goal_types,
	COUNT(*) AS goal_type_count
FROM
	game_events
WHERE
	player_id IN (171424, 217111, 288230) AND
	type LIKE 'Goals'
GROUP BY
	player_id, 
	goal_types
ORDER BY
	player_id   

--- Assist Data for Final Comparision

SELECT
	player_assist_id, 
	assist_types,
	COUNT(*) AS assist_type_count
FROM
	game_events
WHERE
	player_assist_id IN (171424, 217111, 288230) AND
	type LIKE 'Goals'
GROUP BY
	player_assist_id,
	assist_types
ORDER BY
	player_assist_id

--- Tactical Data for Final Comparision

WITH home_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.home_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.home_club_formation
HAVING
	p.player_id IN (171424, 217111, 288230)
),

away_formations AS(
SELECT
	p.player_id,
	p.name AS player_name,
	gl.position,
	g.away_club_formation,	
	COUNT(*) AS formation_count
FROM
	players p
	JOIN game_lineups gl ON p.player_id = gl.player_id
	JOIN games g ON gl.game_id = g.game_id AND (g.home_club_id = gl.club_id OR g.away_club_id = gl.club_id)
GROUP BY
	p.player_id,
	p.name,
	gl.position,
	g.away_club_formation
HAVING
	p.player_id IN (171424, 217111, 288230)
)

SELECT 
    player_id,
    COUNT(DISTINCT position) AS unique_positions,
    COUNT(DISTINCT formation) AS unique_formations
FROM (
    SELECT 
        player_id,
        player_name,
        position,
        away_club_formation AS formation,
        formation_count
    FROM away_formations

    UNION ALL

    SELECT 
        player_id,
        player_name,
        position,
        home_club_formation AS formation,
        formation_count
    FROM home_formations
) AS combined
GROUP BY 
    player_id
ORDER BY 
    player_id