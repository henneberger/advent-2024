# Advent of Code 2024 but in Flink SQL

Why Flink? Because it can be difficult to express some problems as streaming sql. It is also a very constrained SQL env which can be fun.

## Notes
Goals:
- Use joins 'correctly' in flink
- Minimize streaming state
- Use standard functions when possible
- New functions should be general purpose
- Clear and easy to read solutions

Non-goals:
- Advanced tuning like ttl
- Flink job optimization tricks
- Input data purity - I may munge the data slightly because of flink (timestamp) limitations

Other Notes:
- Day 5 is the first puzzle that requires a join. `day5-time.sql` uses all correct stream semantics but adds timestamps to the dataset.

## How to run
Download flink, start the cluster. Either submit the job through the sql-client (`sql-client.sh embedded -f day1-a.sql`) and then do a `tail -n 100 flink-*-taskexecutor-0-*.out` in the flink log.

OR

Run it line-by-line in the sql-client.
