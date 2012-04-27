-- Print hours per life category
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
  d.dt >= '2012-03-28' and
  d.dt <= '2012-04-10' and
  c.abbr not in ('un', 'sto', 'oh', 'bug', 'sm')
group by
  c.name;
