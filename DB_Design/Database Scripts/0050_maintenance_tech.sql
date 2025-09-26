USE Mr_Fix_It;

-- Maintenance_Tech
--
DROP TABLE IF EXISTS Mr_Fix_It.Maintenance_Tech;

-- Create Table
CREATE TABLE Maintenance_Tech
(
  Technician_Code        CHAR(6)      NOT NULL  COMMENT 'Technician Code'
 ,Technician_First_Name  VARCHAR(30)            COMMENT 'Technician First Name'
 ,Technician_Last_Name   VARCHAR(30)  NOT NULL  COMMENT 'Technician Last Name'

 ,PRIMARY KEY(Technician_Code)
)
COMMENT = 'Maintenance Technician'
;

ALTER TABLE Maintenance_Tech
 ADD CONSTRAINT Maintenance_Tech_Code_Uk01
 UNIQUE (Technician_Code)
;


-- Insert data
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('JSMITH', 'John',     'Smith' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('RJONES', 'Robert',   'Jones' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('MJOHNS', 'Michael',  'Johnson' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('PMILLE', 'Patricia', 'Miller' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('MDAVIS', 'Mary',     'Davis' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('JWILLI', 'Jessica',  'Williams' );


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Maintenance_Tech;
