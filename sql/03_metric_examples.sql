select
    month_start,
    active_subscriptions,
    mrr,
    billed_amount,
    paid_amount
from marts.mart_monthly_recurring_revenue
order by month_start;

select
    customer_id,
    company_name,
    invoice_count,
    billed_lifetime_value,
    paid_lifetime_value,
    outstanding_amount
from marts.mart_customer_lifetime_revenue
order by paid_lifetime_value desc nulls last;

select
    invoice_month,
    invoice_status,
    invoice_count,
    billed_amount,
    paid_amount,
    outstanding_amount
from marts.mart_invoice_collection_status
order by invoice_month, invoice_status;
