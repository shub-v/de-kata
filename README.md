````text
                                         /$$   /$$ /$$$$$$$ 
                                        | $$  | $$| $$__  $$
                                        | $$  | $$| $$  \ $$
                                        | $$  | $$| $$$$$$$/
                                        | $$  | $$| $$____/ 
                                        | $$  | $$| $$      
                                        |  $$$$$$/| $$      
                                         \______/ |__/      
````


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

## Quality
> 1. How would you measure the overall data quality of these files?

Data quality checks implemented at multiple stages of the pipeline to ensure the reliability and trustworthiness of the data. 
- **Source Layer**: At the source level, I have applied basic integrity checks such as:
  - **Unique Tests**: Ensuring key fields like `id` are unique.
  - **Not Null Tests**: Critical columns like `id` and `created_at` are validated to ensure they are not missing.
- **Staging Layer**: In the staging layer, I have applied more advanced checks to ensure data consistency and integrity:
  - **Referential Integrity Tests**: Ensuring relationships between the `chats` and `categories` tables are valid (e.g., each `chat_category_id` in the `chats` table must reference a valid `id` in the `categories` table).
  - **Business Logic Validation**: Applying logic checks to ensure correctness, such as ensuring that `resolved_at` is always greater than or equal to `created_at`.
   
By placing checks at both the source and staging layers, I ensure that data quality is assessed at every critical step of the pipeline, providing clean and reliable data for downstream processes.
   
> 2. How would you measure the overall data quality of these files?

dbt tests implemented to enforce the data quality checks mentioned earlier. These tests validate key aspects across both the source and staging layers.

To handle potential issues, I’ve also configured failure thresholds. For example, in the `de_test_categories` raw file, the `disabled` field had a NULL value for one particular `id`. Instead of failing the entire pipeline, this issue was flagged and corrected during the ingestion process, ensuring the data remains usable without significant disruption.
```yaml
  - name: disabled
    description: Flag indicating if the category is disabled.
    data_type: boolean
    tests:
      - not_null:
          config:
            warn_if: ">= 1"  # Warn if there are more than 1 null values
            error_if: ">= 10"  # Fail the test if there are more than 10 null values
            severity: error  # Set severity level to error
```

For further monitoring and analysis, data profiling techniques can be employed to understand data distributions and detect anomalies early. Tools like `Soda` could be used to automate profiling, track data quality over time, and catch issues such as data drift or outliers.

> 3. What would you do with invalid data that is identified?

 