SELECT job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(
        MONTH
        FROM job_posted_date
    ) as date_month,
    EXTRACT(
        YEAR
        FROM job_posted_date
    ) as date_year
FROM job_postings_fact
LIMIT 5;
SELECT COUNT(job_id) as job_posted_count,
    EXTRACT(
        MONTH
        FROM job_posted_date
    ) AS month
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY month
ORDER BY job_posted_count DESC;
SELECT job_schedule_type,
    AVG(salary_year_avg) AS yearly_avg,
    AVG(salary_hour_avg) AS hourly_avg,
    EXTRACT(
        MONTH
        FROM job_posted_date
    ) AS date_month,
    EXTRACT(
        YEAR
        FROM job_posted_date
    ) AS date_year
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) > 5
    AND EXTRACT(
        YEAR
        FROM job_posted_date
    ) > 2022
GROUP BY job_schedule_type,
    date_month,
    date_year;
SELECT job_title_short AS job_list,
    EXTRACT(
        MONTH
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS date_month,
    EXTRACT(
        YEAR
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS date_year
FROM job_postings_fact
WHERE EXTRACT(
        YEAR
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) = 2023
LIMIT 100;
SELECT job_postings.job_id,
    job_postings.job_title_short,
    companies.name,
    EXTRACT(
        MONTH
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS date_month,
    EXTRACT(
        YEAR
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS date_year,
    EXTRACT(
        QUARTER
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS date_quarter
FROM job_postings_fact AS job_postings
    LEFT JOIN company_dim AS companies ON job_postings.company_id = companies.company_id
WHERE EXTRACT(
        QUARTER
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) = 2
    AND EXTRACT(
        YEAR
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) = 2023
LIMIT 1000;
-- January
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 1;
-- for February
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 2;
-- March
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 3;
SELECT job_posted_date
FROM march_jobs;
SELECT job_title_short,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category,
    CASE
        WHEN salary_year_avg < 50000 THEN 'Low'
        WHEN salary_year_avg < 90000 THEN 'Standard'
        ELSE 'High'
    END AS salary_range
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY job_title_short,
    salary_year_avg,
    location_category
ORDER BY salary_range DESC;
SELECT *
FROM (
        -- SubQuery starts here
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT(
                MONTH
                FROM job_posted_date
            ) = 1
    ) AS january_jobs;
-- SubQuery ends here
WITH january_jobs AS (
    -- CTE starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(
            MONTH
            FROM job_posted_date
        ) = 1
)
SELECT *
FROM job_postings_fact;
-- ***********SUBQUERY ***********
SELECT company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
        SELECT company_id
        FROM job_postings_fact
        WHERE job_no_degree_mention = true
        ORDER BY company_id
    );
WITH company_job_count AS (
    SELECT company_id,
        COUNT(*) as total_jobs
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
    LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC;
SELECT COUNT(job_postings_fact.job_id) as job_count,
    skills_dim.skills
FROM job_postings_fact
    LEFT JOIN skills_job_dim AS skills_job ON skills_job.job_id = job_postings_fact.job_id
    LEFT JOIN skills_dim ON skills_job.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_id IN (
        SELECT job_id
        FROM skills_job_dim
    )
GROUP BY skills_dim.skills
ORDER BY job_count DESC
LIMIT 5;
SELECT skills_dim.skills,
    -- Skill name from skills_dim
    COUNT(job_postings_fact.job_id) AS job_count -- Count of job postings for each skill
FROM job_postings_fact
    LEFT JOIN skills_job_dim AS skills_job -- Join with skills_job_dim to link jobs and skills
    ON skills_job.job_id = job_postings_fact.job_id
    LEFT JOIN skills_dim -- Join with skills_dim to get the skill name
    ON skills_job.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_id IN (
        -- Subquery to get job IDs associated with skills
        SELECT job_id
        FROM skills_job_dim -- Subquery returns job_ids that are linked to skills
    )
GROUP BY skills_dim.skills -- Group by skill to count jobs per skill
ORDER BY job_count DESC
LIMIT 10;
SELECT COUNT(job_postings_fact.company_id) AS job_count,
    companies.name,
    job_postings_fact.company_id,
    CASE
        WHEN COUNT(job_postings_fact.company_id) < 10 THEN 'Small'
        WHEN COUNT(job_postings_fact.company_id) BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM job_postings_fact
    LEFT JOIN company_dim AS companies ON job_postings_fact.company_id = companies.company_id
WHERE job_postings_fact.job_id IN (
        SELECT job_id
        FROM company_dim
    )
GROUP BY companies.name,
    job_postings_fact.company_id
ORDER BY job_count ASC
SELECT company_id,
    name
FROM company_dim
WHERE name IN ('Emprego', 'Booz Allen Hamilton', 'Dice')
SELECT COUNT(job_id) AS company_count,
    company_id,
    CASE
        WHEN company_id = 572 THEN 'Emprego'
        WHEN company_id = 49 THEN 'Booz Allen Hamilton'
        ELSE 'Dice'
    END as company_name
FROM job_postings_fact
WHERE company_id IN (572, 49, 1148)
GROUP BY company_id;
WITH remote_job_skills AS (
    SELECT skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim AS skills_to_job
        INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE job_postings.job_work_from_home = True
        AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)
SELECT skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
    INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5;
-- ************** UNION *****************
SELECT *
FROM january_jobs
SELECT *
FROM february_jobs
SELECT *
FROM march_jobs WITH q1_job_post AS (
        SELECT *
        FROM january_jobs
        UNION ALL
        SELECT *
        FROM february_jobs
        UNION ALL
        SELECT *
        FROM march_jobs
    )
SELECT skills.skills,
    skills.type,
    salary_year_avg
FROM q1_job_post
    INNER JOIN skills_job_dim as skills_to_job ON q1_job_post.job_id = skills_to_job.job_id
    INNER JOIN skills_dim AS skills ON skills_to_job.skill_id = skills.skill_id
WHERE salary_year_avg > 70000
    AND q1_job_post.job_title_short = 'Data Analyst'
ORDER BY salary_year_avg