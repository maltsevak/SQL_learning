-- На основе данных в таблицах user_actions, courier_actions и orders для каждого дня рассчитайте следующие показатели:
-- 1. Число платящих пользователей на одного активного курьера; 2. Число заказов на одного активного курьера.

SELECT date,
       round((paying_users ::float / active_couriers)::numeric, 2) as users_per_courier ,
       round((deliver_order ::float / active_couriers)::numeric, 2) as orders_per_courier
FROM   (SELECT date(time) as date,
               count(distinct user_id) as paying_users,
               count(order_id) as deliver_order
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date)deliver_order
    LEFT JOIN (SELECT date(time) as date,
                      count(distinct courier_id) as active_couriers
               FROM   courier_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date)active_couriers using(date)
ORDER BY date
