import requests
import pandas as pd
import time

API_TOKEN = "my API key"

SEASONS = [5321, 718, 7907, 12950, 16029, 17299, 18346, 19699, 21638, 23619]

all_data = []
missing_country_count = 0  # counter for missing country info

for season_id in SEASONS:
    print(f"\n--- Fetching teams for season {season_id} ---")
    
    teams_url = f"https://api.sportmonks.com/v3/football/teams/seasons/{season_id}?api_token={API_TOKEN}"
    teams_resp = requests.get(teams_url).json()
    teams_list = teams_resp.get("data", [])
    
    if not teams_list:
        print(f"No teams found for season {season_id}. Skipping...")
        continue

    for team in teams_list:
        team_id = team.get("id")
        team_name = team.get("name")

        squad_url = (
            f"https://api.sportmonks.com/v3/football/squads/seasons/"
            f"{season_id}/teams/{team_id}"
            f"?api_token={API_TOKEN}&include=player;player.country"
        )

        squad_resp = requests.get(squad_url).json()
        squad_list = squad_resp.get("data", [])

        if not squad_list:
            print(f"No squad found for team {team_name} (ID: {team_id}) in season {season_id}")
            continue

        for entry in squad_list:
            player = entry.get("player") or {}
            country = player.get("country") or {}

            if not country:
                missing_country_count += 1  # increment counter

            row = {
                # Grain identifiers
                "season_id": season_id,
                "team_id": team_id,
                "team_name": team_name,
                
                # Player
                "player_id": player.get("id"),
                "player_name": player.get("display_name", player.get("name")),
                "date_of_birth": player.get("date_of_birth"),
                "position_id": player.get("position_id"),
                
                # Nationality
                "country_id": country.get("id"),
                "country_name": country.get("name"),
                "iso2": country.get("iso2"),
                "iso3": country.get("iso3"),
                "continent_id": country.get("continent_id")
            }

            all_data.append(row)
            time.sleep(0.15)  # gentle delay(Wi-fi kinda slow)

# Save as CSV
df = pd.DataFrame(all_data)
df.to_excel("ucl_player_dimension_raw.csv", index=False)
print(f"Missing country records: {missing_country_count}")

