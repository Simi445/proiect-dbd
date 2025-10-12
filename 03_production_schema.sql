\c test_db;

CREATE TABLE production.student (
    student_id VARCHAR(10) PRIMARY KEY,
    age INT CHECK (age > 0),
    gender VARCHAR(10)
);


CREATE TABLE production.academic_performance (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES student(student_id) ON DELETE CASCADE,
    high_school_gpa NUMERIC(3,2) CHECK (high_school_gpa BETWEEN 2.0 AND 4.0),
    sat_score INT CHECK (sat_score BETWEEN 900 AND 1600),
    university_gpa NUMERIC(3,2) CHECK (university_gpa BETWEEN 2.0 AND 4.0),
    field_of_study VARCHAR(100)
);


CREATE TABLE production.skills_extracurriculars (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES student(student_id) ON DELETE CASCADE,
    internships_completed INT CHECK (internships_completed BETWEEN 0 AND 4),
    projects_completed INT CHECK (projects_completed BETWEEN 0 AND 9),
    certifications INT CHECK (certifications BETWEEN 0 AND 5),
    soft_skills_score INT CHECK (soft_skills_score BETWEEN 1 AND 10),
    networking_score INT CHECK (networking_score BETWEEN 1 AND 10)
);


CREATE TABLE production.career_outcomes (
    student_id VARCHAR(10) PRIMARY KEY
        REFERENCES student(student_id) ON DELETE CASCADE,
    job_offers INT CHECK (job_offers BETWEEN 0 AND 5),
    starting_salary INT CHECK (starting_salary BETWEEN 25000 AND 150000),
    career_satisfaction INT CHECK (career_satisfaction BETWEEN 1 AND 10),
    years_to_promotion INT CHECK (years_to_promotion BETWEEN 1 AND 5),
    current_job_level VARCHAR(20) CHECK (current_job_level IN ('Entry', 'Mid', 'Senior', 'Executive')),
    work_life_balance INT CHECK (work_life_balance BETWEEN 1 AND 10),
    entrepreneurship VARCHAR(3) CHECK (entrepreneurship IN ('Yes', 'No'))
);