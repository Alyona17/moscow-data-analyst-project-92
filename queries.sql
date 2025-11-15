-- шаг 4

select count(customer_id) as customers_count
from customers; -- подсчитываем количество клиентов в таблице customers



-- шаг 5 таблица 1
select
concat(e.first_name, ' ', e.last_name) as seller, -- склеиваем имя и фамилию продавца в одну строку
count(s.sales_id) as operations, -- подсчитываем количество продаж
floor(sum(s.quantity * p.price)) as income -- подсчитываем общую сумму продаж, округляем вниз
from sales s
inner join employees e on s.sales_person_id = e.employee_id -- объединяем с таблицей employees
inner join products p on s.product_id = p.product_id -- объединяем с таблицей products
group by seller --группируем по продавцу
order by income desc -- сортируем по сумме товаров от большей к меньшей
limit 10 -- ограничиваем выборку
;



-- шаг 5 таблица 2
with
seller_average as -- объявляем запрос, подсчитывающий среднюю выручку за сделку по каждому продавцу
(
select
concat(e.first_name, ' ', e.last_name) as seller,
floor(avg(s.quantity * p.price)) as average_income
from sales s
inner join employees e on s.sales_person_id = e.employee_id
inner join products p on s.product_id = p.product_id
group by seller
)
select -- просим показать имя-фамилию и среднюю сумму за сделку тех продавцов, у которых средняя сумма меньше средней суммы по всем продавцам
seller,
average_income
from seller_average
where average_income < (select floor(avg(s.quantity * p.price)) -- создаём подзапрос, считающий общую среднюю сумму сделки
from sales s
inner join products p on s.product_id = p.product_id)
order by average_income asc;




-- шаг 5 таблица 3
select
concat(e.first_name, ' ', e.last_name) as seller, -- склеиваем имя и фамилию продавца
to_char(s.sale_date, 'Day') as day_of_week, -- извлекаем из даты название дня недели
floor(sum(s.quantity * p.price)) as income -- подсчитываем среднюю выручку, округляем вниз
from sales s -- соединяем все три таблицы
inner join employees e on s.sales_person_id = e.employee_id
inner join products p on s.product_id = p.product_id
group by seller, -- группируем по продавцу
extract(isodow from s.sale_date), -- группируем по ISO-номеру дня недели
day_of_week -- группируем по названию дня недели
order by extract(isodow from s.sale_date), seller; -- сортируем по номеру дня недели, продавцу





-- шаг 6 таблица 1
SELECT
CASE
WHEN age BETWEEN 16 AND 25 THEN '16-25'
WHEN age BETWEEN 26 AND 40 THEN '26-40'
ELSE '40+'
END AS age_category, -- разделяем покупателей на возрастные категории
COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;


-- шаг 6 таблица 2
SELECT
to_char(s.sale_date, 'YYYY-MM') as selling_month, -- преобразуем дату в нужный нам формат
count(distinct(s.customer_id)) as total_customers, -- подсчитываем количество уникальных покупателей, группируем по месяцам
round(sum(s.quantity*p.price), 0) as income
FROM sales s
inner join products p
on s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;


--шаг 6 таблица 3
with first_sales as (
select
customer_id,
min(sale_date) as first_sale_date -- находим первую дату покупки для каждого покупателя
from sales
group by customer_id
),
promotional_first_sales as ( -- из первого подзапроса отбираем только те первые покупки, где товар был акционным (цена = 0)
select 
fs.customer_id,
fs.first_sale_date,
s.sales_person_id,
s.product_id
from first_sales fs
inner join sales s on fs.customer_id = s.customer_id 
and fs.first_sale_date = s.sale_date
inner join products p on s.product_id = p.product_id
where p.price = 0)
select
concat(c.first_name, ' ', c.last_name) as customer,
pfs.first_sale_date as sale_date,
concat(e.first_name, ' ', e.last_name) as seller
from promotional_first_sales pfs
inner join customers c on pfs.customer_id = c.customer_id -- соединяем результаты из второго подзапроса с таблицами customers и employees, чтобы получить имена покупателей и продавцов
inner join employees e on pfs.sales_person_id = e.employee_id
order by c.customer_id asc;