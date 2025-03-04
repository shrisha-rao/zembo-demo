DECLARE column_validations ARRAY<STRUCT<column_name STRING, data_type STRING, min_value NUMERIC, max_value NUMERIC, regex STRING>>;

-- Define column validations
SET column_validations = [
  ('soc', 'FLOAT64', 0.0, 100.0, NULL),     -- State of Charge O: 0.0 to 100.0
  ('temperature', 'INT64', -20, 50, NULL),     -- Temperature: 6800 - 8328
  ('status', 'STRING', NULL, NULL, r'^[A-Za-z]+$'), -- Status: Only alphabetic characters
  ('charge_level', 'INT64', 0, 100, NULL) -- Charge Level: 0 to 100
];

EXECUTE IMMEDIATE (
  SELECT STRING_AGG(
    CASE
      WHEN validation.data_type = 'INT64' OR validation.data_type = 'FLOAT64' THEN
        CONCAT(
          "SELECT '", validation.column_name, "' AS column_name, 'Out of Range' AS issue, COUNT(*) AS count FROM `zembo-demo.zembo_data.battery-data` WHERE ",
          validation.column_name, " < ", CAST(validation.min_value AS STRING), " OR ", validation.column_name, " > ", CAST(validation.max_value AS STRING)
        )
      WHEN validation.data_type = 'STRING' AND validation.regex IS NOT NULL THEN
        CONCAT(
          "SELECT '", validation.column_name, "' AS column_name, 'Invalid Format' AS issue, COUNT(*) AS count FROM `zembo-demo.zembo_data.battery-data` WHERE NOT REGEXP_CONTAINS(",
          validation.column_name, ", r'", validation.regex, "')"
        )
      ELSE
        NULL -- Skip columns without defined checks
    END,
    " UNION ALL "
  )
  FROM UNNEST(column_validations) AS validation
  WHERE
    CASE
      WHEN validation.data_type = 'INT64' OR validation.data_type = 'FLOAT64' THEN TRUE
      WHEN validation.data_type = 'STRING' AND validation.regex IS NOT NULL THEN TRUE
      ELSE FALSE
    END
  ORDER BY count ASC
);