from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

with DAG(
        'dbt_orchestration_dag',
        default_args={'owner': 'airflow'},
        schedule_interval='@daily',
        start_date=days_ago(1),
        catchup=True,
) as dag:
    # Run dbt tests on raw data
    source_tests = BashOperator(
        task_id='dbt_source_test',
        bash_command='dbt deps && dbt test --select source:raw_layer'
    )

    # Task to run dbt for stg__chats, stg__categories and chat_volume_analysis
    run_models = BashOperator(
        task_id='dbt_run_models',
        bash_command='dbt run --select stg__chats stg__categories chat_volume_analysis && dbt test --select stg__chats stg__categories',
    )

    # Set the task dependencies
    source_tests >> run_models

