CREATE DATABASE hospital;
USE hospital;

CREATE TABLE patients (
    patient_id  VARCHAR(36) PRIMARY KEY,
    birthdate   DATE NOT NULL,
    deathdate   DATE NULL,
    gender      CHAR(1),
    race        VARCHAR(30),
    ethnicity   VARCHAR(30),
    marital     CHAR(1) NULL,
    city        VARCHAR(60),
    state       VARCHAR(60),
    county      VARCHAR(60)
);

CREATE TABLE payers (
    payer_id    VARCHAR(36) PRIMARY KEY,
    name        VARCHAR(100)
);

CREATE TABLE encounters (
    encounter_id     VARCHAR(36) PRIMARY KEY,
    start_time       DATETIME NOT NULL,
    stop_time        DATETIME NULL,
    patient_id       VARCHAR(36) NOT NULL,
    payer_id         VARCHAR(36) NULL,
    encounter_class  VARCHAR(20),
    description      VARCHAR(200),
    base_cost        DECIMAL(10,2),
    total_claim_cost DECIMAL(10,2),
    payer_coverage   DECIMAL(10,2),
    reason_desc      VARCHAR(200) NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (payer_id)   REFERENCES payers(payer_id)
);

CREATE TABLE conditions (
    start_date    DATE NOT NULL,
    stop_date     DATE NULL,
    patient_id    VARCHAR(36) NOT NULL,
    encounter_id  VARCHAR(36) NOT NULL,
    code          VARCHAR(20),
    description   VARCHAR(200),
    is_disorder   TINYINT NOT NULL,
    FOREIGN KEY (patient_id)   REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id) REFERENCES encounters(encounter_id)
);