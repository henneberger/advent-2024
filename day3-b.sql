-- Problem recap:
--   do(): Enables future mul instructions.
--   don't(): Disables future mul instructions.
--   mul(x, y): Multiplication operation whose result (x * y) should be summed only if enabled.
-- Initial State: mul instructions are enabled.
-- Goal: Sum all x * y results of mul(x, y) operations that are enabled based on the most recent
--       do() or don't() instruction preceding them.

-- This one is a bit tricky. We should avoid any joins or scalar subqueries in
-- favor of small window functions. We could compare the latest computed
-- dont/do state (at the bottom), but instead we'll use the latest_value
-- window fnc. We'll use the fact that last_value will ignore nulls so we can
-- isolate which mul functions we need to execute.

ADD JAR '/Users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

CREATE TEMPORARY FUNCTION IF NOT EXISTS regex_split
  AS 'io.github.henneberger.RegexSplit' LANGUAGE JAVA;

CREATE TABLE input_table (
  input String,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day3-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

CREATE TEMPORARY VIEW a AS
select u,
 COALESCE( -- operations are enabled at start
   LAST_VALUE(
     case when u[1] = 'do()' then true
     when u[1] like 'don%' then false
     else null
     end) OVER (ORDER BY ts),
   true) as current_state
from input_table i
cross join unnest(regex_split('mul\((\d{1,3}),(\d{1,3})\)|don''t\(\)|do\(\)', input)) u;

CREATE TEMPORARY VIEW b AS
SELECT SUM(cast(u[2] as bigint) * cast(u[3] as bigint)) AS total
FROM a where current_state IS NULL or current_state;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM b;


-- This is a possible approach using two window functions instead of last_value
--CREATE TEMPORARY VIEW c AS
--select
--  max(case when op = 'do()' then rn end) OVER (order by ts) as do_rn,
--  max(case when op = 'don''()' then rn end) OVER (order by ts) as dont_rn,
--  *
-- from b;
--CREATE TEMPORARY VIEW d AS
--select case
--    when do_rn is null and dont_rn is not null then false
--    when dont_rn > do_rn then false
--    else true
--end as enabled, * FROM c;
--
--CREATE TEMPORARY VIEW e AS
--select SUM(x*y) AS total FROM d where enabled;
