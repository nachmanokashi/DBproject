import random
from datetime import datetime, timedelta

def generate_batched_data():
    # 1. אשפוזים (1,000 שורות - קובץ אחד)
    with open('insert_admissions.sql', 'w', encoding='utf-8') as f:
        for i in range(1, 1001):
            p_id, d_id = random.randint(1, 1000), random.randint(1, 500)
            date = (datetime.now() - timedelta(days=random.randint(0, 365))).strftime('%Y-%m-%d')
            f.write(f"INSERT INTO admissions (admission_id, room_number, admission_date, patient_id, dept_id) VALUES ({i}, {random.randint(100, 999)}, '{date}', {p_id}, {d_id});\n")
    print("Created insert_admissions.sql")

    # 2. מדדים (מפוצל ל-4 קבצים של 5,000 שורות)
    for batch in range(4):
        start, end = batch * 5000 + 1, (batch + 1) * 5000 + 1
        with open(f'insert_vitals_{batch+1}.sql', 'w', encoding='utf-8') as f:
            for i in range(start, end):
                hr, temp = random.randint(60, 110), round(random.uniform(36.2, 39.5), 1)
                f.write(f"INSERT INTO vitals_logs (log_id, check_time, heart_rate, temperature, admission_id) VALUES ({i}, NOW(), {hr}, {temp}, {random.randint(1, 1000)});\n")
        print(f"Created insert_vitals_{batch+1}.sql")

    # 3. מרשמים (מפוצל ל-4 קבצים של 5,000 שורות)
    meds = ['Acamol', 'Optalgin', 'Amoxicillin', 'Ibuprofen']
    for batch in range(4):
        start, end = batch * 5000 + 1, (batch + 1) * 5000 + 1
        with open(f'insert_prescriptions_{batch+1}.sql', 'w', encoding='utf-8') as f:
            for i in range(start, end):
                f.write(f"INSERT INTO prescriptions (prescription_id, medication_name, dosage, admission_id, doctor_id) VALUES ({i}, '{random.choice(meds)}', 'Daily', {random.randint(1, 1000)}, {random.randint(1, 1000)});\n")
        print(f"Created insert_prescriptions_{batch+1}.sql")

generate_batched_data()