select
  c.name,
  a.memo,
  a.start_at,
  a.end_at,
  (strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0 total
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  a.start_at > '2012-01-06 13:00' and
  a.end_at < '2012-01-06 23:00'
order by
  a.start_at;
