-- WIP, just a translation of the java solution Day6b.java
-- The architecture is correct, just need to work through the details

-- The input puzzle
create table main (
    event_time timestamp(3),
    line string,
    len int
    watermark for event_time as event_time - interval '5' second
) with (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day6-input.txt',
  'format' = 'csv',
  'csv.ignore-parse-errors' = 'true'
);

-- The next possible puzzles to look at
create table check (
    event_time timestamp(3),
    line string,
    pos int,
    dir string,
    ismain boolean,
    original string,
    len int,
    watermark for event_time as event_time - interval '5' second
) with (
  'connector' = 'kafka',
  'topic' = 'check_topic',
  'properties.bootstrap.servers' = 'localhost:9092',
  'format' = 'json',
  'scan.startup.mode' = 'latest-offset'
);

-- intermediate states that might be produced
create table in_progress (
    event_time timestamp(3),
    line string,
    pos int,
    dir string,
    ismain boolean,
    original string,
    len int,
    watermark for event_time as event_time - interval '5' second
) with (
  'connector' = 'kafka',
  'topic' = 'in_progress_topic',
  'properties.bootstrap.servers' = 'localhost:9092',
  'format' = 'json',
  'scan.startup.mode' = 'latest-offset'
);

create table print_sink (
  total bigint
) with (
  'connector' = 'print'
);

create temporary view a as
select *, '^' as dir, position('^') - len as nextPos, true as isMain from main
union all
select *, false as isMain from check;

-- Dedupe input puzzles
create temporary view dedupe_puzzle as
select * from (
  select *, row_number() over (partition by grid order by event_time asc)
  from main
) where rn = 1;

-- Solve check puzzles
create temporary view puzzles_to_check as
select * from dedupe_puzzle
union all
select * from in_progress;

-- Add check for loops
create temporary view puzzles_with_loops as
select line, count(*) as cnt
from puzzles_to_check;

-- Total loops
create temporary view solution_b as
select sum(1) as total
from puzzles_with_loops
having sum(1) > 1;

-- todo halt on loop
create temporary view next_puzzle as
select *,
  case
    -- exit up
    when dir = '^' and pos - len < 0 then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2))

    -- exit right
    when dir = '>' and pos % len > (pos + 1) % len then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2))

    -- exit down
    when dir = 'v' and (pos + len) > char_length(line) then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2))

    -- exit left
    when dir = '<' and pos % len < (pos - 1) % len then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2))

    -- move up
    when dir = '^' and substring(line, pos - len, 1) != '#' then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2)) ||
      concat(substr(line, 1, pos - len), '^', substr(line, pos - len + 2))

    -- rotate up
    when dir = '^' and substring(line, pos - len, 1) = '#' then
      concat(substr(line, 1, pos), '>')

    -- move right
    when dir = '>' and substring(line, pos + 1, 1) != '#' then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2)) ||
      concat(substr(line, 1, pos + 1), '>', substr(line, pos + 3))

    -- rotate right
    when dir = '>' and substring(line, pos + 1, 1) = '#' then
      concat(substr(line, 1, pos), 'v')

    -- move down
    when dir = 'v' and substring(line, pos + len, 1) != '#' then
      concat(substr(line, 1, pos), 'X', substr(line, pos + 2)) ||
      concat(substr(line, 1, pos + len), 'v', substr(line, pos + len + 2))

    -- rotate down
    when dir = 'v' and substring(line, pos + len, 1) = '#' then
      concat(substr(line, 1, pos), '<')

    -- move left
    when dir = '<' and substring(line, pos - 1, 1) != '#' then
      concat(substr(line, 1, pos), 'x', substr(line, pos + 2)) ||
      concat(substr(line, 1, pos - 1), '<', substr(line, pos))

    -- rotate left
    when dir = '<' and substring(line, pos - 1, 1) = '#' then
      concat(substr(line, 1, pos), '^')

    else
      'error'
  end as result,
  ... -- todo next position
  ... -- todo direction
from puzzles_to_check;

-- Insert into check queue
create temporary view next_main as
select
  current_timestamp as event_time,
  concat(substring(original from 1 for pos),
         '#',
         substring(original from pos+2)) as line,
  pos,
  dir,
  false as ismain,
  concat(substring(original from 1 for pos),
         '#',
         substring(original from pos+2)) as original,
  len
from next_puzzle
where ismain = true
-- todo: change from 1 index to 0 index?
  and substring(original from pos+1 for 1) = '.'
  and (
       (dir = '>' and substring(line from pos+2 for 1) <> '#') or
       (dir = '<' and substring(line from pos    for 1) <> '#') or
       (dir = '^' and substring(line from pos-len+1 for 1) <> '#') or
       (dir = 'v' and substring(line from pos+len+1 for 1) <> '#')
  );

execute statement set begin

  -- More main puzzles
  insert into check
  select * from next_main;

  -- next puzzles
  insert into in_progress
  select * from next_puzzle;

  -- The solution
  insert into print_sink
  select total
  from solution_b;
end;