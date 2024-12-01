-- Global sorts are tricky in a stream so we'll do a large top-n on both sides and then
--  compute the diff. This computation would be better off in a relational database and computed
--  at query time since top-n like this is incredibly expensive.

CREATE TABLE input_table (
  left_id INT,
  right_id INT,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/day1-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ' ',
  'csv.ignore-parse-errors' = 'true'
);

-- Deduplicate so we can do a global sort
CREATE TEMPORARY VIEW left_list AS
SELECT * FROM (
   SELECT left_id, ts,
     ROW_NUMBER() OVER (ORDER BY left_id ASC) AS rownum
   FROM input_table)
WHERE rownum <= 1000; -- how long the list is to trick flink into doing a huge top-n

CREATE TEMPORARY VIEW right_list AS
SELECT * FROM (
   SELECT right_id, ts,
     ROW_NUMBER() OVER (ORDER BY right_id ASC) AS rownum
   FROM input_table)
WHERE rownum <= 1000;

CREATE TEMPORARY VIEW paired AS
SELECT
  sl.left_id AS sorted_left,
  sr.right_id AS sorted_right,
  ABS(sl.left_id - sr.right_id) AS distance
FROM left_list AS sl
JOIN right_list AS sr
  ON sl.rownum = sr.rownum;

CREATE TEMPORARY VIEW total_distance AS
SELECT SUM(distance) AS total_distance
FROM paired;

CREATE TABLE print_sink (
  total_distance BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total_distance
FROM total_distance;
