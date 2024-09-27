# Data Engineer Exercise

This project is focused on orchestrating data workflows using Airflow and dbt for efficient data pipeline management. The main objective is to perform transformations on `raw data` and ensure data quality through testing, using `DuckDB` as the underlying data warehouse. The project ingests `chats` and `categories`, transforms it into a more analyzable format, and validates the data through automated tests.

## Prerequisites

- Docker
- Docker Compose
- Python
- pip

## Installation

1. Goto the project directory:
    ```sh
    cd de-kata
    ```

2. Start the data pipeline:
    ```sh
    make up   # Sets up and starts the Airflow containers
    ```

3. Access the Airflow UI:
    - URL: [http://localhost:8080](http://localhost:8080)
    - Username: `airflow`
    - Password: `airflow`

## Architecture

- **dbt**: To transform the raw data into a more analyzable format.
- **DuckDB**: As the underlying data warehouse.
- **Airflow**: To schedule and orchestrate DAGs.
- **Postgres**: To store metadata and logs.
- **Docker**: To containerize the dbt and Airflow environment.
![Project Architecture](assets/img_1.png)


## Project Structure

- **DBT**: The dbt project is located in the `dbt` directory.
  - **`dbt/models`**: Contains the SQL models and tests for the dbt project.
  - **`dbt/dbt_project.yml`**: Contains the dbt project configuration.
  - **`dbt/profiles.yml`**: Contains the dbt profile configuration.
- **DAGs**: The DAG for the project are defined in the `dags` directory.
  - **`dags/dbt_orchestration.py`**: Contains the DAG to orchestrate the dbt workflow.
- **Makefile**: Contains commands to manage the project.

The `anonymize_large_csv_chunked` DAG in the Airflow UI will look like the below image:
![Project Structure](assets/img.png)

## Usage

- Run Data Ingestion and Transformation with dbt:
    ```sh
    cd dbt
    dbt run && dbt test
    ```
    The raw data will be transformed and tested using dbt.

    
- Alternatively, you can manually trigger the DAG from the Airflow UI:
    - URL: [http://localhost:8080](http://localhost:8080)
    - Username: `airflow`
    - Password: `airflow`
