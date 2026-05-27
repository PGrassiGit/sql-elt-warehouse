create or replace view staging.stg_customers as
select
    customer_id,
    company_name,
    industry,
    country,
    created_at
from raw.customers;

create or replace view staging.stg_product_plans as
select
    plan_id,
    plan_name,
    monthly_price,
    included_seats,
    is_active
from raw.product_plans;

create or replace view staging.stg_subscriptions as
select
    subscription_id,
    customer_id,
    plan_id,
    status,
    started_at,
    ended_at,
    seats
from raw.subscriptions;

create or replace view staging.stg_invoices as
select
    invoice_id,
    customer_id,
    subscription_id,
    invoice_date,
    due_date,
    amount,
    status
from raw.invoices;

create or replace view staging.stg_payments as
select
    payment_id,
    invoice_id,
    paid_at,
    amount,
    payment_method
from raw.payments;

create or replace view staging.stg_usage_events as
select
    event_id,
    customer_id,
    subscription_id,
    event_date,
    event_type,
    quantity
from raw.usage_events;

drop table if exists intermediate.int_subscription_months;

create table intermediate.int_subscription_months as
select
    subscriptions.subscription_id,
    subscriptions.customer_id,
    subscriptions.plan_id,
    plans.plan_name,
    subscriptions.status,
    subscriptions.started_at,
    subscriptions.ended_at,
    subscriptions.seats,
    plans.monthly_price,
    date_trunc('month', invoices.invoice_date)::date as month_start,
    sum(case when invoices.status in ('paid', 'open') then invoices.amount else 0 end) as billed_amount,
    sum(coalesce(payments.amount, 0)) as paid_amount
from staging.stg_subscriptions subscriptions
join staging.stg_product_plans plans
    on subscriptions.plan_id = plans.plan_id
left join staging.stg_invoices invoices
    on subscriptions.subscription_id = invoices.subscription_id
left join staging.stg_payments payments
    on invoices.invoice_id = payments.invoice_id
group by
    subscriptions.subscription_id,
    subscriptions.customer_id,
    subscriptions.plan_id,
    plans.plan_name,
    subscriptions.status,
    subscriptions.started_at,
    subscriptions.ended_at,
    subscriptions.seats,
    plans.monthly_price,
    date_trunc('month', invoices.invoice_date)::date;

drop table if exists marts.dim_customer;

create table marts.dim_customer as
select
    row_number() over (order by customer_id) as customer_key,
    customer_id,
    company_name,
    industry,
    country,
    created_at
from staging.stg_customers;

drop table if exists marts.dim_plan;

create table marts.dim_plan as
select
    row_number() over (order by plan_id) as plan_key,
    plan_id,
    plan_name,
    monthly_price,
    included_seats,
    is_active
from staging.stg_product_plans;

drop table if exists marts.fact_invoice;

create table marts.fact_invoice as
select
    invoices.invoice_id,
    customers.customer_key,
    invoices.subscription_id,
    invoices.invoice_date,
    invoices.due_date,
    invoices.amount,
    invoices.status as invoice_status,
    coalesce(sum(payments.amount), 0) as paid_amount,
    invoices.amount - coalesce(sum(payments.amount), 0) as outstanding_amount
from staging.stg_invoices invoices
join marts.dim_customer customers
    on invoices.customer_id = customers.customer_id
left join staging.stg_payments payments
    on invoices.invoice_id = payments.invoice_id
group by
    invoices.invoice_id,
    customers.customer_key,
    invoices.subscription_id,
    invoices.invoice_date,
    invoices.due_date,
    invoices.amount,
    invoices.status;

drop table if exists marts.fact_usage_event;

create table marts.fact_usage_event as
select
    events.event_id,
    customers.customer_key,
    events.subscription_id,
    events.event_date,
    events.event_type,
    events.quantity
from staging.stg_usage_events events
join marts.dim_customer customers
    on events.customer_id = customers.customer_id;

drop table if exists marts.mart_monthly_recurring_revenue;

create table marts.mart_monthly_recurring_revenue as
select
    month_start,
    count(distinct subscription_id) filter (where status = 'active') as active_subscriptions,
    sum(monthly_price) filter (where status = 'active') as mrr,
    sum(billed_amount) as billed_amount,
    sum(paid_amount) as paid_amount
from intermediate.int_subscription_months
where month_start is not null
group by month_start;

drop table if exists marts.mart_customer_lifetime_revenue;

create table marts.mart_customer_lifetime_revenue as
select
    customers.customer_id,
    customers.company_name,
    count(distinct invoices.invoice_id) as invoice_count,
    sum(invoices.amount) as billed_lifetime_value,
    sum(invoices.paid_amount) as paid_lifetime_value,
    sum(invoices.outstanding_amount) as outstanding_amount
from marts.dim_customer customers
left join marts.fact_invoice invoices
    on customers.customer_key = invoices.customer_key
group by customers.customer_id, customers.company_name;

drop table if exists marts.mart_churn;

create table marts.mart_churn as
select
    date_trunc('month', ended_at)::date as churn_month,
    count(*) as churned_subscriptions,
    sum(monthly_price) as churned_mrr
from intermediate.int_subscription_months
where status = 'canceled'
    and ended_at is not null
group by date_trunc('month', ended_at)::date;

drop table if exists marts.mart_invoice_collection_status;

create table marts.mart_invoice_collection_status as
select
    date_trunc('month', invoice_date)::date as invoice_month,
    invoice_status,
    count(*) as invoice_count,
    sum(amount) as billed_amount,
    sum(paid_amount) as paid_amount,
    sum(outstanding_amount) as outstanding_amount
from marts.fact_invoice
group by date_trunc('month', invoice_date)::date, invoice_status;
