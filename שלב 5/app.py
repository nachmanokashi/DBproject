from flask import Flask, jsonify, request
import psycopg2
from psycopg2 import extras
import os

app = Flask(__name__)

# מחרוזת החיבור ל-Supabase
DB_URL = "postgresql://postgres.yllcuqknkqkgdcybiavb:Nachman20???@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres"

def get_db_connection():
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = True
    return conn

def serve_html(filename):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(current_dir, 'templates', filename)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    return f"Error: {filename} not found!", 404

@app.route('/')
@app.route('/index.html')
def index():
    return serve_html('index.html')

@app.route('/monitoring.html')
def monitoring():
    return serve_html('monitoring.html')

@app.route('/analytics.html')
def analytics():
    return serve_html('analytics.html')

@app.route('/management.html')
def management():
    return serve_html('management.html')

# =========================================================================
# 1. דאשבורד וסטטיסטיקות
# =========================================================================

@app.route('/api/dashboard/stats', methods=['GET'])
def get_dashboard_stats():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*) FROM public.admissions;")
    active_admissions = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM public.test_results;")
    pending_tests = cursor.fetchone()[0]
    
    cursor.execute("SELECT ROUND(AVG(heart_rate), 1) FROM public.vitals_logs;")
    avg_heart_rate = cursor.fetchone()[0] or 75
    
    cursor.close()
    conn.close()
    return jsonify({
        "active_admissions": active_admissions,
        "pending_tests": pending_tests,
        "avg_heart_rate": avg_heart_rate
    })

