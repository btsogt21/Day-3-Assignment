-- Day 3 Assigment

-- 1. List all cities that have both Employees and Customers.

select distinct C.City, E.City
from dbo.Customers as [C]
join dbo.Employees as [E] on C.City = E.City
-- 2. List all cities that have Customers but no Employee.

-- a.      Use sub-query
select distinct(City) from dbo.Customers
where City not in (select distinct City from dbo.Employees)

-- b.      Do not use sub-query
select distinct C.City, E.City
from dbo.Customers as [C]
left join dbo.Employees as [E] on C.City = E.City
where E.city is null

-- 3. List all products and their total order quantities throughout all orders.

select p.ProductName, sum(o.Quantity) [TOtal Order Quantity of given Product across all orderIDs] from [Order Details] as [o] join Products as [p] on o.ProductID = p.ProductID
GROUP by p.ProductName
order by p.ProductName

--4. List all Customer Cities and total products ordered by that city.

-- Total quantity of products ordered per customer city
select o.ShipCity, sum(OD.Quantity) [Quantity of products ordered] from Orders as [O]
join [Order Details] as [OD] on o.OrderID = OD.OrderID
group by o.ShipCity

-- Total number of distinct productids ordered per customer city
select o.ShipCity, count(distinct(OD.ProductID)) [Number of distinct types of products ordered] from Orders as [O]
join [Order Details] as [OD] on o.OrderID = OD.OrderID
group by o.ShipCity

-- 5. List all Customer Cities that have at least two customers.

-- a.      Use union
select City, count(companyname) [Companies] from Customers
group by City
having count(companyname) between 2 and 3
UNION
select City, count(companyname) [Companies] from Customers
group by City
having count(CompanyName)>=3

-- b.      Use sub-query and no union
select distinct city from (select distinct city from Customers group by city having count(CompanyName)>=2) as [yah]

-- 6. List all Customer Cities that have ordered at least two different kinds of products.
select city, count(ProductID) [Count of Types of Products] from Customers as [C]
join Orders as [O] on C.City = O.ShipCity
join [Order Details] as [OD] on O.OrderID = OD.OrderID
GROUP by City
having count(ProductID)>=2

-- 7. List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.

select c.CompanyName, count(o.OrderID) [Number of Orders made], c.City, o.ShipCity from Customers as [C]
join Orders as [O] on c.CustomerID = o.CustomerID
where o.ShipCity!=c.City
group by c.CompanyName, c.City, o.ShipCity
having count(o.OrderID)>0

--8. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

select top 5 p.productname, od.ProductID, sum(od.quantity) [quantity of product ordered] into #TempTable1of8 from Products as [p]
join [Order Details] as [od] on p.ProductID = od.ProductID
join orders as [o] on od.OrderID = o.OrderID
group by p.productname, od.ProductID
order by sum(od.Quantity) desc

select od.ProductID, o.shipcity, sum(od.Quantity) [Quantity Ordered],
ROW_NUMBER() over  (partition by od.ProductID order by sum(od.quantity) desc) as [numbering per category]
into #TempTable2of8 from orders as [o]
join [Order Details] as [od] on o.OrderID = od.OrderID
join #TempTable1of8 as [temp]on od.ProductID = temp.ProductID
group by o.ShipCity, od.ProductID
order by od.ProductID, [Quantity Ordered] desc

select t1.ProductName, t1.[quantity of product ordered], t2.shipcity [Customer city that ordered the most]
from #TempTable1of8 as [t1] join #TempTable2of8 as [t2] on t1.productid = t2.ProductID
where t2.[numbering per category] = 1

select avg(UnitPrice) [avg price of 5 most popular products]from Products
where productname in (select productname from #TempTable1of8)

-- 9.      List all cities that have never ordered something but we have employees there.

-- a.      Use sub-query
select City from Employees where city not in (select shipcity from Orders)

-- b.      Do not use sub-query
select e.city from Employees as [e]
left join orders as [o] on e.city = o.ShipCity
where o.shipcity is null

-- 10. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
select e.City, count(o.orderID) [Total count of orders], sum(od.Quantity) [Sum of quantity of products ordered] from Orders as [o]
join Employees as [e] on o.EmployeeID = e.EmployeeID
join [Order Details] as [od] on o.OrderID=od.OrderID
group by e.City
order by count(o.OrderID) desc, sum(od.Quantity) desc

-- If I understand, the question correctly, seems like a throw up between seattle and london.

-- 11. How do you remove the duplicates record of a table?

-- By using a delete statement in conjunction with a subquery including a row number that partitions over the columns you're using to determien which records are duplicates of one another.

-- If we're counting duplicate rows as those that contain similar values for all columns, than we can simply use a group by on one of those columns to delete duplicates. 

