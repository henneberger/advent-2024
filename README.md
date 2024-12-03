# Advent of Code 2024 but in Flink SQL

Why Flink? Because it can be difficult to express some problems as streaming sql. It is also a very constrained SQL env which can be fun.

## How to run
Download flink, start the cluster. Either submit the job through the sql-client (`sql-client.sh embedded -f day1-a.sql`) and then do a `tail -n 100 flink-*-taskexecutor-0-*.out` in the flink log.

OR

Run it line-by-line in the sql-client.

## Notes
Flink lacks some basic functions we'll have to make them but we'll keep it basic.