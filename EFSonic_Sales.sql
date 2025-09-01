declare @Language int =1,@ParFromDate datetime='2023-01-01',@PartoDate datetime='2023-10-01'

SELECT O.OrganizationCode as 'كود التوكيل',OL.Description [التوكيل] 
,STUFF((SELECT  ','+CustomerGroupLanguage.Description FROM dbo.CustomerGroupLanguage WHERE GroupID 
IN (SELECT GroupID FROM dbo.CustomerOutletGroup WHERE C.CustomerID=CustomerOutletGroup.CustomerID AND CO.OutletID=CustomerOutletGroup.OutletID 
and CustomerGroupLanguage.LanguageID=@Language )FOR XML PATH('') ),1,1,'') as 'قطاع البيع'
,CL.Description [اسم العميل ], C.CustomerCode[كود العميل ],COL.Description [فرع العميل  ], CO.CustomerCode [ كود الفرع],T.TransactionID [رقم الفاتورة ],
EL.Description AS [اسم المندوب], E.EmployeeCode AS [كود المندوب] ,
T.TransactionDate [تاريخ الفتورة ],BL.Description as 'براند',ML.Description as 'موديل',ICL.Description as [مجموعة اصناف],I.ItemCode as [كود الصنف],IL.Description [الصنف] 
,sum(CASE WHEN T.TransactionTypeID =2 THEN (TD.Quantity*P.Quantity/q1.Quantity )*-1 else (TD.Quantity*P.Quantity/q1.Quantity ) end ) as 'الكمية',
 sum(CASE WHEN T .TransactionTypeID = 2 then CONVERT(DECIMAL(19,3),TD.Price*TD.Quantity)*-1 ELSE CONVERT(DECIMAL(19,3),(TD.Price*TD.Quantity)) END )AS   [السعر]
 ,sum (CASE WHEN T .TransactionTypeID =2 then CONVERT(DECIMAL(19,3),td.Discount) 
 ELSE CONVERT(DECIMAL(19,3),TD.Discount-TD.AllItemDiscount) * -1 END) AS  [  خصم الصنف]
,sum(CASE WHEN T.TransactionTypeID =2 THEN CONVERT(DECIMAL(19,3),TD.AllItemDiscount) ELSE CONVERT(DECIMAL(19,3),TD.AllItemDiscount) *-1 END) AS  [خصم الفاتورة],
sum(CASE WHEN T.TransactionTypeID =2 THEN  (TD.Quantity*td.Price)*-1 ELSE (TD.Quantity*td.Price) END)  AS 'الاجمالى',
sum(CASE WHEN T.TransactionTypeID = 2 THEN CONVERT(DECIMAL(19,3),TD.Tax)*-1 ELSE CONVERT(DECIMAL(19,3),TD.Tax) END) AS [الضريبة],
sum(CASE WHEN T.TransactionTypeID =2 THEN  CONVERT(DECIMAL(19,3),TD.NetTotal)*-1 ELSE CONVERT(DECIMAL(19,3),TD.NetTotal) END) AS  [صافى الصنف ]

FROM dbo.[Transaction] T WITH(NOLOCK)
INNER JOIN dbo.TransactionDetail TD WITH(NOLOCK) ON T.TransactionID = TD.TransactionID AND T.CustomerID = TD.CustomerID AND T.OutletID = TD.OutletID
INNER JOIN dbo.CustomerOutlet CO WITH(NOLOCK) ON T.CustomerID = CO.CustomerID AND T.OutletID = CO.OutletID
LEFT OUTER JOIN dbo.CustomerOutletLanguage COL WITH(NOLOCK) ON CO.CustomerID = COL.CustomerID AND CO.OutletID = COL.OutletID AND COL.LanguageID=@Language
INNER JOIN dbo.Customer C WITH(NOLOCK) ON T.CustomerID = C.CustomerID
LEFT OUTER JOIN dbo.CustomerLanguage CL WITH(NOLOCK) ON C.CustomerID = CL.CustomerID AND CL.LanguageID=@Language
INNER JOIN Organization O ON T.OrganizationID=O.OrganizationID
LEFT OUTER JOIN dbo.OrganizationLanguage OL WITH(NOLOCK) ON T.OrganizationID = OL.OrganizationID AND OL.LanguageID=@Language
INNER JOIN dbo.Pack P ON TD.PackID = P.PackID
INNER JOIN dbo.ItemLanguage IL ON P.ItemID = IL.ItemID AND IL.LanguageID=@Language
inner join Item I on P.ItemID=I.ItemID
LEFT OUTER JOIN dbo.PackTypeLanguage PTL WITH(NOLOCK) ON P.PackTypeID = PTL.PackTypeID AND PTL.LanguageID=@Language
INNER JOIN dbo.Employee E ON t.EmployeeID = E.EmployeeID
LEFT  JOIN dbo.EmployeeLanguage EL ON E.EmployeeID = EL.EmployeeID AND EL.LanguageID = @Language
left join ItemCategoryLanguage ICL on I.ItemCategoryID=ICL.ItemCategoryID and ICL.LanguageID=@Language
left join BrandLanguage BL on I.BrandID=BL.BrandID and BL.LanguageID=@Language
left join ModelLanguage ML on I.ModelID=ML.ModelID and ML.LanguageID=@Language
inner join (SELECT P.ItemID,P.PackID,P.Quantity,ROW_NUMBER() OVER (PARTITION BY P.ItemID ORDER BY P.ItemID,P.Quantity DESC) Qty_Rank ,P.PackTypeID
FROM dbo.Pack P )q1 on q1.ItemID=i.itemid and q1.Qty_Rank=1

WHERE T.Voided=0 AND T.TransactionTypeID IN (1,2)  and T.TransactionDate >=@ParFromDate and T.TransactionDate < dateadd (day,1,@ParToDate) 

group by O.OrganizationCode,OL.Description,C.CustomerID,CO.OutletID,CL.Description,C.CustomerCode,COL.Description,CO.CustomerCode,T.TransactionID
,EL.Description,E.EmployeeCode,T.TransactionDate,BL.Description,ML.Description,ICL.Description,I.ItemCode,IL.Description,t.CustomerID,t.OutletID,p.PackID,T.TransactionTypeID,TD.BatchNo,P.Quantity

order by TransactionDate