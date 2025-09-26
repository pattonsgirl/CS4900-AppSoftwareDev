USE Mr_Fix_It;

-- Building
--
DROP TABLE IF EXISTS Mr_Fix_It.Building;

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


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Building;
