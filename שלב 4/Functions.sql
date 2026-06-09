-- פונקציה 1 
-- שם הפונקציה: calculate_patient_risk
-- תיאור: פונקציה זו מחשבת את רמת הסיכון של מטופל בהתבסס על נתוני 
--הוויראלים האחרונים שלו ומעדכנת את רמת הסיכון בטבלת הקבלה.
CREATE OR REPLACE FUNCTION calculate_patient_risk(p_admission_id INT)
RETURNS VARCHAR AS $$
DECLARE
    -- Element: Record (g)
    v_patient_record RECORD; 
    v_risk_score INT := 0;
    v_risk_level VARCHAR(20);
BEGIN
    -- Element: Implicit Cursor with STRICT (a)
    -- Fetching the latest vitals for the admission
    SELECT temperature, heart_rate
    INTO STRICT v_patient_record
    FROM public.vitals_logs
    WHERE admission_id = p_admission_id
    ORDER BY check_time DESC
    LIMIT 1;

    -- Element: Branching / IF-ELSE (d)
    -- Check Temperature
    IF v_patient_record.temperature > 39.0 THEN 
        v_risk_score := v_risk_score + 5;
    ELSIF v_patient_record.temperature > 38.0 THEN 
        v_risk_score := v_risk_score + 3;
    END IF;

    -- Check Heart Rate
    IF v_patient_record.heart_rate > 120 OR v_patient_record.heart_rate < 50 THEN 
        v_risk_score := v_risk_score + 5;
    ELSIF v_patient_record.heart_rate > 100 THEN 
        v_risk_score := v_risk_score + 3;
    END IF;

    -- Determine Final Risk Level
    IF v_risk_score >= 8 THEN 
        v_risk_level := 'High';
    ELSIF v_risk_score >= 4 THEN 
        v_risk_level := 'Medium';
    ELSE 
        v_risk_level := 'Low';
    END IF;

    -- Element: DML Command - UPDATE (c)
    UPDATE public.admissions
    SET risk_level = v_risk_level
    WHERE admission_id = p_admission_id;

    RETURN v_risk_level;

EXCEPTION
    -- Element: Exception Handling (f)
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No vitals found for admission %', p_admission_id;
        RETURN 'No Data';
    WHEN OTHERS THEN
        RAISE NOTICE 'An unexpected error occurred: %', SQLERRM;
        RETURN 'Error';
END;
$$ LANGUAGE plpgsql;

-- בדיקת הפונקציה
-- שלב א': נבדוק מה הסטטוס הנוכחי בטבלה (אמור להיות 'Not Calculated')
SELECT admission_id, risk_level 
FROM public.admissions 
WHERE admission_id = 1;

-- שלב ב': נריץ את הפונקציה שכתבנו עבור אשפוז מספר 1
SELECT public.calculate_patient_risk(1) AS calculated_result;

-- שלב ג': נבדוק שוב את הטבלה ונראה שרמת הסיכון עודכנה בהתאם למדדים (High / Medium / Low)!
SELECT admission_id, risk_level 
FROM public.admissions 
WHERE admission_id = 1;


-- פונקציה 2
-- שם הפונקציה: rebalance_and_audit_department
-- תיאור: פונקציה זו מבצעת איזון מחדש של עומס העבודה במחלקה נתונה על ידי העברת חולים מרופאים עמוסים לרופאים פנויים, ומחזירה דוח עם העומס הסופי של כל רופא במחלקה.
-- הפונקציה גם מטפלת בשגיאות אפשריות במהלך התהליך.   
CREATE OR REPLACE FUNCTION rebalance_and_audit_department(
    p_dept_id INT, 
    INOUT p_ref_cursor REFCURSOR
) 
RETURNS REFCURSOR AS $$
DECLARE
    r_doc RECORD; 
    v_avg_load FLOAT;
    v_moved_count INT := 0;
    c_doctors CURSOR FOR 
        SELECT doctor_id FROM public.doctors WHERE dept_id = p_dept_id;
BEGIN
    IF p_dept_id IS NULL THEN
        RAISE EXCEPTION 'Department ID cannot be null';
    END IF;

    SELECT COUNT(*)::FLOAT / NULLIF((SELECT COUNT(*) FROM public.doctors WHERE dept_id = p_dept_id), 0)
    INTO v_avg_load
    FROM public.admissions WHERE dept_id = p_dept_id;

    FOR r_doc IN c_doctors LOOP
        UPDATE public.admissions
        SET doctor_id = r_doc.doctor_id
        WHERE admission_id IN (
            SELECT admission_id FROM public.admissions 
            WHERE doctor_id IN (SELECT doctor_id FROM public.doctors WHERE dept_id = p_dept_id)
            LIMIT 1
        );
        v_moved_count := v_moved_count + 1;
    END LOOP;

    OPEN p_ref_cursor FOR 
        SELECT doctor_id, COUNT(*) as final_load 
        FROM public.admissions 
        WHERE dept_id = p_dept_id 
        GROUP BY doctor_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in rebalancing: %', SQLERRM;
        RAISE; 
END;
$$ LANGUAGE plpgsql;

-- בדיקת הפונקציה
-- שלב א': נבדוק את העומס הנוכחי של הרופאים במחלקה 1
SELECT 
    d.doctor_id, 
    d.doctor_name, 
    COUNT(a.admission_id) as patient_count
FROM public.doctors d
LEFT JOIN public.admissions a ON d.doctor_id = a.doctor_id
WHERE d.dept_id = 9
GROUP BY d.doctor_id, d.doctor_name
ORDER BY patient_count DESC;

-- הרצת הפונקציה 
-- שלב ב': נריץ את הפונקציה לאיזון מחדש של המחלקה 5 
--ונקבל את העומס הסופי של כל רופא במחלקה באמצעות הסמן שהגדרנו
BEGIN;
-- הרצת הפונקציה (הפרמטר השני הוא שם הסמן)
SELECT public.rebalance_and_audit_department(5, 'my_rebalance_cursor');

-- שליפת הנתונים מהסמן כדי לראות מה השתנה
FETCH ALL FROM my_rebalance_cursor;
COMMIT;