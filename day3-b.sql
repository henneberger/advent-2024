add jar '/users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

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
select u,
coalesce( -- operations are enabled at start
   last_value(
     case when u[1] = 'do()' then true
     when u[1] = 'don''t()' then false
     else null -- trick of last_value so we get the last non-null value
     end
   ) over (order by ts), true) as current_state
from input_table i, unnest(regex_split('mul\((\d{1,3}),(\d{1,3})\)|don''t\(\)|do\(\)', input)) u;

create temporary view b as
select sum(cast(u[2] as bigint) * cast(u[3] as bigint)) as total
from a
where current_state;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from b;


-- this is a possible approach using two window functions instead of last_value
--create temporary view c as
--select
--  max(case when op = 'do()' then rn end) over (order by ts) as do_rn,
--  max(case when op = 'don''()' then rn end) over (order by ts) as dont_rn,
--  *
-- from b;
--create temporary view d as
--select case
--    when do_rn is null and dont_rn is not null then false
--    when dont_rn > do_rn then false
--    else true
--end as enabled, * from c;
--
--create temporary view e as
--select sum(x*y) as total from d where enabled;
