# SmartCare HIS – Hospital Information System
## שלב 5: עיצוב ובנייה של המערכת

---

## מבנה הקבצים

| קובץ | תיאור | עמוד |
|---|---|---|
| `index.html` | לוח בקרה ראשי | Dashboard |
| `monitoring.html` | ניטור קליני | Clinical Monitoring |
| `analytics.html` | אנליטיקה ודוחות | Analytics & Reports |
| `management.html` | ניהול בית החולים | Hospital Management |
| `style.css` | עיצוב משותף לכל הדפים | Shared Stylesheet |

---

## מיפוי שאילתות SQL → פיצ'רים במערכת

### שאילתה 1 – מטופלים עם חום גבוה (temp > 39.5)
- **קובץ:** `monitoring.html`
- **פיצ'ר:** טבלת "ניטור חום גבוה לפי מחלקה" עם סינון דינמי לפי מחלקה
- **טריגר UI:** Dropdown סינון מחלקה → מציג רק השורות הרלוונטיות
- **שאילתה מקורית:** `SELECT ... FROM PATIENTS JOIN ADMISSIONS JOIN VITALS_LOGS WHERE Temperature > 39.5`

### שאילתה 2 – חדרים פנויים (NOT EXISTS)
- **קובץ:** `analytics.html`
- **פיצ'ר:** מפת חדרים ויזואלית (room tiles) – ירוק=פנוי, אדום=תפוס
- **שאילתה מקורית:** `SELECT r.Room_Number ... WHERE NOT EXISTS (SELECT 1 FROM ADMISSIONS WHERE Room_ID = r.Room_ID)`

### שאילתה 3 – רופאים שרשמו תרופות לפי יצרן
- **קובץ:** `analytics.html`
- **פיצ'ר:** טבלת "מעקב רישום תרופות לפי יצרן" עם Dropdown סינון יצרן
- **שאילתה מקורית:** `SELECT d.Doctor_Name, m.Med_Name ... WHERE m.Manufacturer = 'GlobalPharma'`

### שאילתה 4 – מטופלים עם תוצאת בדיקה חריגה (Abnormal)
- **קובץ:** `monitoring.html`
- **פיצ'ר:** טבלת "תוצאות בדיקות חריגות" עם כפתור הפניה לרופא
- **שאילתה מקורית:** `SELECT ... JOIN TEST_RESULTS WHERE tr.Result_Value = 'Abnormal'`

### שאילתה 5 – סטטיסטיקת אשפוזים חודשית לפי מחלקה (GROUP BY)
- **קובץ:** `index.html`
- **פיצ'ר 1:** גרף עמודות "עומס אשפוזים חודשי לפי מחלקה" (Chart.js)
- **פיצ'ר 2:** טבלת "עומס אשפוזים לפי מחלקה – יוני 2026"
- **שאילתה מקורית:** `SELECT d.Dept_Name, EXTRACT(YEAR/MONTH), COUNT(...) GROUP BY d.Dept_Name, Floor, Year, Month`

### שאילתה 6 – ממוצע מדדים של מטופלי קרדיולוגיה (HAVING + AVG)
- **קובץ 1:** `index.html` – גרף "עומס רופאים – מטופלים פעילים"
- **קובץ 2:** `analytics.html` – טבלת "רופאי קרדיולוגיה – ממוצע מדדים" + גרף השוואה
- **שאילתה מקורית:** `SELECT d.Doctor_Name, AVG(Heart_Rate), AVG(Temperature) WHERE Specialization='Cardiology' HAVING AVG(Temperature) > 37.0`

### שאילתה 7 – חולים חוזרים (HAVING COUNT >= 2)
- **קובץ 1:** `index.html` – טבלת "חולים עם סיכון לאשפוז חוזר"
- **קובץ 2:** `monitoring.html` – טבלת "חולים בסיכון לאשפוז חוזר" עם ספירת ביקורים
- **שאילתה מקורית:** `SELECT ... COUNT(Admission_ID) HAVING COUNT(Admission_ID) >= 2`

### שאילתה 8 – פופולריות תרופות לפי יצרן (COUNT DISTINCT + HAVING > 20)
- **קובץ:** `analytics.html`
- **פיצ'ר 1:** טבלת "תרופות מובילות לפי כמות מרשמים" עם מגמות
- **פיצ'ר 2:** גרף עוגה "נתח שוק לפי יצרן"
- **שאילתה מקורית:** `SELECT m.Med_Name, COUNT(DISTINCT Doctor_ID), COUNT(...) HAVING COUNT(...) > 20`

---

