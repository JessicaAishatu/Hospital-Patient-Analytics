# Data quality log

Raw-data profile: docs/data_profile.md. This log records the cleaning decisions applied in notebooks/02_clean_data.ipynb.

Analysis window: encounters starting 2011-01-01 to 2021-12-31. Synthea generates each patient's whole life history; the dashboard describes a recent operating period, not a century. The full tables are kept; the window is applied at cleaning and in the SQL views.

| Table | Check | Found | Action | Why |
| --- | --- | --- | --- | --- |
| patients | identifier-like and financial columns | 15 columns (SSN, DRIVERS, PASSPORT, PREFIX, FIRST, LAST, SUFFIX, MAIDEN, BIRTHPLACE, ADDRESS, ZIP, LAT, LON, HEALTHCARE_EXPENSES, HEALTHCARE_COVERAGE) | dropped | not needed for any indicator; de-identification habit even on synthetic data |
| patients | duplicate rows / duplicate patient_id | 0 / 0 | none | — |
| patients | birthdate unparseable | 0 | none | — |
| patients | deathdate missing | 1,000 of 1,163 | kept as null | null = alive at end of simulation; 163 deceased |
| patients | death before birth | 0 | none | — |
| patients | marital missing | 384 | kept as null | Synthea records marital status for adults only; not used in any indicator |
| patients | gender, marital, race, ethnicity spelling | one spelling per value | none | checked, none found |
| encounters | columns ORGANIZATION, PROVIDER, CODE, REASONCODE | 4 columns | dropped | no indicator uses them; description columns carry the meaning |
| encounters | start/stop datetime unparseable | 0 / 0 | none | — |
| encounters | outside analysis window (start before 2011) | 26,819 of 61,459 excluded; 34,640 kept (56.4%) | excluded from clean file | window decision above |
| encounters | stop before start | 0 | none | — |
| encounters | zero-length encounters | 0 | none | — |
| encounters | length of stay over 365 days | 1 (outpatient, 369 days) | kept in table; excluded from LOS averages in SQL view | simulation artefact |
| encounters | inpatient LOS distribution | median 1.00 day, mean 1.69, max 334.89 (n = 943) | report median alongside mean | a few long stays skew the mean |
| encounters | patient_id not in patients | 0 | none | foreign key will hold |
| encounters | payer_id missing | 0 | none | — |
| encounters | duplicate encounter_id | 0 | none | — |
| encounters | reason_desc missing | 24,426 of 34,640 | kept as null | routine wellness/ambulatory visits carry no presenting reason; diagnoses come from conditions |
| conditions | rows whose encounter is outside the window | 16,161 of 38,094 excluded; 17,933 kept | excluded | foreign key to encounters must hold |
| conditions | stop_date missing | 3,405 | kept as null | ongoing condition |
| conditions | social-history findings mixed with disorders | 12,903 findings vs 5,030 disorders (descriptions ending "(finding)", "(situation)", "(person)") | flagged is_disorder; diagnoses chart uses disorders only | top raw entries were employment and stress findings; a few clinical findings (fever, cough, obesity) are lost and stated as a limitation |
| conditions | malformed label "Severe anxiety (panic) (finding" | 96 rows, missing closing bracket | regex allows optional bracket; classed as finding | Synthea label defect |
| conditions | COVID-19 split across "Suspected COVID-19" (96) and "COVID-19" (92) | 2 descriptions | kept separate | distinct SNOMED concepts; noted in findings |
| payers | columns other than Id and NAME | 19 columns | dropped | describe the payer, not the encounters |
| payers | ADDRESS/CITY/STATE/ZIP/PHONE missing | 1 row (NO_INSURANCE) | none; columns dropped | placeholder payer has no address || conditions | rows whose encounter is outside the window | 16,161 of 38,094 excluded; 17,933 kept | excluded | foreign key to encounters must hold |
| conditions | stop_date missing | 3,405 | kept as null | ongoing condition |
| conditions | social-history findings mixed with disorders | 12,903 findings vs 5,030 disorders (descriptions ending "(finding)", "(situation)", "(person)") | flagged is_disorder; diagnoses chart uses disorders only | top raw entries were employment and stress findings; a few clinical findings (fever, cough, obesity) are lost and stated as a limitation |
| conditions | malformed label "Severe anxiety (panic) (finding" | 96 rows, missing closing bracket | regex allows optional bracket; classed as finding | Synthea label defect |
| conditions | COVID-19 split across "Suspected COVID-19" (96) and "COVID-19" (92) | 2 descriptions | kept separate | distinct SNOMED concepts; noted in findings |
| payers | columns other than Id and NAME | 19 columns | dropped | describe the payer, not the encounters |
| payers | ADDRESS/CITY/STATE/ZIP/PHONE missing | 1 row (NO_INSURANCE) | none; columns dropped | placeholder payer has no address || encounters | last encounter date | 2021-11-19 | November 2021 treated as a partial month; monthly trend chart shows Jan 2011–Oct 2021 only | 19 days of data would read as a drop in demand |
| encounters | monthly volume rises from ~100 (2011) to ~320 (2021) | — | kept; caveat printed under the trend chart | Synthea builds its population back from patients alive at the end, so early years have fewer simulated patients; not demand growth |
| encounters | inpatient LOS (SQL) | mean 1.69 days, median 1.0 (n = 943) | reported with median | most simulated admissions last one day |
| encounters | 30-day readmission | 310 of 943 index stays (32.9%) | reported with caveat | any-cause, within this dataset; Synthea chains admissions for chronic conditions, so the rate is far above real-world figures |
| encounters | payer_coverage | commercial payers show $0–5 coverage against claims in the thousands | dropped from dashboard; payer kept as slicer only | Synthea payer-module artefact; not an insurance finding |
| encounters | NO_INSURANCE share of inpatient stays | 340 of 943 (36%), highest average claims in every class | reported as an item to investigate | depends on the simulated payer module; see limitation above |

Encounter mix, 2011–2021: ambulatory 13,107; wellness 9,701; outpatient 7,352; urgent care 1,989; emergency 1,548; inpatient 943.

## Limitations carried forward

- Synthetic data simulating Massachusetts, USA; no inference about any real hospital or population, Nigerian or otherwise.
- No bed, ward, staffing or waiting-time data, so no occupancy or throughput indicator is possible.
- Costs are simulated.
- Readmission can only be seen within this dataset's own encounters; admissions elsewhere are invisible.
- The disorder/finding split is by SNOMED label suffix; a small number of clinical findings are excluded from the diagnoses chart.