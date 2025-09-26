USE Mr_Fix_It;

-- Work_Order_Status
--
DROP TABLE IF EXISTS Mr_Fix_It.Work_Order_Status;

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


-- Insert data
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('OPN',    'Open',        1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('NPRGRS', 'In Progress', 1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('CMPLTD', 'Completed',   1 );
INSERT INTO Mr_Fix_It.Work_Order_Status (Work_Order_Status_Code, Work_Order_Status_Description, Active) VALUES ('CNCLD',  'Cancelled',   1 );


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Work_Order_Status;
