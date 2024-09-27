####################################################################################################################
# Setup containers to run Airflow

docker-spin-up:
	docker compose up airflow-init && docker compose up --build -d

perms:
	mkdir -p logs dags tests data  && chmod -R u=rwx,g=rwx,o=rwx logs dags tests data

up: perms docker-spin-up

down:
	docker compose down --volumes --rmi all

restart: down up

sh:
	docker exec -ti scheduler /bin/bash