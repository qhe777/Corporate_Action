WITH q AS   ( SELECT *, ROW_Number() OVER (PARTITION BY Action_ID, Current_Ticker ORDER BY Last_Updated_Date, Recording_Date) AS RowNumber
 	FROM [ciqdata].[dbo].[Corp_Action]
 	Where (Effective_Date>=Recording_Date or Effective_Date is Null)
 	)
SELECT * FROM q
  where RowNumber==1
 
