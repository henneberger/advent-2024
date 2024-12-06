-- Global sorts are tricky in a stream so we'll do a large top-n on both sides and then
--  compute the diff. This computation would be better off in a relational database and computed
--  at query time since top-n like this is incredibly expensive.

create table input_table (
  left_id int,
  right_id int,
  ts as proctime()
) with (
  'connector' = 'filesystem',
  'path' = '/users/henneberger/advent-of-code/data/day1-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ' ',
  'csv.ignore-parse-errors' = 'true'
);

-- deduplicate so we can do a global sort
create temporary view left_list as
select * from (
   select left_id, ts,
     row_number() over (order by left_id asc) as rownum
   from input_table)
where rownum <= 1000; -- how long the list is to trick flink into doing a huge top-n

create temporary view right_list as
select * from (
   select right_id, ts,
     row_number() over (order by right_id asc) as rownum
   from input_table)
where rownum <= 1000;

create temporary view paired as
select
  sum(abs(sl.left_id - sr.right_id)) as total
from left_list as sl
join right_list as sr
  on sl.rownum = sr.rownum;

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

insert into print_sink
select total
from paired;
