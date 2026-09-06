##Patient utilization view.
CREATE OR REPLACE VIEW vw_patient_utilization AS

SELECT
    p.patient_id,
    p.gender,
    p.race,
    p.ethnicity,
    p.birth_date,

    COUNT(e.encounter_id) AS total_encounters,

    SUM(
        CASE
            WHEN e.encounter_class = 'emergency'
            THEN 1
            ELSE 0
        END
    ) AS emergency_visits,

    SUM(
        CASE
            WHEN e.encounter_class = 'inpatient'
            THEN 1
            ELSE 0
        END
    ) AS inpatient_visits,

    SUM(
        CASE
            WHEN e.encounter_class = 'outpatient'
            THEN 1
            ELSE 0
        END
    ) AS outpatient_visits,

    ROUND(
        SUM(e.total_claim_cost),
        2
    ) AS total_claim_cost

FROM patients p

LEFT JOIN encounters e
    ON p.patient_id = e.patient_id

GROUP BY
    p.patient_id,
    p.gender,
    p.race,
    p.ethnicity,
    p.birth_date;

##Check
SELECT *
FROM vw_patient_utilization
LIMIT 20;

##Encounter view.
CREATE OR REPLACE VIEW vw_encounter_summary AS

SELECT
    e.encounter_id,
    e.patient_id,
    e.start_time,
    e.stop_time,
    e.encounter_class,
    e.description,
    e.base_encounter_cost,
    e.total_claim_cost,
    e.payer_coverage,

    p.gender,
    p.race,
    p.ethnicity,

    EXTRACT(
        YEAR FROM AGE(e.start_time, p.birth_date)
    ) AS age_at_encounter,

    CASE
        WHEN EXTRACT(YEAR FROM AGE(e.start_time, p.birth_date)) < 18
            THEN '0-17'

        WHEN EXTRACT(YEAR FROM AGE(e.start_time, p.birth_date)) < 35
            THEN '18-34'

        WHEN EXTRACT(YEAR FROM AGE(e.start_time, p.birth_date)) < 50
            THEN '35-49'

        WHEN EXTRACT(YEAR FROM AGE(e.start_time, p.birth_date)) < 65
            THEN '50-64'

        WHEN EXTRACT(YEAR FROM AGE(e.start_time, p.birth_date)) < 80
            THEN '65-79'

        ELSE '80+'

    END AS age_group

FROM encounters e

JOIN patients p
    ON e.patient_id = p.patient_id;

##Check
SELECT *
FROM vw_encounter_summary
LIMIT 20;

##Readmission view.
CREATE OR REPLACE VIEW vw_readmission_detail AS

WITH inpatient_encounters AS (

    SELECT
        e.patient_id,
        e.encounter_id,
        e.start_time,
        e.stop_time,
        e.total_claim_cost,

        p.gender,
        p.race,
        p.ethnicity,
        p.birth_date,

        LAG(e.stop_time) OVER (
            PARTITION BY e.patient_id
            ORDER BY e.start_time
        ) AS previous_discharge

    FROM encounters e

    JOIN patients p
        ON e.patient_id = p.patient_id

    WHERE e.encounter_class = 'inpatient'
)

SELECT
    patient_id,
    encounter_id,
    start_time,
    stop_time,
    previous_discharge,
    gender,
    race,
    ethnicity,
    total_claim_cost,

    EXTRACT(
        YEAR FROM AGE(start_time, birth_date)
    ) AS age_at_encounter,

    CASE
        WHEN previous_discharge IS NOT NULL
         AND start_time >= previous_discharge
         AND start_time <= previous_discharge + INTERVAL '30 days'
        THEN 1
        ELSE 0
    END AS readmitted_within_30_days

FROM inpatient_encounters;

##Check
SELECT *
FROM vw_readmission_detail
WHERE readmitted_within_30_days = 1
LIMIT 20;