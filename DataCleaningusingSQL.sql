---------------------------------------


-- Data Cleaning in SQL



----------------------------------------


Select *
From PortfolioProject..NashvilleHousing;



-----------------------------------------

--Standardize Data Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate);


Select SaleDateConverted
From NashvilleHousing


--------------------------------------------

--Update Property Address where NULL


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID]<>b.[UniqueID]
--WHERE a.PropertyAddress is NULL

Update a
Set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL


------------------------------------------------------

--Splitting PropertyAddress by Address,City,State

Select PropertyAddress from PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity=SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing;


-------------------------------------------------------

--Splitting Owner Address into Address,City,State


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


----------------------------------------------------

--Change 'Y' and 'N' to 'Yes' and 'No' in Sold as Vacant field


Select SoldAsVacant,
 CASE WHEN SoldAsVacant='Y'THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
Set 
SoldAsVacant=CASE WHEN SoldAsVacant='Y'THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END

Select SoldAsVacant,Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2



---------------------------------------------------

--Remove Duplicates

WITH RowNumCTE As(
Select *,
 ROW_NUMBER() OVER (
 Partition By ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by UniqueID)
			   row_num

From PortfolioProject..NashvilleHousing

)
DELETE
From RowNumCTE
WHERE row_num<=1





WITH RowNumCTE As(
Select *,
 ROW_NUMBER() OVER (
 Partition By ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by UniqueID)
			   row_num

From PortfolioProject..NashvilleHousing

)
Select * 
From RowNumCTE
WHERE row_num<=1
Order by PropertyAddress


-------------------------------------------------------------------

--Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP Column OwnerAddress,PropertyAddress,SaleDate,TaxDistrict;

Select *
From PortfolioProject..NashvilleHousing