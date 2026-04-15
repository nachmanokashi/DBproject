# 🏥 SmartCare OS | Hospital Management System

**פרויקט בבסיסי נתונים**
**מגישים:** נחמן עוקשי ואליאור ספייב

**מרצה:** מר יעקב ברזילי

---

## 📋 תוכן עניינים

- שלב א
- [🌟 סקירה כללית](#overview)
- [🛠 עיצוב וארכיטקטורה](#design)
- [💾 אכלוס נתונים ב-3 שיטות](#data)
- [🐍 סקריפט ייצור הנתונים (Programming)](#programming)
- [🖥 אפיון ממשק משתמש (UI/UX)](#ui)
- [🔐 גיבוי ושחזור](#backup)
- שלב ב
- [🔍 שאילתות](#Queries)
- [📝 שאילתות עדכון ומחיקה ](#Update_Delete)
- [🛡️ אילוצים ](#Constraints)
- [🔄 טרנזקציות (Rollback & Commit)](#Transactions)
- [⚡ שיפור ביצועים ואינדקסים](#index)

**שלב1**
<a name="overview"></a>

## 🌟 סקירה כללית

מערכת **SmartCare** מנהלת בית חולים עם 10 ישויות ומעל 47,000 רשומות. הארכיטקטורה מבוססת PostgreSQL בענן (Supabase).

---

<a name="design"></a>

## 🛠 עיצוב וארכיטקטורה

![ERD Diagram](שלב%201/תמונות/ERD.png)
_תרשים ה-ERD המעודכן הכולל 10 ישויות._

---

<img width="3744" height="1365" alt="DSD" src="https://github.com/user-attachments/assets/05a8b37a-7218-4172-85db-35bbab1c59f3" />

<a name="data"></a>

## 💾 אכלוס נתונים ב-3 שיטות

1. **ידני (CSV):** מחלקות וחדרים.
2. **חיצוני (Mockaroo):** 1,000 מטופלים ורופאים.
   <img width="1279" height="366" alt="צילום מסך 2026-03-22 174722" src="https://github.com/user-attachments/assets/837a2466-ac24-4fda-9762-f91db39c1d65" />

3. **תכנות (Python):** 42,000 רשומות של מדדים ומרשמים.

---

<a name="programming"></a>

## 🐍 סקריפט ייצור הנתונים (Programming)

כדי לייצר את עשרות אלפי הרשומות של המדדים (`VITALS_LOGS`) והמרשמים (`PRESCRIPTIONS`), כתבנו סקריפט Python חכם שמבצע הכנסה ב-Batches כדי לשמור על יציבות ה-DB.

🔗 **[לחץ כאן לצפייה בסקריפט הפייתון המלא שכתבנו](./שלב%201/Programing/generate_data.py)**

---

<a name="ui"></a>

## 🖥 אפיון ממשק משתמש (UI/UX)

![UI Design](שלב%201/תמונות/צילום%20מסך%202026-03-29%20023113.png)
_אפיון דאשבורד המערכת שבוצע ב-Google AI Studio._

---

<a name="backup"></a>

## 🔐 גיבוי ושחזור

הגיבוי הסופי כולל את כל 10 הטבלאות והנתונים.
![Backup Status](שלב%201/תמונות/צילום%20מסך%202026-03-25%20182640.png)

**שלב 2**
<a name="queries"></a>

## שאילתות

בשלב זה נבחנו שאילתות בשתי צורות כתיבה שונות כדי להשוות ביצועים וקריאות.

1. מציאת מטופלים עם חום גבוה (מעל 39.5)
   מטרה: זיהוי מטופלים במצב קריטי הזקוקים להשגחה מיידית.

צורה 1 (JOIN): שימוש בחיבור טבלאות ישיר. זוהי הצורה המומלצת בנפחים גדולים כיוון שאופטימייזר ה-SQL יודע למקבץ את החיפושים ביעילות.

צורה 2 (IN): שימוש בתתי-שאילתות. בדרך כלל פחות יעיל כיוון שהמערכת עשויה להריץ את השאילתה הפנימית עבור כל שורה בחיצונית.

ביצועים: ה-JOIN מהיר יותר משמעותית בשל שימוש באינדקסים על מפתחות זרים.
<img width="940" height="372" alt="image" src="https://github.com/user-attachments/assets/c199eb49-fbb1-469f-b18e-41ada6ce00ca" />
<img width="487" height="480" alt="צילום מסך 2026-04-15 155011" src="https://github.com/user-attachments/assets/5ef00248-f2d4-4d48-a010-708e9074cd38" />

2. הצגת חדרים פנויים
   מטרה: ניהול תפוסת מיטות בזמן אמת.

צורה 1 (NOT EXISTS): בדיקה האם לא קיימת רשומת אשפוז לחדר. יעיל מאוד ב-PostgreSQL מכיוון שהוא מפסיק את הבדיקה ברגע שנמצאה התאמה.

צורה 2 (NOT IN): חיפוש ברשימת המפתחות. עלול להיות בעייתי אם קיימים ערכי NULL בנתונים.

ביצועים: NOT EXISTS נחשב ליציב ומהיר יותר.
<img width="718" height="171" alt="image" src="https://github.com/user-attachments/assets/8de33b66-afa1-4d66-8139-3e94083fc74d" />
<img width="499" height="483" alt="צילום מסך 2026-04-15 155343" src="https://github.com/user-attachments/assets/ca03a0aa-95c3-40c6-b249-72e5f6468cb9" />


3. מעקב אחר מרשמים לפי יצרן (GlobalPharma)
   מטרה: ניתוח הרגלי רישום תרופות של רופאים מול ספקים ספציפיים.

צורה 1 (JOIN): חיבור קלאסי של 3 טבלאות.

צורה 2 (CTE - WITH): כתיבת תת-שאילתה מקדימה. משפר משמעותית את קריאות הקוד ומאפשר לאופטימייזר לבנות תוכנית הרצה מבודדת.

ביצועים: בגרסאות Postgres חדשות ה-CTE מהיר באותה מידה, אך קל יותר לתחזוקה.
<img width="807" height="348" alt="image" src="https://github.com/user-attachments/assets/589bd7fb-4283-4c35-b3b7-1e65733dc270" />
<img width="940" height="771" alt="צילום מסך 2026-04-15 160750" src="https://github.com/user-attachments/assets/9478f4e9-10a9-40de-9a84-3ca9cefc14f1" />


4. מטופלים עם תוצאות בדיקה חריגות
   מטרה: איתור חריגות רפואיות (Abnormal) למעקב דחוף.

צורה 1 (JOIN): חיבור מלא בין מטופלים לבדיקות.

צורה 2 (EXISTS): בדיקת קיום רשומה ללא שליפת כל הנתונים. חוסך בזיכרון במידה וצריך רק את שמות המטופלים.

ביצועים: EXISTS מנצח במקרים של סינון מהיר.
<img width="539" height="391" alt="image" src="https://github.com/user-attachments/assets/a75f9e05-a7f8-4a32-9205-5776b29470ec" />
<img width="1063" height="765" alt="צילום מסך 2026-04-15 161119" src="https://github.com/user-attachments/assets/1c6d2f44-a1b7-46a8-bec8-4b7447e8126c" />


שאילתות SELECT נוספות:
סטטיסטיקת אשפוזים חודשית: סיכום עומסים לפי מחלקה וזמן.
<img width="809" height="173" alt="image" src="https://github.com/user-attachments/assets/2fbea3ee-2d36-4193-856e-7419997aa880" />
<img width="807" height="793" alt="צילום מסך 2026-04-15 161731" src="https://github.com/user-attachments/assets/3ca021d9-ee96-466b-9c2d-a814d4341a0e" />


מדדים ממוצעים בקרדיולוגיה: ניתוח ביצועי לב אצל חולים תחת השגחת מומחים.
<img width="1035" height="317" alt="image" src="https://github.com/user-attachments/assets/0efe0292-5855-4cfb-9147-3c4414f228f3" />
<img width="1218" height="793" alt="צילום מסך 2026-04-15 162537" src="https://github.com/user-attachments/assets/d30f7cf8-219a-4cb7-af23-6a6299a2e2a2" />


חולים "כבדים": איתור מטופלים חוזרים לטובת ניתוח כרוני.
<img width="595" height="257" alt="image" src="https://github.com/user-attachments/assets/c28fc200-386b-4ccd-9407-181131d58de6" />
<img width="1126" height="683" alt="צילום מסך 2026-04-15 162736" src="https://github.com/user-attachments/assets/02e63966-0809-474c-a594-f516181b3f99" />


פופולריות תרופות: ניתוח תרופות שנרשמו הכי הרבה על ידי מספר רופאים שונים.
<img width="651" height="201" alt="image" src="https://github.com/user-attachments/assets/3c2344fe-1ecb-4e01-a25c-7498a1467882" />

<a name="Update_Delete"></a>

## עדכון ומחיקה

ביצענו שינויים בנתונים כדי לשקף תהליכים עסקיים (כמו סימון דחיפות או ניקוי נתונים ישנים).

Update: עדכון מינונים למטופלים עם חום גבוה וסימון בדיקות כ"דחוף" במחלקה 14.

לפני:

<img width="1417" height="708" alt="צילום מסך 2026-04-15 190651" src="https://github.com/user-attachments/assets/2b6abcc1-c32b-43e3-8114-2c96724fa571" />

אחרי:

<img width="1409" height="721" alt="צילום מסך 2026-04-15 190905" src="https://github.com/user-attachments/assets/96909bbf-839f-4f2c-accd-859aa509437e" />

Delete: מחיקת מדדים למטופלים במחלקה 14 לטובת ניקוי ארכיון.


לפני:

<img width="968" height="543" alt="צילום מסך 2026-04-15 191639" src="https://github.com/user-attachments/assets/7e00706d-37dd-42e4-abd2-e377fdbaabf2" />

אחרי:

<img width="933" height="542" alt="צילום מסך 2026-04-15 191752" src="https://github.com/user-attachments/assets/46ed0c42-69e5-4b3d-93bd-bae94f8333be" />

<a name="Constraints"></a>

## אילוצים

הוספנו חוקים עסקיים באמצעות פקודות ALTER TABLE כדי להבטיח את אמינות המידע הרפואי:

טווח טמפרטורה (30-45 מעלות): מניעת הזנת נתונים לא הגיוניים.

תאריך לידה עבר: מניעת תאריכי לידה עתידיים.

טווח דופק (20-250): הבטחה שנתוני הלב נמצאים בטווח הפיזיולוגי האפשרי.

הוכחת כשל: ניסיון להכניס חום גוף של 50 מעלות גורר שגיאת הרצה מה-DB.


<img width="1431" height="641" alt="Constraint error" src="https://github.com/user-attachments/assets/51dc468f-8c4a-44e7-a0bd-31f6a6f97c55" />

<a name="Transactions"></a>

## טרנזקציות

הדגמנו ניהול טרנזקציות כדי לשמור על עקביות הנתונים (Atomic operations).

Rollback: ביצוע מחיקה בטעות וביטולה לפני השמירה הקבועה. 
חיפשנו נתון אשר לא יפריע לנו ובחרנו בבדיקות אז בהתחלה יש  לנו 

<img width="956" height="705" alt="צילום מסך 2026-04-15 193007" src="https://github.com/user-attachments/assets/62104f3f-c607-4b78-8e87-5047a607fce6" />
<img width="977" height="728" alt="צילום מסך 2026-04-15 193028" src="https://github.com/user-attachments/assets/af6eff47-008a-4235-998f-269db64225af" />
<img width="969" height="740" alt="צילום מסך 2026-04-15 193045" src="https://github.com/user-attachments/assets/acf4d106-1a7f-44d9-ba5c-3487300a0c2e" />

Commit: ביצוע עדכון קומה למחלקה ואישורו הסופי בבסיס הנתונים.

<img width="747" height="565" alt="צילום מסך 2026-04-15 193644" src="https://github.com/user-attachments/assets/cb048e57-439f-4da2-8269-f93309afd14d" />
ואחרי זה נשאר קבוע לנו 
<img width="744" height="567" alt="צילום מסך 2026-04-15 193750" src="https://github.com/user-attachments/assets/2716bb16-cd01-45c2-8a04-841542c1c3a5" />


<a name="index"></a>

## שיפור ביצועים ואינדקסים

צרנו אינדקסים על עמודות המשתתפות בחיפושים וחיבורים תכופים (כמו זמן בדיקה ושמות מטופלים).

אינדקס: idx_vitals_check_time על טבלת VITALS_LOGS המכילה עשרות אלפי שורות.

בדיקת זמני ריצה:

לפני:
<img width="1439" height="764" alt="Time before" src="https://github.com/user-attachments/assets/7adf0070-a185-48d1-805c-6cdc1801b950" />

אחרי:

<img width="1458" height="748" alt="Time after" src="https://github.com/user-attachments/assets/4f96060b-d597-478f-822d-0d69d0df737c" />

הסבר: האינדקס הוריד את זמן השליפה משמעותית ע"י מעבר מסריקה מלאה (Sequential Scan) לחיפוש ממוקד בעץ (Index Scan).
