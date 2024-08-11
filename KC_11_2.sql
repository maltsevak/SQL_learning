-- Для начала давайте проанализируем, насколько быстро растёт аудитория нашего сервиса, и посмотрим на динамику числа пользователей и курьеров. 
-- Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:
-- Число новых пользователей; Число новых курьеров; Общее число пользователей на текущий день; Общее число курьеров на текущий день;
-- Прирост числа новых пользователей, %; Прирост числа новых курьеров, %; Прирост общего числа пользователей, %; Прирост общего числа курьеров, %.

SELECT *,
       round(((new_users::float/ lag(new_users) OVER(ORDER BY date) -1) *100)::numeric,
             2) as new_users_change ,
       round(((new_couriers::float/ lag(new_couriers) OVER(ORDER BY date) -1) *100)::numeric,
             2) as new_couriers_change ,
       round(((total_users::float/ lag(total_users) OVER(ORDER BY date) -1) *100)::numeric,
             2) as total_users_growth ,
       round(((total_couriers::float/ lag(total_couriers) OVER(ORDER BY date) -1) *100)::numeric,
             2) as total_couriers_growth
FROM   (SELECT date,
               new_users,
               new_couriers ,
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
                       GROUP BY date)couriers using(date))query
ORDER BY date
