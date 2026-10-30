USE hospital;
-- 1. Encounters per month, 2011-2021
SELECT YEAR(start_time) AS yr, MONTH(start_time) AS mth, COUNT(*) AS encounters
FROM encounters
GROUP BY YEAR(start_time), MONTH(start_time)
ORDER BY yr, mth;

-- 2. Encounter mix by class, with share of total
SELECT encounter_class,
       COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM encounters
GROUP BY encounter_class
ORDER BY n DESC;

-- 3. Average inpatient length of stay (days), excluding stop<=start and >365 days
SELECT ROUND(AVG(TIMESTAMPDIFF(SECOND, start_time, stop_time) / 86400), 2) AS avg_los_days,
       COUNT(*) AS inpatient_stays
FROM encounters
WHERE encounter_class = 'inpatient'
  AND stop_time > start_time
  AND TIMESTAMPDIFF(DAY, start_time, stop_time) <= 365;
  
  -- 4. Ten most frequent recorded disorders
SELECT c.description, COUNT(*) AS n, COUNT(DISTINCT c.patient_id) AS patients
FROM conditions c
JOIN patients p ON p.patient_id = c.patient_id
WHERE c.is_disorder = 1
GROUP BY c.description
ORDER BY n DESC
LIMIT 10;

-- 5. 30-day inpatient readmission rate (any cause, within this dataset)
WITH inpatient AS (
    SELECT patient_id, encounter_id, start_time, stop_time,
           LEAD(start_time) OVER (PARTITION BY patient_id ORDER BY start_time) AS next_start
    FROM encounters
    WHERE encounter_class = 'inpatient'
)
SELECT COUNT(*) AS index_stays,
       SUM(CASE WHEN DATEDIFF(next_start, stop_time) BETWEEN 0 AND 30 THEN 1 ELSE 0 END) AS readmitted_30d,
       ROUND(100.0 * SUM(CASE WHEN DATEDIFF(next_start, stop_time) BETWEEN 0 AND 30 THEN 1 ELSE 0 END) / COUNT(*), 1) AS readmission_rate_pct
FROM inpatient;

-- 6. Average claim and payer coverage by encounter class and payer
SELECT e.encounter_class, py.name AS payer,
       COUNT(*) AS n,
       ROUND(AVG(e.total_claim_cost), 2) AS avg_claim,
       ROUND(AVG(e.payer_coverage), 2) AS avg_covered
FROM encounters e
LEFT JOIN payers py ON py.payer_id = e.payer_id
GROUP BY e.encounter_class, py.name
ORDER BY e.encounter_class, avg_claim DESC;