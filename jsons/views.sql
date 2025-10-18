use db1;

-- Primary table to fetch most data
CREATE TABLE db1.match_info (
    match_id INT PRIMARY KEY,
    series_id INT,
    series_name VARCHAR(255),
    match_desc VARCHAR(255),
    match_format VARCHAR(50),
    start_date DATETIME,
    state varchar(20),
    status VARCHAR(255),
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    venue VARCHAR(255),
    venue_id int,
    capacity int,
    city VARCHAR(100)
);

UPDATE db1.match_info
SET winner = TRIM(SUBSTRING_INDEX(status, ' won by ', 1)),
    victory_margin = REGEXP_SUBSTR(status, '[0-9]+'),
    victory_type = REGEXP_SUBSTR(status, '[0-9]+ (runs|wkts)')
WHERE status LIKE '%won by%';

ALTER TABLE db1.match_info
  ADD COLUMN team1_id INT,
  ADD COLUMN team2_id INT,
  ADD COLUMN winner_id INT,
  ADD COLUMN team1_sname VARCHAR(10),
  ADD COLUMN team2_sname VARCHAR(10),
  ADD COLUMN winner_sname VARCHAR(10);
  
ALTER TABLE db1.match_info
	ADD COLUMN toss_winner_id INT,
	ADD COLUMN toss_winner_name VARCHAR(100),
	ADD COLUMN toss_decision VARCHAR(10),
	ADD COLUMN toss_decision_text VARCHAR(100);

  select * from db1.match_info;


-- Recent matches players table
CREATE table db1.players (
	team_id varchar(100),
    player_id varchar(100),
    full_name VARCHAR(100),
    batting_style VARCHAR(50),
    bowling_style VARCHAR(50) NULL
);

SELECT * FROM db1.players;

CREATE TABLE db1.odi_stats (
id int,
batter VARCHAR(100) NOT NULL,
runs INT NOT NULL,
avg DECIMAL(6,2) NOT NULL,
hundreds INT NOT NULL
);

-- Top 10 high runs score in odi

 select * from db1.odi_stats;

CREATE TABLE db1.player_highscores (
    player_id INT,
    player_name VARCHAR(100),
    format VARCHAR(10),
    highest_score VARCHAR(10)
);

-- sample insertion
INSERT INTO player_highscores (player_id, player_name, format, highest_score)
VALUES
    (1643, 'Aaron Finch', 'Test', 62),
    (1643, 'Aaron Finch', 'ODI', 153),
    (1643, 'Aaron Finch', 'T20', 172),
    (1643, 'Aaron Finch', 'IPL', 88),
    (576, 'Rohit Sharma', 'Test', 212),
    (576, 'Rohit Sharma', 'ODI', 264),
    (576, 'Rohit Sharma', 'T20', 121),
    (576, 'Rohit Sharma', 'IPL', 109),
    (240, 'Brian Lara', 'Test', 400),
    (240, 'Brian Lara', 'ODI', 169),
    (240, 'Brian Lara', 'T20', 0),
    (240, 'Brian Lara', 'IPL', 0);
    
select * from db1.player_highscores;

-- Series from recent matches
CREATE TABLE db1.series (
    series_id BIGINT,
    series_name VARCHAR(255),
    host_country VARCHAR(100),
    match_type VARCHAR(50),
    start_date DATE,
    end_date DATE
);

select * from db1.series;

-- 2024 series table
CREATE TABLE db1.series24 (
    Match_ID BIGINT,
    Series_Id BIGINT,
    series VARCHAR(255),
    Start_Date BIGINT,
    End_Date BIGINT,
    Status VARCHAR(100),
    Match_Type VARCHAR(50),
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    Venue_Id BIGINT,
    Ground VARCHAR(150),
    City VARCHAR(150)
);

