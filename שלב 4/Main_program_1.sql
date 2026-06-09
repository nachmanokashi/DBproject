-- תוכנית ראשית 1: "זרימת טיפול קליני" (Clinical Flow)
-- זו תוכנית שמדמה טיפול במטופל בודד: מחשבת לו סיכון 
-- (פונקציה) ומבצעת העברה למחלקה אחרת במידת הצורך (פרוצדורה).

DO $$
DECLARE
    v_risk_result VARCHAR;
BEGIN
    -- 1. זימון הפונקציה: חישוב רמת סיכון למטופל (אשפוז מס' 1)
    v_risk_result := public.calculate_patient_risk(1);
    
    -- 2. התניית לוגיקה (רק אם הסיכון גבוה, מעבירים למחלקה טיפולית - נניח מחלקה 2)
    IF v_risk_result = 'High' THEN
        RAISE NOTICE 'High risk patient detected! Executing transfer...';
        
        -- זימון הפרוצדורה: העברת מטופל לטיפול מוגבר
        CALL public.department_handoff_log(1, 2, 999, 'Transfer due to high risk');
        
        RAISE NOTICE 'Transfer to Dept 2 completed successfully.';
    ELSE
        RAISE NOTICE 'Patient risk is %. No transfer needed.', v_risk_result;
    END IF;
END $$;