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
1. Run PostgreSQL using the dockerfile image.
2. Check if everything from the scripts loaded fine

## Author
Database Systems Project - Simion, Dorin, Iarina, Nora
