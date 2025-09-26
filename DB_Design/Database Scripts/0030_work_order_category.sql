USE Mr_Fix_It;

-- Work_Order_Category
--
DROP TABLE IF EXISTS Mr_Fix_It.Work_Order_Category;

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


-- Insert data
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('PLMB', 'Plumbing',            1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('ELCT', 'Electrical',          1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('HVC',  'Hvac',                1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('CRPN', 'Carpentry',           1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('PNT',  'Painting',            1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('INT',  'Internet Access',     1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('GEN',  'General Maintenance', 1 );
INSERT INTO Mr_Fix_It.Work_Order_Category (Work_Order_Category_Code, Work_Order_Category_Description, Active) VALUES ('OTH',  'Other',               1 );


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Work_Order_Category;
