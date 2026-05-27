# Metric Definitions

## MRR

Monthly recurring revenue from active subscriptions.

## Active Subscriptions

Subscriptions with status `active` in the subscription month model.

## Billed Amount

Invoice amount for paid and open invoices.

## Collected Revenue

Payment amount received against invoices.

## Outstanding Revenue

Invoice amount minus collected payment amount.

## Churned MRR

Monthly plan value from subscriptions with status `canceled` and an end date.

## Customer Lifetime Revenue

Total billed and paid revenue by customer across all invoices.

## Assumptions

- Trial subscriptions do not count as active MRR.
- Void invoices do not count as billed MRR.
- Monthly plan value is taken from the plan catalog.
- Payment records are treated as successful payments.
