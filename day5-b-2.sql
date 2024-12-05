-- Topo sort in sql (no recursive cte in flink)
-- This solution is very inefficient

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

-- Rule violations
create temporary view a as
select line, max(u_ts) as ts
from rules as r
left join updates as u on array_position(line, l) > array_position(line, r)
 and array_position(line, l) <> 0 and array_position(line, r) <> 0
group by line;

-- Get list of all rules (arr)
create temporary view b as
select line, array_agg(array[r.l, r.r]) as arr
from a, rules r
where array_position(line, l) <> 0 and array_position(line, r) <> 0
group by line;

-- Prepare for topo sort
create temporary view unique_pages as
select distinct l as page from rules
union
select distinct r as page from rules;

create temporary view c as
select line, u[1] as dependency, u[2] as page from b, unnest(b.arr) as u;

create temporary view c_2 as
select
    line,
    d1.dependency,
    r.r as page
from c d1
join rules r on d1.page = r.l;

-- dependencies of depth 2 (enough to get a solution)
create temporary view all_dependencies as
select line, dependency, page from c
union
select line, dependency, page from c_2;

-- number the dependencies
create temporary view d as
select
    x.line,
    x.page as page,
    count(distinct c.dependency) + 1 as sort_key
from (select line, p.page from unique_pages p, all_dependencies c where array_contains(c.line, p.page)) as x
left join all_dependencies c on c.line = x.line and x.page = c.page
group by x.line, x.page
having array_contains(x.line, x.page);

-- resort the list by the sort_key
create temporary view e as
select * from (
   select *,
     row_number() over (partition by line order by sort_key asc) as rownum
   from d)
where rownum <= 1000;

-- find max so we can find the midpoint
create temporary view f as
select line, max(rownum) as m
from e
group by line;

-- find the midpoint value and sum
create temporary view g as
select sum(page) as total
from e
join f on e.line = f.line
where (m+1)/2 = sort_key;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from g;