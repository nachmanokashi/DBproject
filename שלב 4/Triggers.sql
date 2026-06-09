-- טריגר 1 
-- שם הטריגר: prevent_invalid_discharge_date
-- תיאור: טריגר זה מונע עדכון של תאריך שחרור
-- שיהיה מוקדם מתאריך הקבלה של אותו אשפוז.

-- יצירת הפונקציה
CREATE OR REPLACE FUNCTION prevent_invalid_discharge_date_func()
RETURNS TRIGGER AS $$
BEGIN
    -- בדיקה: האם תאריך השחרור מוקדם מתאריך הקבלה?
    IF NEW.discharge_date IS NOT NULL AND NEW.admission_date IS NOT NULL THEN
        IF NEW.discharge_date < NEW.admission_date THEN
            RAISE EXCEPTION 'שגיאה: תאריך שחרור (%) לא יכול להיות מוקדם מתאריך קבלה (%)', 
            NEW.discharge_date, NEW.admission_date;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- יצירת הטריגר
CREATE TRIGGER prevent_invalid_discharge_date
BEFORE UPDATE ON public.admissions
FOR EACH ROW
EXECUTE FUNCTION prevent_invalid_discharge_date_func();


-- טריגר 2
-- שם הטריגר: validate_doctor_department
-- תיאור: טריגר זה מוודא שכל עדכון של רופא או
מחלקה בטבלת האשפוזים תואם את הקשר בין הרופא למחלקה כפי שמוגדר בטבלת הרופאים.
-- יצירת הפונקציה

CREATE OR REPLACE FUNCTION validate_doctor_department_func()
RETURNS TRIGGER AS $$
DECLARE
    v_doctor_dept_id INT;
BEGIN
    -- אם לא שינו את הרופא או את המחלקה, אין מה לבדוק
    IF NEW.doctor_id = OLD.doctor_id AND NEW.dept_id = OLD.dept_id THEN
        RETURN NEW;
    END IF;

    -- בודקים מה המחלקה של הרופא המעודכן
    SELECT dept_id INTO v_doctor_dept_id
    FROM public.doctors
    WHERE doctor_id = NEW.doctor_id;

    -- אם המחלקה של הרופא לא תואמת למחלקה של האשפוז
    IF v_doctor_dept_id IS NULL OR v_doctor_dept_id != NEW.dept_id THEN
        RAISE EXCEPTION 'שגיאת מערכת: הרופא (ID: %) אינו משויך למחלקה המעודכנת (ID: %).', 
        NEW.doctor_id, NEW.dept_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- יצירת הטריגר
CREATE TRIGGER validate_doctor_department_trigger
BEFORE UPDATE ON public.admissions
FOR EACH ROW
EXECUTE FUNCTION validate_doctor_department_func();
