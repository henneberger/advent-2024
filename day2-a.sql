create table input_table (
  item string,
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day2-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ',',
  'csv.ignore-parse-errors' = 'true'
);

-- unnest array, calc diff
create temporary view a as
select
  cast(split(i.item, ' ') as array<bigint>) as item,
  x - lag(x) over (partition by item order by ts) as diff,
  ts
from input_table i
cross join unnest(cast(split(i.item, ' ') as array<bigint>)) as x;

create temporary view b as
select
  case when
   sum(case when diff >= -3 and diff < 0  then 1 else 0 end) over (partition by item order by ts) = cardinality(item) - 1 or
   sum(case when diff > 0   and diff <= 3 then 1 else 0 end) over (partition by item order by ts) = cardinality(item) - 1
  then 1 else 0 end as is_safe,
  *
from a;

create temporary view c as
select sum(is_safe) as total
from b;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;