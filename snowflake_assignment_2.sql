create database if not exists inovalon;

-- source table for stream 
create table inovalon.satya.Staging_PatientRecords(
  patientid int,
  name varchar(50),
  age int,
  disease varchar(40)
);

-- target table for task 
create table inovalon.satya.Final_PatientRecords(
  patientid int,
  name varchar(50),
  age int,
  disease varchar(40)
);

-- create a stream to track changes on source table 
create stream inovalon.satya.Staging_PatientRecords_Updates on table inovalon.satya.Staging_PatientRecords;
select * from inovalon.satya.Staging_PatientRecords_Updates;  -- empty initially 

-- create task to pull data from stream for every 2 minutes based on new inserts into stream 
create task inovalon.satya.patientRecords_updates_task 
 warehouse = 'COMPUTE_WH'
 schedule='2 MINUTE'
 when SYSTEM$STREAM_HAS_DATA('Staging_PatientRecords_Updates')
 AS
  insert into inovalon.satya.Final_PatientRecords 
   select PATIENTID, NAME, AGE, DISEASE from inovalon.satya.Staging_PatientRecords_Updates
   where METADATA$ACTION='INSERT';
 
-- AFTER ENABLING TASK , insert 3 records into Staging_PatientRecords table 
INSERT INTO inovalon.satya.Staging_PatientRecords VALUES (101, 'test1', 10, 'FEVER');
INSERT INTO inovalon.satya.Staging_PatientRecords VALUES (102, 'test2', 20, 'COLD');
INSERT INTO inovalon.satya.Staging_PatientRecords VALUES (103, 'test', 30, 'COUGH');

SELECT * FROM Final_PatientRecords;  -- initially table is empty

-- after 2 minutes, once task ran
select * from inovalon.satya.Final_PatientRecords;  -- got 3 records into Final_PatientRecords from Staging_PatientRecords_Updates stream

-- TASK 2 

create table inovalon.satya.PatientRecords (
   patientid int,
   name varchar,
   age int,
   disease varchar,
   admissiondate Date 
);
insert into inovalon.satya.PatientRecords values (201, 'srini', 50, 'fever', CURRENT_DATE);
insert into inovalon.satya.PatientRecords values (202, 'hari', 60, 'cold', DATEADD(DAY, -7, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (203, 'kiran', 50, 'cough', DATEADD(DAY, -10, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (204, 'santhi', 30, 'fever', DATEADD(DAY, -4, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (205, 'raju', 40, 'cold', DATEADD(DAY, -15, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (206, 'rani', 60, 'cough', DATEADD(MONTH, -2, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (207, 'keerthi', 80, 'cold', DATEADD(MONTH, -7, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (208, 'sravya', 90, 'fever', DATEADD(YEAR, -1, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (209, 'charan', 30, 'cold', DATEADD(YEAR, -2, CURRENT_DATE()));
insert into inovalon.satya.PatientRecords values (210, 'ram', 60, 'cough', DATEADD(DAY, -1, CURRENT_DATE()));

-- before applying cluster on admissiondate
select * from inovalon.satya.PatientRecords where Year(admissiondate) between 2023 and 2024;  -- 114ms

-- applying cluster on admissiondate column of PatientRecords table 
alter table inovalon.satya.PatientRecords cluster by (admissiondate);
-- querying cluster information on table 
SELECT SYSTEM$CLUSTERING_INFORMATION('PatientRecords', 'admissiondate');
-- results of above query
{
  "cluster_by_keys" : "LINEAR(admissiondate)",
  "total_partition_count" : 1,
  "total_constant_partition_count" : 0,
  "average_overlaps" : 0.0,
  "average_depth" : 1.0,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 1,
    "00002" : 0,
    "00003" : 0,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0
  },
  "clustering_errors" : [ ]
}

-- after applying cluster 
select * from inovalon.satya.PatientRecords where Year(admissiondate) between 2023 and 2024;  --31ms
select * from inovalon.satya.PatientRecords where Year(admissiondate) between 2023 and 2024;  -- 19ms