select * from db1.series24;
-- sample update
UPDATE db1.series24
SET Country = CASE City
    WHEN 'Kampala' THEN 'Uganda'
    WHEN 'Entebbe' THEN 'Uganda'
    WHEN 'Mong Kok' THEN 'Hong Kong'
    WHEN 'Kowloon' THEN 'Hong Kong'
    WHEN 'Kirtipur' THEN 'Nepal'
    WHEN 'Dubai' THEN 'United Arab Emirates'
    WHEN 'Dundee' THEN 'Scotland'
    WHEN 'Voorburg' THEN 'Netherlands'
    WHEN 'Windhoek' THEN 'Namibia'
    WHEN 'King City' THEN 'Canada'
    WHEN 'Houston' THEN 'United States'
    WHEN 'Dallas' THEN 'United States'
    WHEN 'Al Amerat' THEN 'Oman'
    WHEN 'Amstelveen' THEN 'Netherlands'
    WHEN 'Kampong, Utrecht' THEN 'Netherlands'
    WHEN 'Lauderhill, Florida' THEN 'United States'
    WHEN 'Nairobi' THEN 'Kenya'
    WHEN 'St Martin' THEN 'Caribbean island'
    WHEN 'St Saviour' THEN 'Jersey Islands, UK'
    ELSE 'Unknown'
END;

SELECT 
                series AS Series_Name,
                Country AS Host_Country,
                Match_Type,
                MIN(FROM_UNIXTIME(Start_Date/1000)) AS Start_Date,
                COUNT(Match_ID) AS Total_Matches_Planned
            FROM db1.series24
            WHERE YEAR(FROM_UNIXTIME(Start_Date/1000)) = 2024
            GROUP BY series, Country, Match_Type
            ORDER BY Start_Date;
            
-- Ques 11: Compare player stats in different format
CREATE TABLE db1.player_stats (
    player_id INT,
    player_name VARCHAR(100),
    format VARCHAR(10),
    matches INT,
    innings INT,
    runs INT,
    average DECIMAL(6,2)
);

select * from db1.player_stats;

SELECT 
    player_id,
    player_name,
    SUM(CASE WHEN format='test' THEN runs ELSE 0 END) AS total_runs_test,
    SUM(CASE WHEN format='odi' THEN runs ELSE 0 END) AS total_runs_odi,
    SUM(CASE WHEN format='t20' THEN runs ELSE 0 END) AS total_runs_t20i,
    ROUND(SUM(runs) * 1.0 / NULLIF(SUM(innings), 0), 2) AS overall_batting_avg
FROM db1.player_stats
GROUP BY player_id, player_name
HAVING COUNT(DISTINCT format) >= 2;

-- Table of CRUD operation in 4th section
create table db1.crud(
player_id int,
batter varchar(100),
matches int,
innings int,
runs int,
average int);

select * from db1.crud;

-- Batting scorecard or partnership table
CREATE TABLE db1.partnerships (
    match_id INT,
    innings_id INT,
    bat1_id INT,
    bat1_name VARCHAR(100),
    bat1_runs INT,
    bat2_id INT,
    bat2_name VARCHAR(100),
    bat2_runs INT,
    total_runs INT
);

alter table partnerships add column bat2_balls int;

select count(*) from db1.partnerships;

-- Bowlers Scorecard
CREATE TABLE db1.bowling_performance (
    match_id INT,
    innings_no INT,
    bowler_id INT,
    bowler_name VARCHAR(100),
    overs FLOAT,
    maidens INT,
    runs_conceded INT,
    wickets INT,
    economy FLOAT
);

select * from db1.bowling_performance;
describe db1.bowling_performance;
-- Question 15 creating views instead of table:

use db1;

CREATE VIEW batsmen_union AS
SELECT match_id, innings_id, bat1_id AS player_id, bat1_name AS player_name, bat1_runs AS runs_scored, bat1_balls AS balls_faced
FROM db1.partnerships

UNION ALL

SELECT match_id, innings_id, bat2_id AS player_id, bat2_name AS player_name, bat2_runs AS runs_scored, bat2_balls AS balls_faced
FROM db1.partnerships;


CREATE VIEW close_matches AS
SELECT match_id, winner_id, win_by, victory_margin
FROM db1.match_info
WHERE (win_by = 'runs' AND victory_margin < 50) OR (win_by LIKE '%wk%' AND victory_margin < 5);


-- Ques 16:

SELECT 
    b.player_name,
    YEAR(m.start_date) AS match_year,
    COUNT(DISTINCT b.match_id) AS matches_played,
    ROUND(AVG(b.runs_scored), 2) AS avg_runs_per_match,
    ROUND(AVG((b.runs_scored / NULLIF(b.balls_faced,0)) * 100), 2) AS avg_strike_rate
FROM batsmen_union b
JOIN match_info m 
    ON b.match_id = m.match_id
WHERE YEAR(m.start_date) >= 2020
GROUP BY b.player_name, YEAR(m.start_date)
HAVING matches_played >= 3
ORDER BY match_year DESC, avg_runs_per_match DESC;


