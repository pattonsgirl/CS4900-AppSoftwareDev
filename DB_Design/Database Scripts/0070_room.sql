USE Mr_Fix_It;

-- Room
--
DROP TABLE IF EXISTS Mr_Fix_It.Room;

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


-- Verify table and data
SELECT *
FROM Mr_Fix_It.Room;
