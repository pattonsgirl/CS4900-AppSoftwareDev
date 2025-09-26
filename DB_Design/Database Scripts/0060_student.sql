USE Mr_Fix_It;

-- Student
--
DROP TABLE IF EXISTS Mr_Fix_It.Student;

-- Create Table
CREATE TABLE Student
(
  Student_ID         INTEGER(11)   NOT NULL  AUTO_INCREMENT               COMMENT 'PK for Student'
 ,Email_Address      VARCHAR(200)  NOT NULL                               COMMENT 'Email Address'
 ,First_Name         VARCHAR(20)   NOT NULL                               COMMENT 'First Name'
 ,Last_Name          VARCHAR(25)   NOT NULL                               COMMENT 'Last Name'
 ,Phone_Number       VARCHAR(10)   NOT NULL                               COMMENT 'Phone Number'
 ,Last_Login         DATETIME                                             COMMENT 'Last Login'
 ,Active             TINYINT(1)    NOT NULL                               COMMENT 'Active'
 ,Date_Added         DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated  DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY(Student_ID)
)
COMMENT = 'Student'
;

ALTER TABLE Student
 ADD CONSTRAINT Student_Email_Uk01
 UNIQUE (Email_Address)
;


-- Insert data
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('pjones@mrfixit.edu',     'Peter',   'Jones',     '9375551111', null,                  1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('dchen@mrfixit.edu',      'David',   'Chen',      '9375552222', null,                  1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('mrodriguez@mrfixit.edu', 'Maria',   'Rodriguez', '9375553333', null,                  1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('mbrown@mrfixit.edu',     'Michael', 'Brown',     '9375554444', null,                  1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('smiller@mrfixit.edu',    'Sarah',   'Miller',    '9375555555', '2025-08-14 08:00:00', 1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('jdavis@mrfixit.edu',     'Jessica', 'Davis',     '9375556666', '2025-08-14 08:00:00', 1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('cwilson@mrfixit.edu',    'Chris',   'Wilson',    '9375557777', '2025-08-14 08:00:00', 1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('agarcia@mrfixit.edu',    'Ashley',  'Garcia',    '9375558888', '2025-08-14 08:00:00', 1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('jlee@mrfixit.edu',       'James',   'Lee',       '9375559999', '2025-08-14 08:00:00', 1 );
INSERT INTO Mr_Fix_It.Student (Email_Address, First_Name, Last_Name, Phone_Number, Last_Login, Active) VALUES ('nwhite@mrfixit.edu',     'Nicole',  'White',     '9375550000', '2025-08-14 08:00:00', 1 );


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Student;
