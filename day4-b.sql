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
select x, char_length(input) + 1 as len, ts
from input_table, unnest(split(input || ' ', '')) as x;

-- instead of day4-a, we treat the last 'S' or 'M' as the bottom right corner
create temporary view b as
select
  -- negative diagonal
  x,
  lag(x, 1 * len + 1) over (order by ts) as c,
  lag(x, 2 * len + 2) over (order by ts) as n,
  -- positive diagonal
  lag(x, 2      ) over (order by ts) as p,
  lag(x, 2 * len) over (order by ts) as t,
  -- pattern
  array['M', 'A', 'S'] as mas,
  array['S', 'A', 'M'] as sam
from a;

create temporary view c as
select count(*) as total
from b
where array[x, c, n] in (mas, sam) and
      array[p, c, t] in (mas, sam);

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;