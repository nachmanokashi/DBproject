-- Views 1 
-- מבט זה נועד למנהל האגף בבית החולים. הוא מחבר בין נתוני האשפוזים המקומיים שלך 
-- (ADMISSIONS) לבין אנשי הסגל של השותף (partner_personnel) שעוזרים בתיאום הלוגיסטי.

CREATE OR REPLACE VIEW hospital_coordination_view AS
SELECT 
    p.First_Name, 
    p.Last_Name, 
    a.Admission_Date, 
    eb.Emergency_Status,
    eb.Coordination_Date
FROM PATIENTS p
JOIN ADMISSIONS a ON p.Patient_ID = a.Patient_ID
JOIN EMERGENCY_INTEGRATION_BRIDGE eb ON a.Admission_ID = eb.Admission_ID;

-- Views 2 
--מבט זה מחבר בין נתוני האשפוזים של בית החולים לבין טבלת המלאי המרוחקת
-- הוא נועד לאפשר לצוות הרפואי להבין מהן סוגי הפגיעות שעומדות מולם 
-- (למשל, האם מדובר בפגיעה מתחמושת קלה או כבדה שמגיעה מהמחסן הצבאי) כדי להתאים את הציוד הרפואי הנדרש.

CREATE OR REPLACE VIEW ballistic_trauma_analysis AS
SELECT 
    a.Admission_ID,
    p.First_Name || ' ' || p.Last_Name AS Patient_Name,
    a.Admission_Date,
    pa.type AS Suspected_Ammo_Type,
    eb.Emergency_Status
FROM ADMISSIONS a
JOIN PATIENTS p ON a.Patient_ID = p.Patient_ID
JOIN EMERGENCY_INTEGRATION_BRIDGE eb ON a.Admission_ID = eb.Admission_ID
JOIN partner_ammunition pa ON eb.Personnel_ID = pa.location_id;

-- Views 3 
-- מבט זה נועד למנהל האגף בבית החולים ולצוות הרפואי. 
-- הוא מספק לוח מחוונים שמדגיש את המקרים הקריטיים ביותר 
-- (למשל, חולים עם דופק גבוה או חום גבוה)
-- ומציג את אנשי הסגל של השותף שאחראים על התיאום הלוגיסטי של אותם מקרים.


CREATE OR REPLACE VIEW v_critical_alert_dashboard AS
SELECT 
    d.Dept_Name,
    p.First_Name || ' ' || p.Last_Name AS Patient_Name,
    vl.heart_rate,
    vl.temperature,
    -- יצירת סימון חכם (Flag)
    CASE 
        WHEN vl.heart_rate > 100 OR vl.temperature > 39 THEN 'CRITICAL - IMMEDIATE ACTION'
        ELSE 'STABLE'
    END AS alert_level,
    rp.name AS Logistics_Officer_Contact
FROM DEPARTMENTS d
JOIN ADMISSIONS a ON d.Dept_ID = a.Dept_ID
JOIN PATIENTS p ON a.Patient_ID = p.Patient_ID
JOIN vitals_logs vl ON a.Admission_ID = vl.admission_id
JOIN EMERGENCY_INTEGRATION_BRIDGE eb ON a.Admission_ID = eb.Admission_ID
JOIN partner_personnel rp ON eb.Personnel_ID = rp.id;