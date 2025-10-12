FROM postgres:16

RUN apt-get update && apt-get install -y \
    postgresql-16-cron \
    && rm -rf /var/lib/apt/lists/*

RUN echo "shared_preload_libraries = 'pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "cron.database_name = 'test_db'" >> /usr/share/postgresql/postgresql.conf.sample

WORKDIR /app

COPY dataset.csv /app/dataset.csv

COPY 01_database_setup.sql /docker-entrypoint-initdb.d/01_database_setup.sql
COPY 02_staging_schema.sql /docker-entrypoint-initdb.d/02_staging_schema.sql
COPY 03_production_schema.sql /docker-entrypoint-initdb.d/03_production_schema.sql  