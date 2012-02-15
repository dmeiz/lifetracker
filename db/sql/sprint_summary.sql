-- Prints a sprint summary useful in gathering data for my sprint summary
-- spreadsheet. Don't forget to update the dates in all queries.

-- Report total hours for the sprint; useful to sanity check all hours have
-- been accounted for
--
select
  sum((strftime('%s', a.end_at) - strftime('%s', a.start_at))/3600.0) total_hours_tracked
from
  activities a
inner join
  days d on
  a.day_id = d.id
where
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14';

-- Report total work hours for the sprint
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
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14' and
  c.abbr in ('un', 'sto', 'oh', 'bug', 'sm');

-- Print hours per work category
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
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14' and
  c.abbr in ('un', 'sto', 'oh', 'bug', 'sm')
group by
  c.name;

-- Print story work
--
select
  c.name,
  substr(a.memo, 0, 6) story,
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
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14' and
  c.abbr = 'sto'
group by
  story;

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
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14' and
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
  d.dt >= '2012-02-01' and
  d.dt <= '2012-02-14' and
  c.abbr in ('oh');
