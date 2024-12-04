add jar '/users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-snapshot.jar';

create temporary function if not exists regex_split
    as 'io.github.henneberger.RegexSplit' language java;

create table input_table (
  input string,
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day3-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

create temporary view a as
select sum(cast(u[2] as bigint) * cast(u[3] as bigint)) as total
from input_table, unnest(regex_split('mul\((\d{1,3}),(\d{1,3})\)', input)) as u;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from a;
