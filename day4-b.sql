create table input_table (
  input string,
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day4-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

-- convert each letter to row, add a space to simplify later ops
create temporary view a as
select x, char_length(input) + 1 as len, ts from input_table, unnest(split(input || ' ', '')) as x;

-- instead of day4-a, we treat the last 'S' or 'M' as the bottom right corner
create temporary view b as
select
  x,
  lag(x, len + 1) over (order by ts) as n1,
  lag(x, 2 * len + 2) over (order by ts) as n2,
  lag(x, 2) over (order by ts) as p1,
  lag(x, len + 1) over (order by ts) as p2,
  lag(x, 2 * len) over (order by ts) as p3
from a;

create temporary view c as
select sum(case when(
    ((x  = 'M' and n1 = 'A' and n2 = 'S') or (x  = 'S' and n1 = 'A' and n2 = 'M')) and
    ((p1 = 'M' and p2 = 'A' and p3 = 'S') or (p1 = 'S' and p2 = 'A' and p3 = 'M'))
  ) then 1 else 0 end) as total
from b;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;