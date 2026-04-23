-- ===========================================
-- DROP DATABASE IF EXISTS AND CREATE NEW
-- ===========================================

IF DB_ID('UCL_AnalyticsDB') IS NOT NULL
BEGIN
    ALTER DATABASE UCL_AnalyticsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UCL_AnalyticsDB;
END
GO

CREATE DATABASE UCL_AnalyticsDB;
GO

USE UCL_AnalyticsDB;
GO

-- ===========================================
-- DIMENSIONS
-- ===========================================

-- Dimension: COUNTRY
CREATE TABLE DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryId INT UNIQUE, -- API ID
    CountryName VARCHAR(100) DEFAULT 'NA',
    ISO2 CHAR(2) DEFAULT 'NA',
    ISO3 CHAR(3) DEFAULT 'NA',
    ContinentId INT DEFAULT 0
);
GO

-- Dimension: PLAYER
CREATE TABLE DimPlayer (
    PlayerKey INT IDENTITY(1,1) PRIMARY KEY,
    PlayerId INT NOT NULL,
    PlayerName VARCHAR(100) NOT NULL,
    DateOfBirth DATE DEFAULT '1900-01-01',
    PositionId INT DEFAULT 0,
    CountryKey INT NULL REFERENCES DimCountry(CountryKey)
);
GO

-- Dimension: TEAM
CREATE TABLE DimTeam (
    TeamKey INT IDENTITY(1,1) PRIMARY KEY,
    TeamId INT NOT NULL,
    TeamName VARCHAR(100) NOT NULL,
    CountryKey INT NULL REFERENCES DimCountry(CountryKey)
);
GO

-- Dimension: SEASON
CREATE TABLE DimSeason (
    SeasonKey INT IDENTITY(1,1) PRIMARY KEY,
    SeasonId INT NOT NULL,
    SeasonName VARCHAR(100) NOT NULL
);
GO

-- ===========================================
-- STAGING TABLES
-- ===========================================

-- Player details staging
CREATE TABLE StagingPlayerDetails (
    SeasonId INT,
    TeamId INT,
    TeamName VARCHAR(100),
    PlayerId INT,
    PlayerName VARCHAR(100),
    DateOfBirth DATE,
    PositionId INT,
    CountryId INT,
    CountryName VARCHAR(100),
    ISO2 CHAR(2),
    ISO3 CHAR(3),
    ContinentId INT
);
GO

-- Teams staging
CREATE TABLE StagingTeams (
    TeamId INT,
    TeamName VARCHAR(100),
    CountryId INT
);
GO

-- Player stats staging
CREATE TABLE StagingPlayerStats (
    SeasonId INT,
    TeamId INT,
    TeamName VARCHAR(255),
    PlayerId INT,
    PlayerName VARCHAR(255),
    ShotsTotal INT,
    Passes INT,
    GoalsConceded INT,
    Rating DECIMAL(5,2),
    MinutesPlayed INT,
    Appearances INT,
    AccuratePassesPercentage DECIMAL(5,2),
    Goals INT,
    Assists INT,
    SuccessfulPasses INT,
    ShotsOnTarget INT,
    CleanSheets INT,
    TeamWins INT,
    TeamDraws INT,
    TeamLost INT,
    BigChancesCreated INT,
    BigChancesMissed INT,
    AveragePointsPerGame DECIMAL(5,2)
);
GO

-- ===========================================
-- FACT TABLE
-- ===========================================

CREATE TABLE FactPlayerStats (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    SeasonKey INT NOT NULL REFERENCES DimSeason(SeasonKey),
    TeamKey INT NOT NULL REFERENCES DimTeam(TeamKey),
    PlayerKey INT NOT NULL REFERENCES DimPlayer(PlayerKey),

    ShotsTotal INT,
    Passes INT,
    GoalsConceded INT,
    Rating DECIMAL(5,2),
    MinutesPlayed INT,
    Appearances INT,
    AccuratePassesPercentage DECIMAL(5,2),
    Goals INT,
    Assists INT,
    SuccessfulPasses INT,
    ShotsOnTarget INT,
    CleanSheets INT,
    TeamWins INT,
    TeamDraws INT,
    TeamLost INT,
    BigChancesCreated INT,
    BigChancesMissed INT,
    AveragePointsPerGame DECIMAL(5,2)
);
GO

-- ===========================================
-- BULK INSERTING INTO STAGING
-- ===========================================

-- Player details
BULK INSERT StagingPlayerDetails
FROM 'C:\TEMP\ucl_player_dimension_raw.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

-- Teams
BULK INSERT StagingTeams
FROM 'C:\TEMP\dimTEAM.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

-- Player stats
BULK INSERT StagingPlayerStats
FROM 'C:\TEMP\ucl_full_player_stats.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

-- ===========================================
-- POPULATING DIMENSIONS FROM STAGING
-- ===========================================

-- DimCountry
INSERT INTO DimCountry (CountryId, CountryName, ISO2, ISO3, ContinentId)
SELECT DISTINCT
    CountryId,
    CountryName,
    ISO2,
    ISO3,
    ContinentId
FROM StagingPlayerDetails;
GO

-- DimPlayer
INSERT INTO DimPlayer (PlayerId, PlayerName, DateOfBirth, PositionId, CountryKey)
SELECT DISTINCT
    spd.PlayerId,
    spd.PlayerName,
    COALESCE(spd.DateOfBirth, '1900-01-01'),
    COALESCE(spd.PositionId, 0),
    dc.CountryKey
