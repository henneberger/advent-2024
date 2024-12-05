-- Topo sort in sql (no recursive cte in flink)

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

-- number the dependencies
create temporary view d as
select
    c.line,
    c.page as page,
    count(distinct c.dependency) + 1 as sort_key
from c
right join unique_pages p on p.page = c.page
group by c.line, c.page
having array_contains(c.line, c.page);

-- resort the list by the sort_key
create temporary view e as
select * from (
   select *,
     row_number() over (partition by line order by sort_key asc) as rownum
   from d)
where rownum <= 1000;

-- find max so we can find the midpoint
create temporary view f as
select line, max(sort_key) as m
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