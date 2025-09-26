USE Mr_Fix_It;

-- Room_Type_Lk
--
DROP TABLE IF EXISTS Mr_Fix_It.Room_Type_Lk;

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


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Room_Type_Lk;
