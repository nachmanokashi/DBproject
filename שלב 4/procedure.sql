-- פרוצדורה 1 
-- שם הפרוצדורה: flag_long_term_patients
-- תיאור: פרוצדורה זו מסמנת מטופלים שנמצאים בא
--  אשפוז מעל מספר ימים מסוים כרמת סיכון "Long Term Review".
-- הפרוצדורה גם מחזירה רשימה של המטופלים שסומנו באמצעות Ref Cursor
--, ומטפלת בשגיאות אפשריות במהלך התהליך.
CREATE OR REPLACE PROCEDURE flag_long_term_patients(
    p_min_days INT,
    INOUT p_cursor REFCURSOR -- (b) החזרת Ref Cursor
)
LANGUAGE plpgsql AS $$
DECLARE
    r_patient RECORD; -- (g) Record
    v_found_count INT := 0;
    -- (a) Explicit Cursor: שליפת כל המטופלים שעברו את מכסת הימים
    c_long_term CURSOR FOR
        SELECT admission_id, patient_id
        FROM public.admissions
        WHERE CURRENT_DATE - admission_date > p_min_days
          AND risk_level != 'Long Term Review';
BEGIN
    -- (d) Branching: בדיקת תקינות הקלט
    IF p_min_days < 0 THEN
        RAISE EXCEPTION 'Days cannot be negative';
    END IF;

    -- (e) Loops: מעבר על הרשימה
    FOR r_patient IN c_long_term LOOP
        -- (c) DML (UPDATE): עדכון רמת הסיכון של המטופל
        UPDATE public.admissions
        SET risk_level = 'Long Term Review'
        WHERE admission_id = r_patient.admission_id;
        
        v_found_count := v_found_count + 1;
    END LOOP;

    -- (b) Ref Cursor: פתיחת הסמן כדי להחזיר את הרשימה למשתמש/UI
    OPEN p_cursor FOR
        SELECT admission_id, patient_id, admission_date
        FROM public.admissions
        WHERE risk_level = 'Long Term Review';

    RAISE NOTICE 'Flagged % patients as Long Term.', v_found_count;

EXCEPTION -- (f) Exception Handling
    WHEN OTHERS THEN
        RAISE NOTICE 'Error processing long-term patients: %', SQLERRM;
        ROLLBACK; 
END;
$$;

-- בדיקה של הפרוצדורה

SELECT admission_id, admission_date, risk_level
FROM public.admissions
WHERE CURRENT_DATE - admission_date > 30 
LIMIT 10;

-- הרצת הפרוצדורה  
BEGIN;
-- נריץ את הפרוצדורה (הפרמטר השני הוא שם הסמן שנפתח)
CALL public.flag_long_term_patients(30, 'my_results_cursor');

-- נשלוף את התוצאות מהסמן
FETCH ALL FROM my_results_cursor;
COMMIT;

--המצב אחרי 
SELECT admission_id, admission_date, risk_level
FROM public.admissions
WHERE risk_level = 'Long Term Review'
LIMIT 10;

-- פרוצדורה 2
-- שם הפרוצדורה: department_handoff_log
-- תיאור: פרוצדורה זו מתעדת העברות מטופלים בין מחלקות בבית החולים. 
-- היא מקבלת את מזהה המטופל, המחלקה החדשה, מזהה הצוות המעביר והערות נוספות.
-- הפרוצדורה מעדכנת את מחלקת המטופל באשפוזים ומוסיפה רשומה ליומן ההעברות. 
-- היא גם מטפלת בשגיאות אפשריות במהלך התהליך.   
CREATE OR REPLACE PROCEDURE department_handoff_log(
    p_patient_id INT,
    p_new_dept_id INT,
    p_staff_id INT,
    p_notes TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_old_dept_id INT;
    c_patient_info REFCURSOR;
BEGIN
    -- 1. שימוש ב-REF CURSOR כדי לשלוף את המחלקה הנוכחית (שימוש ב-dept_id הנכון)
    OPEN c_patient_info FOR 
        SELECT dept_id FROM public.admissions 
        WHERE patient_id = p_patient_id 
        -- נניח שאין עמודת discharge_date אז נסיר את התנאי הזה או נשתמש בקיים
        ORDER BY admission_date DESC LIMIT 1;
    
    FETCH c_patient_info INTO v_old_dept_id;
    CLOSE c_patient_info;

    -- בדיקה האם המטופל קיים באשפוזים
    IF v_old_dept_id IS NULL THEN
        RAISE EXCEPTION 'Patient is not currently admitted or not found.';
    END IF;

    -- 2. עדכון מחלקת המטופל (תיקון ל-dept_id)
    UPDATE public.admissions 
    SET dept_id = p_new_dept_id
    WHERE patient_id = p_patient_id;

    -- 3. כתיבה ליומן ההעברות (תיקון ל-old_department_id ל-old_dept_id אם צריך או התאמה לשם העמודה בטבלה שיצרת)
    INSERT INTO public.department_transfers_log (patient_id, old_department_id, new_department_id, staff_id, notes)
    VALUES (p_patient_id, v_old_dept_id, p_new_dept_id, p_staff_id, p_notes);

    RAISE NOTICE 'Patient % transferred from % to % successfully.', p_patient_id, v_old_dept_id, p_new_dept_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transfer failed: %', SQLERRM;
        ROLLBACK; 
END;
$$;

-- בדיקה של הפרוצדורה
-- לפני 
SELECT admission_id, patient_id, dept_id 
FROM public.admissions 
WHERE patient_id = 1;

-- הרצת הפרוצדורה
CALL public.department_handoff_log(1, 2, 99, 'העברה לטיפול ממוקד');

-- אחרי
-- בדיקת העדכון בטבלת האשפוזים
SELECT admission_id, patient_id, dept_id 
FROM public.admissions 
WHERE patient_id = 1;

-- בדיקת תיעוד הלוג
SELECT * FROM public.department_transfers_log 
ORDER BY transfer_date DESC LIMIT 5;