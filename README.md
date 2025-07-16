# HealthyLife Hospital SQL Database

![SQL](https://img.shields.io/badge/SQL-Database-blue)
![Status](https://img.shields.io/badge/Project-Mock%20Dataset-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A structured SQL database project designed to simulate daily operations in a hospital. This includes patient admissions, diagnoses, general practitioners (GPs), specialties, wards, and methods of admission. It also demonstrates analytical SQL queries for hospital management insights.

## Project objectives

- Record and track patient admissions.
- Capture diagnoses linked to admissions.
- Associate patients with General Practitioners (GPs) and their clinics.
- Support insights on hospital utilization, diagnoses, and referral patterns.

## Database Schema Overview

**Database Name:** `HealthyLife_Hospital`

### The database consists of the following main tables:

| Table              | Description                                      |
|--------------------|--------------------------------------------------|
| Patients           | Stores patient demographic information.          |
| Specialty          | Lists available medical specialties.             |
| Ward               | Contains ward details and types.                 |
| MethodOfAdmission  | Ways patients are admitted (e.g., Emergency).    |
| GPPractice         | Details of GP practices.                         |
| GP                 | General practitioners linked to GP practices.    |
| Admission          | Hospital admissions records.                     |
| Diagnosis          | Diagnoses linked to specific admissions.         |

Each table is populated with mock data to simulate real-world hospital data flow.
All schemas and data setup are available in the [`HealthyLife Hospital.sql`](HealthyLife%20Hospitals.sql) file.

## Mock Data Highlights

- **Patients**: 100 randomly generated records with alternating genders, randomized DOBs and postcodes.
- **GPs & Practices**: 10 GPs linked to 5 manually created GP practices.
- **Admissions & Diagnoses**: 100 randomized hospital admission records with linked diagnosis data.

## SQL Analysis & Queries
This project includes SQL queries that provide key operational insights. Below are some highlights:

### GP and Practice Analysis
> Identify the GP practice with the highest number of referrals in FY 2024/25.

```sql
SELECT gpp.PracticeName, COUNT(*) AS TotalAdmissions
FROM Admission a
JOIN MethodOfAdmission m ON a.MethodOfAdmissionCode = m.MethodOfAdmissionCode
JOIN Patients p ON a.PatientID = p.PatientID
JOIN GP g ON p.GPCode = g.GPCode
JOIN GPPractice gpp ON g.GPPracticeCode = gpp.GPPracticeCode
WHERE a.AdmissionDate BETWEEN '2024-04-01' AND '2025-03-31'
  AND m.MethodOfAdmissionType = 'GP Referral'
GROUP BY gpp.PracticeName
ORDER BY TotalAdmissions DESC;
```

## Readmission Pattern (Within 7 Days). 
> Track emergency readmissions occurring within 7 days of elective discharge, under the same specialty.

```sql
SELECT
    a1.PatientID, a1.AdmissionID AS FirstAdmissionID, a1.DischargeDate AS FirstDischargeDate,
    m1.MethodOfAdmissionType AS FirstAdmissionMethod, a1.SpecialtyCode AS FirstSpecialtyCode,
    a2.AdmissionID AS SecondAdmissionID, a2.AdmissionDate AS SecondAdmissionDate,
    m2.MethodOfAdmissionType AS SecondAdmissionMethod, a2.SpecialtyCode AS SecondSpecialtyCode,
    DATEDIFF(DAY, a1.DischargeDate, a2.AdmissionDate) AS DaysBetween
FROM Admission a1
JOIN Admission a2 ON a1.PatientID = a2.PatientID AND a1.AdmissionID <> a2.AdmissionID
JOIN MethodOfAdmission m1 ON a1.MethodOfAdmissionCode = m1.MethodOfAdmissionCode
JOIN MethodOfAdmission m2 ON a2.MethodOfAdmissionCode = m2.MethodOfAdmissionCode
WHERE a2.AdmissionDate > a1.DischargeDate
  AND DATEDIFF(DAY, a1.DischargeDate, a2.AdmissionDate) <= 7
  AND m1.MethodOfAdmissionType = 'Elective'
  AND m2.MethodOfAdmissionType = 'Emergency'
  AND a1.SpecialtyCode = a2.SpecialtyCode;
```
## Additional Queries Include:
- Top 5 Specialties by Admission Volume
- ICU Admissions and Diagnosis Overview
- Patients with Multiple Admissions
- Average Length of Stay by Ward
- GPs with Most Admitted Patients
All queries are written with performance and real-world logic in mind.

## Tech Stack

- **Database**: SQL Server (T-SQL syntax)
- **Tools Used**: SSMS (SQL Server Management Studio)
- **Language**: SQL