-- Ques 18:

SELECT 
    b.bowler_name,
    mi.match_format,
    COUNT(DISTINCT b.match_id) AS matches_played,
    SUM(b.overs) AS total_overs,
    SUM(b.runs_conceded) AS total_runs,
    SUM(b.wickets) AS total_wickets,
    ROUND(SUM(b.runs_conceded) / SUM(b.overs), 2) AS economy_rate,
    ROUND(SUM(b.overs) / COUNT(DISTINCT b.match_id), 2) AS avg_overs_per_match
FROM db1.bowling_performance b
JOIN db1.match_info mi 
    ON b.match_id = mi.match_id
WHERE mi.match_format IN ('ODI', 'T20')
GROUP BY b.bowler_id, b.bowler_name, mi.match_format
HAVING 
    COUNT(DISTINCT b.match_id) >= 3
    AND (SUM(b.overs) / COUNT(DISTINCT b.match_id)) >= 2
ORDER BY economy_rate ASC
LIMIT 20;

-- Ques 19: Batsman consistancy

create view player_consistency AS (
    SELECT
        bu.player_id,
        bu.player_name,
        COUNT(DISTINCT bu.match_id) AS matches_played,
        AVG(bu.runs_scored) AS avg_runs,
        STDDEV_SAMP(bu.runs_scored) AS run_stddev
    FROM db1.batsmen_union bu
    JOIN db1.match_info mi ON bu.match_id = mi.match_id
    WHERE YEAR(mi.start_date) >= 2022
      AND bu.balls_faced >= 10
    GROUP BY bu.player_id, bu.player_name
    HAVING matches_played >= 3
);

-- Ques 20:

create view db1.player_format_stats AS (
    SELECT
        bu.player_id,
        bu.player_name,
        mi.match_format,
        COUNT(DISTINCT bu.match_id) AS matches_played,
        SUM(bu.runs_scored) AS total_runs,
        AVG(bu.runs_scored) AS avg_runs
    FROM batsmen_union bu
    JOIN match_info mi ON bu.match_id = mi.match_id
    WHERE mi.match_format IN ('Test', 'ODI', 'T20')
    GROUP BY bu.player_id, bu.player_name, mi.match_format
);
create view db1.player_summary AS (
    SELECT
        player_id,
        player_name,
        SUM(CASE WHEN match_format = 'Test' THEN matches_played ELSE 0 END) AS test_matches,
        SUM(CASE WHEN match_format = 'ODI' THEN matches_played ELSE 0 END) AS odi_matches,
        SUM(CASE WHEN match_format = 'T20' THEN matches_played ELSE 0 END) AS t20_matches,
        ROUND(SUM(CASE WHEN match_format = 'Test' THEN total_runs ELSE 0 END) /
              NULLIF(SUM(CASE WHEN match_format = 'Test' THEN matches_played ELSE 0 END), 0), 2) AS test_avg,
        ROUND(SUM(CASE WHEN match_format = 'ODI' THEN total_runs ELSE 0 END) /
              NULLIF(SUM(CASE WHEN match_format = 'ODI' THEN matches_played ELSE 0 END), 0), 2) AS odi_avg,
        ROUND(SUM(CASE WHEN match_format = 'T20' THEN total_runs ELSE 0 END) /
              NULLIF(SUM(CASE WHEN match_format = 'T20' THEN matches_played ELSE 0 END), 0), 2) AS t20_avg,
        SUM(matches_played) AS total_matches
    FROM player_format_stats
    GROUP BY player_id, player_name
);


-- Ques 21:

create view batting_stats AS (
    SELECT
        player_id,
        match_id,
        player_name,
        SUM(runs_scored) AS total_runs,
        AVG(runs_scored) AS batting_avg,
        ROUND((SUM(runs_scored) / NULLIF(SUM(balls_faced), 0)) * 100, 2) AS strike_rate
    FROM batsmen_union
    GROUP BY player_id, player_name
);
create view bowling_stats AS (
    SELECT
        bowler_id AS player_id,
        bowler_name,
        SUM(wickets) AS total_wickets,
        ROUND(SUM(runs_conceded) / NULLIF(SUM(wickets), 0), 2) AS bowling_avg,
        ROUND(SUM(runs_conceded) / NULLIF(SUM(overs), 0), 2) AS economy_rate
    FROM bowling_performance
    GROUP BY bowler_id, bowler_name
);

