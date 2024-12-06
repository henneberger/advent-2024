-- Now that flink has 2 tables, we can start to work in temporal features

create table rules (
    event_time timestamp(3) not null,
    l int not null,
    r int not null,
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) with (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day5-input-a-time.txt',
  'format' = 'csv',
  'csv.ignore-parse-errors' = 'true'
);


-- step 3: create the updates table
create table updates (
    event_time timestamp(3) not null,
    o String,
    line AS CAST(split(o, ',') as array<int>),
    WATERMARK FOR event_time as event_time - INTERVAL '5' SECOND
) with (
   'connector' = 'filesystem',
   'path' = '/Users/henneberger/advent-of-code/data/day5-input-b-time.txt',
   'format' = 'csv',
   'csv.field-delimiter' = '|',
   'csv.ignore-parse-errors' = 'true'
);

-- Create a 'versioned table' for later temporal joins
-- Sets 'l' as the primary key to be join against
create temporary view rules_distinct as
select * from (
   select l, event_time, arr,
     row_number() over (partition by l order by event_time asc) as rownum
   from (select *, array_agg(r) over (partition by l order by event_time asc) as arr from rules)
   )
where rownum = 1;

-- unnest updates, but keep it as a stream
create temporary view a as
select *,
row_number() over (partition by line order by event_time) as rn
from updates u, unnest(u.line) as t(ele);

-- temporal join against the current rules
create temporary view b as
select
r.l,
array_intersect(a.line, r.arr),
cardinality(a.line) - cardinality(array_intersect(a.line, r.arr)) as i,
case when abs(cardinality(a.line) - cardinality(array_intersect(a.line, r.arr)) - rn) = 0
then 0
else 1 end as is_not_safe,
--last_value(
case when (cardinality(a.line) - cardinality(array_intersect(a.line, r.arr))) = (cardinality(a.line)+1)/2
then l
else null end
--) over (partition by a.line order by a.event_time)
 as mid,
line[(cardinality(a.line)+1)/2] as mid2,
coalesce(last_value(case when abs(cardinality(a.line) - cardinality(array_intersect(a.line, r.arr)) - rn) = 0
           then null
           else 1 end) over (partition by a.line order by a.event_time), 1) as safe_window,
*
from a
join rules_distinct
for system_time as of a.event_time
 as r on r.l = a.ele;


create temporary view c as
select line, max(mid) as m, sum(is_not_safe) as s
from b
group by tumble(event_time, interval '1' second), line;

-- problem 1
create temporary view p1 as
select sum(m) from c where s = 0;

create temporary view p2 as
select sum(m) from c where s > 0;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from b;