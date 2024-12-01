-- The second half is simpler since we can compute the aggregate as we go.
-- We could do an interval join over two streams, but instead we'll create a stateful table on the
--  right hand side and do a join.

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

-- Create a state table from the right list
CREATE TEMPORARY VIEW right_count AS
SELECT right_id, COUNT(*) AS cnt
FROM input_table
GROUP BY right_id;

CREATE TEMPORARY VIEW totals AS
SELECT l.left_id, COALESCE(r.cnt, 0) AS c
FROM input_table l
LEFT JOIN right_count r ON l.left_id = r.right_id;

CREATE TEMPORARY VIEW total_count AS
SELECT SUM(left_id * c) AS total
FROM totals;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM total_count;
