/* Creating a Database for HealthyLife Hospitals */
CREATE DATABASE HealthyLife_Hospital;

--Using The DataBase
Use HealthyLife_Hospital

--********************************************************************************************************--
/* Creating Patient Table*/
CREATE TABLE Patients(
	PatientID INT Primary key,
	ForeName VARCHAR(50),
	SurName VARCHAR(50),
	DateOfBirth DATE,
	Gender VARCHAR(10),
	PostCode VARCHAR(20)
);

/* Inserting into Patient Table */

-- Declare ForeNames
DECLARE @ForeNames TABLE (Name VARCHAR(50));
INSERT INTO @ForeNames (Name) VALUES 
('John'), ('Mary'), ('Ayo'), ('Chinyere'), ('James'),
('Grace'), ('Samuel'), ('Amaka'), ('Daniel'), ('Zainab'),
('Ifeanyi'), ('Fatima'), ('Olivia'), ('Michael'), ('Ngozi'),
('Ahmed'), ('Esther'), ('Emeka'), ('Sophia'), ('David');

-- Declare SurNames
DECLARE @SurNames TABLE (Name VARCHAR(50));
INSERT INTO @SurNames (Name) VALUES 
('Okafor'), ('Johnson'), ('Smith'), ('Brown'), ('Ola'),
('Williams'), ('Ngige'), ('Ibrahim'), ('Anderson'), ('Nwosu'),
('Bello'), ('Aliyu'), ('Adeyemi'), ('Taylor'), ('Umeh'),
('Thomas'), ('Adams'), ('Garba'), ('Eze'), ('George');

-- Loop to insert random patients
DECLARE @counter INT = 1;               -- Loop control for number of patients to insert
DECLARE @ForeName VARCHAR(50);          -- Randomly selected first name from name pool
DECLARE @SurName VARCHAR(50);           -- Randomly selected surname from name pool

WHILE @counter <= 100
BEGIN
    -- Pick random forename
    SELECT TOP 1 @ForeName = Name 
    FROM @ForeNames
    ORDER BY NEWID();

    -- Pick random surname
    SELECT TOP 1 @SurName = Name 
    FROM @SurNames 
    ORDER BY NEWID();

    -- Insert into Patients
    INSERT INTO Patients(PatientID, Forename, Surname, DateOfBirth, Gender, Postcode)
    VALUES (
        @counter,
        @ForeName,
        @SurName,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 15000), GETDATE()), -- Random DOB
        CASE WHEN @counter % 2 = 0 THEN 'Male' ELSE 'Female' END,
        CONCAT('PC', RIGHT('000' + CAST(@counter AS VARCHAR), 3))
    );

    SET @counter = @counter + 1;
END;

/* Adding GPCode to the Patients table */
ALTER TABLE Patients
ADD GPCode VARCHAR(10);

/* Updating the patients table with random GP assignments*/

-- Creating a temporary list of GPs with row numbers
WITH RandomGPs AS (
    SELECT 
        GPCode,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNum
    FROM GP
),
PatientsWithRowNum AS (
    SELECT 
        PatientID,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNum
    FROM Patients
)
-- Join by row number to randomly assign a GP to each patient
UPDATE p
SET GPCode = r.GPCode
FROM Patients p
JOIN PatientsWithRowNum pw ON p.PatientID = pw.PatientID
JOIN RandomGPs r ON pw.RowNum % (SELECT COUNT(*) FROM GP) + 1 = r.RowNum;

/*confirming the spread*/
SELECT GPCode, COUNT(*) AS NumPatients
FROM Patients
GROUP BY GPCode
ORDER BY NumPatients DESC;

SELECT * FROM Patients

-- *********************************************************************************************************--

/* Creating Specialty Table */
CREATE TABLE Specialty(
	SpecialtyCode VARCHAR(10) PRIMARY KEY,
	SpecialtyName VARCHAR(100)
);

/* Inserting Into Specialty table */
INSERT INTO Specialty (SpecialtyCode, SpecialtyName)
VALUES ('CARD', 'Cardiology'),
	   ('NEUR', 'Neurology'),
	   ('PED', 'Pediatrics'),
	   ('GEN', 'General Medicine'),
	   ('SURG', 'Surgery');

-- **********************************************************************************************************--

/* Craeting Ward Table */
CREATE TABLE Ward(
	WardCode VARCHAR(10) PRIMARY KEY,
	WardName VARCHAR(50),
	WardType VARCHAR(100)
);

