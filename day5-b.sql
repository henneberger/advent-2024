add jar '/users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

create temporary function if not exists topo_sort
  as 'io.github.henneberger.TopoSort' language java;

-- step 1: create the rules table
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

-- step 3: create the updates table
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

create temporary view b as
select line, topo_sort(array_agg(array[r.l, r.r])) as arr
from a, rules r
where array_position(line, l) <> 0 and array_position(line, r) <> 0
group by line;

create temporary view c as
select sum(arr[cardinality(arr)/2+1]) as total
from b;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;