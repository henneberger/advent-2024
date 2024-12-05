-- All edges are fully identified so we don't need a topo sort

create table rules (
    l int,
    r int,
    r_ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day5-input-a.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

create table updates (
  o String,
  line AS CAST(split(o, ',') as array<int>),
  u_ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day5-input-b.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

-- rule violations
create temporary view a as
select distinct line
from rules r
join updates u on array_position(line, r.l) > array_position(line, r.r)
               and array_position(line, r.l) <> 0
               and array_position(line, r.r) <> 0;

-- Get rules for each line
create temporary view b as
select a.line, r.l as dependency, r.r as page
from a
join rules r on array_position(line, r.l) <> 0
             and array_position(line, r.r) <> 0;

-- number the dependencies
create temporary view c as
select
    b.line,
    b.page,
    count(distinct b.dependency) + 1 as sort_key
from b
group by b.line, b.page;

-- find max so we can find the midpoint
create temporary view d as
select line, max(sort_key) as m
from c
group by line;

-- find the midpoint value sum
create temporary view e as
select sum(page) as total
from c
join d on c.line = d.line
where (m + 1) / 2 = sort_key;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from e;