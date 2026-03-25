import random
from datetime import datetime, timedelta

# הגדרות מבוססות על מה שכבר הכנסת
EXISTING_DEPTS = 510
EXISTING_DOCTORS = 1000
EXISTING_PATIENTS = 1000

# כמויות ליצירה
NUM_ROOMS = 1000
NUM_MEDS = 600
NUM_TESTS = 600
NUM_ADMISSIONS = 1200
TOTAL_BIG_DATA = 21000
LINES_PER_FILE = 3500

def generate_hospital_data():
    # --- 1. תשתיות בסיסיות (Rooms, Medications, Tests) ---
    with open('01_infrastructure.sql', 'w', encoding='utf-8') as f:
        # חדרים - מקושרים ל-510 המחלקות הקיימות
        for i in range(1, NUM_ROOMS + 1):
            dept_id = random.randint(1, EXISTING_DEPTS)
            f.write(f"INSERT INTO ROOMS (Room_ID, Room_Number, Dept_ID) VALUES ({i}, {100+i}, {dept_id});\n")
        # תרופות
        for i in range(1, NUM_MEDS + 1):
            f.write(f"INSERT INTO MEDICATIONS (Medication_ID, Med_Name, Manufacturer, Description) VALUES ({i}, 'Med_{i}', 'GlobalPharma', 'Generic drug');\n")
        # בדיקות
        for i in range(1, NUM_TESTS + 1):
            f.write(f"INSERT INTO TESTS (Test_ID_, Test_Name) VALUES ({i}, 'Laboratory Test {i}');\n")
    print("Created 01_infrastructure.sql")

    # --- 2. אשפוזים (Admissions) ---
    # תלוי ב-Patients(1000) וב-Rooms(1000) שיצרנו הרגע
    with open('02_admissions.sql', 'w', encoding='utf-8') as f:
        for i in range(1, NUM_ADMISSIONS + 1):
            p_id = random.randint(1, EXISTING_PATIENTS)
            r_id = random.randint(1, NUM_ROOMS)
            d_id = random.randint(1, EXISTING_DEPTS)
            date = (datetime.now() - timedelta(days=random.randint(0, 365))).strftime('%Y-%m-%d')
            f.write(f"INSERT INTO ADMISSIONS (Admission_ID, Admission_Date, Patient_ID, Room_ID, Dept_ID) VALUES ({i}, '{date}', {p_id}, {r_id}, {d_id});\n")
    print("Created 02_admissions.sql")

    # --- 3. מדדים (VITALS_LOGS) - 21,000 רשומות ב-6 קבצים ---
    for batch in range(6):
        start = batch * LINES_PER_FILE + 1
        end = (batch + 1) * LINES_PER_FILE + 1
        filename = f'03_vitals_batch_{batch+1}.sql'
        with open(filename, 'w', encoding='utf-8') as f:
            for i in range(start, end):
                adm_id = random.randint(1, NUM_ADMISSIONS)
                hr = random.randint(58, 120)
                temp = round(random.uniform(36.0, 39.9), 1)
                time = (datetime.now() - timedelta(minutes=random.randint(1, 50000))).strftime('%Y-%m-%d %H:%M:%S')
                f.write(f"INSERT INTO VITALS_LOGS (Log_ID, Check_Time, Heart_Rate, Temperature, Admission_ID) VALUES ({i}, '{time}', {hr}, {temp}, {adm_id});\n")
        print(f"Created {filename}")

    # --- 4. מרשמים (PRESCRIPTIONS) - 21,000 רשומות ב-6 קבצים ---
    dosages = ['Once daily', 'Twice daily', 'Morning and Night', 'With food']
    for batch in range(6):
        start = batch * LINES_PER_FILE + 1
        end = (batch + 1) * LINES_PER_FILE + 1
        filename = f'04_prescriptions_batch_{batch+1}.sql'
        with open(filename, 'w', encoding='utf-8') as f:
            for i in range(start, end):
                adm_id = random.randint(1, NUM_ADMISSIONS)
                doc_id = random.randint(1, EXISTING_DOCTORS)
                med_id = random.randint(1, NUM_MEDS)
                f.write(f"INSERT INTO PRESCRIPTIONS (Prescription_ID, Dosage, Admission_ID, Doctor_ID, Medication_ID) VALUES ({i}, '{random.choice(dosages)}', {adm_id}, {doc_id}, {med_id});\n")
        print(f"Created {filename}")

    # --- 5. תוצאות בדיקות (Test_Results) ---
    with open('05_test_results.sql', 'w', encoding='utf-8') as f:
        for i in range(1, 1001):
            adm_id = random.randint(1, NUM_ADMISSIONS)
            t_id = random.randint(1, NUM_TESTS)
            date = (datetime.now() - timedelta(days=random.randint(0, 30))).strftime('%Y-%m-%d')
            f.write(f"INSERT INTO TEST_RESULTS (Result_ID, Result_Value, Test_Date, Admission_ID, Test_ID_) VALUES ({i}, 'Normal', '{date}', {adm_id}, {t_id});\n")
    print("Created 05_test_results.sql")

if __name__ == "__main__":
    generate_hospital_data()