@app.route('/api/dashboard/chart', methods=['GET'])
def get_chart_data():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    query = """
        SELECT TO_CHAR(check_time, 'HH24:MI') as time_label, heart_rate 
        FROM public.vitals_logs 
        ORDER BY check_time DESC LIMIT 12;
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    
    rows.reverse()
    labels = [r['time_label'] for r in rows]
    data = [r['heart_rate'] for r in rows]
    return jsonify({"labels": labels, "data": data})

# =========================================================================
# 2. ניהול אשפוזים (Full CRUD - מותאם למבנה ה-DB שלך)
# =========================================================================

@app.route('/api/admissions', methods=['GET'])
def get_admissions():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    # הוסר ה-Reason שאינו קיים במבנה שלך
    query = """
        SELECT a.admission_id, 
               p.first_name || ' ' || p.last_name as patient_name, 
               r.room_number, 
               d.doctor_name, 
               TO_CHAR(a.admission_date, 'DD/MM/YYYY') as adm_date,
               a.risk_level, 
               a.review_status
        FROM public.admissions a
        JOIN public.patients p ON a.patient_id = p.patient_id
        JOIN public.rooms r ON a.room_id = r.room_id
        JOIN public.doctors d ON a.doctor_id = d.doctor_id
        ORDER BY a.admission_id DESC LIMIT 15;
    """
    cursor.execute(query)
    rows = [dict(row) for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return jsonify(rows)

@app.route('/api/admissions', methods=['POST'])
def create_admission():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        INSERT INTO public.admissions (patient_id, room_id, doctor_id, dept_id, risk_level, review_status, admission_date)
        VALUES (%s, %s, %s, %s, %s, %s, NOW()) RETURNING admission_id;
    """
    try:
        cursor.execute(query, (data['patient_id'], data['room_id'], data['doctor_id'], data['dept_id'], data['risk_level'], data['review_status']))
        new_id = cursor.fetchone()[0]
        return jsonify({"success": True, "admission_id": new_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/admissions/<int:id>', methods=['GET'])
def get_admission_by_id(id):
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    query = """
        SELECT a.admission_id, a.risk_level, a.review_status, a.patient_id, a.room_id, a.doctor_id, a.dept_id,
               p.first_name || ' ' || p.last_name as patient_name, d.doctor_name
        FROM public.admissions a
        JOIN public.patients p ON a.patient_id = p.patient_id
        JOIN public.doctors d ON a.doctor_id = d.doctor_id
        WHERE a.admission_id = %s;
    """
    cursor.execute(query, (id,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()
    if row: return jsonify(dict(row))
    return jsonify({"error": "Not found"}), 404

@app.route('/api/admissions/<int:id>', methods=['PUT'])
def update_admission(id):
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE public.admissions SET risk_level = %s, review_status = %s WHERE admission_id = %s;",
                   (data['risk_level'], data['review_status'], id))
    cursor.close()
    conn.close()
    return jsonify({"success": True})

@app.route('/api/admissions/<int:id>', methods=['DELETE'])
def delete_admission(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM public.admissions WHERE admission_id = %s;", (id,))
    cursor.close()
    conn.close()
    return jsonify({"success": True})

# =========================================================================
# 3. מסך איתור חולים ומדדים (מתוקן ומקשר דרך admission_id)
# =========================================================================

@app.route('/api/tracking/high-risk-view', methods=['GET'])
def get_high_risk_view():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    query = """
        SELECT a.admission_id, p.first_name || ' ' || p.last_name as patient_name, a.risk_level, r.room_number
        FROM public.admissions a
        JOIN public.patients p ON a.patient_id = p.patient_id
        JOIN public.rooms r ON a.room_id = r.room_id
        WHERE a.risk_level IN ('High', 'Critical', 'גבוה', 'חמור')
        ORDER BY a.admission_id DESC;
    """
    cursor.execute(query)
    rows = [dict(row) for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return jsonify(rows)

@app.route('/api/tracking/abnormal-vitals', methods=['GET'])
def get_abnormal_vitals():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    # הקישור תוקן: מקשרים מ-vitals_logs דרך admissions אל patients
    query = """
        SELECT v.log_id, p.first_name || ' ' || p.last_name as patient_name, v.heart_rate, v.temperature, TO_CHAR(v.check_time, 'HH24:MI:SS') as check_time
        FROM public.vitals_logs v
        JOIN public.admissions a ON v.admission_id = a.admission_id
        JOIN public.patients p ON a.patient_id = p.patient_id
        WHERE v.heart_rate > 100 OR v.heart_rate < 55 OR v.temperature > 38.5
        ORDER BY v.check_time DESC LIMIT 10;
    """
    cursor.execute(query)
    rows = [dict(row) for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return jsonify(rows)

# =========================================================================
# 4. פרוצדורות וטריגרים (כולל הפעלת הפרוצדורה המקורית להעברת חולים!)
# =========================================================================

@app.route('/api/logic/calculate-risk', methods=['POST'])
def run_calculate_risk():
    adm_id = request.json.get('admission_id')
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT public.calculate_patient_risk(%s);", (adm_id,))
        result = cursor.fetchone()[0]
        return jsonify({"success": True, "result": result})
    except Exception as e: 
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/logic/transfer-patient', methods=['POST'])
def run_transfer_patient():
    """ הפעלת הפרוצדורה המקורית שלכם מה-DB להעברת מחלקות ולוגים """
    patient_id = request.json.get('patient_id')
    new_dept_id = request.json.get('new_dept_id')
    staff_id = request.json.get('staff_id')
    notes = request.json.get('notes', 'העברת מחלקה דרך האתר')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # קריאה ישירה ל-Stored Procedure שלכם בעזרת CALL
        cursor.execute("CALL public.department_handoff_log(%s, %s, %s, %s);", 
                       (patient_id, new_dept_id, staff_id, notes))
        return jsonify({"success": True, "message": f"הפרוצדורה בוצעה! המטופל {patient_id} הועבר למחלקה {new_dept_id} בהצלחה ונרשם לוג במערכת."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# =========================================================================
# 5. דוחות ואנליטיקה (מותאם ל-specialization)
# =========================================================================

@app.route('/api/analytics/department-load', methods=['GET'])
def get_department_load():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    query = """
        SELECT d.dept_name, COUNT(a.admission_id) as total_admissions
        FROM public.departments d
        LEFT JOIN public.admissions a ON d.dept_id = a.dept_id
        GROUP BY d.dept_name ORDER BY total_admissions DESC;
    """
    cursor.execute(query)
    rows = [dict(row) for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return jsonify(rows)

@app.route('/api/analytics/doctor-workload', methods=['GET'])
def get_doctor_workload():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    # תוקן מ-specialty ל-specialization לפי קובץ ה-SQL שלך
    query = """
        SELECT d.doctor_name, d.specialization, COUNT(a.admission_id) as active_patients
        FROM public.doctors d
        LEFT JOIN public.admissions a ON d.doctor_id = a.doctor_id
        GROUP BY d.doctor_name, d.specialization
        ORDER BY active_patients DESC;
    """
    cursor.execute(query)
    rows = [dict(row) for row in cursor.fetchall()]
    cursor.close()
    conn.close()
    return jsonify(rows)

# =========================================================================
# 6. Lookup endpoints – departments / patients / doctors
# =========================================================================

@app.route('/api/departments', methods=['GET'])
def get_departments():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        cursor.execute("SELECT dept_id, dept_name FROM public.departments ORDER BY dept_id;")
        return jsonify([dict(r) for r in cursor.fetchall()])
    finally:
        cursor.close(); conn.close()

@app.route('/api/patients', methods=['GET'])
def get_patients():
    """Return admitted patients with their current dept, for transfer form"""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        cursor.execute("""
            SELECT DISTINCT ON (p.patient_id)
                   p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
                   a.admission_id, a.dept_id, dep.dept_name
            FROM public.patients p
            JOIN public.admissions a ON p.patient_id = a.patient_id
            JOIN public.departments dep ON a.dept_id = dep.dept_id
            ORDER BY p.patient_id, a.admission_date DESC;
        """)
        return jsonify([dict(r) for r in cursor.fetchall()])
    finally:
        cursor.close(); conn.close()

@app.route('/api/doctors', methods=['GET'])
def get_doctors():
    """Return doctors, optionally filtered by dept_id"""
    dept_id = request.args.get('dept_id')
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        if dept_id:
            cursor.execute("""
                SELECT doctor_id, doctor_name, specialization, dept_id
                FROM public.doctors WHERE dept_id = %s ORDER BY doctor_name;
            """, (dept_id,))
        else:
            cursor.execute("""
                SELECT doctor_id, doctor_name, specialization, dept_id
                FROM public.doctors ORDER BY doctor_name;
            """)
        return jsonify([dict(r) for r in cursor.fetchall()])
    finally:
        cursor.close(); conn.close()

# =========================================================================
# 7. Procedures / Functions
# =========================================================================

@app.route('/api/logic/rebalance-department', methods=['POST'])
def run_rebalance():
    """
    rebalance_and_audit_department is a FUNCTION that takes (dept_id, INOUT refcursor).
    Must run inside a transaction to FETCH from the cursor.
    """
    dept_id = request.json.get('dept_id')
    conn = get_db_connection()
    conn.autocommit = False          # need explicit transaction for cursor
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        cursor.execute("SELECT public.rebalance_and_audit_department(%s, 'rebal_cur');", (dept_id,))
        cursor.execute("FETCH ALL FROM rebal_cur;")
        raw = cursor.fetchall()
        conn.commit()

        # Enrich with doctor names
        cursor2 = conn.cursor(cursor_factory=extras.DictCursor)
        cursor2.execute("SELECT doctor_id, doctor_name FROM public.doctors WHERE dept_id = %s;", (dept_id,))
        doc_map = {r['doctor_id']: r['doctor_name'] for r in cursor2.fetchall()}
        cursor2.close()

        doctors = [{"doctor_name": doc_map.get(r['doctor_id'], f"רופא {r['doctor_id']}"),
                    "patient_count": r['final_load']} for r in raw]
        return jsonify({"success": True, "doctors": doctors,
                        "message": f"האיזון הושלם – {len(doctors)} רופאים חולקו שווה"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close(); conn.close()

@app.route('/api/logic/flag-long-term', methods=['POST'])
def run_flag_long_term():
    """
    flag_long_term_patients(p_min_days INT, INOUT p_cursor REFCURSOR).
    Must run inside a transaction to FETCH from the cursor.
    """
    days = request.json.get('days', 30)
    conn = get_db_connection()
    conn.autocommit = False
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        cursor.execute("CALL public.flag_long_term_patients(%s, 'lt_cur');", (days,))
        cursor.execute("FETCH ALL FROM lt_cur;")
        raw = cursor.fetchall()
        conn.commit()

        # Enrich with patient names
        cursor2 = conn.cursor(cursor_factory=extras.DictCursor)
        cursor2.execute("""
            SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name
            FROM public.patients p;
        """)
        pat_map = {r['patient_id']: r['patient_name'] for r in cursor2.fetchall()}
        cursor2.close()

        patients = [{"patient_name": pat_map.get(r['patient_id'], f"מטופל {r['patient_id']}"),
                     "admission_id": r['admission_id'],
                     "admission_date": str(r['admission_date']),
                     "review_status": r['review_status']} for r in raw]
        return jsonify({"success": True, "patients": patients,
                        "message": f"סומנו – מטופלים עם אשפוז מעל {days} יום עודכנו ל-Long Term Review"})
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close(); conn.close()

@app.route('/api/logic/doctor-load', methods=['GET'])
def get_doctor_load_by_dept():
    dept_id = request.args.get('dept_id', 1)
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=extras.DictCursor)
    try:
        cursor.execute("""
            SELECT d.doctor_name, COUNT(a.admission_id) as patient_count
            FROM public.doctors d
            LEFT JOIN public.admissions a ON d.doctor_id = a.doctor_id
            WHERE d.dept_id = %s
            GROUP BY d.doctor_name ORDER BY patient_count DESC;
        """, (dept_id,))
        return jsonify({"success": True, "doctors": [dict(r) for r in cursor.fetchall()]})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close(); conn.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)