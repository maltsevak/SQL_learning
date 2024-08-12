-- Давайте подробнее остановимся на платящих пользователях, копнём немного глубже и выясним, как много платящих пользователей совершают более одного заказа в день.
-- Для каждого дня, представленного в таблицах, рассчитайте следующие показатели:
-- 1. Долю пользователей, сделавших в этот день всего один заказ, в общем количестве платящих пользователей;
-- 2. Долю пользователей, сделавших в этот день несколько заказов, в общем количестве платящих пользователей.


SELECT date ,
       round((count(user_id) filter(WHERE orders = 1)::float / count(user_id) *100)::numeric,
             2) as single_order_users_share ,
       round((count(user_id) filter(WHERE orders > 1)::float / count(user_id) *100)::numeric,
             2) as several_orders_users_share
FROM   (SELECT date(time) as date,
               user_id,
               count(order_id) as orders
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date, user_id)pay
GROUP BY date
ORDER BY date