/* Inserting Into Ward table */
INSERT INTO Ward (WardCode, WardName, WardType) 
VALUES ('W01', 'Blue Ward', 'General'),
	   ('W02', 'Red Ward', 'ICU'),
	   ('W03', 'Green Ward', 'Maternity'),
	   ('W04', 'Orange Ward', 'Endoscopy Suite'),
	   ('W05', 'Purple Ward', 'Emergency');

--***********************************************************************************************************--
/* Creating Table for Method Of Admission */
CREATE TABLE MethodOfAdmission(
	MethodOfAdmissionCode VARCHAR(10) PRIMARY KEY,
	MethodOfAdmissiontype VARCHAR(50)
);

/* Inserting into MethodOfAdmission Table*/
INSERT INTO MethodOfAdmission (MethodOfAdmissionCode, MethodOfAdmissionType) 
VALUES ('EMR', 'Emergency'),
	   ('ELC', 'Elective'),
	   ('GP', 'GP Referral');

--***********************************************************************************************************--

/* Creating Table For GPPractice*/
CREATE TABLE GPPractice(
	GPPracticeCode VARCHAR(10) PRIMARY KEY,
	PracticeName VARCHAR(50),
	PracticePostCode VARCHAR(20)
);

/* Inserting into GPPractice Table */
INSERT INTO GPPractice (GPPracticeCode, PracticeName, PracticePostcode) 
VALUES ('P001', 'Lifeline Family Clinic', 'AB12 3CD'),
	   ('P002', 'Bright Health Centre', 'CD45 6EF'),
	   ('P003', 'Harmony Medical Practice', 'GH78 9IJ'),
	   ('P004', 'CityCare Clinic', 'KL10 2MN'),
	   ('P005', 'HealthBridge Practice', 'OP34 5QR');

--***********************************************************************************************************--

/* Creating Table for Gp */
CREATE TABLE GP(
	GPCode VARCHAR(10) PRIMARY KEY,
	GPName VARCHAR(50),
	GPPracticeCode VARCHAR(10) FOREIGN KEY (GPPracticeCode) REFERENCES GPPractice(GPPracticeCode)
);

/* Inserting Into The GP Table */
INSERT INTO GP (GPCode, GPName, GPPracticeCode) 
VALUES ('GP001', 'Dr. Jane Smith', 'P001'),
	   ('GP002', 'Dr. Ayo Johnson', 'P005'),
	   ('GP003', 'Dr. Chinyere Okeke', 'P003'),
	   ('GP004', 'Dr. Emeka Umeh', 'P001'),
	   ('GP005', 'Dr. Sarah George', 'P004'),
   	   ('GP006', 'Dr. Ahmed Bello', 'P002'),
	   ('GP007', 'Dr. Olivia Adeyemi', 'P002'),
	   ('GP008', 'Dr. James Nwosu', 'P004'),
	   ('GP009', 'Dr. Esther Ibrahim', 'P005'),
	   ('GP010', 'Dr. Michael Eze', 'P003');

--***********************************************************************************************************--

/* Creating Admission Table */
CREATE TABLE Admission(
	AdmissionID INT PRIMARY KEY,
	PatientID INT FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
	AdmissionDate DATE,
	DischargeDate DATE,
	SpecialtyCode VARCHAR(10) FOREIGN KEY (SpecialtyCode) REFERENCES Specialty(SpecialtyCode),
	WardCode VARCHAR(10) FOREIGN KEY (WardCode) REFERENCES Ward(WardCode),
	MethodOfAdmissionCode VARCHAR(10) FOREIGN KEY (MethodOfAdmissionCode) REFERENCES MethodOfAdmission(MethodOfAdmissionCode)
);

/* Inserting Into Admission Table */

-- Declare variables used for generating random admissions.
DECLARE @counter INT = 1;                          -- Loop control
DECLARE @PatientID INT;                            -- Foreign key to Patient
DECLARE @SpecialtyCode VARCHAR(10);                -- FK to Specialty
DECLARE @WardCode VARCHAR(10);                     -- FK to Ward
DECLARE @MethodOfAdmissionCode VARCHAR(10);        -- FK to MethodOfAdmission
DECLARE @AdmissionDate DATE;                       -- Randomized admission date
DECLARE @DischargeDate DATE;                       -- Discharge date

