-- 1. Get to know our data:

SHOW TABLES; -- Getting to know the data by investing tables

SELECT * 
FROM
location
LIMIT 5; -- A peep into the location table

SELECT *
FROM 
visits
LIMIT 5; -- looking at the visits table.

-- 2. Dive into the water sources:

SELECT *
FROM 
water_source
LIMIT 5; -- water source' first five

SELECT * FROM md_water_services.data_dictionary; -- a look into the data dictionary

SELECT DISTINCT 
type_of_water_source
FROM 
water_source; -- finding the unique water source types

/* An important note on the home taps: About 6-10 million people have running water 
installed in their homes in Maji Ndogo, including broken taps. If we were to document this, 
we would have a row of data for each home, so that one record is one tap. That means our database 
would contain about 1 million rows of data, which may slow our systems down. For now, the 
surveyors combined the data of many households together into a single record. */

/* For example, the first record, AkHa00000224 is for a tap_in_home that serves 956 people. 
What this means is that the records of about 160 homes nearby were combined into one record,
with an average of 6 people living in each house 160 x 6 ≈ 956. So 1 tap_in_home 
or tap_in_home_broken record actually refers to multiple households, with the sum of the people living in these homes equal to num-
ber_of_people_served. */
-- 3. Unpack the visits to water sources:

SELECT *
FROM 
visits
WHERE 
time_in_queue > 500; /* retrieves all records from this table where the time_in_queue is more
 than some crazy time, say 500 min. How would it feel to queue 8 hours for water? */
 
 -- How is this possible? Can you imagine queueing 8 hours for water?
 
 /* I am wondering what type of water sources take this long to queue for. We will have to 
 find that information in another table that lists the types of water sources. If I remember
 correctly, the table has type_of_water_source, and a source_id column. So we wrote
down a couple of these source_id values from our results, and search for them in the other
 table.
AkKi00881224
SoRu37635224
AkLu01628224
If we just select the first couple of records of the visits table without a WHERE filter,
 we can see that some of these rows also have 0 mins queue time. So we take one or
 two of these too. */

-- Ok, so now back to the water_source table. we checked the records for those source_ids.
SELECT 
*
FROM 
water_source
WHERE source_id IN ("AkKi00881224", "AkLu01628224"); 

/* 4. Assess the quality of water sources:
The quality of our water sources is the whole point of this survey. We have a table that 
contains a quality score for each visit made about a water source that was assigned by a 
Field surveyor. They assigned a score to each source from 1, being terrible, to 10 for a 
good, clean water source in a home. Shared taps are not rated as high, and the score also 
depends on how long the queue times are. */

SELECT *
FROM 
water_quality
WHERE 
(subjective_quality_score = 10 AND visit_count = 2); /* finding records where the 
subject_quality_score is 10 and where the source
was visited a second time. */
 /*The surveyors only made multiple visits to shared taps and did not revisit other types of 
 water sources. So there should be no records of second visits to locations where there 
 are good water sources, like taps in homes.*/ 
 
 /* getting 218 rows of data means there tendency of mistake in our data, there's a need to 
 into our data quality by the engineers*/
 
-- 5. Investigate pollution issues:
/* We noticed that we recorded contamination/pollution data for all of the well sources? 
We will find the right table and print the first few rows.*/
SELECT * 
FROM 
well_pollution
WHERE
biological > 0.01 AND results = 'Clean'
LIMIT 5;

/* It looks like our scientists diligently recorded the water quality of all the wells. Some are contaminated with biological contaminants,
while others are polluted with an excess of heavy metals and other pollutants. Based on the results, each well was classified as Clean,
Contaminated: Biological or Contaminated: Chemical. It is important to know this because wells that are polluted with bio- or
other contaminants are not safe to drink. It looks like they recorded the source_id of each test, so we can link it to a source, at some
place in Maji Ndogo. */ 	

/* In the well pollution table, the descriptions are notes taken by our scientists as text, so it will be challenging to process it. The
biological column is in units of CFU/mL, so it measures how much contamination is in the water. 0 is clean, and anything more than
0.01 is contaminated.
Let's check the integrity of the data. The worst case is if we have contamination, but we think we don't. People can get sick, so we
need to make sure there are no errors here. */

-- So, we write a query that checks if the results is Clean but the biological column is > 0.01.
SELECT * 
FROM 
well_pollution
WHERE
biological > 0.01 AND description LIKE 'Clean%';

/* Case 1a: Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
−− Case 1b: Update the descriptions that mistakenly mention
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
−− Case 2: Update the `result` to `Contaminated: Biological` where
`biological` is greater than 0.01 plus current results is `Clean` */

/* If we compare the results of this query to the entire table it seems like we have some inconsistencies in how the well statuses are
recorded. Specifically, it seems that some data input personnel might have mistaken the description field for determining the clean-
liness of the water.*/ 

/* It seems like, in some cases, if the description field begins with the word “Clean”, the results have been classified as “Clean” in the re-
sults column, even though the biological column is > 0.01. */ 

/* Vuyisile has told me that the descriptions should only have the word “Clean” if there
 is no biological contamination (and no chemical pollutants). Some data personnel must have 
copied the data from the scientist's notes into our database incorrectly. We need to find 
and remove the “Clean” part from all the descriptions that do have a biological 
contamination so this mistake is not made again.*/ 

/* The second issue has arisen from this error, but it is much more problematic. Some of the field surveyors have marked wells as 
Clean in the results column because the description had the word “Clean” in it, even though 
they have a biological contamination. So we need to find all the results that have a value 
greater than 0.01 in the biological column and have been set to Clean in the results column.*/

/* First, let's look at the descriptions. We need to identify the records that mistakenly have the word Clean in the description. 
However, it is important to remember that not all of our field surveyors used the description
 to set the results – some checked the actual data.*/
 
UPDATE
well_pollution
SET
description = "Bacteria: E. coli"
WHERE 
description = "Clean Bacteria: E. coli";
UPDATE
well_pollution
SET
description = "Bacteria: Giardia Lamblia"
WHERE 
description = "Clean Bacteria: Giardia Lamblia";
UPDATE 
well_pollution
SET
results = "Contaminated: Biological"
WHERE
biological > 0.01 AND results= "Clean";
SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%" OR (results = "Clean" AND biological > 0.01);

-- MCQ 1-10
SELECT
*
FROM 
employee
WHERE 
employee_name = 'Bello Azibo';
SELECT
*
FROM
employee
WHERE
position LIKE "%Micro%";
SELECT *
FROM water_source
ORDER BY number_of_people_served DESC;
SELECT 
SUM(number_of_people_served)
FROM
water_source;
SELECT *
FROM data_dictionary WHERE description LIKE '%population%';
SELECT * 
FROM global_water_access 
WHERE name = 'Maji Ndogo';
SELECT employee_name
FROM employee
WHERE
(phone_number LIKE "%86%"
 OR phone_number LIKE "%11%") 
 AND (employee_name LIKE " A%"
 OR employee_name LIKE " M%")
 AND position = "Field Surveyor";
SELECT employee_name
FROM employee
WHERE 
    (phone_number LIKE '%86%'
    OR phone_number LIKE '%11%')
    AND (employee_name LIKE '% A%' 
    OR employee_name LIKE '% M%')
    AND position = 'Field Surveyor';
    
    SELECT * 
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);
