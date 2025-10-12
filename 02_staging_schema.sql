\c test_db;

CREATE TABLE IF NOT EXISTS staging.events (
    stagEventId SERIAL PRIMARY KEY,
    content JSONB NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS etl_logs.job_runs (
    logId SERIAL PRIMARY KEY,
    jobname TEXT NOT NULL,
    status TEXT NOT NULL, 
    error_message TEXT,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    records_count INT DEFAULT 0
);


CREATE OR REPLACE FUNCTION return_max_date()
RETURNS timestamp AS $$
DECLARE
    last_load_time timestamp;
BEGIN
    SELECT MAX(end_date) INTO last_load_time 
    FROM etl_logs.job_runs 
    WHERE jobname = 'dataset-load' AND status = 'completed';

    RETURN last_load_time;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION upsert_dataset()
RETURNS integer AS $$
DECLARE
    rc integer := 0;
    updated_count integer := 0;
    inserted_count integer := 0;
BEGIN
    CREATE TEMP TABLE temp_csv_data (
        student_id TEXT,
        age INTEGER,
        gender TEXT,
        high_school_gpa DECIMAL(3,2),
        sat_score INTEGER,
        university_gpa DECIMAL(3,2),
        field_of_study TEXT,
        internships_completed INTEGER,
        projects_completed INTEGER,
        certifications INTEGER,
        soft_skills_score INTEGER,
        networking_score INTEGER,
        job_offers INTEGER,
        starting_salary INTEGER,
        career_satisfaction INTEGER,
        years_to_promotion INTEGER,
        current_job_level TEXT,
        work_life_balance INTEGER,
        entrepreneurship TEXT
    );

    COPY temp_csv_data
    FROM '/app/dataset.csv'
    WITH (FORMAT csv, HEADER true);

    WITH updated_records AS (
        UPDATE staging.events 
        SET content = row_to_json(t)::jsonb,
            load_date = CURRENT_TIMESTAMP
        FROM temp_csv_data t

        WHERE staging.events.content->>'student_id' = t.student_id
        AND staging.events.content != row_to_json(t)::jsonb
        RETURNING *
    )
    SELECT COUNT(*) INTO updated_count FROM updated_records;

    WITH inserted_records AS (
        INSERT INTO staging.events (content)
        SELECT row_to_json(t)::jsonb
        FROM temp_csv_data t
        
        WHERE NOT EXISTS (
            SELECT 1 FROM staging.events 
            WHERE content->>'student_id' = t.student_id
        )
        RETURNING *
    )
    SELECT COUNT(*) INTO inserted_count FROM inserted_records;

    rc := updated_count + inserted_count;

    DROP TABLE temp_csv_data;
    
    RETURN rc;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_job_run(job_log_id integer, records_inserted integer)
RETURNS void AS $$
BEGIN
    UPDATE etl_logs.job_runs 
    SET status = 'completed', 
        end_date = CURRENT_TIMESTAMP,
        records_count = records_inserted
    WHERE logId = job_log_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_job_skipped(job_log_id integer)
RETURNS void AS $$
BEGIN
    UPDATE etl_logs.job_runs 
    SET status = 'skipped', 
        end_date = CURRENT_TIMESTAMP,
        error_message = 'Dataset file unchanged'
    WHERE logId = job_log_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_job_failed(job_log_id integer,  p_error_message text)
RETURNS void AS $$
BEGIN
    UPDATE etl_logs.job_runs 
    SET status = 'failed', 
        end_date = CURRENT_TIMESTAMP,
        error_message = p_error_message
    WHERE logId = job_log_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION run_load_dataset_job()
RETURNS void AS $$
DECLARE
    file_mod_time timestamp;
    last_load_time timestamp;
    records_inserted int := 0;
    job_log_id int;
BEGIN
    INSERT INTO etl_logs.job_runs (jobname, status, start_date)
    VALUES ('dataset-load', 'running', CURRENT_TIMESTAMP)
    RETURNING logId INTO job_log_id;
    
    BEGIN
        SELECT modification FROM pg_stat_file('/app/dataset.csv') INTO file_mod_time;
        SELECT return_max_date() INTO last_load_time;

        IF last_load_time IS NULL OR file_mod_time > last_load_time THEN

            SELECT upsert_dataset() INTO records_inserted;
            
            PERFORM update_job_run(job_log_id, records_inserted);
                
            RAISE NOTICE 'Loaded % records from dataset.csv', records_inserted;
        ELSE
            PERFORM update_job_skipped(job_log_id);
            RAISE NOTICE 'Dataset file unchanged, skipping load';
        END IF;
        
    EXCEPTION 
        WHEN OTHERS THEN
            PERFORM update_job_failed(job_log_id, SQLERRM);
            RAISE NOTICE 'Dataset load failed: %', SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule(
    'load-dataset',    
    '*/1 * * * *',             
    $$ SELECT run_load_dataset_job(); $$
);