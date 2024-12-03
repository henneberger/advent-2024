ADD JAR '/Users/henneberger/advent-of-code/target/aoc-flink-lib-1.0-SNAPSHOT.jar';

CREATE TEMPORARY FUNCTION IF NOT EXISTS regex_split
  AS 'io.github.henneberger.RegexSplit' LANGUAGE JAVA;

CREATE TABLE input_table (
  input String,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day3-example.txt',
  'format' = 'csv',
  'csv.field-delimiter' = '|',
  'csv.ignore-parse-errors' = 'true'
);

CREATE TEMPORARY VIEW a AS
select regex_split('mul\((\d{1,3}),(\d{1,3})\)', input) AS split from input_table;

CREATE TEMPORARY VIEW b AS
select u[1] as op, CAST(u[2] AS bigint) as x, CAST(u[3] AS bigint) as y from a CROSS JOIN UNNEST(a.split) u;

CREATE TEMPORARY VIEW c AS
select SUM(x*y) AS total FROM b;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM c;
