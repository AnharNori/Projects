--Cleaning Data in SQL

-- Standardize Date Format

Select *
From PortfolioProject.dbo.NashVilleHousing

GRANT ALTER ON [dbo].[NashVilleHousing] TO [Anhar]

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashVilleHousing


Update NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashVilleHousing
SET SaleDateConverted  = cast(SaleDate as Date)

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashVilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


-- Breaking out Address into Individual Columns (Address,City,State)

Select PropertyAddress
From PortfolioProject.dbo.NashVilleHousing
--Where PropertyAddress is null
--order by ParcelID


SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) As Address
, SUBSTRING (PropertyAddress,  CHARINDEX(',',PropertyAddress) +1,LEN(ProPertyAddress)) As Address
From PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add PropertySplitAddress Nvarchar(255);
Update PortfolioProject.dbo.NashVilleHousing
SET  PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)
ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add PropertySplitCity Nvarchar(255);
Update PortfolioProject.dbo.NashVilleHousing
SET  PropertySplitCity = SUBSTRING (PropertyAddress,  CHARINDEX(',',PropertyAddress) +1,LEN(ProPertyAddress))


Select *
From PortfolioProject.dbo.NashVilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashVilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) 
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashVilleHousing


ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update PortfolioProject.dbo.NashVilleHousing
SET  OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)
ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add OwnerSplitCity Nvarchar(255);
Update PortfolioProject.dbo.NashVilleHousing
SET  OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)
ALTER TABLE PortfolioProject.dbo.NashVilleHousing
Add OwnerSplitState Nvarchar(255);
Update PortfolioProject.dbo.NashVilleHousing
SET  OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashVilleHousing 



--Change Y and N to yes and no in sold as vacant field




Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashVilleHousing 

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashVilleHousing 


Update PortfolioProject.dbo.NashVilleHousing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashVilleHousing 



-- Remove Duplicates CTE and window functions 

WITH RowNumCTE AS(
Select *, 
	Row_Number() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER  BY 
				 UniqueID
				 ) row_num
From PortfolioProject.dbo.NashVilleHousing 
--ORDER BY ParcelID 
)

Delete 
From RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress




-- Delete Unused Columns


Alter Table PortfolioProject.dbo.NashVilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


Select *
From PortfolioProject.dbo.NashVilleHousing 

Alter Table PortfolioProject.dbo.NashVilleHousing 
DROP COLUMN SaleDate
