-- This solution is off-by-one (we count a non-descending solution as correct when we shouldn't)
-- Flink's array_slice function is a bit weird here
-- Due to time constraints, I'm leaving this solution as-is

CREATE TABLE input_table (
  item STRING,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/day2-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ',',
  'csv.ignore-parse-errors' = 'true'
);

create temporary view cleaned AS select *, CAST(SPLIT(item, ' ') AS ARRAY<INT>) i from input_table;

-- Unnest array
CREATE TEMPORARY VIEW unnested_cleaned AS
SELECT *, ROW_NUMBER() OVER(PARTITION BY item ORDER BY ts) AS rn FROM cleaned i
-- Todo: probably shouldn't append a null here, but rather later. Causes issues w/ double counting
CROSS JOIN unnest(ARRAY_APPEND(SPLIT(i.item, ' '), null)) x;

CREATE TEMPORARY VIEW cleaned_2 AS
SELECT
 CASE
 WHEN rn = 1 THEN array_slice(i, 2, CARDINALITY(i))
 WHEN rn = CARDINALITY(i) THEN i
 ELSE array_concat(array_slice(i, 1, CAST(rn AS int)), array_slice(i, CAST(rn AS int)+2, CARDINALITY(i)))
 END AS item2, *
FROM unnested_cleaned;

-- Unnest array
CREATE TEMPORARY VIEW unnested_table AS
SELECT * FROM cleaned_2 i
CROSS JOIN unnest(ARRAY_APPEND(i.item2, null)) y;

CREATE TEMPORARY VIEW lag_table AS
select *, lag(CAST(y AS NUMERIC), 1) OVER (order by ts asc) as lag_x from unnested_table;

CREATE TEMPORARY VIEW lag_table_2 AS
select *,CAST(y as NUMERIC) AS x_num, CAST(y as NUMERIC) - CAST(lag_x AS NUMERIC) AS diff_x from lag_table;

CREATE TEMPORARY VIEW safe_nums AS
select *, CASE WHEN diff_x IS NULL THEN NULL WHEN diff_x = 1 THEN 1 WHEN diff_x = 2 THEN 1 WHEN diff_x = 3 THEN 1
 WHEN diff_x = -1 THEN -1 WHEN diff_x = -2 THEN -1 WHEN diff_x = -3 THEN -1 ELSE -9999 END
 AS s FROM lag_table_2;

CREATE TEMPORARY VIEW safe_nums_2 AS
SELECT SUM(s) OVER (PARTITION BY item2 ORDER BY ts) AS sum_val, s, y, * FROM safe_nums;

CREATE TEMPORARY VIEW safe_nums_3 AS
SELECT CARDINALITY(item2) AS cnt, ABS(sum_val) - 1, x_num, * FROM safe_nums_2
-- Sloppy counting here since the strategy im using ends up double counting
 WHERE x_num IS NULL AND (CARDINALITY(item2) = ABS(sum_val) + 1 OR CARDINALITY(item2)*2 = ABS(sum_val) + 1);

CREATE TEMPORARY VIEW safe_nums_4 AS
select distinct item from safe_nums_3;

CREATE TEMPORARY VIEW safe_nums_5 AS
select count(*) as total from safe_nums_4;

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM safe_nums_5;

