CREATE TABLE IF NOT EXISTS EMERGENCY_INTEGRATION_BRIDGE (
    Bridge_ID SERIAL PRIMARY KEY,
    Admission_ID INT NOT NULL,     
    Personnel_ID INT NOT NULL,    
    Coordination_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Emergency_Status VARCHAR(20) CHECK (Emergency_Status IN ('Routine', 'High_Alert', 'Critical')),
    
    CONSTRAINT fk_bridge_hospital_admission FOREIGN KEY (Admission_ID) REFERENCES ADMISSIONS(Admission_ID)
);