# Advent of Code 2024 but in Flink SQL

Why Flink? Because it can be difficult to express some problems as streaming sql. It is also a very constrained SQL env which can be fun.

## How to run
Download flink, start the cluster. Either submit the job through the sql-client (`sql-client.sh embedded -f day1-a.sql`) and then do a `tail -n 100 flink-*-taskexecutor-0-*.out` in the flink log.

OR

Run it line-by-line in the sql-client.

## GPT notes
I will sometimes play around with gpt solutions AFTER I solved them by hand. This is mostly for refactoring to discover more concise solutions.
