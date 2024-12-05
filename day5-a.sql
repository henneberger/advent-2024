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

-- Rule violations
create temporary view a as
select distinct line from rules
join updates on array_position(line, l) > array_position(line, r)
 and array_position(line, l) <> 0 and array_position(line, r) <> 0;

create temporary view b as
select sum(line[cardinality(line)/2+1]) as total
from updates
where line not in (select line from a);

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from b;