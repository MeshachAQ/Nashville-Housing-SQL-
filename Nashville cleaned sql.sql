---Hello, so today I will like to clean this data set using sql to make it more usable. some of the things we looking at is standardization, spliting columns, removing duplicates and unusable columns.

--SO First, let's look at the data set.

select * from [Nashville Housing Data for Data Cleaning (3)]

---So firstly, we want to make sure the SaleDate column is standardised such that, we see only the date.

select SaleDate, convert(date, SaleDate) as SaleDate_Converted from [Nashville Housing Data for Data Cleaning (3)]

---Now we need to add this to our table and for that,

Alter table [Nashville Housing Data for Data Cleaning (3)]
Add  SaleDate_Converted date

--Now we need to update the new column with the values
Update [Nashville Housing Data for Data Cleaning (3)]
SET SaleDate_Converted = convert(date, SaleDate)

--- SO NOW, WE CAN SEE OUR NEW COLUMN WHEN WE RERUN THE TABLE
SELECT * FROM [Nashville Housing Data for Data Cleaning (3)]

---SECONDLY, WE WANT TO SPLIT THE ADDRESS COLUMNS STARTING WITH PROPERTYADDRESS INTO ADDRESS AND CITY
--NOW THERE ARE TWO FORMULAS i KNOW FOR SPLITTING COLUMN AND WE SHALL USE BOTH
SELECT SUBSTRING(PropertyAddress,1,Charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as City from [Nashville Housing Data for Data Cleaning (3)]

--now let's alter table and update these values first before we move to the next one
ALTER TABLE [Nashville Housing Data for Data Cleaning (3)]
ADD Address nvarchar(255)

Update [Nashville Housing Data for Data Cleaning (3)]
SET Address = SUBSTRING(PropertyAddress,1,Charindex(',', PropertyAddress)-1)

Alter table [Nashville Housing Data for Data Cleaning (3)]
Add City1 nvarchar(255)

Update [Nashville Housing Data for Data Cleaning (3)]
SET City1 = SUBSTRING(PropertyAddress,Charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

---Well, we made a slight mistake with the City column thats why I added City1. we shall remove that later on.

select * from [Nashville Housing Data for Data Cleaning (3)]


--Okay so now we would need to split OwnerAddress as well assuming it had been asked. now we shall do this splitting using the parsename.
SELECT PARSENAME(replace(OwnerAddress, ',', '.'), 3) as OwnerAddress_converted,
PARSENAME(replace(OwnerAddress, ',', '.'), 2) as Owner_City,
PARSENAME(replace(OwnerAddress, ',', '.'), 1) as Owner_State from [Nashville Housing Data for Data Cleaning (3)]

---Now let's alter table and update the columns
Alter table [Nashville Housing Data for Data Cleaning (3)]
ADD OwnerAddress_converted nvarchar(255)

UPDATE [Nashville Housing Data for Data Cleaning (3)]
SET OwnerAddress_converted =  PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter table [Nashville Housing Data for Data Cleaning (3)]
ADD Owner_City nvarchar(255)

UPDATE [Nashville Housing Data for Data Cleaning (3)]
SET Owner_City = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter table [Nashville Housing Data for Data Cleaning (3)]
ADD Owner_State nvarchar(255)

UPDATE [Nashville Housing Data for Data Cleaning (3)]
SET Owner_State = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

---OKAY SO LET'S CHECK IT OUT 
SELECT * FROM [Nashville Housing Data for Data Cleaning (3)]

---Now we run a check on th SoldAsVacant column we realise some spaces have N instead of no and others have y instead of Yes. let's take a look before we clean it up
select distinct(SoldAsVacant) from [Nashville Housing Data for Data Cleaning (3)]

---what we want to do here for easy reading is to convert all N's to No and all Y's to Yes. let's gooo
Select SoldAsVacant,
CASE
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END AS SoldAsVacant_Converted
FROM [Nashville Housing Data for Data Cleaning (3)]

--- lets update this again
Alter table [Nashville Housing Data for Data Cleaning (3)]
Add SoldAsVacant_Converted nvarchar(255)

Update [Nashville Housing Data for Data Cleaning (3)]
set SoldAsVacant_Converted = CASE
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END

select * from [Nashville Housing Data for Data Cleaning (3)]

---Now we want to remove duplicates
With Nashville as (
select *, ROW_NUMBER() OVER (PARTITION BY PropertyAddress, ParcelID, SalePrice, LandUse, OwnerName, LegalReference, TaxDistrict Order by UniqueID) row_num
from [Nashville Housing Data for Data Cleaning (3)])
select * from Nashville
where row_num > 1

---Now that we have identified from the above that we have about 117 duplicate rows, we now have to remove these duplicate values thus;

With Nashville as (
select *, ROW_NUMBER() OVER (PARTITION BY PropertyAddress, ParcelID, SalePrice, LandUse, OwnerName, LegalReference, TaxDistrict Order by UniqueID) row_num
from [Nashville Housing Data for Data Cleaning (3)])
delete from Nashville
where row_num > 1



---now lets go back and check so...
select * from [Nashville Housing Data for Data Cleaning (3)]

---yep so we had about 56477 rows but now, we do have 56360 rows meaning duplicate values have been removed

---last thing we want to do before creating a view we shall be using is to remove unwanted columns so
ALTER TABLE [Nashville Housing Data for Data Cleaning (3)]
DROP COLUMN PropertyAddress, SaleDate, SoldAsVacant, OwnerAddress, TaxDistrict, City 

select * from [Nashville Housing Data for Data Cleaning (3)]

--yes we have that now create a view

create view Nashville as select * from [Nashville Housing Data for Data Cleaning (3)]


