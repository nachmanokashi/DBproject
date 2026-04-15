-- אינדקס 1: שיפור דרמטי בחיפוש מדדים לפי זמן (קריטי ל-21,000 רשומות)
CREATE INDEX idx_vitals_check_time ON VITALS_LOGS(Check_Time);

-- אינדקס 2: שיפור חיפוש מטופלים לפי שם משפחה
CREATE INDEX idx_patients_last_name ON PATIENTS(Last_Name);

-- אינדקס 3: שיפור ה-JOIN בין אשפוזים לבדיקות
CREATE INDEX idx_test_results_admission ON TEST_RESULTS(Admission_ID);