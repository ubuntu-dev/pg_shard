-- ===================================================================
-- test INSERT proxy creation functionality
-- ===================================================================

-- create the target table
CREATE TABLE insert_target (
	id bigint PRIMARY KEY,
	data text NOT NULL DEFAULT 'lorem ipsum'
);

-- use transaction to permit multiple calls to proxy function in one session
BEGIN;

-- create proxy and save proxy table name
SELECT create_insert_proxy_for_table('insert_target') AS proxy_tablename
\gset

-- insert to proxy, relying on default value
INSERT INTO pg_temp.:"proxy_tablename" (id) VALUES (1);

-- copy some rows into the proxy
COPY pg_temp.:"proxy_tablename" FROM stdin;
2	dolor sit amet
3	consectetur adipiscing elit
4	sed do eiusmod
5	tempor incididunt ut
6	labore et dolore
\.

-- verify rows were copied to target
SELECT * FROM insert_target ORDER BY id ASC;

-- and not to proxy
SELECT count(*) FROM pg_temp.:"proxy_tablename";

ROLLBACK;

BEGIN;

-- create proxy, passing sequence this time
CREATE TEMPORARY SEQUENCE rows_inserted;
SELECT create_insert_proxy_for_table('insert_target', 'rows_inserted') AS proxy_tablename
\gset

-- do insert and COPY again
INSERT INTO pg_temp.:"proxy_tablename" (id) VALUES (1);
COPY pg_temp.:"proxy_tablename" FROM stdin;
2	dolor sit amet
3	consectetur adipiscing elit
4	sed do eiusmod
5	tempor incididunt ut
6	labore et dolore
\.

-- verify counter matches row count
SELECT (SELECT count(*) FROM insert_target) = currval('rows_inserted') AS count_correct;

ROLLBACK;
