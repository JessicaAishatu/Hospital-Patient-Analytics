# SQL

MySQL 8.0. Run in this order.

| File | What it does |
| --- | --- |
| `01_schema.sql` | Creates the `hospital` database and the `patients`, `payers`, `encounters` and `conditions` tables with primary and foreign keys. Run once in MySQL Workbench. |
| `02_load.py` | Empties the four tables and loads `data/clean/*.csv` into them in foreign-key order. Needs the environment variable `MYSQL_PASSWORD` (your MySQL root password): in cmd, `set MYSQL_PASSWORD=...`, then `python sql/02_load.py`. Prints the row count per table (1,163 / 10 / 34,640 / 17,933). |
| `03_analysis.sql` | The six indicator queries: encounters per month, encounter mix, inpatient length of stay, top ten disorders, 30-day readmission, cost by class and payer. |
| `04_views.sql` | Creates `v_encounters`, `v_inpatient_stays` and `v_patients`, which Power BI reads. |

The clean CSVs already contain only encounters starting 2011-01-01 to 2021-11-19, so the queries carry no date filter.