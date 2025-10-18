# Stage 1

import time
import requests

url = "https://cricbuzz-cricket.p.rapidapi.com/matches/v1/recent"

headers = {
	"x-rapidapi-key": "9fa1f11d3dmsh2be749d1fa264a7p1600e6jsn782bb356cbbf",
	"x-rapidapi-host": "cricbuzz-cricket.p.rapidapi.com"
}

response = requests.get(url, headers=headers)

if response.status_code == 429:
    time.sleep(10)
    response = requests.get(url, headers=headers)

response.raise_for_status()
data = response.json()

site_url = "https://cricbuzz-cricket.p.rapidapi.com"

def fetch_data(endpoint):
    url = f"{site_url}/{endpoint}"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def parse_scorecard(match_id):
    """
    Fetch and parse scorecard data for a given match_id.
    Returns a dict with innings → batsmen and bowlers.
    """
    data = fetch_data(f"mcenter/v1/{match_id}/scard")
    scorecards = []

    for innings in data.get("scorecard", []):
        inning_data = {
            "inning": innings.get("batteamname"),
            "batsmen": [],
            "bowlers": []
        }

        # Batsmen
        for p in innings.get("batsman", []):
            inning_data["batsmen"].append({
                "name": p.get("name"),
                "runs": p.get("runs"),
                "balls": p.get("balls"),
                "fours": p.get("fours"),
                "sixes": p.get("sixes"),
                "strike_rate": p.get("strikerate")
            })

        # Bowlers
        for p in innings.get("bowler", []):
            inning_data["bowlers"].append({
                "name": p.get("name"),
                "overs": p.get("overs"),
                "runs": p.get("runs"),
                "wickets": p.get("wickets"),
                "economy": p.get("economy")
            })

        scorecards.append(inning_data)

    return scorecards
