from datetime import timedelta

from airflow import DAG
from airflow.operators.bash_operator import BashOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    'run_dbt',
    default_args=default_args,
    schedule_interval=None,  # Set your schedule interval here
) as dag:

    # Task to run dbt run
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='dbt test --select source:raw_layer ',
    )

    dbt_run
