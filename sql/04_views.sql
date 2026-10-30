USE hospital;

CREATE OR REPLACE VIEW v_encounters AS
SELECT e.encounter_id, e.patient_id, e.payer_id, e.encounter_class, e.description,
       e.start_time, e.stop_time, DATE(e.start_time) AS start_date,
       TIMESTAMPDIFF(SECOND, e.start_time, e.stop_time) / 86400 AS los_days,
       e.total_claim_cost
FROM encounters e;

CREATE OR REPLACE VIEW v_inpatient_stays AS
SELECT patient_id, encounter_id, start_time, stop_time,
       CASE WHEN DATEDIFF(LEAD(start_time) OVER (PARTITION BY patient_id ORDER BY start_time), stop_time)
                 BETWEEN 0 AND 30 THEN 1 ELSE 0 END AS readmitted_30d
FROM encounters
WHERE encounter_class = 'inpatient';

CREATE OR REPLACE VIEW v_patients AS
SELECT patient_id, birthdate, deathdate, gender, race, ethnicity, marital, city, county,
       TIMESTAMPDIFF(YEAR, birthdate, '2021-11-19') AS age_at_end,
       CASE
         WHEN TIMESTAMPDIFF(YEAR, birthdate, '2021-11-19') < 18 THEN '0-17'
         WHEN TIMESTAMPDIFF(YEAR, birthdate, '2021-11-19') < 40 THEN '18-39'
         WHEN TIMESTAMPDIFF(YEAR, birthdate, '2021-11-19') < 65 THEN '40-64'
         ELSE '65+'
       END AS age_band
FROM patients;