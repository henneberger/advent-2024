-- More efficient solution, ChatGPT-o1 inspired

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

-- Create the print sink to output the result
CREATE TABLE print_sink (
  total_safe_reports BIGINT
) WITH (
  'connector' = 'print'
);

-- Insert the count of safe reports into the print sink
INSERT INTO print_sink
SELECT COUNT(*) AS total_safe_reports
FROM (
  SELECT
    item
  FROM (
    -- Split each report into individual levels with their positions
    SELECT
      item,
      CAST(x AS INT) AS current_level,
      CAST(LAG(x) OVER (PARTITION BY item ORDER BY ts) AS INT) AS next_level
    FROM (
      SELECT *, ROW_NUMBER() OVER (PARTITION BY item ORDER BY ts) AS pos
      FROM (
        SELECT
          i.item,
          t.x,
          *
        FROM input_table i
        CROSS JOIN UNNEST(SPLIT(i.item, ' ')) AS t(x) --Note WITH ORDINALITY seems broken in flink
      )
    )
  )
  -- Filter out the last level as it has no next_level
  WHERE next_level IS NOT NULL
  GROUP BY item
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
    )
) AS safe_reports;
