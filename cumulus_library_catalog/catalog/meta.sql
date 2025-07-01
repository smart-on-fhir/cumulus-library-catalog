CREATE TABLE catalog__meta_date AS

SELECT
    min_date,
    max_date
FROM core__meta_date;

CREATE TABLE catalog__meta_version AS
SELECT 1 AS data_package_version;
