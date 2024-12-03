ADD JAR '/Users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

CREATE TEMPORARY FUNCTION IF NOT EXISTS regex_split
  AS 'io.github.henneberger.RegexSplit' LANGUAGE JAVA;

CREATE TEMPORARY FUNCTION IF NOT EXISTS starts_with
  AS 'io.github.henneberger.StartsWith' LANGUAGE JAVA;

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
select ts, regex_split('mul\((\d{1,3}),(\d{1,3})\)|don''t\(\)|do\(\)', input) AS split from input_table;

CREATE TEMPORARY VIEW b AS
select ts, row_number() OVER (order by ts) as rn, u[1] as op,
CAST(u[2] AS bigint) as x, CAST(u[3] AS bigint) as y from a cross join UNNEST(a.split) u;

CREATE TEMPORARY VIEW c AS
SELECT
  max(case when op like 'do%' and op not like 'don%' then rn end) OVER (order by ts) as do_rn,
  max(case when op like 'don%' then rn end) OVER (order by ts) as dont_rn,
  *
 from b;

CREATE TEMPORARY VIEW d AS
select case
    when do_rn is null and dont_rn is not null then false
    when dont_rn > do_rn then false
    else true
end as enabled, * FROM c;

CREATE TEMPORARY VIEW e AS
select SUM(x*y) AS total FROM d where enabled;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM e;
