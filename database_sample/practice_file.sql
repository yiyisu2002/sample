-- Final Exam Practive 


-- Creating Source Table


if exists(select * from sys.objects where name='greek_source') drop table greek_source
go
create table greek_source
(source_id          int identity,
 source_name        varchar(25) not null,
 source_loc_one     varchar(20) not null,
 source_loc_two     varchar(20),
 source_found_date  date not null,
 source_flower      char(25) not null,
 source_type        char (02) not null,
 source_type_desc   varchar(25) not null,
 constraint pk_greek_source primary key (source_id)
)
go
insert into greek_source 
select  'Delta Chi', 'Syracuse','Auburn','18900613', 'White Carnation', 'F', 'Fratrinity'  union all 
select  'Alpha Phi', 'Harvard','Syracuse','18720123', 'Lily', 'S', 'Surority'  union all
select  'Kappa Kappa', 'Mansfield',null,'19190519', 'Rose', 'SI', 'Special Interest'  union all
select  'Theta Chi', 'Colgate','PennState','18830707', 'Red Carnation', 'F', 'Fratrinity'  
go

select * from greek_source


--end of source table create and insert




--Create Internal Mode for 3 new Tables

if exists (select * from sys.objects where name = 'g_source_location') drop table g_source_location
if exists (select * from sys.objects where name = 'g_source_name') drop table g_source_name
if exists (select * from sys.objects where name = 'g_type') drop table g_type


create table g_type
(
	source_type        char (02) not null,
	source_type_desc   varchar(25) not null,
	constraint pk_source_type primary key(source_type)
	)

create table g_source_name
(
	source_id		int,
	source_name		varchar(25) not null,
	source_found_date  date not null,
	source_flower      char(25) not null,
	source_type        char (02) not null,
	constraint fk_source_type foreign key(source_type) references g_type(source_type),
	constraint pk_source_id primary key(source_id)
	)


create table g_source_location
(
	source_id		int,
	source_location varchar(20),
	constraint fk_source_id foreign key(source_id) references g_source_name(source_id)
	)


go
-- end of internal model build

--Data Cleansing

update greek_source
set source_type_desc = 'Fraternity' where source_type_desc = 'Fratrinity'
update greek_source
set source_type_desc = 'Sorority' where source_type_desc = 'Surority'

select * from greek_source




go
-- end of cleansing sql


--Migration, insert the data into the 3 new tables



insert into g_type
	select distinct source_type, source_type_desc from greek_source

insert into g_source_name
	select distinct source_id, source_name, source_found_date, source_flower, source_type from greek_source

insert into g_source_location
	select source_id, source_loc_one from greek_source
	where source_loc_one is not null
		union
	select source_id, source_loc_two from greek_source
	where source_loc_two is not null

select * from g_source_location

go
-- end of migration sql




--Select statement used to verify migration


select l.source_id as ch_id, 
	source_name as ch_name,
	source_location as ch_location, 
	year(source_found_date) as ch_founding_year,
	source_flower as ch_flower,
	source_type_desc as ct_description
from g_source_name n join g_type t on n.source_type = t.source_type
join g_source_location l on n.source_id = l.source_id
order by l.source_id
go
--end of verify sql


