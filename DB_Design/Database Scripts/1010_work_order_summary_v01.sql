USE Mr_Fix_It;

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
