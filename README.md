# Football Data Analytics Platform

[Русская версия README](README_RU.md)

A personal football data analytics project focused on collecting, processing, storing and analysing football statistics using SQL, SQLite, Python and Metabase.

The project started as an Excel spreadsheet in 2020 and gradually evolved into a relational database and a set of analytical tools for exploring team and player performance.

## Project Overview

The platform brings together football data from multiple sources and stores it in a relational SQLite database. It supports analysis of matches, teams, players, player performance, advanced metrics and historical match information.

The project currently focuses on the Russian Premier League (RPL), with a separate database project for the English Premier League (EPL).

## Key Features

- **Relational database design:** SQLite database with tables for matches, teams, players, player statistics, match statistics and related reference data.
- **SQL analytics:** Analytical queries and views using JOINs, CTEs, window functions, aggregations and subqueries.
- **Database auditing:** SQLite triggers record data changes and maintain an audit history.
- **Data processing:** Python and pandas scripts transform downloaded JSON files into structured Excel files for further validation and database import.
- **Player analysis:** Player performance evaluation, statistical comparisons and radar visualisations.
- **Team and match analysis:** Reports comparing teams and their recent head-to-head performance.
- **Dashboards:** Football statistics visualised in Metabase.

## Technology Stack

| Area | Tools |
|---|---|
| Database | SQLite |
| SQL | JOIN, CTE, Window Functions, Views, Triggers, Aggregations |
| Data processing | Python, pandas |
| Visualisation | Metabase, Matplotlib |
| Data preparation | Microsoft Excel |
| Database management | DB Browser for SQLite |
| Notebooks | Jupyter Notebook, Google Colab |

## Data Processing Workflow

The current workflow combines manual data collection with Python-based processing:

1. Download match and player data in JSON format from the selected data sources.
2. Process and transform JSON files using Python and pandas.
3. Export structured datasets to Excel.
4. Review and prepare the resulting files.
5. Import the prepared data into the SQLite database.
6. Use SQL queries and views to analyse the data.
7. Build reports and visualisations using Metabase and Python.

The data preparation and database loading process is partially manual. Full end-to-end ETL automation is not currently implemented.

## Database

The local SQLite database contains:

- 16 tables
- 22 views
- 39 triggers
- 5 indexes
- More than 65,000 audit log records

The database file itself is not included in this repository. SQL scripts are provided to demonstrate the database structure and implementation.

### Database structure

The SQL scripts are located in `sql/database/`:

- `01_schema.sql` — database tables and relationships
- `02_indexes.sql` — indexes
- `03_views.sql` — analytical and supporting views
- `04_triggers.sql` — audit and data-change triggers

Database schema diagram:

![Database schema](docs/images/schema.png)

## Analytical Examples

The dashboards are designed to answer specific analytical questions rather than only display statistics.

### 1. Team review — how does one club perform across the season?

![Team review](dashboards/team_review.png)

**Question answered:** What are the team's main strengths and weaknesses, and which players contribute most?

The report combines club information, player-level output and team-level indicators. It helps review scoring, expected goals, shots, passing accuracy, final-third passing, duels and other match metrics in one place.

**Example from the screenshot:** CSKA's 2024/25 report shows 1.57 goals and 1.42 xG per match, alongside 0.70 goals conceded and 1.05 xG conceded per match. The passing panels show 83.5% overall passing accuracy and 69.1% accuracy on passes into the final third. This makes it possible to compare attacking output with chance quality and to identify where possession becomes less effective.

### 2. Team comparison — where do two clubs differ?

![Teams comparison](dashboards/teams_comparison.png)

**Question answered:** Which of two selected clubs performs better, how do their head-to-head matches look, and where are the biggest statistical differences?

The report combines the league table, head-to-head results, goals versus xG, position changes during the season, and leaders in attacking, creative and defensive metrics.

**Example from the screenshot:** In 2024/25, CSKA finished third with 59 points and Spartak fourth with 57. Spartak scored 56 goals against 52.5 xG, while CSKA scored 47 against 42.62 xG. The report therefore gives context beyond the final table: it shows both the result and the underlying chance production. The head-to-head panel also shows both meetings, making the seasonal comparison easier to interpret.

### 3. Player radar — how do two players in the same role differ?

![Player radar](dashboards/two%E2%80%91player%20radar.png)

**Question answered:** Which skills distinguish two players who play in the same position?

The radar compares Wendel and Matvey Kislyak as defensive midfielders in 2025/26. Indicators are normalised per 90 minutes, and the comparison pool is restricted to defensive midfielders with at least 300 minutes and four appearances in that position (29 players in the shown sample). The chart also displays total minutes and minutes played in the selected position, so the comparison has playing-time context.

The report is intended to reveal different statistical profiles, not to declare one player universally better. A larger value on one axis should be interpreted in the context of the player's role and the metric definition.

## SQL Analytics Case Studies

The `sql/analytics/` directory contains separate, documented examples. Each file states the analytical question, data sources, query, expected result structure and how to interpret the output.

| File | Analytical question | Main SQL techniques / objects |
|---|---|---|
| `01_team_performance.sql` | How do teams perform in the table and in attack? | Views, CTE, aggregation, conditional metrics |
| `02_player_performance.sql` | Which players perform best after a minutes threshold? | Views, ranking, calculated metrics |
| `03_player_value_epv.sql` | Which players add value through carrying, open play and set pieces? | View, per-90 calculations, ranking |
| `04_game_state_analysis.sql` | Which teams recover after falling behind or protect a lead? | CTE-based views, JOIN, CASE, ratios |
| `05_goal_contribution.sql` | Which combinations and player roles contribute to goals? | Views, aggregation, percentage calculations |
| `06_transfer_analysis.sql` | Which transfers and clubs have the highest recorded fees? | Self-join, CTE, window function, aggregation |

Run the scripts against the SQLite database after creating the schema and loading the required data. The repository does not include the database itself, so numeric query outputs are not embedded as if they had been independently reproduced from a clean database.

## Repository Structure

```text
football-data-analytics/
│
├── dashboards/
│   ├── team_review.png
│   ├── teams_comparison.png
│   └── two‑player radar.png
│
├── docs/
│   └── images/
│       └── schema.png
│
├── python/
│   ├── json_to_excel.ipynb
│   ├── match_report.ipynb
│   ├── radar.ipynb
│   └── weather.ipynb
│
├── sql/
│   ├── analytics/
│   │   ├── 01_team_performance.sql
│   │   ├── 02_player_performance.sql
│   │   ├── 03_player_value_epv.sql
│   │   ├── 04_game_state_analysis.sql
│   │   ├── 05_goal_contribution.sql
│   │   └── 06_transfer_analysis.sql
│   └── database/
│       ├── 01_schema.sql
│       ├── 02_indexes.sql
│       ├── 03_views.sql
│       └── 04_triggers.sql
│
├── .gitignore
└── README.md
```

## Data Sources

The project uses football statistics and reference information from sources including:

- SofaScore
- Understat
- xGLab
- Transfermarkt

The repository does not contain the full source datasets or the SQLite database. Data availability and permitted use are subject to the respective providers' terms.

## Project Goals

The ongoing development focuses on:

- Improving data quality and consistency.
- Reducing manual steps in the data processing workflow.
- Improving player identification and source ID matching.
- Expanding SQL analytics and statistical reports.
- Developing more interactive dashboards and visualisations.
- Improving database documentation and reproducibility.

## About

This is an independent long-term learning and portfolio project. It demonstrates practical experience in relational database design, SQL analytics, data preparation, data validation and visualisation.
