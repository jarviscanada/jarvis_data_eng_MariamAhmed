-- order hosts by CPU count, then by total memory
SELECT id AS host_id, cpu_number, total_mem
FROM host_info
ORDER BY cpu_number ASC, total_mem DESC;


-- average used memory per host over 5-minute intervals
-- total_mem is in kB and memory_free is in MB so total_mem needs to be converted
SELECT
    host_usage.host_id,
    hostname,
    date_trunc('hour', host_usage."timestamp")
        + (date_part('minute', host_usage."timestamp")::int / 5) * interval '5 minutes' AS ts_5min,
    round(avg(100.0 * (1 - memory_free / (total_mem / 1024.0))), 1) AS avg_used_mem
FROM host_usage
JOIN host_info ON host_usage.host_id = host_info.id
GROUP BY host_usage.host_id, hostname, ts_5min
ORDER BY host_usage.host_id, ts_5min;


-- host failure = fewer than 3 data points in a 5-minute interval
SELECT
    host_id,
    date_trunc('hour', "timestamp")
        + (date_part('minute', "timestamp")::int / 5) * interval '5 minutes' AS ts_5min,
    count(*) AS num_data_points
FROM host_usage
GROUP BY host_id, ts_5min
HAVING count(*) < 3
ORDER BY host_id, ts_5min;