WHILE @counter <= 100
BEGIN
    -- Random Patient ID between 1 and 100
    SET @PatientID = FLOOR(RAND() * 100) + 1;

    -- Random SpecialtyCode
    SELECT TOP 1 @SpecialtyCode = SpecialtyCode FROM Specialty ORDER BY NEWID();

    -- Random WardCode
    SELECT TOP 1 @WardCode = WardCode FROM Ward ORDER BY NEWID();

    -- Random MethodOfAdmissionCode
    SELECT TOP 1 @MethodOfAdmissionCode = MethodOfAdmissionCode FROM MethodOfAdmission ORDER BY NEWID();

    -- Random Admission and Discharge Date
    SET @AdmissionDate = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 365), GETDATE());
    SET @DischargeDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 14, @AdmissionDate);  -- stay of up to 2 weeks

    -- Insert into tblAdmission
    INSERT INTO Admission (
        AdmissionID, PatientID, AdmissionDate, DischargeDate,
        SpecialtyCode, WardCode, MethodOfAdmissionCode
    )
    VALUES (
        1000 + @counter,
        @PatientID,
        @AdmissionDate,
        @DischargeDate,
        @SpecialtyCode,
        @WardCode,
        @MethodOfAdmissionCode
    );

    SET @counter = @counter + 1;
END;

--***********************************************************************************************************--

/* Creating Table for Diagnosis */
CREATE TABLE Diagnosis(
	DiagnosisCode VARCHAR(10) PRIMARY KEY,
	DiagnosisDescription VARCHAR(300),
	AdmissionID INT FOREIGN KEY (AdmissionID) REFERENCES Admission(AdmissionID)
);

/* Inserting Into Diagnosis Table*/

-- Declare variables used for generating random diagnosis.
DECLARE @counter INT = 1;                      -- Loop control for number of diagnoses to insert
DECLARE @DiagnosisCode VARCHAR(10);            -- Unique code for each diagnosis (e.g., D001)
DECLARE @DiagnosisDescription VARCHAR(100);    -- Description of the diagnosis (e.g., 'Asthma')
DECLARE @AdmissionID INT;                      -- Foreign key reference to Admission table

WHILE @counter <= 100
BEGIN
    -- Generate DiagnosisCode
    SET @DiagnosisCode = 'D' + RIGHT('000' + CAST(@counter AS VARCHAR), 3);

    -- Rotate diagnosis descriptions
    SET @DiagnosisDescription = CASE @counter % 10
        WHEN 0 THEN 'Hypertension'
        WHEN 1 THEN 'Asthma'
        WHEN 2 THEN 'Diabetes'
        WHEN 3 THEN 'Pneumonia'
        WHEN 4 THEN 'Migraine'
        WHEN 5 THEN 'Appendicitis'
        WHEN 6 THEN 'Malaria'
        WHEN 7 THEN 'Fracture'
        WHEN 8 THEN 'Stroke'
        ELSE 'Ulcer'
    END;

    -- AdmissionID from 1001 to 1100
    SET @AdmissionID = 1000 + @counter;

    -- Insert into Diagnosis table
    INSERT INTO Diagnosis (DiagnosisCode, DiagnosisDescription, AdmissionID)
    VALUES (@DiagnosisCode, @DiagnosisDescription, @AdmissionID);

    SET @counter = @counter + 1;
END;

--***********************************************************************************************************--
/*Patient and Admission Details*/

/*Patients details*/
SELECT 
    PatientID,
    CONCAT(ForeName,' ', SurName) AS FullName,
    Gender,
    DateOfBirth,
    PostCode
FROM Patients;

/*Total number of admissions per patient*/
SELECT 
    p.PatientID,
    p.ForeName + ' ' + p.SurName AS FullName,
    ISNULL(COUNT(a.AdmissionID), 0) AS TotalAdmissions
FROM Patients p
LEFT JOIN Admission a ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.ForeName, p.SurName
ORDER BY TotalAdmissions DESC;

/* Admission Analysis */

/*Maximum Length of Stay (2023/24) for Elective Admissions to Endoscopy Suite*/
SELECT 
    ISNULL(MAX(DATEDIFF(DAY, AdmissionDate, DischargeDate)), 0) AS MaxLengthOfStay
FROM Admission a
JOIN Ward w ON a.WardCode = w.WardCode
JOIN MethodOfAdmission m ON a.MethodOfAdmissionCode = m.MethodOfAdmissionCode
WHERE 
    DischargeDate BETWEEN '2023-04-01' AND '2024-03-31'
    AND w.WardType = 'Endoscopy Suite'
    AND m.MethodOfAdmissionType = 'Elective';

/*Total Admissions by Ward (2015/16)*/
SELECT 
    w.WardName,
    COUNT(*) AS TotalAdmissions
