--Create scripts--
---Insurance---
CREATE TABLE dbo.Insurance
( 
InsuranceID INT IDENTITY(1,1) CONSTRAINT PK_Insurance PRIMARY KEY CLUSTERED NOT NULL,
InsuranceType NVARCHAR(50) NOT NULL,
Company NVARCHAR(50) NOT NULL,
Cover INT CHECK (Cover>50000),
);

GO

---Payment---
CREATE TABLE dbo.Payment
( 
PaymentID INT IDENTITY(1,1) CONSTRAINT PK_Payment PRIMARY KEY CLUSTERED NOT NULL,
InsuranceID INT NOT NULL CONSTRAINT FK_Payment_Insurance_InsuranceID FOREIGN KEY REFERENCES dbo.Insurance (InsuranceID),
PaymentType NVARCHAR(50) NOT NULL,
PaymentMethod NVARCHAR(50) NOT NULL,
PaymentStatus INT CHECK (PaymentStatus=0 or PaymentStatus=1),	
);
GO

---Patient---
CREATE TABLE dbo.Patient
( 
PatientID INT IDENTITY(1,1) CONSTRAINT PK_Patient PRIMARY KEY CLUSTERED NOT NULL,
InsuranceID INT NOT NULL CONSTRAINT FK_Patient_Insurance_InsuranceID FOREIGN KEY REFERENCES dbo.Insurance (InsuranceID),
Name NVARCHAR(50) NOT NULL,
DOB DATE NOT NULL,
Gender NVARCHAR(50) check(Gender in ('Male', 'Female', 'Others')),
Address NVARCHAR(50) NOT NULL,
City NVARCHAR(50) NOT NULL,
[State] NVARCHAR(50) NOT NULL,
Country NVARCHAR(50) NOT NULL,
ZipCode INT NOT NULL,
EmergencyContact NVARCHAR(50) NOT NULL,
Age AS (year(CURRENT_TIMESTAMP) - year(DOB))
);

GO


-- Operation Suite --
CREATE TABLE dbo.OperationSuite(
OperationSuiteID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OperationSuite PRIMARY KEY,
Type [nvarchar] (255) NOT NULL,
Status [nvarchar] (255) NOT NULL,
RoomID INT NOT NULL,
CONSTRAINT FK_OpSuiteRoomID FOREIGN KEY (RoomID)
REFERENCES PatientRoom(RoomID),
);
GO

-- Patient Room --
CREATE TABLE dbo.PatientRoom(
RoomID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PatientRoom PRIMARY KEY,
RoomType [nvarchar] (255) NOT NULL,
PatientRoomStatus [nvarchar] (255) NOT NULL,
);
GO

---InPatient---
CREATE TABLE dbo.InPatient
( 
PatientID INT CONSTRAINT PK_InPatient PRIMARY KEY CLUSTERED NOT NULL,
RoomID INT NOT NULL CONSTRAINT FK_InPatient_PatientRoom_RoomID FOREIGN KEY REFERENCES dbo.PatientRoom (RoomID),
Date_Admission Date NOT NULL,
Date_Discharge Date,
Foreign Key (PatientID) References Patient(PatientID)
);

GO

---OutPatient---
CREATE TABLE dbo.OutPatient
( 
PatientID INT CONSTRAINT PK_OutPatient PRIMARY KEY CLUSTERED NOT NULL,
Foreign Key (PatientID) References Patient(PatientID)
);

GO

--Doc--
CREATE TABLE dbo.Doctor(
DoctorID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Doctor PRIMARY KEY,
Name [nvarchar] (255) NOT NULL,
Gender [nvarchar] (50) NOT NULL check(Gender in ('Male', 'Female', 'Others')),
Address [nvarchar] (255) NOT NULL,
City [nvarchar] (255) NOT NULL,
State [nvarchar] (255) NOT NULL,
Country [nvarchar] (255) NOT NULL,
Specialization [nvarchar] (255) NOT NULL,
ZipCode [nvarchar] (50) NOT NULL,
DOB DATE NOT NULL,
Age AS (year(CURRENT_TIMESTAMP) - year(DOB)),
);
GO


