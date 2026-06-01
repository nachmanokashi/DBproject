-- שאילתות מבט  1 

-- שאילתא 1  
--- שאילתה זו מנתחת את תדירות האירועים לפי ימי השבוע כדי לזהות דפוסים בתיאום הלוגיסטי של האשפוזים.
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM Coordination_Date) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM Coordination_Date) = 6 THEN 'Saturday'
    END AS Day_Of_Week,
    COUNT(*) AS Event_Frequency
FROM hospital_coordination_view
GROUP BY EXTRACT(DOW FROM Coordination_Date)
ORDER BY Event_Frequency DESC;

-- שאילתא 2
-- שאילתה זו מחפשת מטופלים שמופיעים במערכת יותר מפעם אחת 
(כלומר, מישהו שחזר לאשפוז ועבר תיאום לוגיסטי פעם נוספת).
SELECT 
    First_Name, 
    Last_Name, 
    COUNT(*) AS Incident_Count
FROM hospital_coordination_view
GROUP BY First_Name, Last_Name
HAVING COUNT(*) > 1
ORDER BY Incident_Count DESC;

-- שאילתות מבט 2 
-- שאילתא 1 
-- שאילתה זו מנתחת את סוגי הפגיעות השכיחים ביותר
 על ידי חיבור נתוני האשפוזים עם סוגי התחמושת .
SELECT 
    Suspected_Ammo_Type, 
    COUNT(*) AS Case_Count
FROM ballistic_trauma_analysis
WHERE Suspected_Ammo_Type IS NOT NULL
GROUP BY Suspected_Ammo_Type
ORDER BY Case_Count DESC;

-- שאילתא 2
-- שאילתה זו מנתחת את הקשר בין סוגי הפגיעות לבין רמת החירום של המקרים 
-- כדי להבין אילו סוגי פגיעות נוטים להיות יותר קריטיים.
SELECT 
    Suspected_Ammo_Type,
    Emergency_Status,
    COUNT(*) AS Incident_Count
FROM ballistic_trauma_analysis
GROUP BY Suspected_Ammo_Type, Emergency_Status
ORDER BY Suspected_Ammo_Type, Incident_Count DESC;


-- שאילתות מבט 3
-- שאילתא 1
-- שאילתה זו מנתחת את אחוז החולים הקריטיים בכל מחלקה 
כדי לזהות אילו מחלקות מתמודדות עם האתגרים הגדולים ביותר.

SELECT 
    Dept_Name,
    COUNT(*) AS Total_Patients,
    -- ספירת חולים קריטיים
    SUM(CASE WHEN alert_level = 'CRITICAL - IMMEDIATE ACTION' THEN 1 ELSE 0 END) AS Critical_Cases,
    -- ספירת חולים יציבים
    SUM(CASE WHEN alert_level = 'STABLE' THEN 1 ELSE 0 END) AS Stable_Cases,
    -- חישוב האחוז (החלק המתוחכם)
    ROUND(100.0 * SUM(CASE WHEN alert_level = 'CRITICAL - IMMEDIATE ACTION' THEN 1 ELSE 0 END) / COUNT(*), 1) AS Critical_Percentage
FROM v_critical_alert_dashboard
GROUP BY Dept_Name
-- נציג קודם את המחלקות עם הכי הרבה אחוז חולים קריטיים
ORDER BY Critical_Percentage DESC;

-- שאילתא 2
-- שאילתה זו מחפשת את אנשי הסגל של השותף שאחראים על המקרים הקריטיים ביותר
-- ומספקת את פרטי הקשר שלהם כדי להבטיח תקשורת מהירה ויעילה.
SELECT 
    p.First_Name || ' ' || p.Last_Name AS Patient_Name,
    rp.name AS Logistics_Officer,
    rp.phone_number AS Logistics_Contact_Phone,
    rp.email AS Logistics_Contact_Email,
    eb.Emergency_Status,
    CASE 
        WHEN eb.Emergency_Status = 'Critical' THEN 'CALL IMMEDIATELY: Priority Alpha'
        WHEN eb.Emergency_Status = 'High_Alert' THEN 'Contact via encrypted channel'
        ELSE 'Standard coordination'
    END AS Communication_Protocol
FROM ADMISSIONS a
JOIN PATIENTS p ON a.Patient_ID = p.Patient_ID
JOIN EMERGENCY_INTEGRATION_BRIDGE eb ON a.Admission_ID = eb.Admission_ID
JOIN partner_personnel rp ON eb.Personnel_ID = rp.id
ORDER BY eb.Emergency_Status DESC;