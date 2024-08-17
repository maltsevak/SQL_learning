--Для каждого дня в таблице orders рассчитайте следующие показатели:
-- 1. Выручку, полученную в этот день; 2. Суммарную выручку на текущий день; 
-- 3. Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.

SELECT date,
       revenue ,
       sum(revenue) OVER(ORDER BY date) as total_revenue , 
       round(((revenue/ lag(revenue) OVER(ORDER BY date) -1)*100)::numeric,
             2) as revenue_change
FROM   (SELECT date,
               sum(price) as revenue
        FROM   (SELECT date(creation_time) as date,
                       order_id,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order'))t1
            LEFT JOIN products using(product_id)
        GROUP BY date)t2
ORDER BY date
