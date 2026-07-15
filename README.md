
# AtliQ SQL Project

End-to-end SQL case study built on the **AtliQ Hardware** sales database (`gdb0041`) — covering ad-hoc business reporting, stored procedures, views, window functions, triggers, temporary tables, and query performance tuning in MySQL.

## About

AtliQ Hardware is a fictional computer hardware manufacturer used as the dataset for this case study. The database tracks monthly sales, forecasts, pricing, and discounts across markets, customers, and products. Each script in `/sql` solves a real reporting or engineering problem the business team asked for — from a simple monthly sales report to a trigger-driven forecast-accuracy pipeline.

**Core tables used**

| Table | Purpose |
|---|---|
| `fact_sales_monthly` | Monthly quantity sold, by date / product / customer |
| `fact_forecast_monthly` | Monthly forecast quantity, by date / product / customer |
| `fact_gross_price` | Gross price per product per fiscal year |
| `fact_pre_invoice_deductions` | Pre-invoice discount % per customer per fiscal year |
| `fact_post_invoice_deductions` | Post-invoice discounts & other deductions |
| `fact_act_est` | Derived actual-vs-forecast table (built in Module 8) |
| `dim_customer` | Customer, market, platform, channel, region |
| `dim_product` | Product, variant, division |
| `dim_date` | Calendar date to fiscal year mapping |

## Modules

Scripts are numbered in the order the concepts build on each other. Each `.sql` file in [`/sql`](./sql) is self-contained and commented.

| # | Module | Script | What it covers |
|---|---|---|---|
| 1 | Monthly Gross Sales Report | [`01_monthly_gross_sales_report.sql`](./sql/01_monthly_gross_sales_report.sql) | Joining `fact_sales_monthly` → `dim_product` → `fact_gross_price`; computing gross sales value per customer/year |
| 2 | Stored Procedure: Monthly Gross Sales | [`02_stored_procedure_monthly_gross_sales.sql`](./sql/02_stored_procedure_monthly_gross_sales.sql) | Parameterized stored procedure (`FIND_IN_SET` for multi-customer input) to reuse the Module 1 report for any customer |
| 3 | Stored Procedure: Market Badge | [`03_stored_procedure_get_market_badge.sql`](./sql/03_stored_procedure_get_market_badge.sql) | `IN`/`OUT` parameters, default-value handling, conditional logic (`IF`) to classify a market as Gold/Silver by sales volume |
| 4 | Performance Improvement | [`04_performance_improvement.sql`](./sql/04_performance_improvement.sql) | Pre-invoice discount report, then two optimization passes — joining a `dim_date` table, then denormalizing `fiscal_year` directly onto `fact_sales_monthly` — to cut query runtime |
| 5 | Database Views | [`05_database_views.sql`](./sql/05_database_views.sql) | Building `sales_preinv_discount` → `sales_postinv_discount` → `net_sales` as layered views, each building net sales from gross price down through both discount stages |
| 6 | Stored Procedures: Top Markets & Customers | [`06_stored_procedures_top_markets_and_customers.sql`](./sql/06_stored_procedures_top_markets_and_customers.sql) | `get_top_n_markets_by_net_sales` and `get_top_n_customers_by_net_sales` — ranking reports parameterized by year, market, and N |
| 7 | Window Functions | [`07_window_functions.sql`](./sql/07_window_functions.sql) | `SUM() OVER()`, `PARTITION BY` for regional sales share, and `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)` to find top 3 products per division |
| 8 | Helper Table: `fact_act_est` | [`08_helper_table_fact_act_est.sql`](./sql/08_helper_table_fact_act_est.sql) | `UNION` of sales and forecast tables via `LEFT JOIN ... USING`, plus null-cleanup, to create a combined actual-vs-estimate table |
| 9 | Database Triggers | [`09_database_triggers.sql`](./sql/09_database_triggers.sql) | `AFTER INSERT` triggers on `fact_sales_monthly` and `fact_forecast_monthly` that keep `fact_act_est` in sync automatically, with `ON DUPLICATE KEY UPDATE` |
| 10 | Temp Tables & Forecast Accuracy | [`10_temp_tables_and_forecast_accuracy_report.sql`](./sql/10_temp_tables_and_forecast_accuracy_report.sql) | Forecast-accuracy report built three ways — inline CTE, a stored procedure version, and a session-scoped `TEMPORARY TABLE` version — comparing net error % and absolute error % |

## Screenshots

Query outputs for each module live in [`/screenshots`](./screenshots), numbered to match the scripts above 
## How to run

1. Set up a MySQL 8+ instance and load the `gdb0041` schema (dimension + fact tables listed above).
2. Run scripts in numeric order — later modules depend on objects created earlier (e.g. Module 5's views depend on Module 4's logic; Module 9's triggers depend on Module 8's `fact_act_est` table).
3. Stored procedures and triggers use `DELIMITER $$` blocks — run them as-is in the MySQL client/Workbench, not through a plain `mysql < file.sql` pipe unless you strip the delimiter blocks first.

## Tech

MySQL 8 · MySQL Workbench · CTEs · Window Functions · Views · Stored Procedures · Triggers · Temporary Tables
