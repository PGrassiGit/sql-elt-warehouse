select invoice_id, count(*) as duplicate_count
from raw.invoices
group by invoice_id
having count(*) > 1;

select invoice_id
from raw.invoices
where customer_id is null
    or subscription_id is null;

select invoice_id, amount
from raw.invoices
where amount < 0;

select subscription_id, started_at, ended_at
from raw.subscriptions
where ended_at is not null
    and ended_at < started_at;

select payments.payment_id, payments.invoice_id
from raw.payments payments
left join raw.invoices invoices
    on payments.invoice_id = invoices.invoice_id
where invoices.invoice_id is null;

select invoice_id, amount, paid_amount, outstanding_amount
from marts.fact_invoice
where outstanding_amount < 0;

select customer_id, paid_lifetime_value
from marts.mart_customer_lifetime_revenue
where paid_lifetime_value < 0;
