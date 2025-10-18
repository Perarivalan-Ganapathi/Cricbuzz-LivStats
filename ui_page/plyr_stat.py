import streamlit as st
import requests
import pandas as pd


API_HOST = "cricbuzz-cricket.p.rapidapi.com"
HEADERS = {
    "x-rapidapi-key":"9fa1f11d3dmsh2be749d1fa264a7p1600e6jsn782bb356cbbf",
    "x-rapidapi-host": API_HOST
}

# Endpoints
PLAYER_BATTING_URL = "https://cricbuzz-cricket.p.rapidapi.com/stats/v1/player/{player_id}/batting"
PLAYER_BOWLING_URL = "https://cricbuzz-cricket.p.rapidapi.com/stats/v1/player/{player_id}/bowling"
PLAYER_STATS_URL = "https://cricbuzz-cricket.p.rapidapi.com/stats/v1/player/{player_id}"
PLAYER_SEARCH_URL = "https://cricbuzz-cricket.p.rapidapi.com/stats/v1/player/search"


def pl_st():
    st.title("📊 Cricbuzz Player Stats Dashboard")

    st.subheader("🔎 Search for a Player")
    query = st.text_input("Enter Player Name")
    player_id, player_name = None, None

    # Search Player
    if st.button("Search Player") and query.strip():
        res = requests.get(PLAYER_SEARCH_URL, headers=HEADERS, params={"plrN": query.strip()})
        if res.status_code == 200:
            data = res.json()
            players = data.get("player", [])
            if players:
                player_options = {p.get("name", "Unknown"): p.get("id") for p in players if "id" in p}
                player_name = st.selectbox("Select Player", list(player_options.keys()))
                if player_name:
                    player_id = player_options[player_name]
            else:
                st.warning("⚠️ No players found. Try another name.")
        else:
            st.error(f"❌ API Error {res.status_code}: {res.text}")

    # Show Player Info
    if player_id:
        st.markdown(f"### 📌 {player_name} Stats")

        # Career Info
        info_res = requests.get(PLAYER_STATS_URL.format(player_id=player_id), headers=HEADERS)
        if info_res.status_code == 200:
            player_info = info_res.json()
            col1, col2 = st.columns([1, 3])
            with col2:
                st.markdown(f"**Name:** {player_info.get('name','N/A')}")
                st.markdown(f"**Country/Intl Team:** {player_info.get('intlTeam','N/A')}")
                st.markdown(f"**Teams:** {player_info.get('teams','N/A')}")
                st.markdown(f"**Role:** {player_info.get('role','N/A')}")
                st.markdown(f"**DOB:** {player_info.get('DoB','N/A')}")
                st.markdown(f"**Batting Style:** {player_info.get('bat','N/A')}")
                st.markdown(f"**Bowling Style:** {player_info.get('bowl','N/A')}")

            # Career Stats Summary
            career_stats = player_info.get("careerStats", [])
            if career_stats:
                st.write("#### 🏆 Career Stats Summary")
                career_df = pd.DataFrame(career_stats)
                st.dataframe(career_df)
        else:
            st.error("❌ Failed to fetch player info.")


        def convert_stats_to_df(stats_json):
            headers = stats_json.get("headers", [])
            values = stats_json.get("values", [])
            

            columns = headers[1:]
            rows = {}

            for row in values:
                row_vals = row.get("values", [])
                if row_vals:
                    stat_name = row_vals[0]
                    stat_values = row_vals[1:]
                    rows[stat_name] = stat_values
            
            df = pd.DataFrame(rows).T
            df.columns = columns
            df.index.name = "Stat"
            return df


        bat_res = requests.get(PLAYER_BATTING_URL.format(player_id=player_id), headers=HEADERS)
        if bat_res.status_code == 200:
            bat_data = bat_res.json()
            if "headers" in bat_data and "values" in bat_data:
                bat_df = convert_stats_to_df(bat_data)
                st.write("#### 🏏 Batting Stats")
                st.dataframe(bat_df)
        else:
            st.error("❌ Failed to fetch batting stats.")


        bowl_res = requests.get(PLAYER_BOWLING_URL.format(player_id=player_id), headers=HEADERS)
        if bowl_res.status_code == 200:
            bowl_data = bowl_res.json()
            if "headers" in bowl_data and "values" in bowl_data:
                bowl_df = convert_stats_to_df(bowl_data)
                st.write("#### 🎯 Bowling Stats")
                st.dataframe(bowl_df)
        else:
            st.error("❌ Failed to fetch bowling stats.")
        
        convert_stats_to_df(bowl_res.json())
        convert_stats_to_df(bat_res.json())