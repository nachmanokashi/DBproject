UPDATE TEST_RESULTS
SET Result_Value = 'URGENT - ' || Result_Value
WHERE Admission_ID IN (SELECT Admission_ID FROM ADMISSIONS WHERE Dept_ID = 14);

UPDATE PRESCRIPTIONS
SET Dosage = 'High Dose - ' || Dosage
WHERE Admission_ID IN (SELECT Admission_ID FROM VITALS_LOGS WHERE Temperature > 38.5);

UPDATE DOCTORS
SET Specialization = 'Senior ' || Specialization
WHERE Doctor_ID IN (
    SELECT Doctor_ID 
    FROM PRESCRIPTIONS 
    GROUP BY Doctor_ID 
    HAVING COUNT(*) >= 25
);