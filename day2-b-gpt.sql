-- This gpt-refactored solution is also incorrect (missing 4 values), but so it goes

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

CREATE TEMPORARY VIEW unnested_cleaned AS
SELECT *, ROW_NUMBER() OVER(PARTITION BY item ORDER BY ts) AS rn FROM cleaned i
-- Todo: probably shouldn't append a null here, but rather later. Causes issues w/ double counting
CROSS JOIN unnest(ARRAY_APPEND(SPLIT(i.item, ' '), null)) x;

CREATE TEMPORARY VIEW cleaned_2 AS
SELECT
 CASE
 WHEN rn = 1 THEN array_slice(i, 2, CARDINALITY(i))
 WHEN rn = CARDINALITY(i) THEN array_slice(i, 1, CARDINALITY(i)-1)
 WHEN rn = CARDINALITY(i)+1 THEN i
 ELSE array_concat(array_slice(i, 1, CAST(rn AS int)), array_slice(i, CAST(rn AS int)+2, CARDINALITY(i)))
 END AS item2, item, ts
FROM unnested_cleaned;

CREATE TEMPORARY VIEW cleaned_3 AS
SELECT
    item,
    item2
  FROM (
    -- Split each report into individual levels with their positions
    select * FROM (
      SELECT
        item,
        item2,
        ts,
        CAST(x AS INT) AS current_level,
        CAST(LAG(x) OVER (PARTITION BY item2 ORDER BY ts) AS INT) AS next_level
      FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY item2 ORDER BY ts) AS pos
        FROM (
          SELECT
            i.item2,
            i.item,
            t.x,
            *
          FROM cleaned_2 i
          CROSS JOIN UNNEST(ARRAY_APPEND(i.item2, null)) AS t(x) --Note WITH ORDINALITY seems broken in flink
        )
      )
    )
  )
  -- Filter out the last level as it has no next_level
  WHERE next_level IS NOT NULL
  GROUP BY item2, item
  HAVING
    -- Check if all differences are consistently increasing by 1-3 or decreasing by 1-3
    (
      MIN(next_level - current_level) >= 1 AND
      MAX(next_level - current_level) <= 3
    )
    OR
    (
      MIN(next_level - current_level) >= -3 AND
      MAX(next_level - current_level) <= -1
    );


CREATE TEMPORARY VIEW safe_nums_5 AS
SELECT COUNT(*) AS total_safe_reports FROM (SELECT DISTINCT item FROM cleaned_3);


-- Create the print sink to output the result
CREATE TABLE print_sink (
  total_safe_reports BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total_safe_reports
FROM safe_nums_5;

