SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id,
water_quality.subjective_quality_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE  auditor_report.true_water_source_score = water_quality.subjective_quality_score AND visits.visit_count = 1
limit 10000;
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id,
water_quality.subjective_quality_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
limit 10000;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
limit 10000;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
water_source.type_of_water_source AS survey_source,
auditor_report.type_of_water_source AS auditor_source
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
water_source
ON
water_source.source_id = visits.source_id
WHERE  (auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1) 
AND 
water_source.type_of_water_source <> auditor_report.type_of_water_source
limit 10000;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
visits.assigned_employee_id,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
limit 10000;
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
employee.employee_name,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN
employee
 ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
limit 10000; -- incorrect records shows the records where we find discrepancies between the auditor and t
WITH incorrect_records AS (
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT DISTINCT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY 
employee_name;
WITH error_count AS (WITH incorrect_records AS (
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name)
SELECT
AVG(number_of_mistakes)
FROM
error_count;
-- error count
WITH error_count AS (WITH incorrect_records AS (
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name)
SELECT
employee_name,
number_of_mistakes
FROM
error_count 
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);

CREATE VIEW Incorrect_records AS (
SELECT
auditor_report.statements,
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
);
SELECT 
*
FROM
incorrect_records;

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different */

GROUP BY
employee_name)
-- Query
SELECT * FROM error_count;
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different */

GROUP BY
employee_name)
-- Query
SELECT avg(number_of_mistakes) FROM error_count;

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/

GROUP BY
employee_name)
-- Query
SELECT 
employee_name,
number_of_mistakes
FROM error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);

SELECT
auditorRep.location_id,
visitsTbl.record_id,
auditorRep.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS employee_score,
wq.subjective_quality_score - auditorRep.true_water_source_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
WHERE (wq.subjective_quality_score - auditorRep.true_water_source_score) > 9;

-- average error count
WITH error_count AS (WITH incorrect_records AS (
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name)
SELECT 
AVG(number_of_mistakes)
FROM
error_count;
-- error count
WITH suspect_list AS(
WITH error_count AS (WITH incorrect_records AS (
SELECT
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name)
SELECT
employee_name,
number_of_mistakes
FROM
error_count 
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT *
FROM incorrect_records;

/* You should get a column of names back. So let's just recap here...
1. We use Incorrect_records to find all of the records where the auditor and employee scores don't match.
2. We then used error_count to aggregate the data, and got the number of mistakes each employee made.
3. Finally, suspect_list retrieves the data of employees who make an above-average number of mistakes.
Now we can filter that Incorrect_records CTE to identify all of the records associated with the four employees we identified*/

WITH suspect_list AS(
WITH error_count AS (WITH incorrect_records AS (
SELECT
auditor_report.statements,
auditor_report.location_id,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
JOIN 
employee
ON employee.assigned_employee_id=visits.assigned_employee_id
WHERE  auditor_report.true_water_source_score <> water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name)
SELECT
employee_name,
number_of_mistakes
FROM
error_count AS suspect_list
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT 
employee_name,
location_id,
statements
FROM incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);