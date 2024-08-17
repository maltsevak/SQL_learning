-- Вычислим все те же метрики, но для каждого дня будем учитывать накопленную выручку и все имеющиеся на текущий момент данные о числе пользователей и заказов. 
--Таким образом, получим динамический ARPU, ARPPU и AOV и сможем проследить, как он менялся на протяжении времени с учётом поступающих нам данных.

-- По таблицам orders и user_actions для каждого дня рассчитайте следующие показатели:
-- 1. Накопленную выручку на пользователя (Running ARPU).
-- 2. Накопленную выручку на платящего пользователя (Running ARPPU).
-- 3. Накопленную выручку с заказа, или средний чек (Running AOV).


SELECT date,
       round((total_revenue::float / total_new_users)::numeric, 2) as running_arpu ,
       round((total_revenue::float / total_new_paying_user)::numeric,
             2) as running_arppu ,
       round((total_revenue::float / total_orders)::numeric, 2) as running_aov
FROM   (SELECT date,
               sum(new_users) OVER(ORDER BY date) as total_new_users
        FROM   (SELECT date,
                       count(user_id) as new_users
                FROM   (SELECT user_id,
                               date(min(time)) as date
                        FROM   user_actions
                        GROUP BY user_id)us
                GROUP BY date)users)all_new_users
    LEFT JOIN (SELECT date,
                      sum(new_paying_user) OVER(ORDER BY date) as total_new_paying_user
               FROM   (SELECT date,
                              count(user_id) as new_paying_user
                       FROM   (SELECT user_id,
                                      date(min(time)) as date
                               FROM   user_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                               GROUP BY user_id)us
                       GROUP BY date)paying_user)all_new_paying_user using(date)
    LEFT JOIN (SELECT date,
                      sum(revenue) OVER(ORDER BY date) as total_revenue ,
                      sum(orders) OVER(ORDER BY date) as total_orders
               FROM   (SELECT date,
                              sum(price) as revenue,
                              count(distinct order_id) as orders
                       FROM   (SELECT date(creation_time) as date,
                                      order_id,
                                      unnest(product_ids) as product_id
                               FROM   orders
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order'))t3
                           LEFT JOIN products using(product_id)
                       GROUP BY date)revenu4)total_revenue using(date)
ORDER BY date
