/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[Sheet1]

  /*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set saleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

-- If it doesn't Update properly



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID




Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 Where a.Propertyaddress is null

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
  Where a.Propertyaddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertSplitAddress nvarchar(255);

Update NashvilleHousing
set PropertSplitAddress= Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



select *
From PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing



select
ParseName(Replace(OwnerAddress, ',','.') , 3),
ParseName(Replace(OwnerAddress, ',','.') , 2),
ParseName(Replace(OwnerAddress, ',','.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress= ParseName(Replace(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',','.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = ParseName(Replace(OwnerAddress, ',','.') , 1)

select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field



Select Distinct(soldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldasVacant
order by 2

select soldasvacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set  soldasvacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		legalReference
		order by UniqueID
		) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)


select *
From RowNumCTE
where Row_num > 1 
--order by Propertyaddress

select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, propertyAddress, SaleDate


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate














-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO