-- Для каждого дня недели в таблицах orders и user_actions рассчитайте следующие показатели:
-- 1. Выручку на пользователя (ARPU).
-- 2. Выручку на платящего пользователя (ARPPU).
-- 3. Выручку на заказ (AOV).


SELECT weekday,
       weekday_number,
       round((revenue::float / all_users)::numeric, 2) as arpu ,
       round((revenue::float / paying_user)::numeric, 2) as arppu ,
       round((revenue::float / orders)::numeric, 2) as aov
FROM   (SELECT to_char(time, 'Day') as weekday,
               date_part('isodow', time) as weekday_number ,
               count(distinct user_id) as all_users
        FROM   user_actions
        WHERE  date(time) between '2022-08-26'
           and '2022-09-08'
        GROUP BY weekday, weekday_number)t1
    LEFT JOIN (SELECT to_char(time, 'Day') as weekday,
                      date_part('isodow', time) as weekday_number,
                      count(distinct user_id) as paying_user,
                      count(distinct order_id) as orders
               FROM   user_actions
               WHERE  date(time) between '2022-08-26'
                  and '2022-09-08'
                  and order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
               GROUP BY weekday, weekday_number)t2 using(weekday, weekday_number)
    LEFT JOIN (SELECT to_char(date, 'Day') as weekday,
                      date_part('isodow', date) as weekday_number,
                      sum(price) as revenue
               FROM   (SELECT date(creation_time) as date,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  date(creation_time) between '2022-08-26'
                          and '2022-09-08'
                          and order_id not in (SELECT order_id
                                            FROM   user_actions
                                            WHERE  action = 'cancel_order'))t3
                   LEFT JOIN products using(product_id)
               GROUP BY weekday, weekday_number)t4 using(weekday, weekday_number)
ORDER BY weekday_number
