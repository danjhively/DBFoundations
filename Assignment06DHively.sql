--*************************************************************************--
-- Course: Foundations of Databases & SQL Programming
-- Title: Assignment06
-- Author: Daniel Hively
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-16, Daniel Hively, Created File
-- Github: https://github.com/danjhively/DBFoundations
--**************************************************************************--

/************************************************************************************************/
-- Start of assignment code that creates the database
-- used for the assignment questions
/************************************************************************************************/

Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DHively')
	 Begin 
	  Alter Database [Assignment06DB_DHively] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DHively;
	 End
	Create Database Assignment06DB_DHively;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DHively;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go


/************************************************************************************************/
-- End of assignment code that creates the database
-- used for the assignment questions
/************************************************************************************************/

/********************************* Questions and Answers *******************************************************************/
/*
NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/
/**********************************************************************************************************************/
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/*
-- Checking the select statements that will form the views
Select CategoryID, CategoryName From dbo.Categories;
Go
Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
Go
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
Go
Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
Go
*/


/******************************************   Answer 1   ******************************************/

-- Generates Categories basic view
Create View vCategories 
With Schemabinding
As
	Select CategoryID, CategoryName From dbo.Categories;
Go

-- Generates Products basic view
Create View vProducts 
With Schemabinding
As
	Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
Go

-- Generates Employees basic view
Create View vEmployees 
With Schemabinding
As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
Go

-- Generates Inventories basic view
Create View vInventories 
With Schemabinding
As
	Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
Go

-- Checks the basic views
Select * From vCategories;
Go
Select * From vProducts;
Go
Select * From vEmployees;
Go
Select * From vInventories;
Go




/**********************************************************************************************************************/
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

/******************************************   Answer 2   ******************************************/

-- Denies access to the tables for the public group
Deny Select On Categories to Public;
Go
Deny Select On Products to Public;
Go
Deny Select On Employees to Public;
Go
Deny Select On Inventories to Public;
Go

-- Grants access to the views for the public group
Grant Select On vCategories to Public;
Go
Grant Select On vProducts to Public;
Go
Grant Select On vEmployees to Public;
Go
Grant Select On vInventories to Public;
Go

/**********************************************************************************************************************/
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

/*
-- Starting from Answer 1 of Module 5 we get the following select statement, though modified to target views
Select vCategories.CategoryName, vProducts.ProductName, vProducts.UnitPrice
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Order By vCategories.CategoryName, vProducts.ProductName;
Go
*/

/******************************************   Answer 3   ******************************************/

-- To keep the Order By in the view the Top 100000 is added to the select statement
Create View vProductsByCategories
As
	Select Top 100000 vCategories.CategoryName, vProducts.ProductName, vProducts.UnitPrice
	From vCategories
		Inner Join vProducts
			On vCategories.CategoryID = vProducts.CategoryID
		Order By vCategories.CategoryName, vProducts.ProductName;
Go

-- Checks the view
Select * From vProductsByCategories;
Go



/**********************************************************************************************************************/
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

/*
-- Starting from Answer 2 of Module 5 we get the following select statement, though modified to target views
Select vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Order By vInventories.InventoryDate, vProducts.ProductName, vInventories.Count;
Go

-- Change the ordering around
Select vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Order By vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go
*/

/******************************************   Answer 4   ******************************************/
-- The select is made into a view
Create View vInventoriesByProductsByDates
As
	Select Top 100000 vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
	From vProducts
		Inner Join vInventories
			On vProducts.ProductID = vInventories.ProductID
		Order By vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go

-- Checks the view
Select * From vInventoriesByProductsByDates;
Go

/**********************************************************************************************************************/
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

/*
-- Starting from Answer 3 of Module 5 we get the following select statement, though modified to target views
Select Distinct vInventories.InventoryDate, [EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
From vInventories
	Inner Join vEmployees
		On vInventories.EmployeeID = vEmployees.EmployeeID
	Order By vInventories.InventoryDate;
Go
*/

