import pymysql
import streamlit as st
import pandas as pd

def connect_pymysql():
        connect = pymysql.connect(
            host="localhost",
            user="root",
            password="0406",
            database="db1",
            port=3306,
            cursorclass=pymysql.cursors.DictCursor
        )
        st.success("✅ MySQL connection successful!")
        return connect


def sql_page():
    st.title("📊 Cricket SQL Analytics")

    sql_questions = {
        "1. Find all players who represent India": """
            SELECT full_name, role, batting_style, bowling_style
            FROM players
            WHERE team_id = '2';
        """,
        "2. Show all cricket matches in the last 30 days": """
            SELECT match_desc, team1, team2, venue, city, start_date, status
            FROM match_info
            WHERE start_date >= CURRENT_DATE - INTERVAL 30 DAY
            ORDER BY start_date DESC;
        """,
        "3. Top 10 highest run scorers in ODI cricket": """
            SELECT id, batter, runs, avg, hundreds
            FROM odi_stats
            ORDER BY runs DESC
            LIMIT 10;
        """,
        "4. Venues with capacity > 50,000": """
            SELECT venue, city, country, capacity
            FROM match_info
            WHERE capacity >= 50000
            ORDER BY capacity DESC;
        """,
        "5. Matches won by each team": """
            SELECT winner AS team_name, COUNT(*) AS total_wins
            FROM match_info
            WHERE winner IS NOT NULL
            GROUP BY winner
            ORDER BY total_wins DESC;
        """,
        "6. Count players by playing role": """
            SELECT role, COUNT(*) AS player_count
            FROM players
            GROUP BY role;
        """,
        "7. Highest individual batting score in each format": """
            SELECT format, max(highest_score) AS max_score
            FROM player_highscores
            GROUP BY format;
        """,
        "8. Cricket series that started in 2024": """
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
        """,

        "9. All-rounders with >1000 runs AND >50 wickets": """
            SELECT player_name, ranking, total_runs, total_wickets, format
            FROM allrounders
            WHERE total_runs > 1000 AND total_wickets > 50 order by ranking;
        """,
        "10. Last 20 completed matches": """
            SELECT match_desc, team1, team2, victory_margin, win_by,
            venue, start_date FROM match_info
            WHERE state = 'Complete'
            ORDER BY start_date DESC
            LIMIT 20;
;
        """,
        "11. Compare each player's performance across formats": """
            SELECT player_name,
                   SUM(CASE WHEN format='Test' THEN runs ELSE 0 END) AS test_runs,
                   SUM(CASE WHEN format='ODI' THEN runs ELSE 0 END) AS odi_runs,
                   SUM(CASE WHEN format='T20I' THEN runs ELSE 0 END) AS t20_runs,
                   AVG(average) AS overall_avg
            FROM player_stats
            GROUP BY player_name
            HAVING COUNT(DISTINCT format) >= 2;
        """,
        "12. Team performance home vs away": """
            SELECT winner_id, winner_sname AS team,
                    SUM(CASE WHEN country = winner THEN 1 ELSE 0 END) AS home_wins,
                    SUM(CASE WHEN country <> winner THEN 1 ELSE 0 END) AS away_wins
                FROM db1.match_info
                WHERE winner_id IS NOT NULL
                AND winner_id IN (team1_id, team2_id)
                GROUP BY winner_id, winner_sname
                ORDER BY winner_sname;
        """,
        "13. Batting partnerships ≥100 runs": """
            SELECT p.bat1_name, p.bat2_name, m.team1 as Team_Name, m.match_format, p.total_runs, p.innings_id
            FROM db1.partnerships p left join db1.match_info m on p.match_id = m.match_id
            WHERE total_runs >= 100
            ORDER BY total_runs DESC;
        """,
        "14. Bowling performance by venue": """
            SELECT bp.bowler_id, bp.bowler_name, mi.venue,
                    COUNT(DISTINCT bp.match_id) AS matches_played,
                    SUM(bp.wickets) AS total_wickets,
                    ROUND(AVG(bp.economy), 2) AS avg_economy
                FROM db1.bowling_performance bp
                JOIN db1.match_info mi ON bp.match_id = mi.match_id
                WHERE bp.overs >= 4
                GROUP BY bp.bowler_id, bp.bowler_name, mi.venue
                HAVING COUNT(DISTINCT bp.match_id) >= 3
                ORDER BY total_wickets DESC, avg_economy ASC;
        """,
        "15. Players in close matches (<50 runs OR <5 wickets)": """
            SELECT 
                    b.player_name,
                    COUNT(DISTINCT b.match_id) AS close_matches_played,
                    ROUND(AVG(b.runs_scored), 2) AS avg_runs_in_close_matches,
                    SUM(CASE WHEN m.winner_id IS NOT NULL THEN 1 ELSE 0 END) AS close_matches_won
                FROM batsmen_union b
                JOIN close_matches m 
                    ON b.match_id = m.match_id
                GROUP BY b.player_name
                HAVING close_matches_played >= 2
                ORDER BY avg_runs_in_close_matches DESC
                LIMIT 20;
        """,
        "16. Players’ batting trend since 2020": """
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
        """,

        "17. Toss impact on match results": """
              SELECT match_id, match_desc, match_format, winner as match_winner, toss_winner_name, toss_decision, winner_sname
                FROM match_info
                WHERE toss_winner_id IS NOT NULL
                LIMIT 10;
        """,
        "18. Most economical bowlers (ODI & T20)": """
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
        """,
        "19. Consistent batsmen (low std dev)": """
            SELECT
                player_name,
                matches_played,
                ROUND(avg_runs, 2) AS avg_runs,
                ROUND(run_stddev, 2) AS consistency_stddev
            FROM db1.player_consistency
            ORDER BY run_stddev ASC, avg_runs DESC;
        """,
        "20. Matches played & averages across formats": """
            SELECT
                player_name,
                test_matches,
                test_avg,
                odi_matches,
                odi_avg,
                t20_matches,
                t20_avg,
                total_matches
            FROM player_summary
            WHERE total_matches >= 3 
            ORDER BY total_matches DESC;
        """,
        "21. Performance ranking system": """
            SELECT
                player_name,
                ROUND(batting_points + bowling_points, 2) AS total_performance_score,
                batting_points,
                bowling_points,
                RANK() OVER (ORDER BY (batting_points + bowling_points) DESC) AS performance_rank
            FROM combined_stat
            ORDER BY total_performance_score DESC;
        """,
        "22. Head-to-head analysis": """
            select * from db1.team_head_to_head;
        """,
        "23. Recent player form (last 10 innings)": """
            select * from db1.player_recent_form;
        """,
        "24. Best batting partnerships": """
            SELECT * FROM partnership_analysis ORDER BY success_rate DESC LIMIT 10;
        """,
        "25. Time-series career analysis": """
            SELECT player_name, quartre, year, avg_runs, avg_strike_rate, matches_played, performance_trend
            FROM players_timeseries_analysis;

        """
    }
    

    selected_query = st.selectbox("🔍 Select a query:", list(sql_questions.keys()))
    query_to_run = sql_questions[selected_query]

    if st.button("Run Query"):
        cursor = None
        connection = None
        try:
            connection = connect_pymysql()
            cursor = connection.cursor()
            
            cursor.execute(query_to_run)
            rows = cursor.fetchall()
            df = pd.DataFrame(rows)
            
            if not df.empty:
                st.dataframe(df, use_container_width=True)
            else:
                st.warning("⚠️ Query returned no results.")

        except Exception as e:
            st.error(f"❌ Error running query: {e}")

        finally:
            if cursor is not None:
                cursor.close()
            if connection is not None:
                connection.close()

