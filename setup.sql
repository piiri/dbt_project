-- =============================================================
-- HEALTHCARE DATA WAREHOUSE - SETUP SCRIPT
-- Run this BEFORE the demo to create all raw source data
-- =============================================================

USE ROLE CORTEX_CODE_HOL;
USE WAREHOUSE CORTEX_CODE_HOL;

-- =============================================================
-- 1. CREATE DATABASE AND SCHEMAS
-- =============================================================

CREATE DATABASE IF NOT EXISTS HEALTHCARE_DW
  COMMENT = 'Digital Healthcare Platform - Patient Journey & Revenue Analytics';

CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DW.RAW
  COMMENT = 'Raw ingested data from source systems';

CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DW.ANALYTICS
  COMMENT = 'dbt transformed models - staging, SCD, marts';

-- =============================================================
-- 2. CREATE RAW TABLES
-- =============================================================

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.PATIENTS (
    PATIENT_ID VARCHAR(20),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    DATE_OF_BIRTH DATE,
    GENDER VARCHAR(10),
    PHONE VARCHAR(15),
    EMAIL VARCHAR(100),
    ADDRESS_LINE1 VARCHAR(200),
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    PIN_CODE VARCHAR(10),
    INSURANCE_PROVIDER VARCHAR(100),
    INSURANCE_PLAN VARCHAR(50),
    BLOOD_GROUP VARCHAR(5),
    EMERGENCY_CONTACT VARCHAR(15),
    REGISTRATION_DATE TIMESTAMP_NTZ,
    LAST_UPDATED TIMESTAMP_NTZ,
    IS_ACTIVE BOOLEAN
);

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.DOCTORS (
    DOCTOR_ID VARCHAR(20),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    SPECIALIZATION VARCHAR(100),
    QUALIFICATION VARCHAR(100),
    CLINIC_NAME VARCHAR(200),
    CLINIC_CITY VARCHAR(50),
    CLINIC_STATE VARCHAR(50),
    CONSULTATION_FEE NUMBER(10,2),
    YEARS_OF_EXPERIENCE NUMBER(3),
    RATING NUMBER(3,2),
    AVAILABLE_ONLINE BOOLEAN,
    PHONE VARCHAR(15),
    LICENSE_NUMBER VARCHAR(30),
    JOINED_DATE TIMESTAMP_NTZ,
    LAST_UPDATED TIMESTAMP_NTZ,
    IS_ACTIVE BOOLEAN
);

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.CONSULTATIONS (
    CONSULTATION_ID VARCHAR(20),
    PATIENT_ID VARCHAR(20),
    DOCTOR_ID VARCHAR(20),
    CONSULTATION_TYPE VARCHAR(20),
    CONSULTATION_DATE TIMESTAMP_NTZ,
    CHIEF_COMPLAINT VARCHAR(500),
    DIAGNOSIS VARCHAR(500),
    DIAGNOSIS_CODE VARCHAR(20),
    FOLLOW_UP_REQUIRED BOOLEAN,
    FOLLOW_UP_DATE DATE,
    NOTES VARCHAR(2000),
    DURATION_MINUTES NUMBER(5),
    CREATED_AT TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.PRESCRIPTIONS (
    PRESCRIPTION_ID VARCHAR(20),
    CONSULTATION_ID VARCHAR(20),
    PATIENT_ID VARCHAR(20),
    DOCTOR_ID VARCHAR(20),
    MEDICINE_NAME VARCHAR(200),
    DOSAGE VARCHAR(100),
    FREQUENCY VARCHAR(50),
    DURATION_DAYS NUMBER(5),
    QUANTITY NUMBER(5),
    IS_GENERIC BOOLEAN,
    NOTES VARCHAR(500),
    PRESCRIBED_AT TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.ORDERS (
    ORDER_ID VARCHAR(20),
    PATIENT_ID VARCHAR(20),
    PRESCRIPTION_ID VARCHAR(20),
    ORDER_DATE TIMESTAMP_NTZ,
    ORDER_STATUS VARCHAR(30),
    DELIVERY_TYPE VARCHAR(20),
    DELIVERY_ADDRESS VARCHAR(300),
    DELIVERY_CITY VARCHAR(50),
    DELIVERY_PIN_CODE VARCHAR(10),
    SUBTOTAL NUMBER(10,2),
    DISCOUNT NUMBER(10,2),
    DELIVERY_FEE NUMBER(10,2),
    TOTAL_AMOUNT NUMBER(10,2),
    EXPECTED_DELIVERY_DATE DATE,
    ACTUAL_DELIVERY_DATE DATE,
    LAST_UPDATED TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE HEALTHCARE_DW.RAW.PAYMENTS (
    PAYMENT_ID VARCHAR(20),
    ORDER_ID VARCHAR(20),
    PATIENT_ID VARCHAR(20),
    PAYMENT_DATE TIMESTAMP_NTZ,
    AMOUNT NUMBER(10,2),
    PAYMENT_METHOD VARCHAR(30),
    PAYMENT_STATUS VARCHAR(20),
    TRANSACTION_REF VARCHAR(50),
    INSURANCE_CLAIM_ID VARCHAR(30),
    INSURANCE_COVERED_AMOUNT NUMBER(10,2),
    PATIENT_PAID_AMOUNT NUMBER(10,2),
    CREATED_AT TIMESTAMP_NTZ
);

-- =============================================================
-- 3. INSERT PATIENTS DATA (15 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.PATIENTS VALUES
('PAT-001','Aarav','Sharma','1985-03-15','Male','+919876543210','aarav.sharma@email.com','42 MG Road','Mumbai','Maharashtra','400001','Star Health','Gold','B+','+919876543211','2024-01-10 09:00:00','2025-12-15 10:30:00',TRUE),
('PAT-002','Priya','Patel','1990-07-22','Female','+919876543220','priya.patel@email.com','15 Jubilee Hills','Hyderabad','Telangana','500033','ICICI Lombard','Silver','A+','+919876543221','2024-01-12 11:00:00','2026-01-20 14:00:00',TRUE),
('PAT-003','Rohit','Kumar','1978-11-30','Male','+919876543230','rohit.kumar@email.com','8 Connaught Place','New Delhi','Delhi','110001','HDFC ERGO','Platinum','O+','+919876543231','2024-02-01 10:00:00','2025-11-05 09:00:00',TRUE),
('PAT-004','Sneha','Reddy','1995-05-18','Female','+919876543240','sneha.reddy@email.com','23 Koramangala','Bangalore','Karnataka','560034','Max Bupa','Gold','AB+','+919876543241','2024-02-15 08:30:00','2026-02-10 11:00:00',TRUE),
('PAT-005','Vikram','Singh','1982-09-08','Male','+919876543250','vikram.singh@email.com','56 Civil Lines','Jaipur','Rajasthan','302001','Star Health','Silver','B-','+919876543251','2024-03-01 09:00:00','2025-10-20 16:00:00',TRUE),
('PAT-006','Ananya','Iyer','1988-12-25','Female','+919876543260','ananya.iyer@email.com','12 Anna Nagar','Chennai','Tamil Nadu','600040','Bajaj Allianz','Gold','A-','+919876543261','2024-03-10 10:00:00','2026-03-01 12:00:00',TRUE),
('PAT-007','Arjun','Mehta','1975-06-14','Male','+919876543270','arjun.mehta@email.com','34 SG Highway','Ahmedabad','Gujarat','380054','New India Assurance','Silver','O-','+919876543271','2024-04-01 11:00:00','2025-09-15 08:30:00',TRUE),
('PAT-008','Kavya','Nair','1992-02-28','Female','+919876543280','kavya.nair@email.com','7 Marine Drive','Kochi','Kerala','682001','Star Health','Platinum','AB-','+919876543281','2024-04-15 09:30:00','2026-01-05 10:00:00',TRUE),
('PAT-009','Rajesh','Gupta','1968-08-10','Male','+919876543290','rajesh.gupta@email.com','89 Hazratganj','Lucknow','Uttar Pradesh','226001','ICICI Lombard','Gold','B+','+919876543291','2024-05-01 08:00:00','2025-08-20 15:00:00',TRUE),
('PAT-010','Divya','Joshi','1998-04-05','Female','+919876543300','divya.joshi@email.com','45 FC Road','Pune','Maharashtra','411004','HDFC ERGO','Silver','A+','+919876543301','2024-05-15 10:30:00','2026-02-28 09:00:00',TRUE),
('PAT-011','Karthik','Rajan','1980-10-12','Male','+919876543310','karthik.rajan@email.com','18 T Nagar','Chennai','Tamil Nadu','600017','Max Bupa','Gold','O+','+919876543311','2024-06-01 09:00:00','2025-07-10 11:00:00',TRUE),
('PAT-012','Meera','Das','1993-01-20','Female','+919876543320','meera.das@email.com','5 Salt Lake','Kolkata','West Bengal','700091','Bajaj Allianz','Silver','B+','+919876543321','2024-06-15 11:00:00','2026-03-15 14:00:00',TRUE),
('PAT-013','Suresh','Pillai','1970-07-07','Male','+919876543330','suresh.pillai@email.com','22 MG Road','Trivandrum','Kerala','695001','Star Health','Platinum','A-','+919876543331','2024-07-01 10:00:00','2025-06-25 09:30:00',FALSE),
('PAT-014','Neha','Agarwal','1987-03-30','Female','+919876543340','neha.agarwal@email.com','67 Sector 18','Noida','Uttar Pradesh','201301','ICICI Lombard','Gold','AB+','+919876543341','2024-07-15 08:30:00','2026-01-10 13:00:00',TRUE),
('PAT-015','Amit','Choudhury','1991-11-15','Male','+919876543350','amit.choudhury@email.com','3 Park Street','Kolkata','West Bengal','700016','New India Assurance','Gold','O+','+919876543351','2024-08-01 09:00:00','2025-12-01 10:00:00',TRUE);

-- =============================================================
-- 4. INSERT DOCTORS DATA (10 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.DOCTORS VALUES
('DOC-001','Dr. Sanjay','Kapoor','Cardiology','MD, DM Cardiology','Apollo Hospital','Mumbai','Maharashtra',1500.00,22,4.8,TRUE,'+919800000001','MH-12345','2020-01-15 10:00:00','2026-01-15 10:00:00',TRUE),
('DOC-002','Dr. Priyanka','Verma','Dermatology','MD Dermatology','Fortis Clinic','New Delhi','Delhi',800.00,12,4.6,TRUE,'+919800000002','DL-23456','2021-03-10 09:00:00','2025-11-20 11:00:00',TRUE),
('DOC-003','Dr. Arun','Krishnan','General Medicine','MBBS, MD','Max Healthcare','Bangalore','Karnataka',500.00,18,4.5,TRUE,'+919800000003','KA-34567','2019-06-01 08:00:00','2026-02-10 09:00:00',TRUE),
('DOC-004','Dr. Kavitha','Subramaniam','Orthopedics','MS Ortho, DNB','AIIMS','Chennai','Tamil Nadu',1200.00,25,4.9,FALSE,'+919800000004','TN-45678','2018-09-20 10:00:00','2025-10-05 14:00:00',TRUE),
('DOC-005','Dr. Rahul','Saxena','Psychiatry','MD Psychiatry','Medanta','Gurugram','Haryana',1000.00,15,4.7,TRUE,'+919800000005','HR-56789','2020-11-05 11:00:00','2026-03-01 10:00:00',TRUE),
('DOC-006','Dr. Deepa','Menon','Pediatrics','MD Pediatrics, DCH','Narayana Health','Kochi','Kerala',600.00,10,4.4,TRUE,'+919800000006','KL-67890','2022-02-14 09:00:00','2025-12-20 09:30:00',TRUE),
('DOC-007','Dr. Manish','Tiwari','ENT','MS ENT','Manipal Hospital','Pune','Maharashtra',700.00,14,4.3,TRUE,'+919800000007','MH-78901','2021-07-01 10:00:00','2026-01-30 11:00:00',TRUE),
('DOC-008','Dr. Swati','Jain','Gynecology','MS OBG, DNB','Kokilaben Hospital','Mumbai','Maharashtra',1100.00,20,4.8,TRUE,'+919800000008','MH-89012','2019-04-10 08:30:00','2025-09-15 12:00:00',TRUE),
('DOC-009','Dr. Vikrant','Deshmukh','Neurology','DM Neurology','Ruby Hall Clinic','Pune','Maharashtra',1400.00,17,4.6,FALSE,'+919800000009','MH-90123','2020-08-20 10:00:00','2026-02-28 10:00:00',TRUE),
('DOC-010','Dr. Lakshmi','Narayan','Diabetology','MD, DM Endocrinology','Apollo Sugar Clinic','Hyderabad','Telangana',900.00,13,4.5,TRUE,'+919800000010','TS-01234','2021-12-01 09:00:00','2025-11-10 11:00:00',TRUE);

-- =============================================================
-- 5. INSERT CONSULTATIONS DATA (20 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.CONSULTATIONS VALUES
('CON-001','PAT-001','DOC-001','In-Person','2025-01-15 10:00:00','Chest pain and shortness of breath','Stable Angina','I20.8',TRUE,'2025-02-15','ECG normal, stress test recommended',30,'2025-01-15 10:00:00'),
('CON-002','PAT-002','DOC-002','Online','2025-01-20 11:00:00','Recurring skin rash on arms','Contact Dermatitis','L25.9',FALSE,NULL,'Prescribed topical corticosteroid',20,'2025-01-20 11:00:00'),
('CON-003','PAT-003','DOC-003','In-Person','2025-02-05 09:30:00','Persistent fever for 5 days','Viral Fever','B34.9',TRUE,'2025-02-12','Blood tests ordered, paracetamol prescribed',25,'2025-02-05 09:30:00'),
('CON-004','PAT-004','DOC-005','Online','2025-02-18 14:00:00','Anxiety and sleep disturbance','Generalized Anxiety Disorder','F41.1',TRUE,'2025-03-18','Therapy sessions recommended, mild medication started',45,'2025-02-18 14:00:00'),
('CON-005','PAT-005','DOC-004','In-Person','2025-03-01 10:30:00','Knee pain after jogging','Patellofemoral Syndrome','M22.2',TRUE,'2025-04-01','Physiotherapy recommended, avoid running',30,'2025-03-01 10:30:00'),
('CON-006','PAT-006','DOC-010','Online','2025-03-15 11:00:00','Increased thirst and frequent urination','Type 2 Diabetes','E11.9',TRUE,'2025-04-15','HbA1c 7.2%, metformin started',35,'2025-03-15 11:00:00'),
('CON-007','PAT-007','DOC-001','In-Person','2025-04-02 09:00:00','Palpitations and dizziness','Atrial Fibrillation','I48.91',TRUE,'2025-04-16','Echocardiogram ordered, blood thinners prescribed',40,'2025-04-02 09:00:00'),
('CON-008','PAT-008','DOC-006','Online','2025-04-20 10:00:00','Child fever and cough (6yr old)','Upper Respiratory Infection','J06.9',FALSE,NULL,'Symptomatic treatment, rest advised',20,'2025-04-20 10:00:00'),
('CON-009','PAT-009','DOC-009','In-Person','2025-05-10 11:30:00','Recurring headaches and vision issues','Migraine with Aura','G43.1',TRUE,'2025-06-10','MRI recommended, preventive medication started',35,'2025-05-10 11:30:00'),
('CON-010','PAT-010','DOC-007','In-Person','2025-05-25 09:00:00','Sore throat and ear pain','Acute Otitis Media','H66.90',FALSE,NULL,'Antibiotics prescribed, follow up if no improvement',20,'2025-05-25 09:00:00'),
('CON-011','PAT-001','DOC-001','In-Person','2025-06-15 10:00:00','Follow-up for chest pain','Stable Angina - Improved','I20.8',FALSE,NULL,'Stress test normal, continue medication',20,'2025-06-15 10:00:00'),
('CON-012','PAT-011','DOC-003','Online','2025-06-28 14:00:00','Fatigue and body aches','Iron Deficiency Anemia','D50.9',TRUE,'2025-07-28','Iron supplements, dietary changes advised',25,'2025-06-28 14:00:00'),
('CON-013','PAT-012','DOC-008','In-Person','2025-07-10 09:30:00','Routine pregnancy checkup','Normal Pregnancy - 20 weeks','Z34.00',TRUE,'2025-08-10','All vitals normal, ultrasound scheduled',30,'2025-07-10 09:30:00'),
('CON-014','PAT-014','DOC-005','Online','2025-07-25 15:00:00','Panic attacks at work','Panic Disorder','F41.0',TRUE,'2025-08-25','CBT sessions started, medication adjusted',40,'2025-07-25 15:00:00'),
('CON-015','PAT-015','DOC-010','In-Person','2025-08-05 10:00:00','Routine diabetes follow-up','Type 2 Diabetes - Controlled','E11.9',TRUE,'2025-11-05','HbA1c improved to 6.5%, continue current plan',25,'2025-08-05 10:00:00'),
('CON-016','PAT-003','DOC-003','Online','2025-08-20 11:00:00','Cold and cough recurring','Allergic Rhinitis','J30.9',FALSE,NULL,'Antihistamines prescribed',15,'2025-08-20 11:00:00'),
('CON-017','PAT-006','DOC-010','In-Person','2025-09-10 10:30:00','Diabetes follow-up, numbness in feet','Diabetic Neuropathy','E11.40',TRUE,'2025-10-10','Nerve conduction study ordered, gabapentin added',30,'2025-09-10 10:30:00'),
('CON-018','PAT-004','DOC-005','Online','2025-09-18 14:00:00','Anxiety follow-up - improvement','GAD - Improving','F41.1',TRUE,'2025-12-18','Reduce medication gradually, continue therapy',30,'2025-09-18 14:00:00'),
('CON-019','PAT-002','DOC-002','In-Person','2025-10-05 11:00:00','Follow-up skin rash','Contact Dermatitis - Resolved','L25.9',FALSE,NULL,'Condition resolved, avoid allergen',15,'2025-10-05 11:00:00'),
('CON-020','PAT-013','DOC-003','In-Person','2025-10-20 09:00:00','Chronic cough and weight loss','Chronic Bronchitis','J42',TRUE,'2025-11-20','Chest X-ray ordered, smoking cessation advised',35,'2025-10-20 09:00:00');

-- =============================================================
-- 6. INSERT PRESCRIPTIONS DATA (20 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.PRESCRIPTIONS VALUES
('PRE-001','CON-001','PAT-001','DOC-001','Aspirin 75mg','75mg','Once daily',90,90,TRUE,'Take after breakfast','2025-01-15 10:30:00'),
('PRE-002','CON-001','PAT-001','DOC-001','Atorvastatin 10mg','10mg','Once daily at night',90,90,TRUE,'For cholesterol management','2025-01-15 10:30:00'),
('PRE-003','CON-002','PAT-002','DOC-002','Betamethasone Cream 0.1%','Apply thin layer','Twice daily',14,1,FALSE,'Apply on affected area only','2025-01-20 11:20:00'),
('PRE-004','CON-003','PAT-003','DOC-003','Paracetamol 500mg','500mg','Three times daily',5,15,TRUE,'Take after meals','2025-02-05 10:00:00'),
('PRE-005','CON-004','PAT-004','DOC-005','Escitalopram 5mg','5mg','Once daily morning',30,30,FALSE,'Do not stop abruptly','2025-02-18 14:30:00'),
('PRE-006','CON-005','PAT-005','DOC-004','Diclofenac Gel','Apply locally','Three times daily',14,2,TRUE,'Apply on knee, avoid heat','2025-03-01 11:00:00'),
('PRE-007','CON-006','PAT-006','DOC-010','Metformin 500mg','500mg','Twice daily',90,180,TRUE,'Take with meals','2025-03-15 11:30:00'),
('PRE-008','CON-007','PAT-007','DOC-001','Warfarin 2mg','2mg','Once daily','30',30,FALSE,'Regular INR monitoring required','2025-04-02 09:30:00'),
('PRE-009','CON-007','PAT-007','DOC-001','Metoprolol 25mg','25mg','Twice daily',30,60,TRUE,'For heart rate control','2025-04-02 09:30:00'),
('PRE-010','CON-008','PAT-008','DOC-006','Amoxicillin Syrup','5ml','Three times daily',7,1,TRUE,'For child, complete full course','2025-04-20 10:20:00'),
('PRE-011','CON-009','PAT-009','DOC-009','Sumatriptan 50mg','50mg','As needed',30,10,FALSE,'Max 2 tablets per day','2025-05-10 12:00:00'),
('PRE-012','CON-009','PAT-009','DOC-009','Propranolol 20mg','20mg','Twice daily',60,120,TRUE,'Preventive for migraines','2025-05-10 12:00:00'),
('PRE-013','CON-010','PAT-010','DOC-007','Amoxicillin 500mg','500mg','Three times daily',7,21,TRUE,'Complete full course','2025-05-25 09:20:00'),
('PRE-014','CON-012','PAT-011','DOC-003','Ferrous Sulfate 200mg','200mg','Once daily',90,90,TRUE,'Take on empty stomach with vitamin C','2025-06-28 14:20:00'),
('PRE-015','CON-013','PAT-012','DOC-008','Folic Acid 5mg','5mg','Once daily',90,90,TRUE,'Essential for pregnancy','2025-07-10 10:00:00'),
('PRE-016','CON-014','PAT-014','DOC-005','Clonazepam 0.25mg','0.25mg','As needed for panic',30,15,FALSE,'Only during acute panic, max once daily','2025-07-25 15:30:00'),
('PRE-017','CON-015','PAT-015','DOC-010','Metformin 1000mg','1000mg','Twice daily',90,180,TRUE,'Continue current dose','2025-08-05 10:20:00'),
('PRE-018','CON-016','PAT-003','DOC-003','Cetirizine 10mg','10mg','Once daily',14,14,TRUE,'May cause drowsiness','2025-08-20 11:15:00'),
('PRE-019','CON-017','PAT-006','DOC-010','Gabapentin 300mg','300mg','Once daily at night',60,60,FALSE,'For neuropathic pain','2025-09-10 11:00:00'),
('PRE-020','CON-020','PAT-013','DOC-003','Montelukast 10mg','10mg','Once daily at night',30,30,FALSE,'For chronic cough','2025-10-20 09:30:00');

-- =============================================================
-- 7. INSERT ORDERS DATA (18 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.ORDERS VALUES
('ORD-001','PAT-001','PRE-001','2025-01-15 12:00:00','Delivered','Home Delivery','42 MG Road, Mumbai','Mumbai','400001',350.00,35.00,40.00,355.00,'2025-01-18',DATE'2025-01-17','2025-01-17 14:00:00'),
('ORD-002','PAT-002','PRE-003','2025-01-20 13:00:00','Delivered','Home Delivery','15 Jubilee Hills, Hyderabad','Hyderabad','500033',450.00,0.00,40.00,490.00,'2025-01-23',DATE'2025-01-22','2025-01-22 11:00:00'),
('ORD-003','PAT-003','PRE-004','2025-02-05 11:00:00','Delivered','Store Pickup','MedPlus Connaught Place','New Delhi','110001',120.00,12.00,0.00,108.00,'2025-02-06',DATE'2025-02-05','2025-02-05 16:00:00'),
('ORD-004','PAT-004','PRE-005','2025-02-18 16:00:00','Delivered','Home Delivery','23 Koramangala, Bangalore','Bangalore','560034',680.00,68.00,40.00,652.00,'2025-02-21',DATE'2025-02-20','2025-02-20 10:00:00'),
('ORD-005','PAT-005','PRE-006','2025-03-01 12:00:00','Delivered','Home Delivery','56 Civil Lines, Jaipur','Jaipur','302001',220.00,22.00,40.00,238.00,'2025-03-04',DATE'2025-03-03','2025-03-03 15:00:00'),
('ORD-006','PAT-006','PRE-007','2025-03-15 13:00:00','Delivered','Home Delivery','12 Anna Nagar, Chennai','Chennai','600040',180.00,18.00,0.00,162.00,'2025-03-18',DATE'2025-03-17','2025-03-17 09:00:00'),
('ORD-007','PAT-007','PRE-008','2025-04-02 11:00:00','Delivered','Home Delivery','34 SG Highway, Ahmedabad','Ahmedabad','380054',950.00,0.00,40.00,990.00,'2025-04-05',DATE'2025-04-04','2025-04-04 12:00:00'),
('ORD-008','PAT-008','PRE-010','2025-04-20 12:00:00','Delivered','Store Pickup','MedPlus Marine Drive, Kochi','Kochi','682001',85.00,8.50,0.00,76.50,'2025-04-21',DATE'2025-04-20','2025-04-20 17:00:00'),
('ORD-009','PAT-009','PRE-011','2025-05-10 14:00:00','Shipped','Home Delivery','89 Hazratganj, Lucknow','Lucknow','226001',720.00,72.00,40.00,688.00,'2025-05-13',NULL,'2025-05-12 08:00:00'),
('ORD-010','PAT-010','PRE-013','2025-05-25 10:00:00','Delivered','Home Delivery','45 FC Road, Pune','Pune','411004',150.00,15.00,40.00,175.00,'2025-05-28',DATE'2025-05-27','2025-05-27 11:00:00'),
('ORD-011','PAT-011','PRE-014','2025-06-28 16:00:00','Delivered','Home Delivery','18 T Nagar, Chennai','Chennai','600017',95.00,9.50,40.00,125.50,'2025-07-01',DATE'2025-06-30','2025-06-30 14:00:00'),
('ORD-012','PAT-012','PRE-015','2025-07-10 11:00:00','Delivered','Home Delivery','5 Salt Lake, Kolkata','Kolkata','700091',60.00,0.00,40.00,100.00,'2025-07-13',DATE'2025-07-12','2025-07-12 10:00:00'),
('ORD-013','PAT-014','PRE-016','2025-07-25 17:00:00','Cancelled','Home Delivery','67 Sector 18, Noida','Noida','201301',520.00,0.00,40.00,560.00,'2025-07-28',NULL,'2025-07-26 09:00:00'),
('ORD-014','PAT-015','PRE-017','2025-08-05 12:00:00','Processing','Home Delivery','3 Park Street, Kolkata','Kolkata','700016',200.00,20.00,40.00,220.00,'2025-08-08',NULL,'2025-08-06 10:00:00'),
('ORD-015','PAT-003','PRE-018','2025-08-20 13:00:00','Delivered','Store Pickup','Apollo Pharmacy Hazratganj','Lucknow','226001',45.00,4.50,0.00,40.50,'2025-08-21',DATE'2025-08-20','2025-08-20 18:00:00'),
('ORD-016','PAT-006','PRE-019','2025-09-10 12:00:00','Shipped','Home Delivery','12 Anna Nagar, Chennai','Chennai','600040',890.00,89.00,0.00,801.00,'2025-09-13',NULL,'2025-09-11 09:00:00'),
('ORD-017','PAT-013','PRE-020','2025-10-20 11:00:00','Placed','Home Delivery','22 MG Road, Trivandrum','Trivandrum','695001',380.00,38.00,40.00,382.00,'2025-10-23',NULL,'2025-10-20 11:00:00'),
('ORD-018','PAT-001','PRE-002','2025-01-15 12:00:00','Delivered','Home Delivery','42 MG Road, Mumbai','Mumbai','400001',280.00,28.00,0.00,252.00,'2025-01-18',DATE'2025-01-17','2025-01-17 14:00:00');

-- =============================================================
-- 8. INSERT PAYMENTS DATA (18 rows)
-- =============================================================

INSERT INTO HEALTHCARE_DW.RAW.PAYMENTS VALUES
('PAY-001','ORD-001','PAT-001','2025-01-15 12:05:00',355.00,'UPI','Success','UPI-TXN-10001','CLM-001',200.00,155.00,'2025-01-15 12:05:00'),
('PAY-002','ORD-002','PAT-002','2025-01-20 13:10:00',490.00,'Credit Card','Success','CC-TXN-10002','CLM-002',300.00,190.00,'2025-01-20 13:10:00'),
('PAY-003','ORD-003','PAT-003','2025-02-05 11:05:00',108.00,'Cash','Success','CASH-10003',NULL,0.00,108.00,'2025-02-05 11:05:00'),
('PAY-004','ORD-004','PAT-004','2025-02-18 16:10:00',652.00,'UPI','Success','UPI-TXN-10004','CLM-004',400.00,252.00,'2025-02-18 16:10:00'),
('PAY-005','ORD-005','PAT-005','2025-03-01 12:05:00',238.00,'Debit Card','Success','DC-TXN-10005','CLM-005',100.00,138.00,'2025-03-01 12:05:00'),
('PAY-006','ORD-006','PAT-006','2025-03-15 13:10:00',162.00,'UPI','Success','UPI-TXN-10006',NULL,0.00,162.00,'2025-03-15 13:10:00'),
('PAY-007','ORD-007','PAT-007','2025-04-02 11:10:00',990.00,'Credit Card','Success','CC-TXN-10007','CLM-007',600.00,390.00,'2025-04-02 11:10:00'),
('PAY-008','ORD-008','PAT-008','2025-04-20 12:05:00',76.50,'Cash','Success','CASH-10008',NULL,0.00,76.50,'2025-04-20 12:05:00'),
('PAY-009','ORD-009','PAT-009','2025-05-10 14:10:00',688.00,'UPI','Success','UPI-TXN-10009','CLM-009',450.00,238.00,'2025-05-10 14:10:00'),
('PAY-010','ORD-010','PAT-010','2025-05-25 10:10:00',175.00,'UPI','Success','UPI-TXN-10010',NULL,0.00,175.00,'2025-05-25 10:10:00'),
('PAY-011','ORD-011','PAT-011','2025-06-28 16:10:00',125.50,'Debit Card','Success','DC-TXN-10011','CLM-011',50.00,75.50,'2025-06-28 16:10:00'),
('PAY-012','ORD-012','PAT-012','2025-07-10 11:10:00',100.00,'UPI','Success','UPI-TXN-10012',NULL,0.00,100.00,'2025-07-10 11:10:00'),
('PAY-013','ORD-013','PAT-014','2025-07-25 17:05:00',560.00,'Credit Card','Refunded','CC-TXN-10013','CLM-013',350.00,210.00,'2025-07-25 17:05:00'),
('PAY-014','ORD-014','PAT-015','2025-08-05 12:10:00',220.00,'UPI','Pending','UPI-TXN-10014','CLM-014',100.00,120.00,'2025-08-05 12:10:00'),
('PAY-015','ORD-015','PAT-003','2025-08-20 13:05:00',40.50,'Cash','Success','CASH-10015',NULL,0.00,40.50,'2025-08-20 13:05:00'),
('PAY-016','ORD-016','PAT-006','2025-09-10 12:10:00',801.00,'Net Banking','Success','NB-TXN-10016','CLM-016',500.00,301.00,'2025-09-10 12:10:00'),
('PAY-017','ORD-017','PAT-013','2025-10-20 11:05:00',382.00,'UPI','Pending','UPI-TXN-10017','CLM-017',200.00,182.00,'2025-10-20 11:05:00'),
('PAY-018','ORD-018','PAT-001','2025-01-15 12:05:00',252.00,'UPI','Success','UPI-TXN-10018','CLM-018',150.00,102.00,'2025-01-15 12:05:00');

-- =============================================================
-- VERIFY DATA
-- =============================================================

SELECT 'PATIENTS' AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DW.RAW.PATIENTS
UNION ALL
SELECT 'DOCTORS', COUNT(*) FROM HEALTHCARE_DW.RAW.DOCTORS
UNION ALL
SELECT 'CONSULTATIONS', COUNT(*) FROM HEALTHCARE_DW.RAW.CONSULTATIONS
UNION ALL
SELECT 'PRESCRIPTIONS', COUNT(*) FROM HEALTHCARE_DW.RAW.PRESCRIPTIONS
UNION ALL
SELECT 'ORDERS', COUNT(*) FROM HEALTHCARE_DW.RAW.ORDERS
UNION ALL
SELECT 'PAYMENTS', COUNT(*) FROM HEALTHCARE_DW.RAW.PAYMENTS;
