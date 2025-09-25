-- create database roles
--
CREATE OR REPLACE ROLE Mr_Fix_It_Views;
GRANT SELECT ON Mr_Fix_It.* TO Mr_Fix_It_Views;

-- create tables and views
--
USE Mr_Fix_It;

-- drop tables in correct reverse order based on referential integrity
--
-- DROP TABLE IF EXISTS Mr_Fix_It.Work_Order;
-- DROP TABLE IF EXISTS Mr_Fix_It.Room;
-- DROP TABLE IF EXISTS Mr_Fix_It.Student;
-- DROP TABLE IF EXISTS Mr_Fix_It.Maintenance_Tech;
-- DROP TABLE IF EXISTS Mr_Fix_It.Work_Order_Status;
-- DROP TABLE IF EXISTS Mr_Fix_It.Work_Order_Category;
-- DROP TABLE IF EXISTS Mr_Fix_It.Room_Type_Lk;
-- DROP TABLE IF EXISTS Mr_Fix_It.Building;


-- Building
--

-- Create Table
CREATE TABLE Building
(
  Building_ID        INTEGER(11)  NOT NULL  AUTO_INCREMENT               COMMENT 'PK for Building'
 ,Name               VARCHAR(50)  NOT NULL                               COMMENT 'Name'
 ,Address            VARCHAR(50)  NOT NULL                               COMMENT 'Address'
 ,City               VARCHAR(50)  NOT NULL                               COMMENT 'City'
 ,State              VARCHAR(2)   NOT NULL                               COMMENT 'State'
 ,Zip                VARCHAR(10)  NOT NULL                               COMMENT 'Zip'
 ,Nbr_Floors         SMALLINT     NOT NULL                               COMMENT 'Number Of Floors'
 ,Total_Rooms        SMALLINT     NOT NULL                               COMMENT 'Total Rooms'
 ,Active             TINYINT(1)   NOT NULL                               COMMENT 'Active'
 ,Date_Added         DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY (Building_ID)
)
COMMENT 'Building'
;
ALTER TABLE Building
 ADD CONSTRAINT Building_Name_Uk01
 UNIQUE (Name)
;
--
-- Insert data
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Community Center',        'University Blvd', 'Dayton', 'OH', '45435', 1, 10,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Joshi Research Center',   'University Blvd', 'Dayton', 'OH', '45435', 2, 10,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Library Annex',           'Loop Rd',         'Dayton', 'OH', '45435', 3, 20,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Rike Hall',               'University Blvd', 'Dayton', 'OH', '45435', 3, 30,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Russ Engineering Center', 'University Blvd', 'Dayton', 'OH', '45435', 4, 60,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Student Union',           'University Blvd', 'Dayton', 'OH', '45435', 3, 60,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Cedar',                   'Village Dr',      'Dayton', 'OH', '45435', 4, 48,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Everglades',              'Zink Rd',         'Dayton', 'OH', '45435', 3, 12,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Hamilton Hall',           'University Blvd', 'Dayton', 'OH', '45435', 4, 200, 1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Honors Hall',             'Zink Rd',         'Dayton', 'OH', '45435', 3, 200, 1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Olympic',                 'Zink Rd',         'Dayton', 'OH', '45435', 3, 60,  1);
INSERT INTO Mr_Fix_It.Building (Name, Address, City, State, Zip, Nbr_Floors, Total_Rooms, Active) VALUES ('Sycamore',                'University Blvd', 'Dayton', 'OH', '45435', 3, 30,  1);


-- Room_Type_Lk
--

-- Create Table
CREATE TABLE Room_Type_Lk
(
  Room_Type_ID           INTEGER(11)   NOT NULL  AUTO_INCREMENT               COMMENT 'PK for Room Type Lookup'
 ,Room_Type_Code         VARCHAR(25)   NOT NULL                               COMMENT 'Room Type Code'
 ,Room_Type_Description  VARCHAR(100)  NOT NULL                               COMMENT 'Room Type Description'
 ,Active                 TINYINT(1)    NOT NULL                               COMMENT 'Active'
 ,Date_Added             DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated      DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY (Room_Type_ID)
)
COMMENT 'Room Type Lookup'
;
ALTER TABLE Room_Type_Lk
 ADD CONSTRAINT Room_Type_Code_Uk01
 UNIQUE (Room_Type_Code)
