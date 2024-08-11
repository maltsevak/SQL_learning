-- Для каждого дня, представленного в таблице user_actions, рассчитайте следующие показатели:
-- 1. Общее число заказов; 2. Число первых заказов (заказов, сделанных пользователями впервые);
-- 3. Число заказов новых пользователей (заказов, сделанных пользователями в тот же день, когда они впервые воспользовались сервисом);
-- 4. Долю первых заказов в общем числе заказов (долю п.2 в п.1); 5. Долю заказов новых пользователей в общем числе заказов (долю п.3 в п.1).


with orders as (SELECT date(time) as date,
                       user_id,
                       count(order_id) as user_order
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                GROUP BY date, user_id)
SELECT date,
       orders,
       first_orders,
       new_users_orders ,
       round((first_orders::float / orders * 100)::numeric, 2) as first_orders_share ,
       round((new_users_orders::float / orders * 100)::numeric,
             2) as new_users_orders_share
FROM   (SELECT date,
               sum(user_order)::int as orders
        FROM   orders
        GROUP BY date)orders
    LEFT JOIN (SELECT date,
                      count(user_id) as first_orders
               FROM   (SELECT user_id,
                              min(date) as date
                       FROM   orders
                       GROUP BY user_id)start_date_orders
               GROUP BY date)first_orders using(date)
    LEFT JOIN (SELECT date,
                      sum(user_order)::int as new_users_orders
               FROM   (SELECT user_id,
                              date(min(time)) as date
                       FROM   user_actions
                       GROUP BY user_id)start_date
                   LEFT JOIN (SELECT user_id,
                                     date,
                                     user_order
                              FROM   orders)new_users_orders using(user_id, date)
               GROUP BY date)users_orders using(date)
ORDER BY date
