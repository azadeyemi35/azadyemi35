SELECT
REPLACE(employee_name, ' ','.') -- Replace the space with a full stop
FROM
employee;
SELECT
LOWER(REPLACE(employee_name, ' ','.')) -- Make it all lower case
FROM
employee;
SELECT
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email -- add it all together
FROM
employee;
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),

'@ndogowater.gov');
SELECT
LENGTH(phone_number)
FROM
employee; -- checking excesses in phone number
SELECT
TRIM(phone_number) -- Trim space after number
FROM	
employee;
UPDATE 
employee
SET
phone_number = TRIM(phone_number); -- updates correct phone number lenght
SELECT 
town_name,
COUNT(employee_name)
FROM
employee
GROUP BY
town_name; -- To see our employee locations
SELECT
assigned_employee_id,
COUNT(vis111111111111111111111111111111111111111111111111111111111111111111111111111111111111it_count) AS C
FROM
visits
GROUP BY
assigned_employee_id 
ORDER BY C DESC LIMIT 3; -- The top three employee
SELECT
assigned_employee_id,
employee_name,
phone_number,
email
FROM
employee
WHERE assigned_employee_id IN (1, 30, 34); -- views the top 3 employee info

SELECT 
province_name,
COUNT(location_id)
FROM
location
GROUP BY
province_name;
SELECT
province_name,
town_name,
COUNT(location_id) AS records_per_town
FROM
location
GROUP BY  province_name, town_name
ORDER BY province_name, records_per_town DESC;  /* These results show us that our field surveyors did an excellent job of documenting the status of our country's water crisis. 
Every province and town*/

SELECT
location_type,
COUNT(location_id)
FROM
location
GROUP BY 
location_type; -- records for location type
SELECT 
ROUND(23740 / (15910 + 23740) * 100); -- records for location type in percentage

-- INSIGHTS FROM THE LOCATION TABLE
/* 1. The entire country was properly canvassed, and our dataset represents the situation on the ground.
   2. 60% of the water sources are in rural communities across Maji Ndogo. We need to keep this in mind when we make decisions.*/
SELECT
type_of_water_source,
COUNT(type_of_water_source) AS number_of_sources
FROM 
water_source
GROUP BY
type_of_water_source;
SELECT
ROUND(AVG(number_of_people_served)) AS avg_number_of_people_served,
type_of_water_source
FROM
water_source
GROUP BY 
type_of_water_source;
SELECT
type_of_water_source,
SUM(number_of_people_served) AS total_served_persoure
FROM
water_source
GROUP BY type_of_water_source
ORDER BY  total_served_persoure DESC;
SELECT
type_of_water_source,
ROUND(SUM(number_of_people_served)/(select (sum(number_of_people_served)) from water_source) *100)AS total_people_served
FROM
water_source
GROUP BY 
type_of_water_source
ORDER BY total_people_served DESC;-- sum of total number of people served by each water source

SELECT
type_of_water_source,
SUM(number_of_people_served) AS population,
RANK () OVER (ORDER BY SUM(number_of_people_served) desc) AS rank_by_population
FROM
water_source
WHERE
type_of_water_source <> 'tap_in_home'
GROUP BY
type_of_water_source; -- ranking by population (number of people served)

SELECT
source_id,
type_of_water_source,
SUM(number_of_people_served) AS population,
row_number () OVER (PARTITION BY type_of_water_source ORDER BY SUM(number_of_people_served) desc) AS priority_rank
FROM
water_source
WHERE
type_of_water_source <> 'tap_in_home'
GROUP BY
source_id,
type_of_water_source
ORDER BY population desc; -- Ranking fixing priority	


SELECT * FROM md_water_services.visits;
/* 
To calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), and subtract
them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.*/

SELECT 
timestampdiff(DAY, MIN(time_of_record), MAX(time_of_record))
FROM 
visits;
/*Let's see how long people have to queue on average in Maji Ndogo. Keep in mind that many sources like taps_in_home have no queues. These
are just recorded as 0 in the time_in_queue column, so when we calculate averages, we need to exclude those rows. Try using NULLIF() do to
this.*/
SELECT
AVG(time_in_queue) 
FROM
md_water_services.visits
WHERE time_in_queue > 0;
SELECT
DAYNAME(time_of_record)AS day_week,
ROUND(AVG(time_in_queue))
FROM 
visits
WHERE time_in_queue > 0
GROUP BY 
day_week; -- queue time per day
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS day_time,
round(AVG(time_in_queue))
FROM 
visits
WHERE time_in_queue > 0
GROUP BY 
day_time
ORDER BY AVG(time_in_queue) desc;
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0; -- this exludes other sources with 0 queue times.
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;
SELECT
town_name,
COUNT(town_name) AS num_employee
FROM
employee
GROUP BY town_name;
SELECT
assigned_employee_id,
COUNT(visit_count) 
FROM
visits
GROUP BY
assigned_employee_id
ORDER BY 
COUNT(visit_count) ASC;
SELECT 
assigned_employee_id,
employee_name
FROM
employee
WHERE 
assigned_employee_id IN (20, 22);
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
    SELECT
    AVG(number_of_people_served), type_of_water_source
FROM water_source
GROUP BY
type_of_water_source;



																																																																																																																																																																																																																																																																																																																																																																				