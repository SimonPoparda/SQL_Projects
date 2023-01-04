/*
Cleaning Data in SQL Queries
*/

--------------------------------------------------------------------------------------------------------------------------
-- MAKE BACKUP TABLE
DROP TABLE backup_Data_For_DataCleaningProject;
SELECT * INTO backup_Data_For_DataCleaningProject FROM Nashvile_Housing;

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) as Goal
FROM DataCleaning_Project..Nashvile_Housing

ALTER TABLE Nashvile_Housing
add SaleDateConverted Date;

UPDATE Nashvile_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data where it's NULL

SELECT *
FROM DataCleaning_Project..Nashvile_Housing
ORDER BY ParcelID

SELECT A.[UniqueID ], B.[UniqueID ],A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, 
isnull(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning_Project..Nashvile_Housing AS A
JOIN DataCleaning_Project..Nashvile_Housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning_Project..Nashvile_Housing AS A
JOIN DataCleaning_Project..Nashvile_Housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM DataCleaning_Project..Nashvile_Housing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM DataCleaning_Project..Nashvile_Housing

ALTER TABLE Nashvile_Housing
add PropertySplitAddress Nvarchar(255);

UPDATE Nashvile_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Nashvile_Housing
add PropertySplitCity Nvarchar(255);

UPDATE Nashvile_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM DataCleaning_Project..Nashvile_Housing




SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaning_Project..Nashvile_Housing

ALTER TABLE Nashvile_Housing
add OwnerSplitAddress Nvarchar(255);

UPDATE Nashvile_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashvile_Housing
add OwnerSplitCity Nvarchar(255);

UPDATE Nashvile_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashvile_Housing
add OwnerSplitState Nvarchar(255);

UPDATE Nashvile_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS CountOf
FROM DataCleaning_Project..Nashvile_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM DataCleaning_Project..Nashvile_Housing

UPDATE Nashvile_Housing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) as row_num

FROM DataCleaning_Project..Nashvile_Housing
)

SELECT *
FROM RowNumCTE
where row_num > 1
ORDER BY PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM DataCleaning_Project..Nashvile_Housing
ORDER BY [UniqueID ]

ALTER TABLE DataCleaning_Project..Nashvile_Housing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
