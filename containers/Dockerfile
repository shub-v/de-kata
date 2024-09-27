# Use the official Airflow image as the base image
FROM apache/airflow:2.9.2

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy requirements.txt first to install dependencies
COPY requirements.txt ./

# Install any additional Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Set environment variables
ENV AIRFLOW_HOME=/opt/airflow
ENV DBT_PROFILES_DIR=/opt/airflow/dbt
ENV DBT_PROJECT_DIR=/opt/airflow/dbt
ENV RAW_DATA_PATH=/opt/airflow/raw_data

