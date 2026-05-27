# SQL ELT Warehouse

## Problem

This project models SaaS billing data for reporting.

The warehouse turns raw customer, subscription, invoice, payment, plan, and usage records into billing marts for MRR, churn, invoice collection, and customer lifetime revenue.

## Data Flow

Raw billing tables -> staging views -> intermediate subscription months -> marts

## Design Choices

- Plain Postgres SQL keeps the project easy to run locally.
- Raw tables keep source-like records.
- Staging views standardize fields without business logic.
- Marts answer billing questions directly.
- SQL checks return rows only when something is wrong.

## How To Run

```bash
docker compose up -d
make build
make checks
```

Without `make`:

```bash
docker compose exec -T postgres psql -U portfolio -d portfolio -f /work/sql/01_schema.sql
docker compose exec -T postgres psql -U portfolio -d portfolio -f /work/sql/02_models.sql
docker compose exec -T postgres psql -U portfolio -d portfolio -f /work/tests/data_quality.sql
```

## Tests

The SQL checks cover duplicate invoices, missing keys, negative amounts, invalid subscription dates, orphan payments, and impossible outstanding balances.

Metric examples:

```bash
docker compose exec -T postgres psql -U portfolio -d portfolio -f /work/sql/03_metric_examples.sql
```

## Production Notes

- A production version would load raw data incrementally instead of rebuilding every table.
- Data quality checks should fail the pipeline before marts are published.
- Metric definitions should be owned with the finance or revenue operations team.
- The current sample data is small but includes active, trial, canceled, paid, open, and void records.

## Docs

- [Architecture](docs/architecture.md)
- [Metric definitions](docs/metric_definitions.md)
- [Sample results](docs/sample_results.md)

## Portuguese

Este projeto modela dados de billing SaaS para reporting.

Ele transforma dados brutos de clientes, assinaturas, invoices, pagamentos, planos e uso em marts para MRR, churn, cobranca e receita por cliente.
