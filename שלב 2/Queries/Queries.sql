-- שאילתה 1: מציאת מטופלים שסובלים מחום גבוה (מעל 39.5) .
-- המטרה: זיהוי מטופלים בסיכון גבוה במחלקה ספציפית.

-- JOIN (מהיר)
SELECT p.First_Name, p.Last_Name, v.Temperature, d.Dept_Name
FROM PATIENTS p
JOIN ADMISSIONS a ON p.Patient_ID = a.Patient_ID
JOIN VITALS_LOGS v ON a.Admission_ID = v.Admission_ID
JOIN ROOMS r ON a.Room_ID = r.Room_ID
JOIN DEPARTMENTS d ON a.Dept_ID = d.Dept_ID
WHERE v.Temperature > 39.5
ORDER BY v.Check_Time DESC;

-- צורה 2: IN (פחות יעילה בנפח גדול)
SELECT First_Name, Last_Name FROM PATIENTS 
WHERE Patient_ID IN (
    SELECT Patient_ID FROM ADMISSIONS WHERE Dept_ID IN (SELECT Dept_ID FROM DEPARTMENTS WHERE Dept_Name = 'Pediatrics')
    AND Admission_ID IN (SELECT Admission_ID FROM VITALS_LOGS WHERE Temperature > 39.5)
);

-- שאילתה 2: הצגת חדרים פנויים (כאלו שאין בהם אשפוז פעיל כרגע).
-- המטרה: ניהול תפוסת מיטות בבית החולים.

-- צורה 1: NOT EXISTS (מביא לנו מספר חדר ושם מחלקה )
SELECT r.Room_Number, d.Dept_Name, d.Floor, 'Available' AS Status
FROM ROOMS r
JOIN DEPARTMENTS d ON r.Dept_ID = d.Dept_ID
WHERE NOT EXISTS (SELECT 1 FROM ADMISSIONS a WHERE a.Room_ID = r.Room_ID);

-- צורה 2: NOT IN () (  מביא לנו רק מספר חדר ומספר מחלקה )
SELECT Room_Number, Dept_ID FROM ROOMS WHERE Room_ID NOT IN (SELECT Room_ID FROM ADMISSIONS);

-- שאילתה 3: רופאים שנתנו מרשמים לתרופה מסוימת  שיוצרה ע"י .
-- המטרה: מעקב אחר הרגלי רישום תרופות של רופאים לפי יצרן.

--  JOIN
SELECT d.Doctor_Name, d.Specialization, m.Med_Name, m.Manufacturer, pr.Dosage
FROM DOCTORS d
JOIN PRESCRIPTIONS pr ON d.Doctor_ID = pr.Doctor_ID
JOIN MEDICATIONS m ON pr.Medication_ID = m.Medication_ID
WHERE m.Manufacturer = 'GlobalPharma';

-- צורה 2: CTE (WITH clause) - נחשב למתקדם וקריא יותר
WITH PharmaMeds AS (
    SELECT Medication_ID, Med_Name, Manufacturer FROM MEDICATIONS WHERE Manufacturer = 'GlobalPharma'
)
SELECT d.Doctor_Name, d.Specialization, pm.Med_Name, pr.Dosage
FROM DOCTORS d
JOIN PRESCRIPTIONS pr ON d.Doctor_ID = pr.Doctor_ID
JOIN PharmaMeds pm ON pr.Medication_ID = pm.Medication_ID;

-- שאילתה 4: מטופלים שעברו בדיקת דם  וקיבלו תוצאה חריגה .
-- המטרה: איתור מטופלים שזקוקים להמשך טיפול דחוף לפי סוג בדיקה.

-- צורה 1: JOIN
SELECT p.First_Name , p.Last_Name, 
       t.Test_Name, tr.Result_Value, tr.Test_Date, d.Dept_Name
FROM PATIENTS p
JOIN ADMISSIONS a ON p.Patient_ID = a.Patient_ID
JOIN TEST_RESULTS tr ON a.Admission_ID = tr.Admission_ID
JOIN TESTS t ON tr.Test_ID_ = t.Test_ID_
JOIN DEPARTMENTS d ON a.Dept_ID = d.Dept_ID
WHERE tr.Result_Value = 'Abnormal';

