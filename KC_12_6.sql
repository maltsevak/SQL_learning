-- Также было бы интересно посмотреть, какие товары пользуются наибольшим спросом и приносят нам основной доход.
-- Задание: Для каждого товара за весь период времени рассчитайте следующие показатели:
-- 1. Суммарную выручку, полученную от продажи этого товара за весь период.
-- 2. Долю выручки от продажи этого товара в общей выручке, полученной за весь период.

SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT case when round((revenue / sum(revenue) OVER() * 100)::numeric,
                               2) < 0.5 then 'ДРУГОЕ'
                    else name end as product_name ,
               revenue,
               round((revenue / sum(revenue) OVER() * 100)::numeric, 2) as share_in_revenue
        FROM   (SELECT name,
                       product_count * price as revenue
                FROM   (SELECT product_id,
                               count(order_id) as product_count
                        FROM   (SELECT order_id,
                                       unnest(product_ids) as product_id
                                FROM   orders
                                WHERE  order_id not in (SELECT order_id
                                                        FROM   user_actions
                                                        WHERE  action = 'cancel_order'))t1
                        GROUP BY product_id)t2
                    LEFT JOIN products using(product_id))t3)t4
GROUP BY product_name
ORDER BY revenue desc
