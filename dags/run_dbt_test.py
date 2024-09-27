from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator, PythonOperator

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
with DAG(
    'dbt_test_with_notification',
    default_args=default_args,
    description='Run dbt tests and notify on failures or warnings',
    schedule_interval=None,
    start_date=datetime(2023, 1, 1),
    catchup=False,
) as dag:
    # Task to run the dbt test
    run_dbt_test = BashOperator(
        task_id='run_dbt_test',
        bash_command='dbt test --select source:raw_layer > /tmp/dbt_test_output.txt; '
        'tail -n 10 /tmp/dbt_test_output.txt',  # Store the output
        do_xcom_push=True,
    )

    # Function to determine if there are warnings or errors
    def check_dbt_test_status(**kwargs):
        test_output = kwargs['ti'].xcom_pull(task_ids='run_dbt_test')

        # Check the output for warnings or errors
        if 'WARNING' in test_output or 'ERROR' in test_output:
            return 'log_test_results'  # Trigger the notification task
        else:
            return 'skip_notification'  # Skip the notification task

    # Task to check if there are warnings or errors in the dbt test
    check_test_results = BranchPythonOperator(
        task_id='check_test_results',
        python_callable=check_dbt_test_status,
        provide_context=True,
    )

    # Function to log the dbt test results based on success or failure
    def log_dbt_test_results(**kwargs):
        test_output = kwargs['ti'].xcom_pull(task_ids='run_dbt_test')

        if 'WARNING' in test_output or 'ERROR' in test_output:
            print("DBT Tests completed with warnings or errors. Output:")
            print(test_output)
        else:
            print("DBT Tests passed without warnings or errors.")

    # Task to log the dbt test results
    log_test_results = PythonOperator(
        task_id='log_test_results',
        python_callable=log_dbt_test_results,
        provide_context=True,
    )

    # Dummy task to skip the notification if no warnings or errors are found
    skip_notification = DummyOperator(task_id='skip_notification')

    # Define the task dependencies
    run_dbt_test >> check_test_results
    check_test_results >> [log_test_results, skip_notification]
