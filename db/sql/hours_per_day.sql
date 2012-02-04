-- Sum up hours recorded for each day. Useful for finding days which I forgot
-- to log activity.
--
select
  d.dt,
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) total
from
  activities a
join
  days d on
  a.day_id = d.id
group by
  d.dt;


