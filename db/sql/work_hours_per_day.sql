-- Report hours per work category for the sprint
--
select
  c.name,
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) total
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= '2012-01-19' and
  d.dt <= '2012-01-31' and
  c.abbr in ('un', 'sto', 'oh', 'bug', 'sm')
group by
  c.name;

-- Report total work hours for the sprint
--
select
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) total_hours_tracked
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= '2012-01-19' and
  d.dt <= '2012-01-31' and
  c.abbr in ('un', 'sto', 'oh', 'bug', 'sm');

-- Report all uncategorized activity
--
select
  d.dt,
  a.memo as overhead,
  (strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0 as total
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= '2012-01-19' and
  d.dt <= '2012-01-31' and
  c.abbr in ('un');

-- Report all overhead activity
--
select
  d.dt,
  a.memo as overhead,
  (strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0 as total
from
  activities a
inner join
  categories c on
  c.id = a.category_id
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= '2012-01-19' and
  d.dt <= '2012-01-31' and
  c.abbr in ('oh');
