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
select row_number() over (order by ts) as rn,
 x, char_length(input) + 1 as len, ts from input_table, unnest(split(input || ' ', '')) as x;

-- instead of day4-a, we treat the last 'S' or 'M' as the bottom right corner
create temporary view b as
select
x || lag(x, len+1) over (order by ts) || lag(x, len+len+2) over (order by ts) as dneg,
lag(x, 2) over (order by ts) || lag(x, len+1) over (order by ts) || lag(x, len+len) over (order by ts) as dpos,
*
from a;

create temporary view c as
select sum(case when (dneg = 'MAS' or dneg = 'SAM') and (dpos = 'MAS' or dpos = 'SAM') then 1 else 0 end) as total
from b;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from c;