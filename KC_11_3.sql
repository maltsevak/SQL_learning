-- Теперь предлагаем вам посмотреть на нашу аудиторию немного под другим углом — давайте посчитаем не просто всех пользователей,
-- а именно ту часть, которая оформляет и оплачивает заказы в нашем сервисе.
-- Для каждого дня, представленного в таблицах, рассчитайте следующие показатели:
-- 1. Число платящих пользователей; 2. Число активных курьеров; 3. Долю платящих пользователей в общем числе пользователей на текущий день;
-- 4. Долю активных курьеров в общем числе курьеров на текущий день.


SELECT date,
       paying_users,
       active_couriers ,
       round((paying_users::float/ total_users *100)::numeric, 2) as paying_users_share ,
       round((active_couriers::float/ total_couriers *100)::numeric,
             2) as active_couriers_share
FROM   (SELECT date(time) as date,
               count(distinct user_id) as paying_users
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date)paying_users
    LEFT JOIN (SELECT date(time) as date,
                      count(distinct courier_id) as active_couriers
               FROM   courier_actions
               WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
               GROUP BY date)active_couriers using(date)
    LEFT JOIN (SELECT date,
                      sum(new_users) OVER(ORDER BY date rows between unbounded preceding and current row) ::int as total_users ,
                      sum(new_couriers) OVER(ORDER BY date rows between unbounded preceding and current row) ::int as total_couriers
               FROM   (SELECT date,
                              count(user_id) as new_users
                       FROM   (SELECT user_id,
                                      date(min(time)) as date
                               FROM   user_actions
                               GROUP BY user_id)us
                       GROUP BY date)users
                   LEFT JOIN (SELECT date,
                                     count(courier_id) as new_couriers
                              FROM   (SELECT courier_id,
                                             date(min(time)) as date
                                      FROM   courier_actions
                                      GROUP BY courier_id)cour
                              GROUP BY date)couriers using(date))query using(date)
ORDER BY date
