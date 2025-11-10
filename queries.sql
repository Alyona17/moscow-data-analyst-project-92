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
with overall_average_income as -- объявляем запрос, который подсчитывает среднюю выручку за сделку по всем продавцам
(
select
floor(avg(s.quantity * p.price)) as overall_average
from sales s
inner join products p on s.product_id = p.product_id
),
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
where average_income < (select overall_average from overall_average_income)
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