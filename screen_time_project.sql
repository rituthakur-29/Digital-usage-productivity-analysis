CREATE TABLE screen_time (
    Date DATE,
    App_name TEXT,
    Category TEXT,
    Time_spent_min INT,
    Pickups INT,
    Notifications INT,
	Is_productive TEXT
);

select * from screen_time;


-- A. BASIC EXPLORATION
-- 1. Total screen time
select SUM(time_spent_min) as total_screen_time
from screen_time;

-- Ans: 5110 minutes

--2. Total screen time per day
select date, SUM(time_spent_min) as total_time
from screen_time
group by date
order by date;

--Ans: Range is between 325(min) to 455(max)

--3. Average daily screen time
select round(AVG(daily_time),2) as avg_time
from 
	(select date, SUM(time_spent_min) as daily_time
	 from screen_time
	 group by date) t;

-- Ans: Avg time is 365 mins

-- B. CATEGORY-LEVEL ANALYSIS
-- 4. Time spent per category
select category, SUM(time_spent_min) as total_time
from screen_time
group by category
order by total_time DESC;

-- Max time spent in 'social media'(1730) and 'entertainment'(1640)

-- 5. % Contribution by category
select category, SUM(time_spent_min) as total_time,
	round(100.0*SUM(time_spent_min)/ SUM(SUM(time_spent_min)) OVER(),2) as percentage
from screen_time
group by category
order by percentage DESC;

-- Ans: social_media-33.86% , entertainment- 32.39% , communication- 18.49, productivity- 15.36%

-- C. APP LEVEL INSIGHTS
-- 6. Top 5 most used apps
select app_name, SUM(time_spent_min) as total_time
from screen_time
group by app_name
order by total_time desc
limit 5;

-- Ans: Instagram- 1730, youtube-1215, whatsapp- 945, spotify- 435, google docs- 365

-- 7. Most frequent opened apps
select app_name, SUM(pickups) as total_pickups
from screen_time
group by app_name
order by total_pickups desc;

--Ans: Instagram has most pickups (729)

-- D. BEHAVIORAL ANALYSIS
-- 8. Avg Time Per Pickup (Focus vs Distraction)
select app_name, SUM(time_spent_min) as total_time,
	SUM(pickups) as total_pickups,
	Round(SUM(time_spent_min)*1.0/SUM(pickups),2) as avg_time_per_pickups
from screen_time
group by app_name
order by avg_time_per_pickups;

--Ans:- Range from: Whatsapp-1.78, Notion-5

-- E. PRODUCTIVITY VS NON-PRODUCTIVITY
-- 9. Total time by productivity type
select is_productive, SUM(time_spent_min) as total_time
from screen_time
group by is_productive;

-- Ans: No-3380, Yes- 785, Neutral- 945

-- 10. Productivity Ratio
select 
	round(100.0* SUM(CASE WHEN is_productive= 'Yes' THEN time_spent_min END)
	/ SUM(time_spent_min),2) as productive_percentage
from screen_time;

--Ans: Productive percentage-15.36

-- F. TREND ANALYSIS
-- 11. Day-wise trend
select date, SUM(time_spent_min) as total_time
from screen_time
group by date
order by date;

-- 12. Rolling Average
select date, SUM(time_spent_min) as daily_time,
	round(Avg(Sum(time_spent_min))OVER(order by date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	),2) as rolling_avg_3_day
from screen_time
group by date;

-- 13. Weekend vs. Weekday Analysis
select
	CASE WHEN EXTRACT(DOW from date) IN (0,6) THEN 'Weekend'
	ELSE 'Weekday'
	END AS day_type,
	SUM(time_spent_min) as total_time
from screen_time
group by day_type;

--Ans: weekend- 1625, weekday-3485

-- G. PEAK DISTRACTION APPS
-- 14. Apps with high pickups but low time (most addictive)
select app_name, 
	SUM(pickups) as total_pickups,
	SUM(time_spent_min) as total_time
from screen_time
group by app_name
having SUM(pickups)>500
order by total_pickups desc;

-- Ans: Instagram has total_pickups of 729 and total_time of 1730. Whatsapp, total_pickups-531 and total_time-945

-- 15. Daily App ranking
select date, app_name, SUM(time_spent_min) as total_time,
	RANK() OVER(PARTITION BY date ORDER BY SUM(time_spent_min)DESC) AS rank
from screen_time
group by date, app_name	;

-- Ans: Instagram is ranked 1, followed by youtube and whatsapp

--16. Most 'Time Wasting' Category
select category, SUM(time_spent_min) as total_time
from screen_time
where category IN ('Social Media', 'Entertainment')
group by category
order by total_time desc;

-- Ans: Social media- 1730, Entertainment- 1650