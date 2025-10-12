# Student Career ETL Database Project

## Overview
This project implements a fully automated ETL (Extract, Transform, Load) pipeline for processing student career data using PostgreSQL. The system automatically loads, processes, and structures student career outcome data from JSON format into a normalized relational database.

## Dataset Description
- **Source**: Student Career Dataset (JSON format)
- **Records**: 400 student records
- **Fields**: Student demographics, academic performance, career outcomes, and professional development metrics

## Architecture

### Data Flow
1. **Extract**: Raw JSON data loaded into staging table
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
- PostgreSQL 12+
- pg_cron extension for job scheduling
- JSON processing capabilities

## Setup Instructions
1. Install PostgreSQL using the dockerfile
2. Check if everything from the scripts loaded fine

## Author
Database Systems Project - Simion, Dorin, Iarina, Nora
