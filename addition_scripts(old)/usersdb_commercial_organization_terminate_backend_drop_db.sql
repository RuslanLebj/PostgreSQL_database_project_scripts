SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'usersdb_commercial_organization';
DROP DATABASE usersdb_commercial_organization;