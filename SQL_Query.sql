--Data cleaning project -
--56477 rows (initially)

select *
from Sheet1$
order by UniqueID desc



--Standardising the data -

update Sheet1$ 
set PropertyAddress = trim (PropertyAddress)


update Sheet1$ 
set OwnerName = trim (OwnerName)


update Sheet1$ 
set OwnerAddress = trim (OwnerAddress)


update Sheet1$ 
set TaxDistrict = trim (TaxDistrict)




--Standardising the date format -


alter table Sheet1$
add Sale_Date date

update Sheet1$
set Sale_Date = convert (Date,SaleDate)



--Populate PropertyAddress -



update a
set a.PropertyAddress =  isnull (a.PropertyAddress, b.PropertyAddress)
from dbo.Sheet1$ a
join dbo.Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL




--Breaking out Propertyaddress into individual columns (Property_Address, City_Address) using substrings and charindex.
 


alter table Sheet1$
add Property_Address nvarchar (255)

update Sheet1$
set Property_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1 ) 


alter table Sheet1$
add City_Address nvarchar (255)

update Sheet1$
set City_Address = SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress ))




--Breaking out OwnerAddress into individual columns (Address,City,State) using parsename and replace function.



alter table Sheet1$
add Address nvarchar (255)

update Sheet1$
set Address =  PARSENAME (Replace(OwnerAddress,',','.'),3)


alter table Sheet1$
add City nvarchar (255)

update Sheet1$
set City =  PARSENAME (Replace(OwnerAddress,',','.'),2)


alter table Sheet1$
add State nvarchar (255)

update Sheet1$
set State =  PARSENAME (Replace(OwnerAddress,',','.'),1)



--changing the names of columns using stored proceudre (EXEC sp_rename) -

EXEC sp_rename
@objname = 'Sheet1$.Address',
@newname = 'Owner_Address',
@objtype = 'column'



EXEC sp_rename
@objname = 'Sheet1$.City',
@newname = 'Owner_City',
@objtype = 'column'



EXEC sp_rename
@objname = 'Sheet1$.State',
@newname = 'Owner_State',
@objtype = 'column'



--Changing Y and N to Yes and No in 'SoldAsVacant column' 


update Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
End


select distinct (SoldAsVacant), count (SoldAsVacant)

from Sheet1$
group by SoldAsVacant
order by 2



--Deleting duplicate rows using CTE and row_number -
--104 duplicates


with RowNumCTE as (
select *,
row_number() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID
) row_num

from Sheet1$)


delete 
from RowNumCTE
where row_num > 1








