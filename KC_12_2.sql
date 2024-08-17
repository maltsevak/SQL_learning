-- Теперь на основе данных о выручке рассчитаем несколько относительных показателей, которые покажут, 
-- сколько в среднем потребители готовы платить за услуги нашего сервиса доставки. Остановимся на следующих метриках:
-- 1. ARPU (Average Revenue Per User) — средняя выручка на одного пользователя за определённый период.
-- 2. ARPPU (Average Revenue Per Paying User) — средняя выручка на одного платящего пользователя за определённый период.
-- 3. AOV (Average Order Value) — средний чек, или отношение выручки за определённый период к общему количеству заказов за это же время.


SELECT date,
       round((revenue::float / all_users)::numeric, 2) as arpu ,
       round((revenue::float / paying_user)::numeric, 2) as arppu ,
       round((revenue::float / orders)::numeric, 2) as aov
FROM   (SELECT date(time) as date,
               count(distinct user_id) as all_users
        FROM   user_actions
        GROUP BY date)t1
    LEFT JOIN (SELECT date(time) as date,
                      count(distinct user_id) as paying_user,
                      count(distinct order_id) as orders
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date)t2 using(date)
    LEFT JOIN (SELECT date,
                      sum(price) as revenue
               FROM   (SELECT date(creation_time) as date,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order'))t3
                   LEFT JOIN products using(product_id)
               GROUP BY date)t4 using(date)
ORDER BY date
