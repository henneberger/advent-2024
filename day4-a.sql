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

-- using only lag functions, look back the various directions
-- on the m and s, look back
create temporary view b as
select
x || lag(x, 1) over (order by ts) || lag(x, 2) over (order by ts) || lag(x, 3) over (order by ts) as h,
x || lag(x, len) over (order by ts) || lag(x, len+len) over (order by ts) || lag(x, len+len+len) over (order by ts) as v,
x || lag(x, len-1) over (order by ts) || lag(x, len+len-2) over (order by ts) || lag(x, len+len+len-3) over (order by ts) as d1,
x || lag(x, len+1) over (order by ts) || lag(x, len+len+2) over (order by ts) || lag(x, len+len+len+3) over (order by ts) as d2,
*
from a;

create temporary view c as
select
 case when h = 'XMAS' or h = 'SAMX' then 1 else 0 end as a,
 case when v = 'XMAS' or v = 'SAMX' then 1 else 0 end as b,
 case when d1 = 'XMAS' or d1 = 'SAMX' then 1 else 0 end as c,
 case when d2 = 'XMAS' or d2 = 'SAMX' then 1 else 0 end as d,
 *
from b;

create temporary view d as
select sum(a) + sum(b) + sum(c) + sum(d) as total from c;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from d;