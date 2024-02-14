SELECT
location.location_id,
location.province_name,
location.town_name,
visits.visit_count
FROM
location
JOIN
visits
ON
location.location_id=visits.location_id;
SELECT
location.location_id,
location.province_name,
location.town_name,
visits.visit_count
FROM
location
JOIN
visits
ON
location.location_id=visits.location_id;
	SELECT
	location.location_type,
	location.province_name,
	location.town_name,
	visits.time_in_queue,
    water_source.type_of_water_source,
    water_source.number_of_people_served
	/FROM
	location
	JOIN
	visits
	ON
	location.location_id=visits.location_id
    JOIN
    water_source
    ON
    water_source.source_id=visits.source_id
    WHERE visits.visit_count = 1;
    
			SELECT
			location.location_type,
			location.province_name,
			location.town_name,
			visits.time_in_queue,
			water_source.type_of_water_source,
			water_source.number_of_people_served
			FROM
			location
			JOIN
			visits
			ON
			location.location_id=visits.location_id
			JOIN
			water_source
			ON
			water_source.source_id=visits.source_id
			WHERE visits.visit_count = 1;

-- This table assembles data from different tables into one to simplify analysis
                SELECT
				water_source.type_of_water_source,
				location.town_name,
				location.province_name,
				location.location_type,
				water_source.number_of_people_served,
				visits.time_in_queue,
				well_pollution.results
				FROM
				visits
				LEFT JOIN
				well_pollution
				ON well_pollution.source_id = visits.source_id
				INNER JOIN
				location
				ON location.location_id = visits.location_id
				INNER JOIN
				water_source
				ON water_source.source_id = visits.source_id
				WHERE
				visits.visit_count = 1;
					
			-- −− This view assembles data from different tables into one to simplify analysis
				CREATE VIEW combined_analysis_table AS
                SELECT
					water_source.type_of_water_source AS source_type,
					location.town_name,
					location.province_name,
					location.location_type,
					water_source.number_of_people_served AS people_served,
					visits.time_in_queue,
					well_pollution.results
					FROM
					visits
					LEFT JOIN
					well_pollution
					ON well_pollution.source_id = visits.source_id
					INNER JOIN
					location
					ON location.location_id = visits.location_id
					INNER JOIN
					water_source
					ON water_source.source_id = visits.source_id
					WHERE
					visits.visit_count = 1;
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;

WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;
SELECT*
FROM town_aggregated_water_access;
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access
ORDER BY ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) DESC;

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future. */
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity. */
Address VARCHAR(50), -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/ Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);
-- Project_progress_query
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
 AND (
well_pollution.results != 'clean'
OR water_source.type_of_water_source='shared_tap' AND time_in_queue >= 30
OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
);
	
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter and RO filter'
WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
ELSE NULL
END AS Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
 AND (
well_pollution.results != 'clean'
OR water_source.type_of_water_source='shared_tap' AND time_in_queue >= 30
OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
);

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter and RO filter'
WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
ELSE NULL
END AS Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
 AND (
well_pollution.results != 'clean'
OR water_source.type_of_water_source='shared_tap' AND time_in_queue >= 30
OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
);

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter and RO filter'
WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
WHEN water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30 THEN CONCAT("Install", FLOOR(time_in_queue/30), "taps nearby")
WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
ELSE NULL
END AS Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
 AND (
well_pollution.results != 'clean'
OR water_source.type_of_water_source='shared_tap' AND time_in_queue >= 30
OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
);

CREATE VIEW project_progress_requirements AS (
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter and RO filter'
WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
WHEN water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30 THEN CONCAT("Install", FLOOR(time_in_queue/30), "taps nearby")
WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
ELSE NULL
END AS Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
 AND (
well_pollution.results != 'clean'
OR water_source.type_of_water_source='shared_tap' AND time_in_queue >= 30
OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
));
INSERT INTO project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT source_id, address, town_name, province_name, type_of_water_source, Improvements
FROM project_progress_requirements;

