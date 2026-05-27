drop schema if exists raw cascade;
drop schema if exists staging cascade;
drop schema if exists intermediate cascade;
drop schema if exists marts cascade;

create schema raw;
create schema staging;
create schema intermediate;
create schema marts;

create table raw.product_plans (
    plan_id text,
    plan_name text,
    monthly_price numeric(12, 2),
    included_seats integer,
    is_active boolean
);

create table raw.customers (
    customer_id text,
    company_name text,
    industry text,
    country text,
    created_at date
);

create table raw.subscriptions (
    subscription_id text,
    customer_id text,
    plan_id text,
    status text,
    started_at date,
    ended_at date,
    seats integer
);

create table raw.invoices (
    invoice_id text,
    customer_id text,
    subscription_id text,
    invoice_date date,
    due_date date,
    amount numeric(12, 2),
    status text
);

create table raw.payments (
    payment_id text,
    invoice_id text,
    paid_at date,
    amount numeric(12, 2),
    payment_method text
);

create table raw.usage_events (
    event_id text,
    customer_id text,
    subscription_id text,
    event_date date,
    event_type text,
    quantity integer
);

insert into raw.product_plans values
    ('starter', 'Starter', 99.00, 5, true),
    ('growth', 'Growth', 249.00, 20, true),
    ('enterprise', 'Enterprise', 799.00, 100, true);

insert into raw.customers values
    ('C001', 'Northwind Labs', 'SaaS', 'US', '2025-10-01'),
    ('C002', 'Atlas Finance', 'Finance', 'BR', '2025-11-12'),
    ('C003', 'Bright Retail', 'Retail', 'US', '2025-12-05'),
    ('C004', 'Delta Health', 'Health', 'CA', '2026-01-03'),
    ('C005', 'Meridian Ops', 'Logistics', 'US', '2026-02-11');

insert into raw.subscriptions values
    ('S001', 'C001', 'growth', 'active', '2025-10-01', null, 18),
    ('S002', 'C002', 'starter', 'active', '2025-11-15', null, 5),
    ('S003', 'C003', 'enterprise', 'canceled', '2025-12-10', '2026-02-14', 72),
    ('S004', 'C004', 'growth', 'trial', '2026-01-05', null, 10),
    ('S005', 'C005', 'growth', 'active', '2026-02-15', null, 12);

insert into raw.invoices values
    ('I001', 'C001', 'S001', '2026-01-01', '2026-01-10', 249.00, 'paid'),
    ('I002', 'C002', 'S002', '2026-01-01', '2026-01-10', 99.00, 'paid'),
    ('I003', 'C003', 'S003', '2026-01-01', '2026-01-10', 799.00, 'paid'),
    ('I004', 'C001', 'S001', '2026-02-01', '2026-02-10', 249.00, 'paid'),
    ('I005', 'C002', 'S002', '2026-02-01', '2026-02-10', 99.00, 'paid'),
    ('I006', 'C003', 'S003', '2026-02-01', '2026-02-10', 799.00, 'void'),
    ('I007', 'C004', 'S004', '2026-02-01', '2026-02-10', 249.00, 'open'),
    ('I008', 'C005', 'S005', '2026-02-15', '2026-02-25', 249.00, 'paid'),
    ('I009', 'C001', 'S001', '2026-03-01', '2026-03-10', 249.00, 'paid'),
    ('I010', 'C002', 'S002', '2026-03-01', '2026-03-10', 99.00, 'open'),
    ('I011', 'C005', 'S005', '2026-03-01', '2026-03-10', 249.00, 'paid');

insert into raw.payments values
    ('P001', 'I001', '2026-01-05', 249.00, 'card'),
    ('P002', 'I002', '2026-01-06', 99.00, 'bank_transfer'),
    ('P003', 'I003', '2026-01-08', 799.00, 'card'),
    ('P004', 'I004', '2026-02-04', 249.00, 'card'),
    ('P005', 'I005', '2026-02-09', 99.00, 'bank_transfer'),
    ('P006', 'I008', '2026-02-20', 249.00, 'card'),
    ('P007', 'I009', '2026-03-05', 249.00, 'card'),
    ('P008', 'I011', '2026-03-06', 249.00, 'card');

insert into raw.usage_events values
    ('E001', 'C001', 'S001', '2026-01-15', 'api_call', 12000),
    ('E002', 'C001', 'S001', '2026-02-15', 'api_call', 15500),
    ('E007', 'C001', 'S001', '2026-03-15', 'api_call', 17000),
    ('E003', 'C002', 'S002', '2026-01-18', 'api_call', 2300),
    ('E004', 'C002', 'S002', '2026-02-18', 'api_call', 2600),
    ('E008', 'C002', 'S002', '2026-03-18', 'api_call', 2800),
    ('E005', 'C003', 'S003', '2026-01-20', 'api_call', 31000),
    ('E006', 'C004', 'S004', '2026-02-20', 'api_call', 900),
    ('E009', 'C005', 'S005', '2026-02-22', 'api_call', 3200),
    ('E010', 'C005', 'S005', '2026-03-22', 'api_call', 7800);