;
--
-- Insert data
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('BTH',  'Bathroom',        1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('CMN',  'Common Area',     1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('CONF', 'Conference Room', 1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('DRM',  'Dorm Room',       1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('KTCN', 'Kitchen',         1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('LNDR', 'Laundry Room',    1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('LBY',  'Lobby',           1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('MCH',  'Mechanical Room', 1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('MEET', 'Meeting Room',    1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('OFC',  'Office',          1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('OTH',  'Other',           1 );
INSERT INTO Mr_Fix_It.Room_Type_Lk (Room_Type_Code, Room_Type_Description, Active) VALUES ('STDR', 'Study Room',      1 );


-- Work_Order_Category
--

-- Create Table
CREATE TABLE Work_Order_Category
(
  Work_Order_Category_ID           INTEGER(11)   NOT NULL  AUTO_INCREMENT               COMMENT 'PK for Work Order Category'
 ,Work_Order_Category_Code         VARCHAR(25)   NOT NULL                               COMMENT 'Work Order Category Code'
 ,Work_Order_Category_Description  VARCHAR(100)  NOT NULL                               COMMENT 'Work Order Category Description'
 ,Active                           TINYINT(1)    NOT NULL                               COMMENT 'Active'
 ,Date_Added                       DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated                DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                                           ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY (Work_Order_Category_ID)
)
COMMENT 'Work Order Category'
;
ALTER TABLE Work_Order_Category
 ADD CONSTRAINT Work_Order_Category_Code_Uk01
 UNIQUE (Work_Order_Category_Code)
;
--
-- Insert data
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('PLMB', 'Plumbing',            1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('ELCT', 'Electrical',          1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('HVC',  'Hvac',                1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('CRPN', 'Carpentry',           1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('PNT',  'Painting',            1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('INT',  'Internet Access',     1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('GEN',  'General Maintenance', 1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('OTH',  'Other',               1 );


-- Work_Order_Status
--

-- Create Table
CREATE TABLE Work_Order_Status
(
  Work_Order_Status_Code         CHAR(15)     NOT NULL                               COMMENT 'Work Order Status Code'
 ,Work_Order_Status_Description  VARCHAR(50)  NOT NULL                               COMMENT 'Work Order Status Desc'
 ,Active                         TINYINT(1)   NOT NULL                               COMMENT 'Active'
 ,Date_Added                     DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated              DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                                        ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY (Work_Order_Status_Code)
)
COMMENT 'Work Order Status'
;
ALTER TABLE Work_Order_Status
 ADD CONSTRAINT Work_Order_Status_Code_Uk01
 UNIQUE (Work_Order_Status_Code)
;
--
-- Insert data
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('OPN',    'Open',        1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('NPRGRS', 'In Progress', 1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('CMPLTD', 'Completed',   1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('CNCLD',  'Cancelled',   1 );


-- Maintenance_Tech
--

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
--
-- Insert data
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('JSMITH', 'John',     'Smith' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('RJONES', 'Robert',   'Jones' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('MJOHNS', 'Michael',  'Johnson' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('PMILLE', 'Patricia', 'Miller' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('MDAVIS', 'Mary',     'Davis' );
INSERT INTO Mr_Fix_It.Maintenance_Tech (Technician_Code, Technician_First_Name, Technician_Last_Name) VALUES ('JWILLI', 'Jessica',  'Williams' );


-- Student
--

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
--
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


-- Room
--

-- Create Table
CREATE TABLE Room
(
  Building_ID        INTEGER(11)  NOT NULL                               COMMENT 'Composite PK for Room'
 ,Room_Number        VARCHAR(25)  NOT NULL                               COMMENT 'Composite PK for Room'
 ,Room_Type_ID       INT(11)      NOT NULL                               COMMENT 'FK to Room Type Lookup'
 ,Floor_Number       SMALLINT     NOT NULL                               COMMENT 'Floor Number'
 ,Capacity           SMALLINT     NOT NULL                               COMMENT 'Capacity'
 ,Active             TINYINT(1)   NOT NULL                               COMMENT 'Active'
 ,Date_Added         DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP    COMMENT 'Date Added'
 ,Date_Last_Updated  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP  COMMENT 'Date Last Updated'

 ,PRIMARY KEY(Building_ID, Room_Number)
)
COMMENT = 'Room'
;
ALTER TABLE Room
  ADD CONSTRAINT Room_2_Building_Fk01
  FOREIGN KEY (Building_ID)
  REFERENCES Building (Building_ID)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT
;
ALTER TABLE Room
  ADD CONSTRAINT Room_2_Room_Type_Fk01
  FOREIGN KEY (Room_Type_ID)
  REFERENCES Room_Type_Lk (Room_Type_ID)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT
;
-- Buildings
set @community_center_id        = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Community Center');
set @joshi_research_center_id   = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Joshi Research Center');
set @library_annex_id           = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Library Annex');
set @rike_hall_id               = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Rike Hall');
set @russ_engineering_center_id = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Russ Engineering Center');
set @student_union_id           = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Student Union');
set @cedar_id                   = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Cedar');
set @everglades_id              = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Everglades');
set @hamilton_hall_id           = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Hamilton Hall');
set @honors_hall_id             = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Honors Hall');
set @olympic_id                 = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Olympic');
set @sycamore_id                = (SELECT Building_ID FROM Mr_Fix_It.Building WHERE Name = 'Sycamore');
--
-- Room Types
set @bathroom_id        = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Bathroom');
set @common_area_id     = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Common Area');
set @conference_room_id = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Conference Room');
set @dorm_room_id       = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Dorm Room');
set @kitchen_id         = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Kitchen');
set @laundry_room_id    = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Laundry Room');
set @lobby_id           = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Lobby');
set @mechanical_room_id = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Mechanical Room');
set @meeting_room_id    = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Meeting Room');
set @office_id          = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Office');
set @other_id           = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Other');
set @study_room_id      = (SELECT Room_Type_ID FROM Mr_Fix_It.Room_Type_Lk WHERE Room_Type_Description = 'Study Room');
--
-- Insert data
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '101', @meeting_room_id,     1, 200, 1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '105', @kitchen_id,          1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '110', @lobby_id,            1, 50,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '201', @conference_room_id,  2, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '205', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '206', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '210', @study_room_id,       2, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '301', @common_area_id,      3, 75,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@community_center_id,        '310', @other_id,            3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '101', @lobby_id,            1, 30,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '105', @other_id,            1, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '110', @other_id,            1, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '201', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '205', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '210', @study_room_id,       2, 12,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '301', @other_id,            3, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '310', @office_id,           3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@joshi_research_center_id,   '315', @other_id,            3, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '101', @lobby_id,            1, 40,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '105', @study_room_id,       1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '110', @other_id,            1, 30,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '201', @study_room_id,       2, 8,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '205', @study_room_id,       2, 8,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '210', @other_id,            2, 50,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '301', @office_id,           3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '310', @study_room_id,       3, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@library_annex_id,           '315', @bathroom_id,         3, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '101', @lobby_id,            1, 50,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '105', @other_id,            1, 150, 1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '110', @other_id,            1, 40,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '201', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '205', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '210', @other_id,            2, 30,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '301', @office_id,           3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '305', @office_id,           3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '310', @other_id,            3, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@rike_hall_id,               '315', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '101', @lobby_id,            1, 60,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '105', @other_id,            1, 40,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '110', @other_id,            1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '201', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '205', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '210', @other_id,            2, 35,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '301', @other_id,            3, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '305', @office_id,           3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '310', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@russ_engineering_center_id, '315', @other_id,            3, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '101', @lobby_id,            1, 100, 1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '105', @other_id,            1, 300, 1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '110', @kitchen_id,          1, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '115', @bathroom_id,         1, 5,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '201', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '205', @office_id,           2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '210', @common_area_id,      2, 50,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '301', @other_id,            3, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '305', @other_id,            3, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '310', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@student_union_id,           '315', @common_area_id,      3, 40,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '101', @lobby_id,            1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '105', @laundry_room_id,     1, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '110', @common_area_id,      1, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '201', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '202', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '203', @bathroom_id,         2, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '301', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '302', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '303', @bathroom_id,         3, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@cedar_id,                   '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '101', @lobby_id,            1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '105', @kitchen_id,          1, 8,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '110', @study_room_id,       1, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '201', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '202', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '203', @bathroom_id,         2, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '301', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '302', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '303', @bathroom_id,         3, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@everglades_id,              '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '101', @lobby_id,            1, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '105', @laundry_room_id,     1, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '110', @common_area_id,      1, 30,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '201', @dorm_room_id,        2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '202', @dorm_room_id,        2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '203', @bathroom_id,         2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '301', @dorm_room_id,        3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '302', @dorm_room_id,        3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '303', @bathroom_id,         3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@hamilton_hall_id,           '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '101', @lobby_id,            1, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '105', @study_room_id,       1, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '110', @kitchen_id,          1, 8,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '201', @dorm_room_id,        2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '202', @dorm_room_id,        2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '203', @bathroom_id,         2, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '301', @dorm_room_id,        3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '302', @dorm_room_id,        3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '303', @bathroom_id,         3, 1,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@honors_hall_id,             '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '101', @lobby_id,            1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '105', @common_area_id,      1, 25,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '110', @laundry_room_id,     1, 15,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '201', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '202', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '203', @bathroom_id,         2, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '301', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '302', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '303', @bathroom_id,         3, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@olympic_id,                 '305', @mechanical_room_id,  3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '101', @lobby_id,            1, 20,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '105', @study_room_id,       1, 10,  1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '110', @kitchen_id,          1, 8,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '201', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '202', @dorm_room_id,        2, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '203', @bathroom_id,         2, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '301', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '302', @dorm_room_id,        3, 2,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '303', @bathroom_id,         3, 6,   1);
INSERT INTO Mr_Fix_It.Room (Building_ID, Room_Number, Room_Type_ID, Floor_Number, Capacity, Active) Values (@sycamore_id,                '305', @mechanical_room_id,  3, 2,   1);


-- Work_Order
--

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
 ON UPDATE RESTRICT
;
ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Room_Fk02
 FOREIGN KEY (Building_ID, Room_Number)
 REFERENCES Room (Building_ID, Room_Number)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT
;
ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Work_Order_Category_Fk03
 FOREIGN KEY (Work_Order_Category_ID)
 REFERENCES Work_Order_Category (Work_Order_Category_ID)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT
;
ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Work_Order_Status_Fk04
 FOREIGN KEY (Work_Order_Status_Code)
 REFERENCES Work_Order_Status (Work_Order_Status_Code)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT
;
ALTER TABLE Work_Order
 ADD CONSTRAINT Work_Order_2_Technician_Fk05
 FOREIGN KEY (Technician_Code)
 REFERENCES Maintenance_Tech (Technician_Code)
 ON DELETE RESTRICT
 ON UPDATE RESTRICT;
--
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


-- Work_Order_Summary_V01
--
CREATE OR REPLACE DEFINER = Mr_Fix_It_Views VIEW Work_Order_Summary_V01
(
  Total_Orders
 ,Open_Orders
 ,In_Progress_Orders
 ,Completed_Orders
 ,Cancelled_Orders
)
AS
SELECT
  COUNT(*)
 ,COUNT(CASE
          WHEN WO.Work_Order_Status_Code = 'OPN'
            THEN WO.Work_Order_Status_Code
        END
       )
 ,COUNT(CASE
          WHEN WO.Work_Order_Status_Code = 'NPRGRS'
            THEN WO.Work_Order_Status_Code
        END
       )
 ,COUNT(CASE
          WHEN WO.Work_Order_Status_Code = 'CMPLTD'
            THEN WO.Work_Order_Status_Code
        END
       )
 ,COUNT(CASE
          WHEN WO.Work_Order_Status_Code = 'CNCLD'
            THEN WO.Work_Order_Status_Code
        END
       )
  END
FROM Mr_Fix_It.Work_Order WO
;



