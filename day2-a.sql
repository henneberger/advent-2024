-- Keep everything as windows except final count, add state ttl

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
CREATE TEMPORARY VIEW a AS
SELECT /*+ STATE_TTL('i'='1s', x='1s') */
 cast(x as bigint) - lag(cast(x as bigint)) over (partition by item order by ts) as y,
 item, ts FROM input_table i
CROSS JOIN unnest(SPLIT(i.item, ' ')) x;

-- Keep it as a stream
CREATE TEMPORARY VIEW b AS
select /*+ STATE_TTL('a'='1s') */
 max(y > 3 or y = 0 or y < -3) OVER (partition by item order by ts) as unsafe,
 case
   when sum(case when y > 0 then 1 else 0 end) OVER (partition by item order by ts) = count(y) OVER (partition by item order by ts) THEN false
   when sum(case when y < 0 then 1 else 0 end) OVER (partition by item order by ts) = count(y) OVER (partition by item order by ts) THEN false
   ELSE true
 end as not_strictly_asc_desc,
  *
from a;

CREATE TEMPORARY VIEW c AS
select count(*) as total from (
  select item, max(unsafe) as m
  from b
  group by item
  having not max(unsafe) and not max(not_strictly_asc_desc)
);

CREATE TABLE print_sink (
  total BIGINT
) WITH (
  'connector' = 'print'
);

INSERT INTO print_sink
SELECT total
FROM c;
