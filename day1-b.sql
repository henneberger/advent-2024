-- The second half is simpler since we can compute the aggregate as we go.
-- We could do an interval join over two streams, but instead we'll create a stateful table on the
--  right hand side and do a join.

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
select right_id, count(*) as cnt
from input_table
group by right_id;

create temporary view totals as
select sum(l.left_id * coalesce(r.cnt, 0)) as total
from input_table l
left join right_count r on l.left_id = r.right_id;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from totals;
