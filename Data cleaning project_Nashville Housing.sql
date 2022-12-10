-- Standardize date format

Select SaleDateConverted
From [data cleaning project]..Housing

Alter table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property address data

Select *
From [data cleaning project]..Housing
--Where PropertyAddress is null
order by ParcelID

-- For same parcel id, Propertyaddress will be same, so we are updating Propertyaddresses which are null and having same parcel id where address is there

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From [data cleaning project]..Housing a
Join [data cleaning project]..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [data cleaning project]..Housing a
Join [data cleaning project]..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address (both propert and owner address) into individual columns (Address City, State)

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From [data cleaning project]..Housing

Alter table Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table Housing
Add City Nvarchar(255);

Update Housing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--From [data cleaning project]..Housing

Alter table Housing
Add Address_Owner Nvarchar(255);

Update Housing
Set Address_Owner = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table Housing
Add OwnerCity Nvarchar(255);

Update Housing
Set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table Housing
Add OwnerState Nvarchar(255);

Update Housing
Set OwnerState = PARSENAME(Replace(OwnerAddress,',','.'),1)

-- Changing 'Y' to 'Yes' and 'N' to 'No' in SoldAsVacant column

Update Housing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End

-- Removing duplicate rows

With rownumCTE as (
Select *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName ORDER BY UniqueID) as rownum
From [data cleaning project]..Housing
)

DELETE
From rownumCTE
Where rownum > 1

-- Deleting unused columns

Alter table Housing
Drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate



