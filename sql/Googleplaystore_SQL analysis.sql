/*  
===========================================================
📊 GOOGLE PLAY STORE APPS ANALYSIS — SQL SCRIPT
Author  : Pooja  
Dataset : googleplaystore_cleaned_safe.csv  
Project : End-to-End Data Analytics (Python + SQL + Power BI)
Database: PostgreSQL

Description:
This script:
1. Drops old table  
2. Creates a fresh table  
3. Imports cleaned CSV  
4. Converts datatypes  
5. Performs analysis based on business questions  
6. Contains final insights summary  
===========================================================
*/

--DROP TABLE--

DROP TABLE IF EXISTS google_playstore_apps;

--Create table--

CREATE TABLE google_playstore_apps (
    app_name TEXT,
    app_id TEXT,
    category TEXT,
    rating TEXT,
    rating_count TEXT,
    installs TEXT,
    minimum_installs TEXT,
    maximum_installs TEXT,
    free TEXT,
    price TEXT,
    currency TEXT,
    size TEXT,
    minimum_android TEXT,
    developer_id TEXT,
    developer_website TEXT,
    developer_email TEXT,
    released TEXT,
    last_updated TEXT,
    content_rating TEXT,
    privacy_policy TEXT,
    ad_supported TEXT,
    in_app_purchases TEXT,
    editors_choice TEXT,
    scraped_time TEXT,
    revenue TEXT
);

------------------------------------------------------------
-- 3 IMPORT CLEANED CSV
------------------------------------------------------------

COPY google_playstore_apps
FROM 'D:/Pooja/Data analyst/Projects/Resume Project/Google Project/googleplaystore_cleaned_safe.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    ENCODING 'LATIN1'
);

------------------------------------------------------------
-- 4 CLEANING: CONVERT TO CORRECT DATA TYPES
------------------------------------------------------------
-- Convert numeric columns

ALTER TABLE google_playstore_apps
    ALTER COLUMN rating TYPE NUMERIC(10,3)
        USING NULLIF(rating, 'NULL')::NUMERIC,
    ALTER COLUMN rating_count TYPE BIGINT
        USING NULLIF(REPLACE(rating_count, '.0', ''), 'NULL')::BIGINT,
    ALTER COLUMN installs TYPE BIGINT
        USING NULLIF(REPLACE(installs, '.0', ''), 'NULL')::BIGINT,
    ALTER COLUMN minimum_installs TYPE BIGINT
        USING NULLIF(REPLACE(minimum_installs, '.0', ''), 'NULL')::BIGINT,
    ALTER COLUMN maximum_installs TYPE BIGINT
        USING NULLIF(REPLACE(maximum_installs, '.0', ''), 'NULL')::BIGINT,
    ALTER COLUMN price TYPE NUMERIC(10,2)
        USING NULLIF(price, 'NULL')::NUMERIC,
    ALTER COLUMN revenue TYPE NUMERIC(15,2)
        USING NULLIF(revenue, 'NULL')::NUMERIC;

-- Convert boolean columns
ALTER TABLE google_playstore_apps
    ALTER COLUMN free TYPE BOOLEAN USING NULLIF(free, 'NULL')::BOOLEAN,
    ALTER COLUMN ad_supported TYPE BOOLEAN USING NULLIF(ad_supported, 'NULL')::BOOLEAN,
    ALTER COLUMN in_app_purchases TYPE BOOLEAN USING NULLIF(in_app_purchases, 'NULL')::BOOLEAN,
    ALTER COLUMN editors_choice TYPE BOOLEAN USING NULLIF(editors_choice, 'NULL')::BOOLEAN;


-- Convert date & timestamp columns
ALTER TABLE google_playstore_apps
    ALTER COLUMN released TYPE DATE USING NULLIF(released, 'NULL')::DATE,
    ALTER COLUMN last_updated TYPE DATE USING NULLIF(last_updated, 'NULL')::DATE,
    ALTER COLUMN scraped_time TYPE TIMESTAMP USING NULLIF(scraped_time, 'NULL')::TIMESTAMP;

------------------------------------------------------------
-- 5 DATA QUALITY CHECKS
------------------------------------------------------------	

-- View structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'google_playstore_apps';

-- Check null counts in critical columns
SELECT 
    SUM(CASE WHEN rating IS NULL THEN 1 END) AS null_ratings,
    SUM(CASE WHEN installs IS NULL THEN 1 END) AS null_installs,
    SUM(CASE WHEN price IS NULL THEN 1 END) AS null_price
FROM google_playstore_apps;

------------------------------------------------------------
-- 6️ ANALYSIS QUERIES
------------------------------------------------------------

-------------------------
-- STEP 1: Basic Overview
-------------------------

--Total number of apps

SELECT COUNT(*) AS total_apps
FROM google_playstore_apps;


--Free vs Paid apps

SELECT free, COUNT(*) AS app_count
FROM google_playstore_apps
GROUP BY free;

--Number of apps per category

SELECT category, COUNT(*) AS category_count
FROM google_playstore_apps
GROUP BY category
ORDER BY category_count DESC;

--Average rating across all apps

SELECT ROUND(AVG(rating), 2) AS avg_rating
FROM google_playstore_apps;

----------------------------
-- STEP 2: Install Analysis
----------------------------

--Top 10 categories by installs

SELECT category, SUM(installs) AS total_installs
FROM google_playstore_apps
GROUP BY category
ORDER BY total_installs DESC
LIMIT 10;

----------------------------
-- STEP 3: Rating Analysis
----------------------------

--Top 10 Categories by Average Rating

SELECT category, ROUND(AVG(rating), 3) AS avg_rating
FROM google_playstore_apps
WHERE rating IS NOT NULL
GROUP BY category
ORDER BY avg_rating DESC
LIMIT 10;

----------------------------
-- STEP 4: Revenue Analysis
----------------------------

--Top Revenue-Generating Categories (Paid Apps Only)

SELECT category, SUM(revenue) AS total_revenue
FROM google_playstore_apps
WHERE free = false
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-------------------------------
-- STEP 5: Free vs Paid Compare
-------------------------------

-- Average Rating for Free vs Paid Apps

SELECT free, ROUND(AVG(rating), 2) AS avg_rating
FROM google_playstore_apps
GROUP BY free
ORDER BY free;

-- Total Installs for Free vs Paid Apps

SELECT free, SUM(installs) AS total_installs
FROM google_playstore_apps
GROUP BY free
ORDER BY free;

----------------------------
-- STEP 6: Trend Analysis
----------------------------

--Apps released per year

SELECT EXTRACT(YEAR FROM released) AS release_year,
       COUNT(*) AS apps_released
FROM google_playstore_apps
WHERE released IS NOT NULL
GROUP BY release_year
ORDER BY release_year;

-- Apps updated per year

SELECT EXTRACT(YEAR FROM last_updated) AS update_year,
       COUNT(*) AS apps_updated
FROM google_playstore_apps
WHERE last_updated IS NOT NULL
GROUP BY update_year
ORDER BY update_year;


------------------------------------------------------------
-- 7️ FINAL INSIGHTS SUMMARY 
------------------------------------------------------------

/*
1. Tools & Communication categories have the highest installs.
2. Music & Audio and Books & Reference have the highest average ratings.
3. Action, Tools, and Business categories generate the most revenue among paid apps.
4. Free apps dominate installs (~98%), but paid apps rate slightly higher.
5. Peak years for releases & updates were 2018–2020.
*/