FROM StagingPlayerDetails spd
LEFT JOIN DimCountry dc
    ON dc.CountryId = spd.CountryId;
GO

-- DimTeam
INSERT INTO DimTeam (TeamId, TeamName, CountryKey)
SELECT DISTINCT
    st.TeamId,
    st.TeamName,
    dc.CountryKey
FROM StagingTeams st
LEFT JOIN DimCountry dc
    ON dc.CountryId = st.CountryId;
GO

-- DimSeason
INSERT INTO DimSeason (SeasonId, SeasonName)
VALUES
(5321,'2015/2016'),
(718,'2016/2017'),
(7907,'2017/2018'),
(12950,'2018/2019'),
(16029,'2019/2020'),
(17299,'2020/2021'),
(18346,'2021/2022'),
(19699,'2022/2023'),
(21638,'2023/2024'),
(23619,'2024/2025');
GO

-- ===========================================
-- POPULATNG PLAYER STATS TABLE
-- ===========================================

INSERT INTO FactPlayerStats (
    SeasonKey,
    TeamKey,
    PlayerKey,
    ShotsTotal,
    Passes,
    GoalsConceded,
    Rating,
    MinutesPlayed,
    Appearances,
    AccuratePassesPercentage,
    Goals,
    Assists,
    SuccessfulPasses,
    ShotsOnTarget,
    CleanSheets,
    TeamWins,
    TeamDraws,
    TeamLost,
    BigChancesCreated,
    BigChancesMissed,
    AveragePointsPerGame
)
SELECT 
    s.SeasonKey,
    t.TeamKey,
    p.PlayerKey,
    st.ShotsTotal,
    st.Passes,
    st.GoalsConceded,
    st.Rating,
    st.MinutesPlayed,
    st.Appearances,
    st.AccuratePassesPercentage,
    st.Goals,
    st.Assists,
    st.SuccessfulPasses,
    st.ShotsOnTarget,
    st.CleanSheets,
    st.TeamWins,
    st.TeamDraws,
    st.TeamLost,
    st.BigChancesCreated,
    st.BigChancesMissed,
    st.AveragePointsPerGame
FROM StagingPlayerStats st
JOIN DimSeason s ON s.SeasonId = st.SeasonId
JOIN DimTeam t   ON t.TeamId   = st.TeamId
JOIN DimPlayer p ON p.PlayerId = st.PlayerId;
GO

-- ===========================================
-- TRUNCATE STAGING TABLES
-- ===========================================

TRUNCATE TABLE StagingPlayerDetails;
TRUNCATE TABLE StagingPlayerStats;
TRUNCATE TABLE StagingTeams;
GO

-- ===========================================
-- INDEXES
-- ===========================================

-- DimCountry
CREATE UNIQUE NONCLUSTERED INDEX IX_DimCountry_CountryId
ON DimCountry (CountryId);

-- DimPlayer
CREATE UNIQUE NONCLUSTERED INDEX IX_DimPlayer_PlayerId
ON DimPlayer (PlayerId);

-- DimTeam
CREATE UNIQUE NONCLUSTERED INDEX IX_DimTeam_TeamId
ON DimTeam (TeamId);

-- DimSeason
CREATE UNIQUE NONCLUSTERED INDEX IX_DimSeason_SeasonId
ON DimSeason (SeasonId);

-- FactPlayerStats
CREATE NONCLUSTERED INDEX IX_FactStats_SeasonKey
ON FactPlayerStats (SeasonKey);

CREATE NONCLUSTERED INDEX IX_FactStats_TeamKey
ON FactPlayerStats (TeamKey);

CREATE NONCLUSTERED INDEX IX_FactStats_PlayerKey
ON FactPlayerStats (PlayerKey);
GO

-- ===========================================
-- VIEWS
-- ===========================================

CREATE VIEW vwPlayer AS
SELECT
    p.PlayerKey,
    p.PlayerId,
    p.PlayerName,
    p.DateOfBirth,
    p.PositionId,
    c.CountryName
FROM DimPlayer p
LEFT JOIN DimCountry c
    ON p.CountryKey = c.CountryKey;
GO

CREATE VIEW vwTeam AS
SELECT
    TeamKey,
    TeamId,
    TeamName
FROM DimTeam;
GO

CREATE VIEW vwSeason AS
SELECT
    SeasonKey,
    SeasonId,
    SeasonName
FROM DimSeason;
GO

CREATE VIEW vwPlayerStats AS
SELECT
    s.SeasonName,
    t.TeamName,
    p.PlayerName,
    f.ShotsTotal,
    f.Passes,
    f.GoalsConceded,
    f.Rating,
    f.MinutesPlayed,
    f.Appearances,
    f.AccuratePassesPercentage,
    f.Goals,
    f.Assists,
    f.SuccessfulPasses,
    f.ShotsOnTarget,
    f.CleanSheets,
    f.TeamWins,
    f.TeamDraws,
    f.TeamLost,
    f.BigChancesCreated,
    f.BigChancesMissed,
    f.AveragePointsPerGame
FROM FactPlayerStats f
JOIN DimSeason s ON f.SeasonKey = s.SeasonKey
JOIN DimTeam t   ON f.TeamKey   = t.TeamKey
JOIN DimPlayer p ON f.PlayerKey = p.PlayerKey;
GO

-- ===========================================
-- BACKUP DATABASE
-- ===========================================

BACKUP DATABASE UCL_AnalyticsDB
TO DISK = 'C:\TEMP\UCL_AnalyticsDBFinal.bak'
WITH INIT;
GO
