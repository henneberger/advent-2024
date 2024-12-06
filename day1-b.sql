create table input_table (
  left_id int,
  right_id int,
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day1-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ' ',
  'csv.ignore-parse-errors' = 'true'
);

-- create a state table from the right list
create temporary view right_count as
select right_id, count(*) as cnt, max(ts) as ts
from input_table
group by right_id;

create temporary view totals as
select sum(l.left_id * coalesce(r.cnt, 0)) as total
from input_table l, right_count r
where l.left_id = r.right_id
  and l.ts between l.ts - interval '1' second and r.ts;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from totals;
