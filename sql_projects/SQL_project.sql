# From initial tables to full overview
select c.id_cliente as customer_id,
       c.nome as name,
       c.cognome as surname,
       c.data_nascita as birth_date,
       co.id_conto as account_id,
       tc.desc_tipo_conto as account_type_desc,
       tr.data as transaction_date,
       ttr.desc_tipo_trans as transaction_type_desc,
       ttr.segno as transaction_type_sign,
       tr.importo as amount
from banca.cliente c
left join banca.conto co 
      on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
      on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
      on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
      on tr.id_tipo_trans = ttr.id_tipo_transazione;

## Behavioral Indicators to be Calculated
# The indicators will be calculated for each individual customer (referenced by customer ID) and include:
# Basic indicators
# 1 - Customer age
select c.id_cliente as customer_id,
       c.nome as name,
       c.cognome as surname,
       c.data_nascita as birth_day,
       timestampdiff(year, c.data_nascita, curdate()) as customer_age
from banca.cliente c;

# Transaction indicators
# 2 - Number of outgoing transactions on all accounts
select c.id_cliente as customer_id,
       count(case when ttr.segno = '-' then 1 end) as outgoing_tx_count
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 3 - Number of incoming transactions on all accounts
select c.id_cliente as customer_id,
       count(case when ttr.segno = '+' then 1 end) as incoming_tx_count
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 4 - Total amount of outgoing transactions across all accounts
select c.id_cliente as customer_id,
       round(coalesce(sum(case when ttr.segno = '-' then tr.importo end), 0), 2) as outgoing_tx_total
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 5 - Total amount of incoming transactions across all accounts
select c.id_cliente as customer_id,
       round(coalesce(sum(case when ttr.segno = '+' then tr.importo end), 0), 2) as incoming_tx_total
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;

# Account indicators
# 6 - Total number of accounts held
select c.id_cliente as customer_id,
       coalesce(count(distinct co.id_conto), 0) as total_accounts
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
group by c.id_cliente
order by c.id_cliente;
# 7 - Number of accounts held by type (one indicator for each type of account)
select c.id_cliente as customer_id,
       count(case when tc.desc_tipo_conto = 'Conto Base' then 1 end) as base_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' then 1 end) as business_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' then 1 end) as private_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' then 1 end) as family_account_count
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
    on co.id_tipo_conto = tc.id_tipo_conto
group by c.id_cliente
order by c.id_cliente;

# Transaction indicators by account type
# 8 - Number of outgoing transactions by account type (one indicator per account type)
select c.id_cliente as customer_id,
       count(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '-' then 1 end) as outgoing_base_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '-' then 1 end) as outgoing_business_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '-' then 1 end) as outgoing_private_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '-' then 1 end) as outgoing_family_tx_count
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
    on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 9 - Number of incoming transactions by account type (one indicator per account type)
select c.id_cliente as customer_id,
       count(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '+' then 1 end) as incoming_base_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '+' then 1 end) as incoming_business_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '+' then 1 end) as incoming_private_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '+' then 1 end) as incoming_family_tx_count
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
    on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 10 - Outgoing transaction amount by account type (one indicator per account type)
select c.id_cliente as customer_id,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '-' then tr.importo end), 0), 2) as outgoing_base_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '-' then tr.importo end), 0), 2) as outgoing_business_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '-' then tr.importo end), 0), 2) as outgoing_private_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '-' then tr.importo end), 0), 2) as outgoing_family_tx_total
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
    on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;
# 11 - Incoming transaction amount by account type (one indicator per account type)
select c.id_cliente as customer_id,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_base_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_business_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_private_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_family_tx_total
from banca.cliente c
left join banca.conto co 
    on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
    on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
    on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
    on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;

