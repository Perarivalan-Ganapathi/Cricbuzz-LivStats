USE db1;

-- 1.Player
CREATE TABLE players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50),
    playing_role VARCHAR(50),
    batting_style VARCHAR(50),
    bowling_style VARCHAR(50)
);

-- 2.teams
CREATE TABLE teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100),
    short_name VARCHAR(10),
    country VARCHAR(50)
);

-- 3.Venue
CREATE TABLE venues (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    capacity INT
);

-- 4.Series
CREATE TABLE series (
    series_id INT AUTO_INCREMENT PRIMARY KEY,
    series_name VARCHAR(150),
    host_country VARCHAR(50),
    match_type VARCHAR(20),
    start_date DATE,
    total_matches INT
);

-- 5.Matches
CREATE TABLE matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    series_id INT,
    match_desc VARCHAR(100),
    format VARCHAR(20),
    team1_id INT,
    team2_id INT,
    winner INT,
    victory_margin VARCHAR(50),
    victory_type VARCHAR(50),
    venue_id INT,
    start_date DATE,
    end_date DATE,
    state VARCHAR(20),
    status VARCHAR(200),
    toss_winner INT,
    toss_decision VARCHAR(20),
    FOREIGN KEY (series_id) REFERENCES series(series_id),
    FOREIGN KEY (venue_id) REFERENCES venues(venue_id),
    FOREIGN KEY (team1_id) REFERENCES teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES teams(team_id),
    FOREIGN KEY (winner) REFERENCES teams(team_id),
    FOREIGN KEY (toss_winner) REFERENCES teams(team_id)
);

-- 6.Batting
CREATE TABLE batting (
    player_id INT,
    match_id INT,
    runs INT,
    balls_faced INT,
    fours INT,
    sixes INT,
    strike_rate DECIMAL(5,2),
    highest_score INT,
    batting_average DECIMAL(5,2),
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- 7.Bowling
CREATE TABLE bowling (
    player_id INT,
    match_id INT,
    overs DECIMAL(4,1),
    maidens INT,
    runs_conceded INT,
    wickets INT,
    economy DECIMAL(4,2),
    bowling_average DECIMAL(5,2),
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- 8. Batting Partner
CREATE TABLE partnerships (
    match_id INT,
    innings INT,
    player1_id INT,
    player2_id INT,
    runs INT,
    PRIMARY KEY (match_id, innings, player1_id, player2_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (player1_id) REFERENCES players(player_id),
    FOREIGN KEY (player2_id) REFERENCES players(player_id)
);