---Appointment---
CREATE TABLE dbo.Appointment
( 
AppointmentID INT Identity(1,1) CONSTRAINT PK_Appointment	 PRIMARY KEY CLUSTERED NOT NULL,
DoctorID INT NOT NULL CONSTRAINT FK_Appointment_Doctor_DoctorID FOREIGN KEY REFERENCES dbo.Doctor (DoctorID),
PatientID INT NOT NULL CONSTRAINT FK_Appointment_Patient_PatientID FOREIGN KEY REFERENCES dbo.Patient (PatientID),
TimeFrom TIME NOT NULL,
TimeTo TIME NOT NULL,
DateofAppointment DATE NOT NULL
);

GO


-- MediStaff --
CREATE TABLE dbo.MedicalStaff(
StaffID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MediStaff PRIMARY KEY,
Name [nvarchar] (255) NOT NULL,
Gender [nvarchar] (50) NOT NULL check(Gender in ('Male', 'Female', 'Others')),
Address [nvarchar] (255) NOT NULL,
City [nvarchar] (255) NOT NULL,
State [nvarchar] (255) NOT NULL,
Country [nvarchar] (255) NOT NULL,
Level INT NOT NULL check(Level in (1, 2, 3)),
ZipCode [nvarchar] (50) NOT NULL,
DoctorID INT,
CONSTRAINT FK_MediStaffDoc FOREIGN KEY (DoctorID)
REFERENCES Doctor(DoctorID),
DOB DATE NOT NULL,
Age AS (year(CURRENT_TIMESTAMP) - year(DOB)),
);
GO


-- StockManagement --
CREATE TABLE dbo.StockManagement(
StockManagementID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_StockManagement PRIMARY KEY,
EquipmentID INT NOT NULL,
StaffID INT NOT NULL,
CONSTRAINT FK_StockManagementEquip FOREIGN KEY (EquipmentID)
REFERENCES Inventory(EquipmentID),
CONSTRAINT FK_StockManagementStaff FOREIGN KEY (StaffID)
REFERENCES MedicalStaff(StaffID),
);
GO

-- Inventory --
CREATE TABLE dbo.Inventory(
EquipmentID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Inventory PRIMARY KEY,
EquipmentName [nvarchar] (250) NOT NULL,
InventoryStatus [nvarchar] (50) NOT NULL check(InventoryStatus in ('Sufficient', 'Ordered', 'To be Ordered')),
);
GO

-- Diagnosis --
CREATE TABLE dbo.Diagnosis(
DiagnosisID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Diagnosis PRIMARY KEY,
DiagnosisType [nvarchar] (250) NOT NULL,
Result [nvarchar] (250) NOT NULL check(Result in ('Positive', 'Negative', 'Inconclusive')),
);
GO

-- TestResult --
CREATE TABLE dbo.TestResult(
TestID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TestResult PRIMARY KEY,
BloodType [nvarchar] (250) NOT NULL,
Haemoglobin [nvarchar] (250) NOT NULL,
WBC [nvarchar] (250) NOT NULL,
RBC [nvarchar] (250) NOT NULL,
PatientID INT Not Null,
Cholesterol [nvarchar] (250) NOT NULL,
DiagnosisID INT CONSTRAINT FK_TestDiagnosis FOREIGN KEY (DiagnosisID)
REFERENCES Diagnosis(DiagnosisID),
CONSTRAINT FK_TestResultPatient FOREIGN KEY (PatientID)
REFERENCES Patient(PatientID),
);
GO
	
/* Doctor */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Doctor')BEGIN
DELETE FROM dbo.Doctor;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Insurance',RESEED,0);
GO



-- Insert in Insurance --
INSERT INTO Insurance
(InsuranceType,Company,Cover)
VALUES
('Self','AIG',200000),
('Employee','Google',100000),
('Self','AIG',65000),
('Employee','Samsung',120000),
('Self','AFI',600000),
('Self','LIC',240000),
('Employee','Oracle',70000),
('Employee','Amazon',150000),
('Employee','Microsoft',110000),
('Self','AIG',55000)

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Payment',RESEED,0);
GO


