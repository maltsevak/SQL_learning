-- Давайте оценим почасовую нагрузку на наш сервис, выясним, в какие часы пользователи оформляют больше всего заказов, 
-- и заодно проанализируем, как изменяется доля отмен в зависимости от времени оформления заказа.
-- На основе данных в таблице orders для каждого часа в сутках рассчитайте следующие показатели:
-- 1. Число успешных (доставленных) заказов; 2. Число отменённых заказов; 3. Долю отменённых заказов в общем числе заказов (cancel rate).

SELECT hour,
       successful_orders,
       canceled_orders ,
       round((canceled_orders::float / (successful_orders + canceled_orders))::numeric,
             3) as cancel_rate
FROM   (SELECT date_part('hour', time)::int as hour,
               count(order_id) as successful_orders
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY hour)successful_orders
    LEFT JOIN (SELECT date_part('hour', time)::int as hour,
                      count(order_id) as canceled_orders
               FROM   user_actions
               WHERE  order_id in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
                  and action = 'create_order'
               GROUP BY hour)canceled_orders using(hour)
ORDER BY hour
