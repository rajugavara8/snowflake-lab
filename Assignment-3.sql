create database satyatest;

create schema satyatest.training;

create or replace table patient 
(
patientid int,
name string,
gender string,
address string,
region string
);

insert into patient values (101, 'patienta', 'M', 'asia pacific', 'ASIA');
insert into patient values (102, 'patientb', 'F', 'asia pacific', 'ASIA');
insert into patient values (103, 'patientc', 'M', 'usa', 'USA');
insert into patient values (104, 'patientd', 'U', 'usa', 'USA');
insert into patient values (105, 'patiente', 'M', 'usa', 'USA');
insert into patient values (106, 'patientf', 'F', 'INDIA', 'INDIA');

select * from patient;

-- ROW ACCESS POLICY
CREATE or replace ROW ACCESS POLICY region_policy AS
(region STRING, address STRING) RETURNS BOOLEAN ->
region = address;

-- apply row access policy to the table
ALTER TABLE Patient ADD ROW ACCESS POLICY region_policy ON (region,address);

SELECT * FROM Patient;
106	patientf	F	INDIA	INDIA


-- Creating patientrecord table
CREATE OR REPLACE TABLE PatientRecords (
    PatientID INT,
    Name STRING,
    Diagnosis STRING,
    AdmissionDate DATE
);

--Insert statements
INSERT INTO PatientRecords VALUES (1, 'Alice', 'Flu', '2024-11-01');
INSERT INTO PatientRecords VALUES (2, 'Bob', 'Cold', '2024-11-02');
INSERT INTO PatientRecords VALUES (3, 'Charlie', 'Asthma', '2024-11-03');

select * from patientrecords;
1	Alice	  Flu	   2024-11-01
2	Bob	      Cold	   2024-11-02
3	Charlie	  Asthma   2024-11-03

--Update statement
UPDATE PatientRecords
SET Diagnosis = 'Pneumonia'
WHERE PatientID = 1;

--Clone the Table Using Time Travel
CREATE OR REPLACE TABLE PatientRecordsClone
CLONE PatientRecords
AT (OFFSET => -30);

SELECT * FROM PatientRecordsClone;
1	Alice	   Flu	     2024-11-01
2	Bob	      Cold	     2024-11-02
3	Charlie	  Asthma	 2024-11-03

SELECT * FROM PatientRecords;
1	Alice	    Pneumonia	2024-11-01
2	Bob	        Cold	    2024-11-02
3	Charlie	    Asthma	    2024-11-03

SELECT * FROM PatientRecordsClone BEFORE(STATEMENT => '01b8e1dd-0002-3aa1-0000-0006f50ab0f9');