/*
Cleaning Data in SQL Queries
*/

USE PortfolioProject




Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date





 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT A.ParcelID, A.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS NEW_PropertyAddress
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <>  B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
ORDER BY A.ParcelID


UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <>  B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


SELECT *
FROM NashvilleHousing
ORDER BY ParcelID






--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT	PropertyAddress, 
		TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1)) AS Address,
		TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 1, CHARINDEX(',', PropertyAddress, 1))) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD NEW_PropertyAddress NVARCHAR(255), NEW_PropertyCity NVARCHAR(255)

-- Splitting PropertyAddress using Substring and CharIndex
UPDATE NashvilleHousing
SET NEW_PropertyAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1)),
	NEW_PropertyCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 1, CHARINDEX(',', PropertyAddress, 1)))

-- Splitting OwnerAddress using 
SELECT OwnerAddress, REPLACE(OwnerAddress, ',', '.'),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD NEW_OwnerAddress NVARCHAR(255), NEW_OwnerCity NVARCHAR(255), NEW_OwnerState NVARCHAR(255)

UPDATE NashvilleHousing
SET NEW_OwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	NEW_OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	NEW_OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * From NashvilleHousing


-- RENAME Column header
EXEC sp_RENAME 'NashvilleHousing.City' , 'NEW_PropertyCity', 'COLUMN';
EXEC sp_RENAME 'NashvilleHousing.Address' , 'NEW_PropertyAddress', 'COLUMN';



SELECT *
FROM NashvilleHousing
ORDER BY ParcelID




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(ParcelID)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END 
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = (CASE
						WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
					END)

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates



WITH RowNumCTE AS(
   SELECT *,
       RN = ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, LegalReference, SaleDate, SalePrice ORDER BY ParcelID)
   FROM NashvilleHousing
)
SELECT * FROM RowNumCTE WHERE RN > 1


SELECT *
FROM NashvilleHousing















---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress





SELECT *
FROM NashvilleHousing















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















