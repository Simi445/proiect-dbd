# Student Career ETL Database Project

## Overview
This project implements a fully automated ETL (Extract, Transform, Load) pipeline for processing student career data using PostgreSQL. The system automatically loads, processes, and structures student career outcome data from JSON format into a normalized relational database.

## Dataset Description
- **Source**: Student Career Dataset (CSV format)
- **Records**: 400 student records
- **Fields**: Student demographics, academic performance, career outcomes, and professional development metrics

## Architecture

### Data Flow
1. **Extract**: CSV loaded into staging table
2. **Transform**: Data validation, cleansing, and normalization
3. **Load**: Processed data inserted into normalized production schema

### Database Design
- **Staging Schema**: Raw data import tables
- **Production Schema**: Normalized tables (1NF, 2NF, 3NF compliant)
- **Automated Jobs**: Scheduled ETL processes running daily at 02:00

## Project Structure
```
proiectdbd/
├── dataset.json
├── Dockerfile.json      
├── script01.sql ....
└── README.md
```

## Requirements
- Docker installed and up to date

## Setup Instructions

### 1. Build the Docker Image
```bash
docker build -t postgres-test .
```

### 2. Run the PostgreSQL Container
```bash
docker run -d --name postgres-job-test -e POSTGRES_PASSWORD=password -p 5432:5432 postgres-test
```

### 3. Check Container Status
```bash
docker ps
```
This command shows all running containers to verify the setup.

### 4. Connect to the Database
```bash
docker exec -it postgres-job-test psql -U postgres -d test_db
```

### 5. Verify ETL Pipeline
Once connected, you can check the automated ETL processes:
- Staging data: `SELECT * FROM staging.events LIMIT 5;`
- Production data: `SELECT * FROM production.student LIMIT 5;`
- Job logs: `SELECT * FROM etl_logs.job_runs ORDER BY start_date DESC LIMIT 10;`

## Author
Database Systems Project - Simion, Dorin, Iarina, Nora, Rares