-- Insert Into Payment --
INSERT INTO Payment
(InsuranceID,PaymentType,PaymentMethod,PaymentStatus)
VALUES
(4,'Full','Wire-Transfer',1),
(8,'Full','Cheque',1),
(3,'Partial','Wire-Transfer',0),
(1,'Full','Online',0),
(7,'Partial','Online',0),
(2,'Full','Cheque',1),
(5,'Full','Wire-Transfer',1),
(6,'Full','Online',1),
(10,'Partial','Cheque',0),
(9,'Full','Online',1)


--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Patient',RESEED,0);
GO

---Insert into Patient--
INSERT INTO Patient
(InsuranceID,Name,DOB,Gender,Address,City,State,Country,ZipCode,EmergencyContact)
VALUES
(4,'Rajeev Michael','1983-06-08','Male','4464 10th Avenue','Seattle','WA','USA',93820,'+19821901984'),
(8,'Rachel Singh','1989-04-11','Female','4444 115th Avenue','Seattle','WA','USA',83392,'srishti@gmail.com'),
(3,'Surya Raymond','1963-02-01','Male','6454 11th Avenue','Santa Clara','CA','USA',39230,'+13898390284'),
(1,'Justin Michael','1993-08-02','Male','7324 84th Avenue','Seattle','WA','USA',45821,'+15839249293'),
(7,'Emily Bajet','1959-04-07','Female','6392 66th Avenue','Portland','OR','USA',12930,'chrisjames@gmail.com'),
(2,'James Oliver','1955-12-03','Male','2931 34th Avenue','Portland','OR','USA',12930,'+13293839048'),
(5,'Shai Lily','1990-05-12','Female','8934 123th Avenue','Las Vegas','NV','USA',29473,'jackshield@gmail.com'),
(6,'January Lee','1951-03-01','Female','1193 54th Avenue','Seattle','WA','USA',98105,'clintjosh@gmail.com'),
(10,'Spider Lawrence','1973-01-01','Male','7428 69th Avenue','Seattle','WA','USA',46900,'+17863545409'),
(9,'Jake Paul','1997-01-13','Male','2893 Venice Beach','Los Angeles','CA','USA',57890,'+19393990201')


--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Doctor',RESEED,0);
GO

Select* FROM OutPatient


-- Insert in Doctor --
INSERT INTO Doctor(Name, Gender, Address, City, State, Country, Specialization, ZipCode, DOB)
VALUES
    ('Tushar Saxena', 'Male','1209 Andrew Apt 2','Seattle','WA','USA','Physician', 87311, '1973-12-17'),
    ('Natasha Sinha', 'Female','106 Goss Apt 8','San Francisco','CA','USA','Pediatrician', 63311, '1962-09-16'),
	('Virag Doshi', 'Male','709 Stuart Apt 2', 'Palo Alto','CA','USA','Surgeon', 98107, '1983-11-13'),
	('Nick Ethan', 'Male','764 23rd St Unit 8', 'Sunnyville','CA','USA','Surgeon', 48344, '1977-10-23'),
	('Samantha Jones', 'Female','78 56th St Apt 7', 'Seattle','WA','USA','Psychiatrist', 67468, '1991-01-09'),
	('Richard Struman','Male','1769 78th St', 'Seattle','WA','USA','Cardiologist', 74873, '1983-11-29'),
	('Karla Hudson', 'Female','Unknown', 'Seattle','WA','USA','Dermatologist', 75899, '1955-07-13'),
	('Robbie Ray', 'Male','Unknown', 'Seattle','WA','USA','Physician', 76899, '1987-06-07'),
	('Martha Stewart', 'Female','6851 Apt 6', 'Los Angeles','CA','USA','Physician', 67698, '1988-05-19'),
	('Matt Gupta','Male','6987 Wallace St', 'Los Angeles','CA','USA','Gynecologist ', 67868, '1979-04-26')
	


/* Medical Staff */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'MedicalStaff')BEGIN
DELETE FROM dbo.MedicalStaff;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.MedicalStaff',RESEED,0);
GO

