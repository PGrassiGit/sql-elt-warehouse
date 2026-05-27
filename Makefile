PSQL = docker compose exec -T postgres psql -U portfolio -d portfolio

.PHONY: up down build checks

up:
	docker compose up -d

down:
	docker compose down

build:
	$(PSQL) -f /work/sql/01_schema.sql
	$(PSQL) -f /work/sql/02_models.sql

checks:
	$(PSQL) -f /work/tests/data_quality.sql
