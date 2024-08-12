-- Давайте рассчитаем ещё один полезный показатель, характеризующий качество работы курьеров.
-- На основе данных в таблице courier_actions для каждого дня рассчитайте, за сколько минут в среднем курьеры доставляли свои заказы.

SELECT date,
       avg(time_to_deliver)::int as minutes_to_deliver
FROM   (SELECT date(max(time)) as date,
               (extract(epoch
        FROM   max(time) - min(time)) / 60)::int as time_to_deliver
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY order_id)time_to_deliver
GROUP BY date
ORDER BY date
