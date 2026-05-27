# Architecture

## Problem

The warehouse answers billing questions for a SaaS business:

- How much MRR do we have?
- Which customers are active?
- How much revenue was billed and collected?
- Which subscriptions churned?
- Which invoices still need collection?

## Data Flow

Raw billing data -> staging views -> subscription month model -> marts -> metric queries

## Design Choices

- Raw tables keep source-shaped billing data.
- Staging views clean names without hiding source fields.
- Intermediate tables hold reusable business logic.
- Marts are built for reporting and metric queries.
- Quality checks are plain SQL so they can run anywhere Postgres runs.

## Tradeoffs

- This project uses SQL scripts instead of dbt to keep the local setup small.
- The sample data is small on purpose, but it includes active, trial, paid, open, void, and canceled records.
- The models are rebuilt from scratch locally. A production version would use incremental loads.
