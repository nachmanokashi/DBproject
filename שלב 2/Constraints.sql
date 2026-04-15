-- אילוץ 1: הגבלת טמפרטורה (חום גוף) לטווח הגיוני (30 עד 45 מעלות)
ALTER TABLE VITALS_LOGS 
ADD CONSTRAINT chk_temperature_range 
CHECK (Temperature >= 30.0 AND Temperature <= 45.0);

-- אילוץ 2: מניעת תאריכי לידה עתידיים למטופלים
ALTER TABLE PATIENTS 
ADD CONSTRAINT chk_birth_date_past 
CHECK (Birth_Date <= CURRENT_DATE);

-- אילוץ 3: הגבלת דופק לב לטווח תקין (למשל 20 עד 250 פעימות)
ALTER TABLE VITALS_LOGS 
ADD CONSTRAINT chk_heart_rate_range 
CHECK (Heart_Rate >= 20 AND Heart_Rate <= 250);