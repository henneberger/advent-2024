-- We have to maintain a uuid to keep partitions unique, also flink has no simple way to remove items
-- from arrays consistently.

create table input_table (
  parent_item STRING,
  ts AS proctime(),
  parent_uuid as UUID()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day2-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ',',
  'csv.ignore-parse-errors' = 'true'
);

-- create enough entries to enumerate
-- Note: add uuid b/c partitions can be duplicated
-- Note: rn must be an 'int' for later array operations
create temporary view a as
select
  cast(split(parent_item, ' ') as array<bigint>) as item,
  cast(row_number() over(partition by parent_uuid order by ts) as int) as rn,
  uuid() AS uuid, -- add a uuid
  *
from input_table i
cross join unnest(split(i.parent_item, ' ')) as x;

-- Create set to enumerate, we can exclude the original list since it'll be covered by the case where the ends are missing
-- Note: array_slice has odd behavior with removing the first element
create temporary view b as
select
 case
   when rn = cardinality(item) then array_slice(item, 2, cardinality(item)) --remove first element
   else array_concat(array_slice(item, 1, rn), array_slice(item, rn + 2, cardinality(item)))
 end as item,
 uuid,
 parent_uuid,
 ts
from a;

-- Convert to single elements
create temporary view c as
select
  ele - lag(ele) over (partition by uuid order by ts) as diff,
  item,
  uuid,
  parent_uuid,
  ts
from b
cross join unnest(item) as ele;

create temporary view d as
select
  case when
   sum(case when diff >= -3 and diff < 0  then 1 else 0 end) over (partition by uuid order by ts) = cardinality(item) - 1 or
   sum(case when diff > 0   and diff <= 3 then 1 else 0 end) over (partition by uuid order by ts) = cardinality(item) - 1
  then true else false end as is_safe,
  *
from c;

create temporary view e as
select count(distinct parent_uuid) as total
from d
where is_safe;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from e;