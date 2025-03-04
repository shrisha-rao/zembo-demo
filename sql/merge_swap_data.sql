CREATE OR REPLACE TABLE `zembo-demo.zembo_data.merged_swap_data` AS
WITH SwapInData AS (
  SELECT
    battery_id AS swap_in_battery_id,
    swap_in_SOC,
    swap_in_date
  FROM
    `zembo-demo.zembo_data.swap_in_data`
),
SwapOutData AS (
  SELECT
    battery_id AS swap_out_battery_id,
    swap_out_SOC,
    swap_out_date
  FROM
    `zembo-demo.zembo_data.swap_out_data`
),
SwapOutWithPreviousIn AS (
  SELECT
    SwapOutData.swap_out_battery_id AS battery_id,
    SwapOutData.swap_out_SOC AS swap_out_SOC,
    SwapOutData.swap_out_date AS swap_out_date,
    LAG(SwapInData.swap_in_date) OVER (PARTITION BY SwapOutData.swap_out_battery_id ORDER BY SwapOutData.swap_out_date) AS previous_swap_in_date,
    LAG(SwapInData.swap_in_SOC) OVER (PARTITION BY SwapOutData.swap_out_battery_id ORDER BY SwapOutData.swap_out_date) AS previous_swap_in_SOC
  FROM
    SwapOutData
  LEFT JOIN
    SwapInData
  ON SwapOutData.swap_out_battery_id = SwapInData.swap_in_battery_id AND SwapInData.swap_in_date < SwapOutData.swap_out_date
),
MergedSwap AS (
  SELECT
    SwapOutWithPreviousIn.battery_id,
    SwapOutWithPreviousIn.previous_swap_in_SOC AS swap_in_SOC,
    SwapOutWithPreviousIn.previous_swap_in_date AS swap_in_date,
    SwapOutWithPreviousIn.swap_out_SOC AS swap_out_SOC,
    SwapOutWithPreviousIn.swap_out_date AS swap_out_date,
    SwapOutWithPreviousIn.swap_out_SOC - SwapOutWithPreviousIn.previous_swap_in_SOC AS soc_difference
  FROM
    SwapOutWithPreviousIn
  WHERE SwapOutWithPreviousIn.previous_swap_in_date is not null
)
SELECT
  *
FROM
  MergedSwap
ORDER BY
  swap_out_date ASC;