-- תוכנית ראשית 2: "ניהול ותחזוקת מחלקה" (System Maintenance)
-- תוכנית זו מבצעת סריקה של עומסים במחלקה 
-- (פונקציית איזון) ואז מבצעת אכיפת חוקים
--  על מטופלים ותיקים (פרוצדורת תיוג).
DO $$
DECLARE
    v_rebalance_msg TEXT;
    v_cursor_name REFCURSOR := 'my_long_term_cursor';
BEGIN
    -- 1. זימון הפונקציה: איזון עומסים במחלקה 9 (Surgery)
    -- הפונקציה מחזירה טקסט עם סטטוס
    v_rebalance_msg := public.rebalance_and_audit_department(9, 'my_rebalance_cursor');
    RAISE NOTICE 'Department Rebalance Status: %', v_rebalance_msg;
    
    -- 2. זימון הפרוצדורה: תיוג מטופלים ותיקים (מעל 30 יום)
    -- הפרוצדורה ממלאת סמן (Cursor) שניתן לשלוף
    CALL public.flag_long_term_patients(30, v_cursor_name);
    
    RAISE NOTICE 'Maintenance sequence completed. Check cursor % for results.', v_cursor_name;
    
    -- הערה: בממשק של Supabase, אחרי הרצה כזו, 
    -- ניתן להריץ FETCH ALL FROM my_long_term_cursor; בנפרד כדי לראות את הרשימה.
END $$;