FROM Admission a
JOIN Ward w ON a.WardCode = w.WardCode
WHERE 
    DischargeDate BETWEEN '2023-04-01' AND '2025-03-31'
GROUP BY w.WardName
ORDER BY TotalAdmissions DESC;

/*GP and Practice Analysis*/

/*Top GP Practice for Admissions via GP Referral (2024/25)*/
SELECT 
    gpp.PracticeName,
    COUNT(*) AS TotalAdmissions
FROM Admission a
JOIN MethodOfAdmission m ON a.MethodOfAdmissionCode = m.MethodOfAdmissionCode
JOIN Patients p ON a.PatientID = p.PatientID
JOIN GP g ON p.GPCode = g.GPCode
JOIN GPPractice gpp ON g.GPPracticeCode = gpp.GPPracticeCode
WHERE 
    a.AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
    AND m.MethodOfAdmissionType = 'GP Referral'
GROUP BY gpp.PracticeName
ORDER BY TotalAdmissions DESC;

/*Readmission pattern*/

/*Patients who were readmitted via Emergency within 7 days of an Elective discharge*/
SELECT
    a1.PatientID,
    a1.AdmissionID AS FirstAdmissionID,
    a1.DischargeDate AS FirstDischargeDate,
    m1.MethodOfAdmissionType AS FirstAdmissionMethod,
    a1.SpecialtyCode AS FirstSpecialtyCode,
    a2.AdmissionID AS SecondAdmissionID,
    a2.AdmissionDate AS SecondAdmissionDate,
    m2.MethodOfAdmissionType AS SecondAdmissionMethod,
    a2.SpecialtyCode AS SecondSpecialtyCode,
    DATEDIFF(DAY, a1.DischargeDate, a2.AdmissionDate) AS DaysBetween
FROM Admission a1
JOIN Admission a2 ON a1.PatientID = a2.PatientID AND a1.AdmissionID <> a2.AdmissionID
JOIN MethodOfAdmission m1 ON a1.MethodOfAdmissionCode = m1.MethodOfAdmissionCode
JOIN MethodOfAdmission m2 ON a2.MethodOfAdmissionCode = m2.MethodOfAdmissionCode
-- include emergency readmissions within 7 days
WHERE 
    a2.AdmissionDate > a1.DischargeDate
    AND DATEDIFF(DAY, a1.DischargeDate, a2.AdmissionDate) <= 7
    AND m1.MethodOfAdmissionType = 'Elective'
    AND m2.MethodOfAdmissionType = 'Emergency'
    AND a1.SpecialtyCode = a2.SpecialtyCode;

/*Patients with more than 1 Admission (2024/26) */
SELECT PatientID
FROM Admission
WHERE AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
GROUP BY PatientID
HAVING COUNT(*) > 1;

/*Average Length of Stay by Ward (2024/25) */
SELECT 
    WardCode,
    AVG(DATEDIFF(DAY, AdmissionDate, DischargeDate)) AS AvgLengthOfStay
FROM Admission
WHERE AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
GROUP BY WardCode;

/*Top 5 Specialties by Admission Volume (2024/25)*/
SELECT 
    SpecialtyCode,
    COUNT(*) AS NumAdmissions
FROM Admission
WHERE AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
GROUP BY SpecialtyCode
ORDER BY NumAdmissions DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

/*GP with Most Patients Admitted (2024/25)*/
SELECT 
    g.GPName,
    COUNT(DISTINCT a.PatientID) AS NumPatientsAdmitted
FROM Admission a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN GP g ON p.GPCode = g.GPCode
WHERE a.AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
GROUP BY g.GPName
ORDER BY NumPatientsAdmitted DESC;

/*Patients Admitted to ICU and Their Diagnoses*/
SELECT 
    p.PatientID,
    p.ForeName + ' ' + p.SurName AS FullName,
    a.AdmissionID,
    w.WardName,
    d.DiagnosisDescription
FROM Admission a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Ward w ON a.WardCode = w.WardCode
JOIN Diagnosis d ON a.AdmissionID = d.AdmissionID
WHERE w.WardType = 'ICU';




SELECT * FROM Patients
SELECT * FROM Specialty
SELECT * FROM Ward
SELECT * FROM MethodOfAdmission
SELECT * FROM GPPractice
SELECT * FROM GP

SELECT * FROM Admission
SELECT * FROM Diagnosis

SELECT TOP 10 * FROM Admission ORDER BY AdmissionDate DESC;
SELECT TOP 10 * FROM Diagnosis ORDER BY DiagnosisCode;