-- צורה 2: EXISTS (מביא לנו רק שם פרטי ושם משפחה של המטופל)
SELECT p.First_Name, p.Last_Name FROM PATIENTS p
 WHERE EXISTS (SELECT 1 FROM ADMISSIONS a 
 JOIN TEST_RESULTS tr ON a.Admission_ID = tr.Admission_ID
  WHERE a.Patient_ID = p.Patient_ID
   AND tr.Result_Value = 'Abnormal'
   );

-- 5. סטטיסטיקת אשפוזים חודשית לפי מחלקה וקומה (מציג: שם מחלקה, קומה, שנה, חודש, וכמות אשפוזים)
SELECT d.Dept_Name, d.Floor,
       EXTRACT(YEAR FROM a.Admission_Date) as Year,
       EXTRACT(MONTH FROM a.Admission_Date) as Month,
       COUNT(a.Admission_ID) as Total_Admissions
FROM DEPARTMENTS d
JOIN ADMISSIONS a ON d.Dept_ID = a.Dept_ID
GROUP BY d.Dept_Name, d.Floor, Year, Month
ORDER BY Year DESC, Month DESC, Total_Admissions DESC;

-- 6. בודקת את המדדים הממוצעים (חום ודופק) של מטופלים שקיבלו טיפול תרופתי מרופאים מומחים בקרדיולוגיה. (אגרגציה על 5 טבלאות)
SELECT d.Doctor_Name, 
       p.First_Name , p.Last_Name AS Patient_Name,
       d.Specialization,
       ROUND(AVG(v.Heart_Rate), 2) as Avg_Heart_Rate, 
       ROUND(AVG(v.Temperature), 2) as Avg_Temperature,
       COUNT(v.Log_ID) as Total_Measurements
FROM DOCTORS d
JOIN PRESCRIPTIONS pr ON d.Doctor_ID = pr.Doctor_ID
JOIN ADMISSIONS a ON pr.Admission_ID = a.Admission_ID
JOIN PATIENTS p ON a.Patient_ID = p.Patient_ID
JOIN VITALS_LOGS v ON a.Admission_ID = v.Admission_ID
WHERE d.Specialization = 'Cardiology'
GROUP BY d.Doctor_ID, d.Doctor_Name, d.Specialization, p.Patient_ID, p.First_Name, p.Last_Name
HAVING AVG(v.Temperature) > 37.0
ORDER BY Avg_Temperature DESC;

-- 7. חולים "כבדים" - מטופלים שהיו להם כמה אשפוזים שונים באותה מחלקה 
SELECT p.First_Name , p.Last_Name AS Patient_Name,
       d.Dept_Name,
       d.Floor,
       COUNT(a.Admission_ID) as Total_Admissions_In_Dept,
       MIN(a.Admission_Date) as First_Seen_In_Dept,
       MAX(a.Admission_Date) as Last_Seen_In_Dept
FROM PATIENTS p
JOIN ADMISSIONS a ON p.Patient_ID = a.Patient_ID
JOIN DEPARTMENTS d ON a.Dept_ID = d.Dept_ID
GROUP BY p.Patient_ID, p.First_Name, p.Last_Name, d.Dept_Name, d.Floor
HAVING COUNT(a.Admission_ID) >= 2
ORDER BY Total_Admissions_In_Dept DESC;
    
-- 8. ניתוח פופולריות תרופות לפי יצרן ומספר רופאים רושמים
-- מציג: שם תרופה, יצרן, כמה מטופלים קיבלו אותה וכמה רופאים שונים רשמו אותה.
SELECT m.Med_Name, m.Manufacturer,
       COUNT(DISTINCT pr.Doctor_ID) as Distinct_Doctors,
       COUNT(pr.Prescription_ID) as Total_Prescriptions
FROM MEDICATIONS m
JOIN PRESCRIPTIONS pr ON m.Medication_ID = pr.Medication_ID
GROUP BY m.Med_Name, m.Manufacturer
HAVING COUNT(pr.Prescription_ID) > 20
ORDER BY Total_Prescriptions DESC;