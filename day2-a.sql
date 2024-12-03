CREATE TABLE input_table (
  item String,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day2-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ',',
  'csv.ignore-parse-errors' = 'true'
);

-- Unnest array
CREATE TEMPORARY VIEW unnested_table AS
SELECT * FROM input_table i
CROSS JOIN unnest(ARRAY_APPEND(SPLIT(i.item, ' '), null)) x;

CREATE TEMPORARY VIEW lag_table AS
select *, lag(CAST(x AS NUMERIC), 1) OVER (order by ts asc) as lag_x from unnested_table;

CREATE TEMPORARY VIEW lag_table_2 AS
select *,CAST(x as NUMERIC) AS x_num, CAST(x as NUMERIC) - CAST(lag_x AS NUMERIC) AS diff_x from lag_table;

CREATE TEMPORARY VIEW safe_nums AS
select *, CASE WHEN diff_x IS NULL THEN NULL WHEN diff_x = 1 THEN 1 WHEN diff_x = 2 THEN 1 WHEN diff_x = 3 THEN 1
 WHEN diff_x = -1 THEN -1 WHEN diff_x = -2 THEN -1 WHEN diff_x = -3 THEN -1 ELSE -9999 END
 AS s FROM lag_table_2;

CREATE TEMPORARY VIEW safe_nums_2 AS
SELECT *, SUM(s) OVER (PARTITION BY item ORDER BY ts) AS sum_val FROM safe_nums;

CREATE TEMPORARY VIEW safe_nums_3 AS
SELECT *,  CARDINALITY(SPLIT(item, ' ')) FROM safe_nums_2 WHERE x_num IS NULL AND CARDINALITY(SPLIT(item, ' ')) = ABS(sum_val) - 1;

CREATE TEMPORARY VIEW safe_nums_4 AS
SELECT COUNT(*) as total FROM safe_nums_2 WHERE x_num IS NULL AND CARDINALITY(SPLIT(item, ' ')) = ABS(sum_val) + 1;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM safe_nums_4;
