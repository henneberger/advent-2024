-- We have to maintain a uuid to keep partitions unique, also flink has no simple way to remove items
-- from arrays consistently.

CREATE TABLE input_table (
  item STRING,
  ts AS PROCTIME()
) WITH (
  'connector' = 'filesystem',
  'path' = '/Users/henneberger/advent-of-code/data/day2-input.txt',
  'format' = 'csv',
  'csv.field-delimiter' = ',',
  'csv.ignore-parse-errors' = 'true'
);

-- create enough entries to enumerate
CREATE TEMPORARY VIEW a AS
SELECT cast(split(item, ' ') as array<bigint>) as item, ts, ROW_NUMBER() OVER(PARTITION BY item ORDER BY ts) AS rn
FROM input_table i
CROSS JOIN unnest(split(i.item, ' ')) as x;

-- Create set to enumerate, we can exclude the original list since it'll be covered by the case where the ends are missing
CREATE TEMPORARY VIEW b AS
SELECT
 CASE
 WHEN rn = CARDINALITY(item) THEN array_slice(item, 2, CARDINALITY(item)) --remove first element
 ELSE array_concat(array_slice(item, 1, CAST(rn AS int)), array_slice(item, CAST(rn AS int)+2, CARDINALITY(item)))
 END AS item, item as original, ts, rn,  uuid() as uuid
FROM a;

-- Unnest array
 --add another record b/c lag can span partitions
CREATE TEMPORARY VIEW c AS
SELECT /*+ STATE_TTL('i'='1s', x='1s') */
 cast(x as bigint) - lag(cast(x as bigint)) over (partition by uuid order by ts) as y,
 item, original, ts, uuid FROM b
CROSS JOIN unnest(item) x;

-- [43, 40, 39, 35]

-- Keep it as a stream
CREATE TEMPORARY VIEW d AS
select /*+ STATE_TTL('a'='1s') */
 max(y > 3 or y = 0 or y < -3) OVER (partition by uuid order by ts) as unsafe,
 case when y > 0 then 1 else 0 end strict_asc,
 case when y < 0 then 1 else 0 end strict_desc,
  *
from c;

create temporary view e as
select count(distinct original) as total from (
  select original, uuid, item, max(unsafe) as is_unsafe, sum(strict_asc), sum(strict_desc), count(*)
  from d
  group by original, uuid, item
  having not max(unsafe) and (sum(strict_asc) = count(*) - 1 or sum(strict_desc) = count(*) - 1)
);

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM e;