## מיפוי פונקציות → פיצ'רים

### פונקציה 1 – `calculate_patient_risk(p_admission_id)`
- **קובץ:** `monitoring.html`
- **פיצ'ר:** "מחשבון סיכון מטופל אוטומטי" – ממשק גרפי להזנת דופק וחום
- **אופן הפעולה:** מחשב ניקוד (0–10) לפי אותו אלגוריתם IF-ELSIF שבפונקציה, מציג Low/Medium/High עם מד ויזואלי, ומסמל עדכון DB
- **רכיבי PL/pgSQL מוצגים:** IF-ELSIF Branching, Score accumulation, RETURN level

### פונקציה 2 – `rebalance_and_audit_department(p_dept_id)`
- **קובץ:** `management.html`
- **פיצ'ר:** "איזון אוטומטי של עומס רופאים" – בוחרים מחלקה, לוחצים על הכפתור
- **אופן הפעולה:** מציג השוואת לפני/אחרי של עומס מטופלים לפי רופא, ממחיש ROW_NUMBER חלוקה שווה
- **רכיבי PL/pgSQL מוצגים:** CTE עם ROW_NUMBER, חלוקה שווה, REFCURSOR ← דוח סופי

---

## מיפוי פרוצדורות → פיצ'רים

### פרוצדורה 1 – `flag_long_term_patients(p_min_days)`
- **קובץ:** `monitoring.html`
- **פיצ'ר:** טבלת "אשפוזים ממושכים – Long Term Review" עם כפתור "עדכן רשימה"
- **אופן הפעולה:** לחיצה על הכפתור מדמה הרצת הפרוצדורה ומציגה כמה מטופלים סומנו
- **רכיבי PL/pgSQL:** Explicit Cursor FOR LOOP, UPDATE DML, REFCURSOR ← רשימת מסומנים

### פרוצדורה 2 – `department_handoff_log(p_patient_id, p_new_dept_id, p_staff_id, p_notes)`
- **קובץ:** `management.html`
- **פיצ'ר:** "טופס העברת מטופל" + יומן העברות חי
- **אופן הפעולה:** מלא פרטים → לחץ "בצע העברה" → רשומה חדשה מופיעה ביומן + הודעת הצלחה
- **רכיבי PL/pgSQL:** OPEN/FETCH/CLOSE REFCURSOR, UPDATE + INSERT DML, ROLLBACK on error

---

## מיפוי טריגרים → פיצ'רים

### טריגר 1 – `prevent_invalid_discharge_date`
- **קובץ:** `management.html`
- **פיצ'ר:** טופס "רישום אשפוז חדש" – ולידציה בזמן אמת
- **אופן הפעולה:** אם תאריך שחרור מוקדם מתאריך קבלה → הודעת שגיאה אדומה מופיעה לפני השמירה

### טריגר 2 – `validate_doctor_department`
- **קובץ:** `management.html`
- **פיצ'ר:** טופס "רישום אשפוז חדש" – ולידציה רופא-מחלקה
- **אופן הפעולה:** אם הרופא שנבחר לא שייך למחלקה שנבחרה → שגיאה ברורה עם שם הטריגר

---

## מיפוי Views → פיצ'רים

### View 1 – `hospital_coordination_view`
- **קובץ:** `management.html`
- **פיצ'ר:** טבלת "תצוגת תיאום – קשר עם שותפים" (מטופלים + סטטוס חירום + תאריך תיאום)

### View 2 – `ballistic_trauma_analysis`
- **קובץ:** `management.html`
- **פיצ'ר:** טבלת "ניתוח טראומה – ציוד נדרש לטיפול" (סוג פגיעה חשוד + סטטוס)

### View 3 – `v_critical_alert_dashboard`
- **קובץ:** `index.html`
- **פיצ'ר 1:** באנר אדום בראש הדף – "X מטופלים במצב קריטי דורשים טיפול מיידי"
- **פיצ'ר 2:** טבלת "חולים עם מדדים חריגים – דורשים התייחסות מיידית" עם עמודת איש קשר לוגיסטי

---

## טכנולוגיות

- **HTML5 / CSS3** – ללא frameworks חיצוניים (רק Inter font מ-Google Fonts)
- **Vanilla JavaScript** – לוגיקת UI, סינון, אנימציות
- **Chart.js** – גרפי עמודות, קווים ועוגה
- **עיצוב:** CSS Variables, CSS Grid, RTL מלא, Responsive design

---

## הרצה

פתח את `index.html` בדפדפן – כל הקישורים בין הדפים עובדים מקומית (קבצים באותה תיקייה).
