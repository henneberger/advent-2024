-- step 1: create the rules table
create table rules (
    l int,
    r int,
    r_ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day5-input-a.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

-- step 3: create the updates table
create table updates (
    o String,
    line AS CAST(split(o, ',') as array<int>),
    u_ts as proctime()
) with (
   'connector' = 'filesystem',
   'path' = '/Users/henneberger/advent-of-code/data/day5-input-b.txt',
   'format' = 'csv',
   'csv.field-delimiter' = '|',
   'csv.ignore-parse-errors' = 'true'
);

-- return 0 if there is a return violation, else midpoint
create temporary view a as
select
 line,
 coalesce(
  last_value(
      case when array_position(line, l) > array_position(line, r) then 0
      else null
      end
    ), line[cardinality(line)/2+1]) as val
from rules
inner join updates on array_position(line, l) <> 0 and array_position(line, r) <> 0
group by line;

create temporary view b as
select sum(val) as total
from a;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from b;