-- Insert in MedicalStaff --
INSERT INTO MedicalStaff(Name, Gender, Address, City, State, Country, Level, ZipCode, DoctorID, DOB)
VALUES
    ('Ash Saxena', 'Male','120 Hitt Apt 2','Seattle','WA','USA',1, 87311,1, '1973-12-17'),
    ('Bruce Sinha', 'Female','106 Goss Apt 8','San Francisco','CA','USA',1, 63311,2, '1962-09-16'),
	('Naman Doshi', 'Male','788 Stuart Apt 2', 'Palo Alto','CA','USA',1, 98107,3, '1983-11-13'),
	('Venkatesh Ethan', 'Male','7902 23rd St Unit 8', 'Sunnyville','CA','USA',2, 48344,4, '1977-10-23'),
	('Priya Jones', 'Female','478 56th St Apt 7', 'Seattle','WA','USA',2, 67468,5, '1991-01-09'),
	('James Struman','Male','768 78th St', 'Seattle','WA','USA',2, 74873,6, '1983-11-29'),
	('katherine Hudson', 'Female','Unknown', 'Seattle','WA','USA',2, 75899,7, '1955-07-13'),
	('Sean Ray', 'Male','Unknown', 'Seattle','WA','USA',3, 27081,8, '1987-06-07'),
	('Sam H', 'Male','Unknown', 'Seattle','WA','USA',3, 37191,9, '1987-12-17'),
	('Anna Henry', 'Female','Unknown', 'Seattle','WA','USA',3, 64391,10, '1985-06-18'),
	('Maple Freeman', 'Female','6851 Apt 6', 'Seattle','WA','USA',3, 16381,2, '1985-11-27'),
	('Beth Johnson', 'Female','Unknown', 'Seattle','WA','USA',3, 16308,2, '1990-06-26'),
	('Gloria Flyn', 'Female','6987 Wallace St', 'Seattle','WA','USA',3, 15379,8, '1989-06-17')
	;


/* Inventory */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Inventory')BEGIN
DELETE FROM dbo.Inventory;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Inventory',RESEED,0);
GO

	-- Insert in Inventory --
INSERT INTO Inventory(EquipmentName, InventoryStatus)
VALUES
    ('Stretcher','Ordered'),
    ('Defibrillator', 'Ordered'),
	('Anesthesia Machine', 'Ordered'),
	('Patient Monitor', 'Sufficient'),
	('Sterilizer', 'Sufficient'),
	('EKG', 'Sufficient'),
	('EGC', 'Sufficient'),
	('Surgical Table', 'Sufficient'),
	('Blanket', 'Sufficient'),
	('Fluid Warmer', 'Ordered'),
	('Oxygen tank', 'To be Ordered'),
	('Insulin pump', 'To be Ordered'),
	('Traction equipment', 'To be Ordered')
	;


/* StockManagement */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StockManagement')BEGIN
DELETE FROM dbo.StockManagement;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.StockManagement',RESEED,0);
GO

-- Inserting in StockManagement --
INSERT INTO dbo.StockManagement(EquipmentID, StaffID)
VALUES
    (1,13),
    (2, 13),
	(3, 13),
	(4, 9),
	(5, 12),
	(6, 12),
	(7, 12),
	(8, 11),
	(9, 11),
	(10, 11),
	(11, 10),
	(12, 10),
	(13, 8)
	;



/* Diagnosis */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Diagnosis')BEGIN
DELETE FROM dbo.Diagnosis;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.Diagnosis',RESEED,0);
GO

		-- Insert in Diagnosis --
INSERT INTO Diagnosis(DiagnosisType, Result)
VALUES
    ('Malaria','Negative'),
    ('Dengue', 'Negative'),
	('Tuberculosis', 'Negative'),
	('Cancer', 'Sufficient'),
	('Stroke', 'Negative'),
	('Flu', 'Positive'),
	('CAD', 'Inconclusive'),
	('Flu', 'Positive'),
	('Flu', 'Positive'),
	('Malaria', 'Negative');

/* Test Result */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TestResult')BEGIN
DELETE FROM dbo.TestResult;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.TestResult',RESEED,0);
GO

