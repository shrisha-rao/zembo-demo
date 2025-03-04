DECLARE column_names ARRAY<STRING>;
DECLARE column_count INT64;
DECLARE total_rows INT64;
DECLARE dynamic_sql STRING;

SET column_names = (
  SELECT ARRAY_AGG(column_name)
  FROM `zembo-demo.preprocessed_data.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = 'battery_data'
);

SET column_count = ARRAY_LENGTH(column_names);

IF column_count > 0 THEN
  SET dynamic_sql = (
    SELECT """
    SELECT
      COUNT(*) AS total_rows
    FROM
      `zembo-demo.preprocessed_data.battery_data`
    """
  );

  EXECUTE IMMEDIATE dynamic_sql INTO total_rows;

  EXECUTE IMMEDIATE (
    SELECT """
    SELECT
      'total_rows' AS metric,
      CAST(""" || CAST(total_rows AS STRING) || """ AS STRING) AS value,
      CAST(NULL AS FLOAT64) AS percentage_missing
    UNION ALL
    """ || (SELECT STRING_AGG(CONCAT("""
    SELECT
      '""", column_name, """' AS metric,
      CAST(COUNT(CASE WHEN """, column_name, """ IS NULL THEN 1 ELSE NULL END) AS STRING) AS value,
      CAST(COUNT(CASE WHEN """, column_name, """ IS NULL THEN 1 ELSE NULL END) / CAST(""", total_rows, """ AS FLOAT64) * 100 AS FLOAT64) AS percentage_missing
    FROM
      `zembo-demo.preprocessed_data.battery_data`"""), " UNION ALL ") FROM UNNEST(column_names) AS column_name) || """
    ORDER BY
      percentage_missing ASC NULLS LAST
      LIMIT 15

    """
  );
ELSE
  SELECT "Table not found or has no columns.";
END IF;



SELECT   
  Extract(week from timestamp) AS week,
  count(distinct devId) as num_batteries
FROM `zembo-demo.zembo_data.battery-data`
WHERE devId LIKE 'BGU%'  
AND timestamp IS NOT NULL
GROUP BY week ORDER BY week;



-- ALTER TABLE `zembo-demo.zembo_data.battery-data`
-- ADD COLUMN timestamp TIMESTAMP;

-- UPDATE `zembo-demo.zembo_data.battery-data`
-- SET timestamp = SAFE.TIMESTAMP(_time)
-- WHERE _time IS NOT NULL;




  