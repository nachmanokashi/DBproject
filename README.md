🏥 SmartCare OS - Hospital Management System
פרויקט בבסיסי נתונים
מגישים: נחמן עוקשי ואליאור ספייב
מרצה: מר יעקב ברזילי

🌟 סקירה כללית
מערכת SmartCare היא פלטפורמה מתקדמת לניהול בתי חולים, המתוכננת לטפל בנפח נתונים גדול (Big Data). המערכת מאפשרת ניהול מלא של סבב האשפוז - החל מקליטת המטופל, דרך ניטור מדדים רפואיים בזמן אמת, ועד ניהול מרשמים ובדיקות מעבדה.

נתוני מפתח:

10 ישויות מנורמלות (3NF).

מעל 47,000 רשומות מאוכלסות.

ארכיטקטורה: PostgreSQL בענן (Supabase).

🛠 עיצוב וארכיטקטורה (Design)
בשלב זה הגדרנו את הלוגיקה העסקית והקשרים בין הישויות. המערכת מורכבת מ-10 טבלאות המבטיחות שלמות נתונים (Referential Integrity).

תרשים ERD (Entity Relationship Diagram)
התרשים מציג את הקשרים (1:N) בין המטופלים, האשפוזים, המדדים והבדיקות.

<img width="3744" height="1365" alt="ERD" src="https://github.com/user-attachments/assets/41e9e2be-2b89-4b31-a710-ddb04e15a3ff" />

תרשים DSD (Database Schema Design)
פירוט המפתחות הראשיים (PK) והמפתחות הזרים (FK) עבור כל 10 הטבלאות.

<img width="3744" height="1365" alt="DSD" src="https://github.com/user-attachments/assets/70c594fe-deec-469a-afeb-f2586c5a969d" />


🚀 הקמת בסיס הנתונים (DDL)
יצרנו את מבנה הטבלאות ב-Supabase תוך שימוש בטיפוסי נתונים אופטימליים (כמו TIMESTAMP למדדים ו-NUMERIC לטמפרטורה).

פירוט הטבלאות:

PATIENTS

DOCTORS

DEPARTMENTS

ROOMS

ADMISSIONS

VITALS_LOGS

MEDICATIONS

PRESCRIPTIONS

TESTS

TEST_RESULTS

💾 אכלוס נתונים (Data Population)
זוהי הליבה של הפרויקט. השתמשנו ב-3 שיטות שונות כדי למלא את המערכת ביותר מ-47,000 שורות:

1. הכנסה ידנית (Manual)
   יצירת נתוני הליבה (מחלקות ומבנה) בעזרת שאילתות INSERT ידניות וקבצי CSV מותאמים.
<img width="1132" height="684" alt="צילום מסך 2026-03-29 022822" src="https://github.com/user-attachments/assets/98c07df3-6481-4d6f-8de9-83e125625f24" />


2. שימוש בקבצי נתונים חיצוניים (Mockaroo)
   ייצור של 1,000 מטופלים ו-1,000 רופאים בעזרת אתר Mockaroo וייבואם כקבצי SQL.

<img width="1279" height="366" alt="צילום מסך 2026-03-22 174722" src="https://github.com/user-attachments/assets/ca4f3d24-137e-4624-81f4-e687ff4eee02" />

3. תכנות (Programming - Python)
   כתיבת סקריפטים ב-Python המייצרים נתונים הגיוניים בנפח גדול (Batching).

יצירת 21,000 רשומות מדדים.

יצירת 21,000 רשומות מרשמים.

🖥 אפיון ממשק משתמש (UI/UX)
בעזרת Google AI Studio, אפיינו את הממשק הניהולי של המערכת. הממשק מציג דאשבורד חי המבוסס על הנתונים בטבלאות.

Dashboard: ניטור תפוסת חדרים ומדדי דופק ממוצעים.

Clinical View: ניהול מרשמים ובדיקות מעבדה.
<img width="1886" height="727" alt="צילום מסך 2026-03-29 023113" src="https://github.com/user-attachments/assets/cea7b1bd-3d08-47aa-9073-e03c65ea7ffc" />

    

🔐 גיבוי ושחזור (Backup & Restore)
ביצוע גיבוי מלא למערכת באמצעות כלי ה-pg_dump. הקובץ כולל את כל המבנה והנתונים המאכלסים את המערכת.

קובץ הגיבוי: backup_final_stage_a.sql

אימות: הגיבוי נבדק ושוחזר בהצלחה על בסיס נתונים נקי.
<img width="1329" height="317" alt="צילום מסך 2026-03-25 182640" src="https://github.com/user-attachments/assets/3856ddaa-7deb-4a07-8fa3-9dfd586337c2" />