/******************************************   Answer 5   ******************************************/
-- The select is made into a view
Create View vInventoriesByEmployeesByDates
As
	Select Distinct Top 10000 vInventories.InventoryDate, [EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
	From vInventories
		Inner Join vEmployees
			On vInventories.EmployeeID = vEmployees.EmployeeID
		Order By vInventories.InventoryDate;
Go

-- Checks the view
Select * From vInventoriesByEmployeesByDates;

/**********************************************************************************************************************/
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

/*
-- Starting from Answer 4 of Module 5 we get the following select statement, though modified to target views
Select vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Order By vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go
*/

/******************************************   Answer 6   ******************************************/
-- The select is made into a view
Create View vInventoriesByProductsByCategories
As
	Select Top 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
	From vCategories
		Inner Join vProducts
			On vCategories.CategoryID = vProducts.CategoryID
		Inner Join vInventories
			On vProducts.ProductID = vInventories.ProductID
		Order By vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go

-- Checks the view
Select * From vInventoriesByProductsByCategories;
Go

/**********************************************************************************************************************/
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

/*
-- Starting from Answer 5 of Module 5 we get the following select statement, though modified to target views
Select vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, 
	[EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
		On vInventories.EmployeeID = vEmployees.EmployeeID
	Order By vInventories.InventoryDate, vCategories.CategoryName, vProducts.ProductName, [EmployeeName];
Go
*/

/******************************************   Answer 7   ******************************************/
-- The select is made into a view
Create View vInventoriesByProductsByEmployees
As
	Select Top 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, 
		[EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
	From vCategories
		Inner Join vProducts
			On vCategories.CategoryID = vProducts.CategoryID
		Inner Join vInventories
			On vProducts.ProductID = vInventories.ProductID
		Inner Join vEmployees
			On vInventories.EmployeeID = vEmployees.EmployeeID
		Order By vInventories.InventoryDate, vCategories.CategoryName, vProducts.ProductName, [EmployeeName];
Go

-- Checks the view
Select * From vInventoriesByProductsByEmployees;
Go

/**********************************************************************************************************************/
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

/*
-- Starting from Answer 6 of Module 5 we get the following select statement, though modified to target views
Select vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, 
	[EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
		On vInventories.EmployeeID = vEmployees.EmployeeID
	Where vProducts.ProductID in (Select ProductID From vProducts Where ProductName in ('Chai','Chang'))
	Order By vInventories.InventoryDate, vCategories.CategoryName, vProducts.ProductName;
Go
*/

/******************************************   Answer 8   ******************************************/

-- The select is made into a view
Create View vInventoriesForChaiAndChangByEmployees
As
	Select Top 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, 
		[EmployeeName] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
	From vCategories
		Inner Join vProducts
			On vCategories.CategoryID = vProducts.CategoryID
		Inner Join vInventories
			On vProducts.ProductID = vInventories.ProductID
		Inner Join vEmployees
			On vInventories.EmployeeID = vEmployees.EmployeeID
		Where vProducts.ProductID in (Select ProductID From vProducts Where ProductName in ('Chai','Chang'))
		Order By vInventories.InventoryDate, vCategories.CategoryName, vProducts.ProductName;
Go

-- Checks the view
Select * From vInventoriesForChaiAndChangByEmployees;
Go

/**********************************************************************************************************************/
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

/*
-- Starting from Answer 7 of Module 5 we get the following select statement, though modified to target views
Select [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName, [Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
From vEmployees As E
	Inner Join vEmployees M
		On E.ManagerID = M.EmployeeID
	Order By Manager, Employee;
Go
*/

/******************************************   Answer 9   ******************************************/

-- The select is made into a view
Create View vEmployeesByManager
As
	Select Top 10000 [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName, [Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From vEmployees As E
		Inner Join vEmployees M
			On E.ManagerID = M.EmployeeID
		Order By Manager, Employee;
Go

-- Checks the view
Select * From vEmployeesByManager;
Go

/**********************************************************************************************************************/
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

/*
-- Starting from a basic select from Inventories
Select I.InventoryID, I.InventoryDate, I.EmployeeID, I.ProductID, I.Count 
From vInventories As I;
Go

-- Add in the Employee and Manager names per Question 9 logic, and the other Employees data
Select I.ProductID, I.InventoryID, I.InventoryDate, I.Count, I.EmployeeID, 
	[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName,
	[Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
From vInventories As I
	Inner Join vEmployees E
		On I.EmployeeID = E.EmployeeID
	Inner Join VEmployees M
		On E.ManagerID = M.EmployeeID;
Go

-- Adds in Products data
Select P.CategoryID, I.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, I.EmployeeID, 
	[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName, [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
From vInventories As I
	Inner Join vEmployees E
		On I.EmployeeID = E.EmployeeID
	Inner Join VEmployees M
		On E.ManagerID = M.EmployeeID
	Inner Join vProducts P
		On I.ProductID = P.ProductID;
Go

-- Adds in Categories data
Select P.CategoryID, C.CategoryName, I.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, I.EmployeeID, 
	[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName, [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
From vInventories As I
	Inner Join vEmployees E
		On I.EmployeeID = E.EmployeeID
	Inner Join VEmployees M
		On E.ManagerID = M.EmployeeID
	Inner Join vProducts P
		On I.ProductID = P.ProductID
	Inner Join vCategories C
		On P.CategoryID = C.CategoryID;
Go

-- Include ordering
Select P.CategoryID, C.CategoryName, I.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, I.EmployeeID, 
	[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName, [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
From vInventories As I
	Inner Join vEmployees E
		On I.EmployeeID = E.EmployeeID
	Inner Join VEmployees M
		On E.ManagerID = M.EmployeeID
	Inner Join vProducts P
		On I.ProductID = P.ProductID
	Inner Join vCategories C
		On P.CategoryID = C.CategoryID
	Order By P.CategoryID, I.ProductID, I.InventoryDate;
Go
*/

/******************************************   Answer 10   ******************************************/
-- The select is made into a view
Create View vInventoriesByProductsByCategoriesByEmployees
As
	Select Top 10000 P.CategoryID, C.CategoryName, I.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, I.EmployeeID, 
		[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName, [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
	From vInventories As I
		Inner Join vEmployees E
			On I.EmployeeID = E.EmployeeID
		Inner Join VEmployees M
			On E.ManagerID = M.EmployeeID
		Inner Join vProducts P
			On I.ProductID = P.ProductID
		Inner Join vCategories C
			On P.CategoryID = C.CategoryID
		Order By P.CategoryID, I.ProductID, I.InventoryDate;
Go

-- Checks the view
Select * From vInventoriesByProductsByCategoriesByEmployees;
Go

/**********************************************************************************************************************/

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories];
Go
Select * From [dbo].[vProducts];
Go
Select * From [dbo].[vInventories];
Go
Select * From [dbo].[vEmployees];
Go



Select * From [dbo].[vProductsByCategories];
Go
Select * From [dbo].[vInventoriesByProductsByDates];
Go
Select * From [dbo].[vInventoriesByEmployeesByDates];
Go
Select * From [dbo].[vInventoriesByProductsByCategories];
Go
Select * From [dbo].[vInventoriesByProductsByEmployees];
Go
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees];
Go
Select * From [dbo].[vEmployeesByManager];
Go
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees];
Go

/***************************************************************************************/