
/* select database */
use nashville_dataset;

/* view table */
select * from nashville_dataset.dbo.nashville_data;

/* standardize the date format from datetime format to date format using Alter */

select saledate from nashville_dataset.dbo.nashville_data;

alter table nashville_data
alter column saledate date;

/* populate the propertyaddress */

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from nashville_data a
join nashville_data b
on a.parcelid = b.parcelid
and a.uniqueid<> b.uniqueid
where a.propertyaddress is null;

update a
set a.propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from nashville_data a
join nashville_data b
on a.parcelid = b.parcelid
and a.uniqueid<> b.uniqueid;

/* check whether its updated or not */

select propertyaddress
from nashville_data
where propertyaddress is null;

/* Break the property address into separate columns (address, city, state) */

select propertyaddress , SUBSTRING(propertyaddress, 1,charindex(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as city
from nashville_data;

/*  syntax of substring : substring(columnname, startpostion, stoppostion)
	syntax of charindex : charindex('punctuation symbol', columnname) 
	Here we use substring to separate sentances and charindex is a postion identifier of mentioned object */

/* add column in table and update the values in address column*/

alter table nashville_data
add address varchar(255); 

update nashville_data
set address = SUBSTRING(propertyaddress, 1,charindex(',',propertyaddress)-1);

/* again add column in table and update the values in city column */

alter table nashville_data
add city varchar(255);

update nashville_data
set city = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress));

/* check both columns wheather they are updated or not */

select address , city from nashville_data;

/* Now look into owneraddress column */

select owneraddress from nashville_data;

/* Here we use parsename function instead of substring */
/* parsename consider '.' */

select PARSENAME(replace(owneraddress, ',' , '.') ,1) as state ,
PARSENAME(replace(owneraddress, ',' , '.') ,2) ,
PARSENAME(replace(owneraddress, ',' , '.') ,3) 
from nashville_data;

/* add column and update sate column */

alter table nashville_data
add state varchar(255);

update nashville_data
set state = PARSENAME(replace(owneraddress, ',' , '.') ,1);

/* now view soldasvacant column */

select distinct(soldasvacant),count(soldasvacant) 
from nashville_data
group by soldasvacant;

select soldasvacant,
case 
	when soldasvacant ='Y' then 'yes'
	when soldasvacant = 'N' then 'no'
	else soldasvacant
	end
from nashville_data;

update nashville_data
set soldasvacant = case 
	when soldasvacant ='Y' then 'yes'
	when soldasvacant = 'N' then 'no'
	else soldasvacant
	end;

/* Remove Duplicates */  

with rownumcte as
(
select * , 
row_number() over(
partition by parcelid,
			 propertyaddress,
			 saledate,
			 legalreference
			 order by uniqueid
			 ) as row_num
from nashville_data
)
Delete   from rownumcte
where row_num > 1;
			