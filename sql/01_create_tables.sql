# patients table
CREATE TABLE patients (
    patient_id VARCHAR(200) PRIMARY KEY,
    birth_date DATE,
    death_date DATE,
    race VARCHAR(100),
    ethnicity VARCHAR(100),
    gender VARCHAR(10),
    city VARCHAR(100),
    state VARCHAR(100),
    county VARCHAR(100),
    zip VARCHAR(100),
    healthcare_expenses NUMERIC,
    healthcare_coverage NUMERIC
);

# encounters table
CREATE TABLE encounters (
    encounter_id VARCHAR(200) PRIMARY KEY,
    start_time TIMESTAMPTZ,
    stop_time TIMESTAMPTZ,
    patient_id VARCHAR(200),
    encounter_class VARCHAR(100),
    description TEXT,
    base_encounter_cost NUMERIC,
    total_claim_cost NUMERIC,
    payer_coverage NUMERIC,

    CONSTRAINT fk_encounter_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

# conditions table
CREATE TABLE conditions (
    condition_id BIGSERIAL PRIMARY KEY,
    start_date DATE,
    stop_date DATE,
    patient_id VARCHAR(200),
    encounter_id VARCHAR(200),
    condition_code VARCHAR(50),
    condition_description TEXT,

    CONSTRAINT fk_condition_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_condition_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

# procedures table
CREATE TABLE procedures (
    procedure_id BIGSERIAL PRIMARY KEY,
    procedure_date DATE,
    patient_id VARCHAR(200),
    encounter_id VARCHAR(200),
    procedure_code VARCHAR(50),
    procedure_description TEXT,
    base_cost NUMERIC,

    CONSTRAINT fk_procedure_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_procedure_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