create view combined_stat AS (
    SELECT
        COALESCE(b.player_id, bo.player_id) AS player_id,
        COALESCE(b.player_name, bo.bowler_name) AS player_name,
        
        -- Batting metrics
        b.total_runs,
        b.batting_avg,
        b.strike_rate,
        
        -- Bowling metrics
        bo.total_wickets,
        bo.bowling_avg,
        bo.economy_rate,
        
        -- Weighted scores
        ROUND(
            COALESCE((b.total_runs * 0.01) + (b.batting_avg * 0.5) + (b.strike_rate * 0.3), 0)
        ,2) AS batting_points,
        
        ROUND(
            COALESCE((bo.total_wickets * 2) + ((50 - bo.bowling_avg) * 0.5) + ((6 - bo.economy_rate) * 2), 0)
        ,2) AS bowling_points
    FROM batting_stats b
    JOIN bowling_stats bo ON b.player_id = bo.player_id
);

-- Ques 22:

CREATE TABLE db1.team_head_to_head (
    team_a VARCHAR(50),
    team_b VARCHAR(50),
    total_matches INT,
    team_a_wins INT,
    team_b_wins INT,
    team_a_avg_margin FLOAT,
    team_b_avg_margin FLOAT,
    team_a_win_pct FLOAT,
    team_b_win_pct FLOAT,
    team_a_batfirst_wins INT,
    team_b_batfirst_wins INT,
    team_a_bowlfirst_wins INT,
    team_b_bowlfirst_wins INT,
    most_common_venue VARCHAR(100)
);
use db1;

