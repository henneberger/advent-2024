-- See Day7.java WIP: Not sure if computing a variable set of

add jar '/users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

create temporary function if not exists last_value_calculator
  as 'io.github.henneberger.day7.LastValueCalculator' language java;
create temporary function if not exists op_permute
  as 'io.github.henneberger.day7.OperatorPermuteFunction' language java;

create table input_table (
  input string,
  vals string,
  uuid as uuid(),
  arr as cast(split(trim(vals), ' ') as array<int>),
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day7-example.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ':',
  'csv.ignore-parse-errors' = 'true'
);

create temporary view a as
select  uuid() as uuid2, *
from input_table,unnest(arr) as t1(ele);

create temporary view b as
select cardinality(arr) as len, *
 from input_table;
-- last_value_calculator(ele, op)
create temporary view b as

select arr, ops
from input_table i
cross join lateral(table(op_permute(i.len))) as t2(ops) on true

group by input, uuid2;

select input, uuid2, last_value_calculator(ele, op) as total, max(input) as s
from a
group by input, uuid2
having last_value_calculator(ele, op) = cast(max(input) as bigint);


select * from (values( ((('||'))), ((('*'))), ((('+')))));

last_value_calculator
execute statement set begin

  -- More main puzzles
  insert into check
  select * from next_main;

  -- next puzzles
  insert into in_progress
  select * from next_puzzle;

  -- The solution
  insert into print_sink
  select total
  from solution_b;
end;