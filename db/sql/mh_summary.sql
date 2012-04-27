-- Report total MH hours for the last month
--
select
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) total_work_hours_tracked
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= date('now', 'localtime', '-1 month') and
  d.dt <= date('now') and
  c.abbr in ('mh');

-- Detail MH hours
--
select
  d.dt,
  a.memo,
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) as total
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= date('now', 'localtime', '-1 month') and
  d.dt <= date('now') and
  c.abbr in ('mh')
group by
  a.memo
order by
  d.dt;