INSERT INTO team_head_to_head
SELECT 
    LEAST(team1_sname, team2_sname) AS team_a,
    GREATEST(team1_sname, team2_sname) AS team_b,
    COUNT(*) AS total_matches,

    SUM(CASE WHEN winner_sname = team1_sname THEN 1 ELSE 0 END) AS team_a_wins,
    SUM(CASE WHEN winner_sname = team2_sname THEN 1 ELSE 0 END) AS team_b_wins,

    AVG(CASE WHEN winner_sname = team1_sname THEN victory_margin ELSE NULL END) AS team_a_avg_margin,
    AVG(CASE WHEN winner_sname = team2_sname THEN victory_margin ELSE NULL END) AS team_b_avg_margin,

    ROUND(SUM(CASE WHEN winner_sname = team1_sname THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS team_a_win_pct,
    ROUND(SUM(CASE WHEN winner_sname = team2_sname THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS team_b_win_pct,

    SUM(CASE WHEN winner_sname = team1_sname AND toss_decision = 'bat' THEN 1 ELSE 0 END) AS team_a_batfirst_wins,
    SUM(CASE WHEN winner_sname = team2_sname AND toss_decision = 'bat' THEN 1 ELSE 0 END) AS team_b_batfirst_wins,
    SUM(CASE WHEN winner_sname = team1_sname AND toss_decision = 'bowl' THEN 1 ELSE 0 END) AS team_a_bowlfirst_wins,
    SUM(CASE WHEN winner_sname = team2_sname AND toss_decision = 'bowl' THEN 1 ELSE 0 END) AS team_b_bowlfirst_wins,

    (
        SELECT venue 
        FROM match_info m2 
        WHERE (m2.team1_sname IN (team1_sname, team2_sname) 
               AND m2.team2_sname IN (team1_sname, team2_sname))
        GROUP BY venue 
        ORDER BY COUNT(*) DESC 
        LIMIT 1
    ) AS most_common_venue

FROM match_info
WHERE state = 'Complete'
  AND match_format IN ('ODI', 'T20')
  AND start_date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
  AND team1_sname IS NOT NULL
  AND team2_sname IS NOT NULL
GROUP BY LEAST(team1_sname, team2_sname), GREATEST(team1_sname, team2_sname);


-- Ques 23:

CREATE TABLE db1.player_recent_form (
    player_id INT,
    player_name VARCHAR(100),
    avg_last5 FLOAT,
    avg_last10 FLOAT,
    scores_50_plus_last10 INT,
    stddev_last10 FLOAT,
    avg_strike_rate_last10 FLOAT,
    form_category VARCHAR(20)
);


-- insert data from match_info and batsmen_union

INSERT INTO player_recent_form (player_id, player_name, avg_last5, avg_last10,
scores_50_plus_last10, stddev_last10, avg_strike_rate_last10, form_category)
WITH ranked_innings AS (
    SELECT 
        bu.player_id,
        bu.player_name,
        bu.runs_scored,
        bu.balls_faced,
        mi.start_date,
        ROW_NUMBER() OVER(PARTITION BY bu.player_id ORDER BY mi.start_date DESC) AS rn
    FROM batsmen_union bu
    JOIN match_info mi ON bu.match_id = mi.match_id
),

 last10 AS (SELECT * FROM ranked_innings WHERE rn <= 10)
 

SELECT 
    player_id,
    player_name,
    AVG(CASE WHEN rn <= 5 THEN runs_scored END) AS avg_last5,
    AVG(runs_scored) AS avg_last10,
    SUM(CASE WHEN runs_scored >= 50 THEN 1 ELSE 0 END) AS scores_50_plus_last10,
    STDDEV(runs_scored) AS stddev_last10,
    (AVG(CASE WHEN balls_faced > 0 THEN runs_scored * 100.0 / balls_faced END)) AS avg_strike_rate_last10,
    (CASE
        WHEN AVG(CASE WHEN rn <= 5 THEN runs_scored END) > 50 AND STDDEV(runs_scored) < 20 THEN 'Excellent Form'
        WHEN AVG(CASE WHEN rn <= 5 THEN runs_scored END) BETWEEN 35 AND 50 THEN 'Good Form'
        WHEN AVG(CASE WHEN rn <= 5 THEN runs_scored END) BETWEEN 20 AND 35 THEN 'Average Form'
		ELSE 'Poor Form'
        END) AS form_category FROM last10 GROUP BY player_id, player_name;



-- Ques 24:
CREATE TABLE db1.partnership_analysis (
    player1 VARCHAR(100),
    player2 VARCHAR(100),
    total_partnerships INT,
    avg_partnership_runs FLOAT,
    fifty_plus_count INT,
    highest_partnership INT,
    success_rate FLOAT,
    PRIMARY KEY (player1, player2)
);

INSERT INTO db1.partnership_analysis (player1, player2, total_partnerships,
avg_partnership_runs, fifty_plus_count, highest_partnership, success_rate)
SELECT 
    LEAST(bat1_name, bat2_name) AS player1,
    GREATEST(bat1_name, bat2_name) AS player2,
    COUNT(*) AS total_partnerships,
    AVG(total_runs) AS avg_partnership_runs,
    SUM(CASE WHEN total_runs >= 50 THEN 1 ELSE 0 END) AS fifty_plus_count,
    MAX(total_runs) AS highest_partnership,
    ROUND(SUM(CASE WHEN total_runs >= 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM db1.partnerships
GROUP BY player1, player2
HAVING COUNT(*) >= 3;

select * from db1.partnership_analysis;


-- Ques 25: TimeSeries analysis

CREATE TABLE db1.quarterly_matches AS
SELECT *, NULL AS quartre FROM db1.match_info;

ALTER TABLE db1.quarterly_matches ADD COLUMN q_no INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE db1.quarterly_matches MODIFY quartre VARCHAR(5);


UPDATE db1.quarterly_matches
SET quartre = CASE
    WHEN q_no BETWEEN 1 AND 10 THEN 'Q1'
    WHEN q_no BETWEEN 11 AND 20 THEN 'Q2'
    WHEN q_no BETWEEN 21 AND 30 THEN 'Q3'
    ELSE 'Q4'
END;
select * from db1.quarterly_matches ;

CREATE TABLE db1.time_series_analysis (
    player_id INT,
    player_name VARCHAR(100),
    year INT,
    quartre VARCHAR(5),
    avg_runs FLOAT,
    avg_strike_rate FLOAT,
    matches_played INT
);
use db1;

INSERT INTO db1.time_series_analysis (player_id, player_name, year, quartre, avg_runs, avg_strike_rate, matches_played)
SELECT 
    b.player_id,
    p.full_name AS player_name,
    YEAR(qm.start_date) AS year,
    qm.quartre,
    AVG(b.total_runs) AS avg_runs,
    AVG(b.strike_rate) AS avg_strike_rate,
    COUNT(DISTINCT b.match_id) AS matches_played
FROM batting_stats b
JOIN players p ON b.player_id = p.player_id
JOIN quarterly_matches qm ON b.match_id = qm.match_id
GROUP BY b.player_id, p.full_name, year, qm.quartre
HAVING matches_played >= 3;

select * from db1.batting_stats;


