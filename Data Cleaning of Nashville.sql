/*Cleaning Nashville Data */
SELECT *
FROM Nashville

--standardize the sale date of Nashville
SELECT SaleDate, CONVERT(Date, SaleDate) AS 'Date Converted'
FROM Nashville

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)

--To permanently change date you can use the ALTER table method
ALTER TABLE Nashville
ADD SalesDate Date;

UPDATE Nashville
SET SalesDate = CONVERT(DATE, SaleDate);

/* POPPULATE PROPERTY ADDRESS THAT ARE NULL*/
SELECT *
FROM Nashville
ORDER BY ParcelID;

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


/* Breaking out PropertyAddress into columns i.e (Address, City, State) */

SELECT *
FROM Nashville;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Nashville;

ALTER TABLE Nashville
ADD PropertyAddresSplit NVARCHAR(255);

UPDATE Nashville
SET PropertyAddresSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE Nashville
ADD City NVARCHAR(255);

UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

/* Now breaking OwnerAddress into column i.e (OwnerAddress, OwnerCity, OwnerState) By using PARSENAME Method, but in Decending order*/
/*You also need to replace ',' with '.'*/

SELECT OwnerAddress
FROM Nashville
WHERE OwnerAddress IS NOT NULL;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddressSplit,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)AS OwnerState
FROM Nashville;

ALTER TABLE Nashville
ADD OwnerAddressSplit NVARCHAR(255);

UPDATE Nashville
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Nashville
ADD OwnerCity NVARCHAR(255);

SELECT *
FROM Nashville;

UPDATE Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashville
ADD OwnerState NVARCHAR(255);

UPDATE Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT OwnerAddressSplit AS 'Owner Address Split',
OwnerCity AS 'Owner City',
OwnerState AS 'Owner State'
FROM Nashville
WHERE OwnerAddress IS NOT NULL;

/*Change Y and N to Yes and No in 'Sold As Vacant' Field*/
/*USE CASE FUNCTION ton Convert Y and N into Yes and No*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS 'TOTAL COUNT'
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 'TOTAL COUNT';

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Nashville

/*Removing the duplicates by using Partition method*/
--Pretend there is no Unique ID

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
FROM Nashville
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num = 2;



/*Delete Unused Columns*/

SELECT *
FROM Nashville;

ALTER TABLE Nashville
DROP COLUMN PropertyAddress, OwnerAddress

--These were the useless address.
