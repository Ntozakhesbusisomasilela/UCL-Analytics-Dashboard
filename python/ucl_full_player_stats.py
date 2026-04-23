import requests
import pandas as pd
import time

API_TOKEN = "My API key"

SEASONS = [5321, 718, 7907, 12950, 16029, 17299, 18346, 19699, 21638, 23619]

STAT_TYPES = {
    42: "shots_total",
    52: "goals",
    79: "assists",
    80: "passes",
    81: "successful_passes",
    86: "shots_on_target",
    88: "goals_conceded",
    118: "rating",
    119: "minutes_played",
    194: "cleansheets",
    214: "team_wins",
    215: "team_draws",
    216: "team_lost",
    321: "appearances",
    580: "big_chances_created",
    581: "big_chances_missed",
    1584: "accurate_passes_percentage",
    9676: "average_points_per_game"
}

all_data = []

for season_id in SEASONS:
    print(f"\n--- Fetching teams for season {season_id} ---")
    
    # Fetching all teams for the season
    teams_url = f"https://api.sportmonks.com/v3/football/teams/seasons/{season_id}?api_token={API_TOKEN}"
    teams_resp = requests.get(teams_url).json()
    teams_list = teams_resp.get("data", [])
    
    if not teams_list:
        print(f"No teams found for season {season_id}.")
        continue

    for team in teams_list:
        team_id = team.get("id")
        team_name = team.get("name", "Unknown Team")
        
        # Fetching squad for this team + season
        squad_url = f"https://api.sportmonks.com/v3/football/squads/seasons/{season_id}/teams/{team_id}?api_token={API_TOKEN}&include=player;details"
        squad_resp = requests.get(squad_url).json()
        squad_list = squad_resp.get("data", [])
        
        if not squad_list:
            continue
        
        for entry in squad_list:
            pid = entry.get("player_id")
            player_info = entry.get("player", {})
            player_name = player_info.get("display_name", player_info.get("name", f"Player {pid}"))
            
            stats_dict = {
                "season_id": season_id,
                "team_id": team_id,
                "team_name": team_name,
                "player_id": pid,
                "player_name": player_name
            }
            
            # Extract stats details
            details = entry.get("details", [])
            for stat in details:
                type_id = stat.get("type_id")
                if type_id in STAT_TYPES:
                    val = stat.get("value", {}).get("total") or stat.get("value", {}).get("average") or 0
                    stats_dict[STAT_TYPES[type_id]] = val
            
            # This ensures missing stats are set to 0
            for col in STAT_TYPES.values():
                stats_dict.setdefault(col, 0)
            
            all_data.append(stats_dict)
            time.sleep(0.15)  # gentle delay

# Save as CSV
df = pd.DataFrame(all_data)
df.to_excel("ucl_full_player_stats.csv", index=False)
print("Done! Saved to ucl_full_player_stats.csv")