# Customer Feature Table
create or replace view banca.customer_features as
select # personal details
       c.id_cliente as customer_id,
       c.nome as name,
       c.cognome as surname,
       c.data_nascita as birth_day,
       timestampdiff(year, c.data_nascita, curdate()) as customer_age,
       # number of transactions
       count(case when ttr.segno = '-' then 1 end) as outgoing_tx_count,
       count(case when ttr.segno = '+' then 1 end) as incoming_tx_count,
       # total amounts transacted
       round(coalesce(sum(case when ttr.segno = '-' then abs(tr.importo) end), 0), 2) as outgoing_tx_total,
       round(coalesce(sum(case when ttr.segno = '+' then tr.importo end), 0), 2) as incoming_tx_total,
       # total number of accounts
       coalesce(count(distinct co.id_conto), 0) as total_accounts,
       # number of accounts by type
       count(case when tc.desc_tipo_conto = 'Conto Base' then 1 end) as base_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' then 1 end) as business_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' then 1 end) as private_account_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' then 1 end) as family_account_count,
       # number of outgoing transactions by account type
       count(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '-' then 1 end) as outgoing_base_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '-' then 1 end) as outgoing_business_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '-' then 1 end) as outgoing_private_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '-' then 1 end) as outgoing_family_tx_count,
       # number of incoming transactions by account type
       count(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '+' then 1 end) as incoming_base_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '+' then 1 end) as incoming_business_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '+' then 1 end) as incoming_private_tx_count,
       count(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '+' then 1 end) as incoming_family_tx_count,
       # outgoing transaction amount by account type
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '-' then abs(tr.importo) end), 0), 2) as outgoing_base_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '-' then abs(tr.importo) end), 0), 2) as outgoing_business_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '-' then abs(tr.importo) end), 0), 2) as outgoing_private_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '-' then abs(tr.importo) end), 0), 2) as outgoing_family_tx_total,
       # incoming transaction amount by account type
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Base' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_base_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Business' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_business_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Privati' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_private_tx_total,
       round(coalesce(sum(case when tc.desc_tipo_conto = 'Conto Famiglie' and ttr.segno = '+' then tr.importo end), 0), 2) as incoming_family_tx_total
from banca.cliente c
left join banca.conto co 
      on c.id_cliente = co.id_cliente
left join banca.tipo_conto tc 
      on co.id_tipo_conto = tc.id_tipo_conto
left join banca.transazioni tr 
      on co.id_conto = tr.id_conto
left join banca.tipo_transazione ttr 
      on tr.id_tipo_trans = ttr.id_tipo_transazione
group by c.id_cliente
order by c.id_cliente;

# Extracting data from the newly created view
select * from banca.customer_features;


## NOTES ON THE VIEW: ABS() USAGE AND RATIONALE FOR CREATING A VIEW

# WHY USE ABS() ON OUTGOING AMOUNTS
# Project goal: build a feature table for ML.
# In the database, outgoing amounts are naturally stored as negative values (accounting logic).
# In the feature table:
# - The column names already distinguish between incoming and outgoing flows (incoming_* vs outgoing_*).
# - Keeping the negative sign adds no information and may complicate interpretation and preprocessing.
# In ML, having all numerical features non-negative:
# - Simplifies statistical analysis and normalization (e.g., MinMaxScaler, log-scaling).
# - Makes features more intuitive (e.g., "total outgoing = 1200 €" instead of "-1200 €").
# Conclusion: Outgoing amounts are transformed into absolute values (ABS(tr.importo)) to represent always 
# positive quantities, which are easier to use in ML models and clearer for analysis.

# WHY CREATE A VIEW (customer_features)
# A view is the best way to centralize the calculation logic of all indicators.
# In line with the project goals:
# - The view returns one row per customer with all aggregated indicators.
# - Ensures the feature table is always up-to-date with accounts and transactions.
# - Avoids duplicating SQL code whenever features need to be extracted.
# For ML workflows, it is more efficient:
# - Simply run SELECT * FROM banca.customer_features to get the ready-to-use dataset.
# - New features can be added by modifying the view, without changing the training scripts.