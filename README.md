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

שלב 1\תמונות\צילום מסך 2026-03-22 174722.png

3. תכנות (Programming - Python)
   כתיבת סקריפטים ב-Python המייצרים נתונים הגיוניים בנפח גדול (Batching).

יצירת 21,000 רשומות מדדים.

יצירת 21,000 רשומות מרשמים.

🖥 אפיון ממשק משתמש (UI/UX)
בעזרת Google AI Studio, אפיינו את הממשק הניהולי של המערכת. הממשק מציג דאשבורד חי המבוסס על הנתונים בטבלאות.

Dashboard: ניטור תפוסת חדרים ומדדי דופק ממוצעים.

Clinical View: ניהול מרשמים ובדיקות מעבדה.
[SmartCare.html](https://github.com/user-attachments/files/26326839/SmartCare.html)
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartCare OS | Clinical Management 2026</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #1e293b; }
        .sidebar-item { transition: all 0.2s; cursor: pointer; border-radius: 12px; margin-bottom: 4px; }
        .sidebar-item:hover { background-color: #f1f5f9; }
        .sidebar-item.active { background-color: #0F52BA; color: white; box-shadow: 0 4px 12px rgba(15, 82, 186, 0.2); }
        .view-section { display: none; animation: fadeIn 0.4s ease-out; }
        .view-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .table-container { background: white; border-radius: 20px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        th { font-style: italic; color: #64748b; font-weight: 600; text-align: right; padding: 16px; border-bottom: 1px solid #f1f5f9; }
        td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-weight: 500; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <!-- Sidebar -->
    <aside class="w-72 bg-white border-l border-gray-200 flex flex-col p-6 z-20">
        <div class="mb-10">
            <h1 class="text-2xl font-black text-blue-700 tracking-tight">SmartCare<span class="text-blue-300">.</span></h1>
            <p class="text-[10px] text-gray-400 font-bold uppercase tracking-widest mt-1">Hospital Management System</p>
        </div>
        
        <nav class="flex-1 space-y-1 overflow-y-auto pr-1">
            <div onclick="showView('dashboard')" id="nav-dashboard" class="sidebar-item active flex items-center px-4 py-3">
                <span class="ml-3 text-lg">📊</span> <span class="font-semibold text-sm">Dashboard</span>
            </div>
            <div onclick="showView('patients')" id="nav-patients" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">👥</span> <span class="font-semibold text-sm">מטופלים</span>
            </div>
            <div onclick="showView('doctors')" id="nav-doctors" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">👨‍⚕️</span> <span class="font-semibold text-sm">רופאים</span>
            </div>
            <div onclick="showView('departments')" id="nav-departments" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">🏢</span> <span class="font-semibold text-sm">מחלקות</span>
            </div>
            <div onclick="showView('rooms')" id="nav-rooms" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">🛌</span> <span class="font-semibold text-sm">חדרים</span>
            </div>
            <div onclick="showView('admissions')" id="nav-admissions" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">📝</span> <span class="font-semibold text-sm">אשפוזים</span>
            </div>
            <div onclick="showView('tests')" id="nav-tests" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">🧪</span> <span class="font-semibold text-sm">בדיקות</span>
            </div>
            <div onclick="showView('prescriptions')" id="nav-prescriptions" class="sidebar-item flex items-center px-4 py-3">
                <span class="ml-3 text-lg">📜</span> <span class="font-semibold text-sm">מרשמים</span>
            </div>
        </nav>

        <div class="mt-auto pt-6 border-t border-gray-100 flex items-center">
            <img src="https://ui-avatars.com/api/?name=Dr+Levi&background=0F52BA&color=fff" class="w-10 h-10 rounded-xl ml-3">
            <div>
                <p class="text-sm font-bold">ד"ר לוי</p>
                <p class="text-[10px] text-green-500 font-bold uppercase">מנהל מערכת</p>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-hidden">
        <!-- Header -->
        <header class="h-20 bg-white/80 backdrop-blur-md border-b border-gray-200 flex items-center justify-between px-10">
            <div>
                <h2 id="view-title" class="text-xl font-bold italic text-gray-800 tracking-tight">Dashboard</h2>
                <p id="view-subtitle" class="text-xs text-gray-400 font-medium">ברוך הבא, ד"ר לוי. הנה מה שקורה היום.</p>
            </div>
            <div class="flex items-center gap-4">
                <div class="bg-gray-100 px-4 py-2 rounded-xl flex items-center">
                    <span class="text-gray-400 ml-2">🔍</span>
                    <input type="text" placeholder="חיפוש חופשי..." class="bg-transparent border-none outline-none text-sm w-48">
                </div>
                <button class="w-10 h-10 bg-blue-50 text-blue-600 rounded-xl font-bold">🔔</button>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-10 bg-[#f8fafc]" id="content-parent">

            <!-- 1. DASHBOARD VIEW -->
            <section id="view-dashboard" class="view-section active space-y-8">
                <div class="grid grid-cols-4 gap-6">
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">תפוסת חדרים</p>
                        <h4 class="text-3xl font-black mt-2">84.2%</h4>
                        <div class="w-full bg-gray-100 h-1.5 mt-4 rounded-full overflow-hidden">
                            <div class="bg-blue-600 h-full w-[84%]"></div>
                        </div>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">בדיקות ממתינות</p>
                        <h4 class="text-3xl font-black mt-2 text-red-500">12</h4>
                        <p class="text-[10px] text-red-400 font-bold mt-2">● 3 בדיקות דחופות</p>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">אשפוזים פעילים</p>
                        <h4 class="text-3xl font-black mt-2 text-blue-700">1,420</h4>
                        <p class="text-[10px] text-gray-400 font-bold mt-2">סה"כ 47,000 רשומות</p>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">דופק חריג (ממוצע)</p>
                        <h4 class="text-3xl font-black mt-2 text-orange-500">108 <span class="text-sm">BPM</span></h4>
                        <p class="text-[10px] text-orange-400 font-bold mt-2 italic">מבוסס ניתוח AI</p>
                    </div>
                </div>
                <div class="bg-white p-8 rounded-3xl border border-gray-100 shadow-sm">
                    <h3 class="font-bold italic mb-6">ניטור ויטליים בזמן אמת (Big Data)</h3>
                    <canvas id="mainChart" height="80"></canvas>
                </div>
            </section>

            <!-- 2. PATIENTS VIEW -->
            <section id="view-patients" class="view-section space-y-6">
                <div class="flex justify-between items-center">
                    <h3 class="text-2xl font-bold italic">מאגר מטופלים (PATIENTS)</h3>
                    <button class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-bold text-sm shadow-lg shadow-blue-200">+ מטופל חדש</button>
                </div>
                <div class="table-container">
                    <table class="w-full">
                        <thead>
                            <tr>
                                <th>מזהה</th>
                                <th>שם מלא</th>
                                <th>גיל</th>
                                <th>סוג דם</th>
                                <th>סטטוס אשפוז</th>
                                <th>פעולות</th>
                            </tr>
                        </thead>
                        <tbody class="italic">
                            <tr>
                                <td>#P-1001</td>
                                <td>ישראל ישראלי</td>
                                <td>45</td>
                                <td>O+</td>
                                <td><span class="status-badge bg-green-100 text-green-700">מאושפז</span></td>
                                <td><button class="text-blue-600 font-bold">צפייה</button></td>
                            </tr>
                            <tr>
                                <td>#P-1002</td>
                                <td>שרה כהן</td>
                                <td>32</td>
                                <td>A-</td>
                                <td><span class="status-badge bg-green-100 text-green-700">מאושפז</span></td>
                                <td><button class="text-blue-600 font-bold">צפייה</button></td>
                            </tr>
                            <tr>
                                <td>#P-1003</td>
                                <td>אבי לוי</td>
                                <td>67</td>
                                <td>B+</td>
                                <td><span class="status-badge bg-gray-100 text-gray-500">שוחרר</span></td>
                                <td><button class="text-blue-600 font-bold">צפייה</button></td>
                            </tr>
                            <tr>
                                <td>#P-1004</td>
                                <td>מיכל רז</td>
                                <td>28</td>
                                <td>AB+</td>
                                <td><span class="status-badge bg-green-100 text-green-700">מאושפז</span></td>
                                <td><button class="text-blue-600 font-bold">צפייה</button></td>
                            </tr>
                            <tr>
                                <td>#P-1005</td>
                                <td>דוד אברהם</td>
                                <td>54</td>
                                <td>O-</td>
                                <td><span class="status-badge bg-yellow-100 text-yellow-700">במיון</span></td>
                                <td><button class="text-blue-600 font-bold">צפייה</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- 3. DOCTORS VIEW -->
            <section id="view-doctors" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">צוות רפואי (DOCTORS)</h3>
                <div class="table-container">
                    <table class="w-full">
                        <thead>
                            <tr>
                                <th>רופא</th>
                                <th>התמחות</th>
                                <th>מס' רישיון</th>
                                <th>טלפון</th>
                                <th>סטטוס</th>
                            </tr>
                        </thead>
                        <tbody class="italic">
                            <tr>
                                <td class="flex items-center"><img src="https://ui-avatars.com/api/?name=AL&background=blue&color=fff" class="w-8 h-8 rounded-lg ml-2"> ד"ר אברהם לוי</td>
                                <td class="text-blue-600">קרדיולוגיה</td>
                                <td>LIC-4452</td>
                                <td>054-1234567</td>
                                <td><span class="status-badge bg-green-100 text-green-700">במשמרת</span></td>
                            </tr>
                            <tr>
                                <td class="flex items-center"><img src="https://ui-avatars.com/api/?name=SC&background=purple&color=fff" class="w-8 h-8 rounded-lg ml-2"> ד"ר שרה כהן</td>
                                <td class="text-blue-600">נוירולוגיה</td>
                                <td>LIC-8891</td>
                                <td>052-9988776</td>
                                <td><span class="status-badge bg-green-100 text-green-700">במשמרת</span></td>
                            </tr>
                            <tr>
                                <td class="flex items-center"><img src="https://ui-avatars.com/api/?name=YM&background=orange&color=fff" class="w-8 h-8 rounded-lg ml-2"> ד"ר יוסי מזרחי</td>
                                <td class="text-blue-600">אורתופדיה</td>
                                <td>LIC-1122</td>
                                <td>050-4433221</td>
                                <td><span class="status-badge bg-gray-100 text-gray-500">חופשה</span></td>
                            </tr>
                            <tr>
                                <td class="flex items-center"><img src="https://ui-avatars.com/api/?name=DR&background=pink&color=fff" class="w-8 h-8 rounded-lg ml-2"> ד"ר דנה רון</td>
                                <td class="text-blue-600">ילדים</td>
                                <td>LIC-6677</td>
                                <td>054-0009988</td>
                                <td><span class="status-badge bg-green-100 text-green-700">במשמרת</span></td>
                            </tr>
                            <tr>
                                <td class="flex items-center"><img src="https://ui-avatars.com/api/?name=RB&background=teal&color=fff" class="w-8 h-8 rounded-lg ml-2"> ד"ר רון ברק</td>
                                <td class="text-blue-600">מיון דחוף</td>
                                <td>LIC-3344</td>
                                <td>053-1112233</td>
                                <td><span class="status-badge bg-red-100 text-red-700">בניתוח</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- 4. DEPARTMENTS VIEW -->
            <section id="view-departments" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">ניהול מחלקות (DEPARTMENTS)</h3>
                <div class="grid grid-cols-3 gap-6">
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <h4 class="font-bold text-lg">קרדיולוגיה</h4>
                        <p class="text-xs text-gray-400 italic">קומה 3 | מנהל: ד"ר א. לוי</p>
                        <div class="mt-6 flex justify-between items-end">
                            <div>
                                <p class="text-[10px] font-bold text-gray-400">תפוסה</p>
                                <p class="text-2xl font-black italic">92%</p>
                            </div>
                            <span class="status-badge bg-red-50 text-red-600">עומס גבוה</span>
                        </div>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <h4 class="font-bold text-lg">מיון (ER)</h4>
                        <p class="text-xs text-gray-400 italic">קומה 1 | מנהל: ד"ר ר. ברק</p>
                        <div class="mt-6 flex justify-between items-end">
                            <div>
                                <p class="text-[10px] font-bold text-gray-400">ממתינים</p>
                                <p class="text-2xl font-black italic">14</p>
                            </div>
                            <span class="status-badge bg-yellow-50 text-yellow-600">בינוני</span>
                        </div>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <h4 class="font-bold text-lg">אורתופדיה</h4>
                        <p class="text-xs text-gray-400 italic">קומה 4 | מנהל: ד"ר י. מזרחי</p>
                        <div class="mt-6 flex justify-between items-end">
                            <div>
                                <p class="text-[10px] font-bold text-gray-400">תפוסה</p>
                                <p class="text-2xl font-black italic">65%</p>
                            </div>
                            <span class="status-badge bg-green-50 text-green-600">תקין</span>
                        </div>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <h4 class="font-bold text-lg">טיפול נמרץ</h4>
                        <p class="text-xs text-gray-400 italic">קומה 2 | מנהלת: ד"ר ש. כהן</p>
                        <div class="mt-6 flex justify-between items-end">
                            <div>
                                <p class="text-[10px] font-bold text-gray-400">מיטות פנויות</p>
                                <p class="text-2xl font-black italic">2</p>
                            </div>
                            <span class="status-badge bg-red-600 text-white">קריטי</span>
                        </div>
                    </div>
                    <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                        <h4 class="font-bold text-lg">ילדים</h4>
                        <p class="text-xs text-gray-400 italic">קומה 5 | מנהלת: ד"ר ד. רון</p>
                        <div class="mt-6 flex justify-between items-end">
                            <div>
                                <p class="text-[10px] font-bold text-gray-400">תפוסה</p>
                                <p class="text-2xl font-black italic">40%</p>
                            </div>
                            <span class="status-badge bg-green-50 text-green-600">תקין</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 5. ROOMS VIEW -->
            <section id="view-rooms" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">סטטוס חדרים (ROOMS)</h3>
                <div class="grid grid-cols-5 gap-4">
                    <!-- Dynamic Room Cards -->
                    <div class="bg-white p-4 rounded-2xl border-2 border-green-500 text-center shadow-sm">
                        <p class="font-black text-xl">101</p>
                        <p class="text-[10px] uppercase font-bold text-gray-400">מיון</p>
                        <div class="mt-3 text-[10px] bg-green-100 text-green-700 py-1 rounded-lg font-bold">פנוי</div>
                    </div>
                    <div class="bg-white p-4 rounded-2xl border-2 border-red-500 text-center shadow-sm">
                        <p class="font-black text-xl">102</p>
                        <p class="text-[10px] uppercase font-bold text-gray-400">מיון</p>
                        <div class="mt-3 text-[10px] bg-red-100 text-red-700 py-1 rounded-lg font-bold">תפוס</div>
                    </div>
                    <div class="bg-blue-600 p-4 rounded-2xl text-center text-white shadow-lg">
                        <p class="font-black text-xl italic">ICU-1</p>
                        <p class="text-[10px] uppercase font-bold opacity-80">טיפול נמרץ</p>
                        <div class="mt-3 text-[10px] bg-white/20 py-1 rounded-lg font-bold">תפוס</div>
                    </div>
                    <div class="bg-white p-4 rounded-2xl border-2 border-red-500 text-center shadow-sm">
                        <p class="font-black text-xl">301</p>
                        <p class="text-[10px] uppercase font-bold text-gray-400">קרדיולוגיה</p>
                        <div class="mt-3 text-[10px] bg-red-100 text-red-700 py-1 rounded-lg font-bold">תפוס</div>
                    </div>
                    <div class="bg-white p-4 rounded-2xl border-2 border-green-500 text-center shadow-sm">
                        <p class="font-black text-xl">302</p>
                        <p class="text-[10px] uppercase font-bold text-gray-400">קרדיולוגיה</p>
                        <div class="mt-3 text-[10px] bg-green-100 text-green-700 py-1 rounded-lg font-bold">פנוי</div>
                    </div>
                </div>
            </section>

            <!-- 6. ADMISSIONS VIEW -->
            <section id="view-admissions" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">אשפוזים פעילים (ADMISSIONS)</h3>
                <div class="table-container">
                    <table class="w-full">
                        <thead>
                            <tr>
                                <th>מטופל</th>
                                <th>חדר</th>
                                <th>סיבת אשפוז</th>
                                <th>רופא אחראי</th>
                                <th>תאריך כניסה</th>
                            </tr>
                        </thead>
                        <tbody class="italic font-bold">
                            <tr>
                                <td>ישראל ישראלי</td>
                                <td>301</td>
                                <td class="text-red-600">כאבים בחזה</td>
                                <td>ד"ר א. לוי</td>
                                <td class="text-gray-400">24/03/2026</td>
                            </tr>
                            <tr>
                                <td>שרה כהן</td>
                                <td>ICU-1</td>
                                <td class="text-red-600">ניתוח ראש</td>
                                <td>ד"ר ש. כהן</td>
                                <td class="text-gray-400">25/03/2026</td>
                            </tr>
                            <tr>
                                <td>מיכל רז</td>
                                <td>404</td>
                                <td>שבר פתוח</td>
                                <td>ד"ר י. מזרחי</td>
                                <td class="text-gray-400">23/03/2026</td>
                            </tr>
                            <tr>
                                <td>אלי רפאל</td>
                                <td>202</td>
                                <td>חום גבוה</td>
                                <td>ד"ר ד. רון</td>
                                <td class="text-gray-400">25/03/2026</td>
                            </tr>
                            <tr>
                                <td>סימה לוי</td>
                                <td>102</td>
                                <td>תצפית</td>
                                <td>ד"ר ר. ברק</td>
                                <td class="text-gray-400">25/03/2026</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- 7. TESTS VIEW -->
            <section id="view-tests" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">תוצאות בדיקות (TEST_RESULTS)</h3>
                <div class="table-container">
                    <table class="w-full text-sm">
                        <thead>
                            <tr>
                                <th>מטופל</th>
                                <th>סוג בדיקה</th>
                                <th>תוצאה</th>
                                <th>טווח נורמה</th>
                                <th>סטטוס</th>
                            </tr>
                        </thead>
                        <tbody class="italic font-bold">
                            <tr>
                                <td>ישראל ישראלי</td>
                                <td>Glucose (צום)</td>
                                <td class="text-red-600">145 mg/dL</td>
                                <td class="text-gray-400">70-100</td>
                                <td><span class="status-badge bg-red-100 text-red-700">גבוה</span></td>
                            </tr>
                            <tr>
                                <td>שרה כהן</td>
                                <td>HbA1c</td>
                                <td>5.4%</td>
                                <td class="text-gray-400">4.0-5.6</td>
                                <td><span class="status-badge bg-green-100 text-green-700">תקין</span></td>
                            </tr>
                            <tr>
                                <td>מיכל רז</td>
                                <td>Sodium</td>
                                <td>138 mEq/L</td>
                                <td class="text-gray-400">135-145</td>
                                <td><span class="status-badge bg-green-100 text-green-700">תקין</span></td>
                            </tr>
                            <tr>
                                <td>אבי לוי</td>
                                <td>WBC</td>
                                <td class="text-red-600">14.2 K/uL</td>
                                <td class="text-gray-400">4.5-11.0</td>
                                <td><span class="status-badge bg-red-600 text-white">זיהום!</span></td>
                            </tr>
                            <tr>
                                <td>דוד אברהם</td>
                                <td>Platelets</td>
                                <td>250 K/uL</td>
                                <td class="text-gray-400">150-450</td>
                                <td><span class="status-badge bg-green-100 text-green-700">תקין</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- 8. PRESCRIPTIONS VIEW -->
            <section id="view-prescriptions" class="view-section space-y-6">
                <h3 class="text-2xl font-bold italic">מרשמים פעילים (PRESCRIPTIONS)</h3>
                <div class="table-container">
                    <table class="w-full text-sm">
                        <thead>
                            <tr>
                                <th>מטופל</th>
                                <th>תרופה</th>
                                <th>מינון</th>
                                <th>תדירות</th>
                                <th>רופא מרשם</th>
                            </tr>
                        </thead>
                        <tbody class="italic font-bold">
                            <tr>
                                <td>ישראל ישראלי</td>
                                <td class="text-blue-700">Aspirin</td>
                                <td>100mg</td>
                                <td>פעם ביום</td>
                                <td>ד"ר א. לוי</td>
                            </tr>
                            <tr>
                                <td>שרה כהן</td>
                                <td class="text-blue-700">Morphine</td>
                                <td>2mg</td>
                                <td>כל 4 שעות (IV)</td>
                                <td>ד"ר ש. כהן</td>
                            </tr>
                            <tr>
                                <td>מיכל רז</td>
                                <td class="text-blue-700">Amoxicillin</td>
                                <td>500mg</td>
                                <td>3 פעמים ביום</td>
                                <td>ד"ר ד. רון</td>
                            </tr>
                            <tr>
                                <td>אלי רפאל</td>
                                <td class="text-blue-700">Paracetamol</td>
                                <td>1g</td>
                                <td>לפי הצורך</td>
                                <td>ד"ר ר. ברק</td>
                            </tr>
                            <tr>
                                <td>דוד אברהם</td>
                                <td class="text-blue-700">Metformin</td>
                                <td>850mg</td>
                                <td>פעמיים ביום</td>
                                <td>ד"ר א. לוי</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>
    </main>

    <script>
        // לוגיקה להחלפת מסכים (SPA Logic)
        function showView(viewId) {
            // הסתרת כל הסקשנים
            document.querySelectorAll('.view-section').forEach(section => {
                section.classList.remove('active');
            });

            // הסרת Active מהתפריט
            document.querySelectorAll('.sidebar-item').forEach(item => {
                item.classList.remove('active');
            });

            // הצגת הסקשן הנבחר
            document.getElementById('view-' + viewId).classList.add('active');
            
            // עדכון התפריט
            document.getElementById('nav-' + viewId).classList.add('active');

            // עדכון כותרת
            const titles = {
                'dashboard': 'Dashboard',
                'patients': 'ניהול מטופלים',
                'doctors': 'צוות רפואי',
                'departments': 'מחלקות בית החולים',
                'rooms': 'סטטוס חדרים ומיטות',
                'admissions': 'ניהול אשפוזים',
                'tests': 'תוצאות מעבדה',
                'prescriptions': 'מרשמים ותרופות'
            };
            document.getElementById('view-title').innerText = titles[viewId];
        }

        // אתחול הגרף בדאשבורד
        window.onload = function() {
            const ctx = document.getElementById('mainChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
                    datasets: [{
                        label: 'דופק ממוצע',
                        data: [72, 75, 88, 70, 74, 95, 78, 82],
                        borderColor: '#0F52BA',
                        backgroundColor: 'rgba(15, 82, 186, 0.05)',
                        fill: true,
                        tension: 0.4,
                        borderWidth: 4,
                        pointRadius: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { grid: { color: '#f1f5f9' }, ticks: { font: { weight: 'bold' } } },
                        x: { grid: { display: false } }
                    }
                }
            });
        };
    </script>
</body>
</html>
🔐 גיבוי ושחזור (Backup & Restore)
ביצוע גיבוי מלא למערכת באמצעות כלי ה-pg_dump. הקובץ כולל את כל המבנה והנתונים המאכלסים את המערכת.

קובץ הגיבוי: backup_final_stage_a.sql

אימות: הגיבוי נבדק ושוחזר בהצלחה על בסיס נתונים נקי.

שלב 1\תמונות\צילום מסך 2026-03-25 182640.png
