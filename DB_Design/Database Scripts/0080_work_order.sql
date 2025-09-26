USE Mr_Fix_It;

-- Work_Order
--
DROP TABLE IF EXISTS Mr_Fix_It.Work_Order;

-- Create Table
CREATE TABLE Work_Order
(
  Work_Order_Number       INTEGER(11)   NOT NULL  AUTO_INCREMENT               COMMENT 'Work Order Number'
 ,Student_ID              INTEGER(11)   NOT NULL                               COMMENT 'Customer ID'
 ,Building_ID             INTEGER(11)   NOT NULL                               COMMENT 'FK to Room'
 ,Room_Number             VARCHAR(25)   NOT NULL                               COMMENT 'FK to Room'
 ,Work_Order_Category_ID  INTEGER(11)   NOT NULL                               COMMENT 'FK to Work Order Category'
 ,Work_Order_Status_Code  VARCHAR(15)   NOT NULL                               COMMENT 'FK to Work Order Status'
 ,Title                   VARCHAR(100)  NOT NULL                               COMMENT 'Title'
 ,Description             VARCHAR(300)  NOT NULL                               COMMENT 'Description'
 ,Date_Requested          DATE          NOT NULL                               COMMENT 'Date Ordered'
 ,Technician_Code         CHAR(6)                                              COMMENT 'Technician Code'
 ,Appointment_Scheduled   DATETIME                                             COMMENT 'Date Time Scheduled'
 ,Appointment_Completed   DATETIME                                             COMMENT 'Date Time Completed'
 ,Completion_Notes        VARCHAR(700)                                         COMMENT 'Completion Notes'
 ,Date_Added              DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated       DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                                  ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY(Work_Order_Number)
)
COMMENT = 'Work Order'
;

ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Student_Fk01
 FOREIGN KEY (Student_ID)
 REFERENCES Student (Student_ID)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;

ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Room_Fk02
 FOREIGN KEY (Building_ID, Room_Number)
 REFERENCES Room (Building_ID, Room_Number)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;

ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Work_Order_Category_Fk03
 FOREIGN KEY (Work_Order_Category_ID)
 REFERENCES Work_Order_Category (Work_Order_Category_ID)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;

ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Work_Order_Status_Fk04
 FOREIGN KEY (Work_Order_Status_Code)
 REFERENCES Work_Order_Status (Work_Order_Status_Code)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;

ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Technician_Fk05
 FOREIGN KEY (Technician_Code)
 REFERENCES Maintenance_Tech (Technician_Code)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;


-- Insert data
INSERT INTO Mr_Fix_It.Work_Order
(
  Student_ID
 ,Building_ID
 ,Room_Number
 ,Work_Order_Category_ID
 ,Work_Order_Status_Code
 ,Title
 ,Description
 ,Date_Requested
 ,Technician_Code
 ,Appointment_Scheduled
 ,Appointment_Completed
 ,Completion_Notes
)
VALUES
 (
  5
 ,10
 ,'302'
 ,7
 ,'CMPLTD'
 ,'Light bulb not working'
 ,'The light bulb above the mirror is not working'
 ,'2024-08-11'
 ,'PMILLE'
 ,'2024-08-12 09:00:00'
 ,'2024-08-12 09:15:00'
 ,'The light bulb was replaced'
 )
,
 (
  1
 ,8
 ,'201'
 ,8
 ,'CMPLTD'
 ,'Need help with Internet'
 ,'Student is unable to connect to internet with network cable'
 ,'2024-08-24'
 ,'JSMITH'
 ,'2025-08-25 09:00:00'
 ,'2025-08-25 10:15:00'
 ,'Replaced network cable.'
 )
,
 (
  1
 ,8
 ,'201'
 ,2
 ,'OPN'
 ,'Electrical outlet not working'
 ,'Electrical outlet by the window is not working'
 ,'2025-01-04'
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 )
,
 (
  8
 ,10
 ,'302'
 ,7
 ,'NPRGRS'
 ,'Light bulb not working'
 ,'The light bulb above the mirror is not working'
 ,'2025-08-11'
 ,'PMILLE'
 ,'2025-08-12 09:00:00'
 ,NULL
 ,NULL
 )
;

-- Verify table and data
SELECT *
FROM Mr_Fix_It.Work_Order;