--Inserting into TestResult--
INSERT INTO TestResult(BloodType, Haemoglobin, WBC, RBC, PatientID, Cholesterol, DiagnosisID)
VALUES
    ('O negative','Normal', 'Normal', 'Normal',1,'Normal', 1),
    ('O positive', 'High','Normal', 'Normal',2, 'High', 2),
	('A negative', 'Low','Normal', 'Normal',3, 'High', 3),
	('A positive', 'Normal','Normal', 'Normal',4, 'Normal', 4),
	('O negative', 'Normal', 'Low', 'Low',5, 'High', 5),
	('O positive', 'Normal', 'Low', 'Low',6, 'Low', 6),
	('AB negative', 'Low','Normal', 'Normal',7, 'High', 7),
	('AB positive', 'Normal','Normal', 'Normal',8, 'Low', 8),
	('A positive', 'Low','Normal', 'Normal',9, 'Normal', 9),
	('A positive', 'Low','Normal', 'Normal',10, 'Normal', 10)
	;

/* Patient Room */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PatientRoom')BEGIN
DELETE FROM dbo.PatientRoom;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.PatientRoom',RESEED,0);
GO

-- Insert in PatientRoom --
INSERT INTO PatientRoom(RoomType, PatientRoomStatus)
VALUES
    ('Patient Room','Occupied'),
    ('Patient Room', 'Occupied'),
	('Patient Room', 'Occupied'),
	('Patient Room', 'Occupied'),
	('Patient Room', 'Occupied'),
	('Patient Room', 'Empty'),
	('Patient Room', 'Empty'),
	('Opertaion Suite', 'Available'),
	('Opertaion Suite', 'Available'),
	('Opertaion Suite', 'Available')
	;

	--Insert in InPatient--
INSERT INTO InPatient
(PatientID,RoomID,Date_Admission,Date_Discharge)
VALUES
(10,1,'2020-03-05',NULL),
(3,8,'2020-01-28','2020-02-21'),
(7,1,'2019-11-04','2019-12-17')

--Insert in OutPatient--
INSERT INTO OutPatient
(PatientID)
VALUES
(1),
(2),
(4),
(5),
(6),
(8),
(9)
 -- Reseeding Key--
DBCC CHECKIDENT('dbo.Appointment',RESEED,1);
GO

--- Insert into Appt---
INSERT INTO Appointment
(DoctorID,PatientID,TimeFrom,TimeTo,DateofAppointment)
VALUES
(1,2,'12:30:00','13:30:00','2019-03-06'),
(2,1,'10:30:00','11:30:00','2020-03-06'),
(3,8,'15:30:00','19:30:00','2019-11-23'),
(4,6,'09:30:00','14:30:00','2019-12-01'),
(5,1,'08:30:00','10:30:00','2020-01-31'),
(6,6,'10:30:00','12:30:00','2020-02-20'),
(7,8,'15:30:00','17:30:00','2019-02-20'),
(8,4,'10:30:00','11:30:00','2020-01-15'),
(9,9,'14:30:00','16:30:00','2020-01-13'),
(10,5,'14:30:00','16:30:00','2020-01-13'),
(5,2,'09:30:00','10:30:00','2020-02-02')

/* Operation Suite */
IF EXISTS (
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'OperationSuite')BEGIN
DELETE FROM dbo.OperationSuite;
END
GO

--Reseeding Identity Key--
DBCC CHECKIDENT('dbo.OperationSuite',RESEED,0);
GO

-- Insert in OperationSuite--
INSERT INTO OperationSuite(Type, Status, RoomID)
VALUES
    ('Operation Theatre','Available',8),
    ('ICU', 'Available',9),
	('Consulting Room', 'Available',10)
	;


	-- Views --
CREATE VIEW [Room Availability] AS
SELECT RoomID, RoomType, PatientRoomStatus
FROM PatientRoom
WHERE PatientRoomStatus = 'Empty'

CREATE VIEW [Staff Availability] AS
SELECT max(StaffID) AS StaffID, max(Name) AS [Staff Name], count(DoctorID) AS [Doctor Assignment]
FROM MedicalStaff
group by DoctorID
having count(DoctorID) < 1

CREATE VIEW Payment_Info
AS
(SELECT Company,PaymentStatus 
FROM Payment p LEFT JOIN Insurance i 
ON p.InsuranceID=i.InsuranceID)


--PS--
--This file is not re-runnable and the Database Name is Hospital_Management_System