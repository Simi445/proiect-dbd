\c test_db;

CREATE TABLE production.student (
    student_id VARCHAR(10) PRIMARY KEY,
    age INT CHECK (age > 0),
    gender VARCHAR(10)
);


CREATE TABLE production.academic_performance (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES production.student(student_id) ON DELETE CASCADE,
    high_school_gpa NUMERIC(3,2) CHECK (high_school_gpa BETWEEN 2.0 AND 4.0),
    sat_score INT CHECK (sat_score BETWEEN 900 AND 1600),
    university_gpa NUMERIC(3,2) CHECK (university_gpa BETWEEN 2.0 AND 4.0),
    field_of_study VARCHAR(100)
);


CREATE TABLE production.skills_extracurriculars (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES production.student(student_id) ON DELETE CASCADE,
    internships_completed INT CHECK (internships_completed BETWEEN 0 AND 4),
    projects_completed INT CHECK (projects_completed BETWEEN 0 AND 9),
    certifications INT CHECK (certifications BETWEEN 0 AND 5),
    soft_skills_score INT CHECK (soft_skills_score BETWEEN 1 AND 10),
    networking_score INT CHECK (networking_score BETWEEN 1 AND 10)
);


CREATE TABLE production.career_outcomes (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES production.student(student_id) ON DELETE CASCADE,
    job_offers INT CHECK (job_offers BETWEEN 0 AND 5),
    starting_salary INT CHECK (starting_salary BETWEEN 25000 AND 1000000),
    career_satisfaction INT CHECK (career_satisfaction BETWEEN 1 AND 10),
    years_to_promotion INT CHECK (years_to_promotion BETWEEN 1 AND 5),
    current_job_level VARCHAR(20) CHECK (current_job_level IN ('Entry', 'Mid', 'Senior', 'Executive')),
    work_life_balance INT CHECK (work_life_balance BETWEEN 1 AND 10),
    entrepreneurship VARCHAR(3) CHECK (entrepreneurship IN ('Yes', 'No'))
);

CREATE OR REPLACE FUNCTION load_production_data()
RETURNS void AS $$
BEGIN
    INSERT INTO production.student (student_id, age, gender)
    SELECT DISTINCT 
        content->>'student_id',
        (content->>'age')::INTEGER,
        content->>'gender'
    FROM staging.events
    ON CONFLICT (student_id) DO UPDATE SET
        age = EXCLUDED.age,
        gender = EXCLUDED.gender;

    INSERT INTO production.academic_performance (
        student_id, high_school_gpa, sat_score, university_gpa, field_of_study
    )
    SELECT DISTINCT
        content->>'student_id',
        (content->>'high_school_gpa')::NUMERIC(3,2),
        (content->>'sat_score')::INTEGER,
        (content->>'university_gpa')::NUMERIC(3,2),
        content->>'field_of_study'
    FROM staging.events
    ON CONFLICT (student_id) DO UPDATE SET
        high_school_gpa = EXCLUDED.high_school_gpa,
        sat_score = EXCLUDED.sat_score,
        university_gpa = EXCLUDED.university_gpa,
        field_of_study = EXCLUDED.field_of_study;

    INSERT INTO production.skills_extracurriculars (
        student_id, internships_completed, projects_completed, 
        certifications, soft_skills_score, networking_score
    )
    SELECT DISTINCT
        content->>'student_id',
        (content->>'internships_completed')::INTEGER,
        (content->>'projects_completed')::INTEGER,
        (content->>'certifications')::INTEGER,
        (content->>'soft_skills_score')::INTEGER,
        (content->>'networking_score')::INTEGER
    FROM staging.events
    ON CONFLICT (student_id) DO UPDATE SET
        internships_completed = EXCLUDED.internships_completed,
        projects_completed = EXCLUDED.projects_completed,
        certifications = EXCLUDED.certifications,
        soft_skills_score = EXCLUDED.soft_skills_score,
        networking_score = EXCLUDED.networking_score;

    INSERT INTO production.career_outcomes (
        student_id, job_offers, starting_salary, career_satisfaction,
        years_to_promotion, current_job_level, work_life_balance, entrepreneurship
    )
    SELECT DISTINCT
        content->>'student_id',
        (content->>'job_offers')::INTEGER,
        (content->>'starting_salary')::INTEGER,
        (content->>'career_satisfaction')::INTEGER,
        (content->>'years_to_promotion')::INTEGER,
        content->>'current_job_level',
        (content->>'work_life_balance')::INTEGER,
        content->>'entrepreneurship'
    FROM staging.events
    ON CONFLICT (student_id) DO UPDATE SET
        job_offers = EXCLUDED.job_offers,
        starting_salary = EXCLUDED.starting_salary,
        career_satisfaction = EXCLUDED.career_satisfaction,
        years_to_promotion = EXCLUDED.years_to_promotion,
        current_job_level = EXCLUDED.current_job_level,
        work_life_balance = EXCLUDED.work_life_balance,
        entrepreneurship = EXCLUDED.entrepreneurship;
END;
$$ LANGUAGE plpgsql;


SELECT cron.schedule(
    'etl-job',    
    '*/2 * * * *',             
    $$ SELECT load_production_data(); $$
);
