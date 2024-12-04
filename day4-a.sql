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

-- using only lag functions, look back the various directions
-- on the m and s, look back
create temporary view b as
select
  -- h
  lag(x, 1) over (order by ts) as h1,
  lag(x, 2) over (order by ts) as h2,
  lag(x, 3) over (order by ts) as h3,
  -- v
  lag(x, 1 * len) over (order by ts) as v1,
  lag(x, 2 * len) over (order by ts) as v2,
  lag(x, 3 * len) over (order by ts) as v3,
  -- positive diagonal
  lag(x, 1 * len - 1) over (order by ts) as d1_1,
  lag(x, 2 * len - 2) over (order by ts) as d1_2,
  lag(x, 3 * len - 3) over (order by ts) as d1_3,
  -- negative diagonal
  lag(x, 1 * len + 1) over (order by ts) as d2_1,
  lag(x, 2 * len + 2) over (order by ts) as d2_2,
  lag(x, 3 * len + 3) over (order by ts) as d2_3,
  *
from a;

create temporary view c as
select
 sum(case when array[x, h1  , h2  , h3  ] in (xmas, samx) then 1 else 0 end) +
 sum(case when array[x, v1  , v2  , v3  ] in (xmas, samx) then 1 else 0 end) +
 sum(case when array[x, d1_1, d1_2, d1_3] in (xmas, samx) then 1 else 0 end) +
 sum(case when array[x, d2_1, d2_2, d2_3] in (xmas, samx) then 1 else 0 end) as total
from (
 select
   array['X', 'M', 'A', 'S'] as xmas,
   array['S', 'A', 'M', 'X'] as samx, *
 from b);

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;