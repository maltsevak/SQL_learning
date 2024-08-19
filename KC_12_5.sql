-- Отдельно посчитаем ежедневную выручку с заказов новых пользователей нашего сервиса. 
-- Посмотрим, какую долю она составляет в общей выручке с заказов всех пользователей — и новых, и старых.

-- Задание: Для каждого дня рассчитайте следующие показатели:
-- 1. Выручку, полученную в этот день.
-- 2. Выручку с заказов новых пользователей, полученную в этот день.
-- 3. Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
-- 4. Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.

SELECT date,
       revenue,
       new_users_revenue ,
       round((new_users_revenue::float / revenue *100)::numeric,
             2) as new_users_revenue_share ,
       round(((1 - new_users_revenue::float / revenue) *100)::numeric,
             2) as old_users_revenue_share
FROM   (SELECT date,
               sum(price) as revenue
        FROM   (SELECT date(creation_time) as date,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order'))t1
            LEFT JOIN products using(product_id)
        GROUP BY date)t2
    LEFT JOIN (SELECT date,
                      sum(price) as new_users_revenue
               FROM   (SELECT user_id,
                              date(min(time)) as date
                       FROM   user_actions
                       GROUP BY user_id)t3
                   LEFT JOIN (SELECT user_id,
                                     date(time),
                                     order_id
                              FROM   user_actions
                              WHERE  order_id not in (SELECT order_id
                                                      FROM   user_actions
                                                      WHERE  action = 'cancel_order'))t4 using(date, user_id)
                   LEFT JOIN (SELECT order_id,
                                     unnest(product_ids) as product_id
                              FROM   orders)t5 using(order_id)
                   LEFT JOIN products using(product_id)
               GROUP BY date)t6 using(date)
ORDER BY date
