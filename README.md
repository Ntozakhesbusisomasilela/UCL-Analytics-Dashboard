
# UEFA Champions League (2015-2025) Analytics Dashboard
End-to-end BI project: from raw API data to interactive Power BI dashboards.

This project demonstrates end-to-end BI skills by building a UEFA Champions League analytics dashboard (2015–2025). Using Python for API extraction, SQL Server for star-schema modeling, and Power BI for interactive visualization, I transformed fragmented football data into a clean, scalable pipeline. The result is a recruiter-ready dashboard that highlights player and team performance trends, showcases advanced data modeling, and proves my ability to deliver insights from raw data to polished visuals.


## Project Overview
In this project, I analysed UEFA Champions League data across multiple seasons to understand player performance, team performance, and overall tournament trends.

The project follows an end-to-end data pipeline, from API data extraction to building an interactive dashboard in Power BI.

## Problem Statement
Football data is often fragmented and difficult to analyse across seasons. 

The aim of this project was to:
-	Combine data from multiple seasons into a single model
-	Enable meaningful comparison between players and teams
-	Go beyond basic stats (goals, assists) and analyse efficiency metrics


## Tech tools used
1.	Python (data extraction and transformation)
2.	SQL Server (data storage and modelling)
3.	Power BI (data modelling and visualization)


## Data Pipeline

1. Data Extraction  
Data was collected using the SportMonks API across multiple seasons. Python scripts were used to automate requests and structure the data.

2. Data Transformation  
The data was cleaned and standardized. Missing values were handled, and all required metrics were aligned into a consistent format.

3. Data Storage
   A star schema was implemented in SQL Server:
-	Fact tables: FactPlayerStats, FactTeamSeasonStats
-	Dimension tables: DimPlayer, DimTeam, DimSeason, DimPlayerCountry, DimTeamCountry

4. Data Modelling (Power BI)  
Relationships were created using a one-to-many structure. Ambiguous relationships were resolved by splitting country dimensions for players and teams. Organized measures into folders.

5. Visualization
    
   Three main dashboards were created:
-	Executive Overview  
- Player Performance  
- Team Performance  


## Optimization

To improve performance and usability, several optimizations were applied:

-	Reduced model size → Removed unused columns from tables.
-	Improved clarity → Hid technical IDs and raw metrics to keep the model clean.
-	Boosted performance → Implemented a star schema for efficient queries.
-	Resolved ambiguity → Split country dimensions for players and teams.
-	Centralized calculations → Created a dedicated Measures table.
-	Ensured meaningful analysis → Applied filters (e.g., minimum minutes, minimum shots).
-	Simplified relationships → Enforced single direction links to avoid complexity.
-	Prevented hidden clutter → Disabled auto date/time tables.


These steps improved both dashboard responsiveness and model clarity.

## Key Metrics

Player Metrics:
-	Total Goals
-	Total Assists
-	Goals per 90
-	Shot Conversion %
-	Total Minutes Played
-	Goal Contribution

Team Metrics:
-	Total Wins
-	Win Percentage
-	Goals per Match
-	Total Points


## Key Decisions and Why

-	Star schema design → Chosen for scalability and performance, ensuring efficient queries and a clean model structure.
-	Split country dimensions → Avoided ambiguous relationships by separating player and team countries into distinct tables.
-	Dedicated Measures table → Centralized calculations for clarity, professionalism, and easier maintenance.
-	Applied thresholds → Enforced minimum minutes and shots to prevent misleading metrics and ensure meaningful comparisons.


## Challenges & Solutions
-	Ambiguous Relationships
o	Problem: A single Country table connected to both players and teams, creating ambiguity in Power BI.
o	Solution: Split into DimPlayerCountry and DimTeamCountry to ensure clean, one to many relationships.
-	Misleading Metrics
o	Problem: Stats like Goals per 90 or Shot Conversion % gave unrealistic results for players with very low minutes or shots (e.g., 1 shot = 100% conversion).
o	Solution: Applied thresholds (e.g., Minutes > 900, Shots > 50) to filter out unreliable data.
-	Data Gaps
o	Problem: Defensive metrics (e.g., Goals Conceded) were missing in one dataset.
o	Solution: Adjusted analysis to emphasize available indicators such as Points, Wins, Goals per Match.
-	Performance Issues in Power BI
o	Problem: Slow loading and cluttered model due to unused columns and technical fields.
o	Solution: Removed unnecessary columns, hid technical IDs, centralized calculations in a Measures table, and enforced single direction relationships.


## Key Insights
-	Players with very low shot volume tend to show artificially high shot conversion rates, highlighting the importance of applying thresholds in analysis.

-	High-performing players only become visible after filtering for sufficient minutes played and shot volume.

-	Goals per 90 can be misleading without a minimum minutes filter, as players with limited playtime can dominate rankings unfairly.

-	Teams that perform best typically balance attacking strength (goals scored) with consistency (wins and points).

-	Some teams score many goals but do not rank highly in points, suggesting inconsistency or defensive weaknesses.


## Outcome

The project resulted in:
-	A fully interactive Power BI dashboard
-	A clean and optimized data model
-	A complete data pipeline from API to visualization

This project demonstrates end to end BI skills, aligning with my goal of becoming a Data Analyst / BI Analyst.

## Future Improvements

-	Include goals conceded for better defensive analysis
-	Add match-level data for deeper insights
-	Automate data refresh
-	Publish dashboard to Power BI Service


## Repository Structure

-	/data → datasets
-	Images → dashboard screenshots
-	/sql → database scripts  
-	/python → API scripts  
-	/Power BI → dashboard file  


## How to Recreate the Project
This project is fully reproducible — scripts and sample data are included so anyone can rebuild the database and dashboard.

1.	Run the SQL script to create the database  
2.	Update file paths for your local environment  
3.	Run the Python scripts to fetch data  
4.	Connect Power BI to SQL Server  
5.	Load tables and build visuals  


## Author 
Masilela Ntozakhe Sbusiso 
Final-year Informatics student | Aspiring Data Analyst / BI Analyst 

