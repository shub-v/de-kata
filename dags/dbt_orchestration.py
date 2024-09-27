from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

with DAG(
    'dbt_orchestration_dag',
    default_args={'owner': 'airflow'},
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:

    # Run dbt tests on raw data
    source_tests = BashOperator(
        task_id='dbt_source_test',
        bash_command='dbt test --select source:raw_layer'
    )

    # Run dbt  and test transformations for staging models
    run_staging_and_tests = BashOperator(
        task_id='dbt_run_staging_and_tests',
        bash_command='dbt run --select stg__chats stg__categories && dbt test --select stg__chats stg__categories'
        # bash_command='dbt run --select stg__chats stg__categories -d'
    )


    # # Run dbt tests on staging models
    # staging_tests = BashOperator(
    #     task_id='dbt_staging_test',
    #     bash_command='dbt test --select stg__chats+ stg__categories+ -d'
    #     # bash_command='dbt test'
    # )

    # Define task dependencies
    # source_tests >> run_staging
    source_tests >> run_staging_and_tests
