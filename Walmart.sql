create database Walmart
use Walmart

--Top Sales--
select order_id, sum(quantity) as 'Items', customer from Walmart
group by order_id, customer
order by Items desc

--Sales with the biggest profit--

select order_id, sum(profit) as 'Profit',sum(quantity) as 'Items', customer from Walmart
group by order_id, customer
order by Profit desc

--Categories with the highest and lower profit--
select sum(profit) as 'Profit', category from Walmart
group by category
order by Profit desc
--Lowest
select sum(profit) as 'Profit', category from Walmart
group by category
order by Profit asc

--PROFIT POR ESTADOS--

select state, sum(profit) as Profit from Walmart
group by state
order by Profit desc

--PROFIT DE CIUDADES EN LOS ESTADOS CON PROFIT NEGATIVO--

select city, sum(profit) as Profit from Walmart
where state like '%Oregon%'
group by city
order by Profit desc

select city, sum(profit) as Profit from Walmart
where state like '%Arizona%'
group by city
order by Profit desc

select city, sum(profit) as Profit from Walmart
where state like '%Colorado%'
group by city
order by Profit desc

--CONTRASTE ENTRE PROFIT Y LOSES--
--Creé una tabla temporal (temp table) con los estados y sus profits para obtener los números totales de Ingresos, Perdidas y Ganancias o Profit
create table #Profit_State
(state varchar(255),
profit float
)
insert into #Profit_State
select state, sum(profit) as Profit from Walmart
group by state
order by Profit desc

--GANANCIAS TOTALES
select
  sum(case when profit > 0 then profit else 0 end) as Ingresos,
  SUM(case when profit < 0 then profit else 0 end) as Perdidas,
  sum(case when profit > 0 then profit else 0 end) + sum(case when profit < 0 then profit else 0 end) as Ganancias
FROM #Profit_State

--TRABAJAR POR PERIODOS DE TIEMPOS: MESES

select distinct (left(order_date, 4)) as Month from Walmart

select distinct (case 
	when (left(order_date, 4)) like 'Jan' then 1
	when (left(order_date, 4)) like 'Feb' then 2
	when (left(order_date, 4)) like 'Mar' then 3
	when (left(order_date, 4)) like 'Apr' then 4
	when (left(order_date, 4)) like 'May' then 5
	when (left(order_date, 4)) like 'Jun' then 6
	when (left(order_date, 4)) like 'Jul' then 7
	when (left(order_date, 4)) like 'Aug' then 8
	when (left(order_date, 4)) like 'Sep' then 9
	when (left(order_date, 4)) like 'Oct' then 10
	when (left(order_date, 4)) like 'Nov' then 11
	when (left(order_date, 4)) like 'Dec' then 12
	end) as Month
from Walmart
order by Month 

alter table Walmart
add month_number int;

update Walmart
set month_number = case 
	when (left(order_date, 4)) like 'Jan' then 1
	when (left(order_date, 4)) like 'Feb' then 2
	when (left(order_date, 4)) like 'Mar' then 3
	when (left(order_date, 4)) like 'Apr' then 4
	when (left(order_date, 4)) like 'May' then 5
	when (left(order_date, 4)) like 'Jun' then 6
	when (left(order_date, 4)) like 'Jul' then 7
	when (left(order_date, 4)) like 'Aug' then 8
	when (left(order_date, 4)) like 'Sep' then 9
	when (left(order_date, 4)) like 'Oct' then 10
	when (left(order_date, 4)) like 'Nov' then 11
	when (left(order_date, 4)) like 'Dec' then 12
	end;

select * from Walmart

--SEPARAR POR QUINCENA. Con el motivo de generar un análisis mas descriptivo a la hora de representar en una visualizacion.
alter table Walmart
add quincena int

SELECT DAY(order_date) AS day
FROM Walmart;

update Walmart
set quincena = case
	when DAY(order_date) between 1 and 15 then 1
	else 2
	end
from Walmart

update Walmart --Al tratar de convertir la columna 'order_date' de tipo datetime a date y no tener exito, procedí a crear otra tabla
set order_date = CONVERT(date, CAST(order_date AS smalldatetime)) --con los tipos de datos deseados e insertar el contenido de la
FROM Walmart;--tabla original a la nueva.

create table Walmart2(
order_id nvarchar (255),
order_date date,
ship_date date,
customer nvarchar (255),
country nvarchar (255),
city nvarchar (255),
state nvarchar (255),
category nvarchar (255),
product nvarchar (255),
sales float,
quantity float,
profit float,
month_number int,
quincena int)

insert into Walmart2
select * from Walmart


select * from Walmart2


select distinct state from walmart2

--Ventas por mes

select distinct(month_number),count(order_id) as Sales from Walmart2
group by month_number
order by Sales desc

-- Ventas por mes y quincena
select distinct(month_number),quincena, count(order_id) as Sales from Walmart2
group by month_number, quincena
order by Sales desc

--ESTADOS--

create table #Walmart_States(
state varchar(255),
ingresos int,
profit int, 
items int,
ventas int)

insert into #Walmart_States
select state, sum(sales) as Ingresos, sum(profit) as Profit, sum(quantity) as Items, count(order_id) as Ventas from Walmart2
group by state
order by Profit desc

select profit from Walmart


SELECT state, ingresos, profit, items, ventas, RANK() OVER (ORDER BY profit DESC) AS ranking
FROM #Walmart_States

create table Walmart_States(
state varchar(255),
ingresos float,
profit float, 
items int,
ventas int,
ranking int)

insert into Walmart_States
SELECT state, ingresos, profit, items, ventas, RANK() OVER (ORDER BY profit DESC) AS ranking
FROM #Walmart_States

select * from Walmart_States

select * from Walmart2

--Dividir la columna order_date en yyyy/mm/dd en POWER BI

select count (customer) from Walmart2
where state = 'California'

select DATEDIFF(DAY, order_date, ship_date) from Walmart2


--CALCULANDO EL RENDIMIENTO DE CADA ESTADO PARA SITUARLO EN UN RANKING.

select count(order_id) as Compras, state from Walmart2
group by state
order by Compras desc

select sum(profit) as Profit, state from Walmart2
group by state
order by Profit desc