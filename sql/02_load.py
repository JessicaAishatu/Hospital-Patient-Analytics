from pathlib import Path
import pandas as pd
import mysql.connector
import os

CLEAN = Path(__file__).resolve().parent.parent / 'data' / 'clean'

conn = mysql.connector.connect(
    host='localhost', user='root', password=os.environ['MYSQL_PASSWORD'], database='hospital')
cur = conn.cursor()
cur.execute("SET FOREIGN_KEY_CHECKS = 0")
for t in ['conditions', 'encounters', 'payers', 'patients']:
    cur.execute(f"TRUNCATE TABLE {t}")
cur.execute("SET FOREIGN_KEY_CHECKS = 1")
conn.commit()

def load(table, csv, columns):
    df = pd.read_csv(CLEAN / csv)[columns]
    sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({', '.join(['%s'] * len(columns))})"
    rows = [tuple(None if pd.isna(v) else v for v in r)
    for r in df.itertuples(index=False, name=None)]
    cur.executemany(sql, rows)
    conn.commit()
    cur.execute(f"SELECT COUNT(*) FROM {table}")
    print(f"{table}: {cur.fetchone()[0]} rows")

load('patients', 'patients.csv',
     ['patient_id', 'birthdate', 'deathdate', 'gender', 'race', 'ethnicity', 'marital', 'city', 'state', 'county'])
load('payers', 'payers.csv', ['payer_id', 'name'])
load('encounters', 'encounters.csv',
     ['encounter_id', 'start_time', 'stop_time', 'patient_id', 'payer_id', 'encounter_class', 'description',
      'base_cost', 'total_claim_cost', 'payer_coverage', 'reason_desc'])
load('conditions', 'conditions.csv',
     ['start_date', 'stop_date', 'patient_id', 'encounter_id', 'code', 'description', 'is_disorder'])

cur.close(); conn.close()
