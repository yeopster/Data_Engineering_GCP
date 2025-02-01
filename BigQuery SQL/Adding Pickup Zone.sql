UPDATE `taxi-data-project-449307.taxi_data_engineering.taxi_analytics` AS target
SET 
  target.pickup_zone = subquery.pickup_zone,
  target.pickup_borough = subquery.pickup_borough
FROM (
  WITH TaxiZones AS (
    SELECT 
      zone_id, 
      zone_name, 
      borough, 
      zone_geom AS geom  
    FROM `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom`
  )
  SELECT 
      t.zone_name AS pickup_zone, 
      t.borough AS pickup_borough, 
      ST_GEOGPOINT(d.pickup_longitude, d.pickup_latitude) AS pickup_point
  FROM `taxi-data-project-449307.taxi_data_engineering.pickup_location_dim` d
  JOIN TaxiZones t 
  ON ST_CONTAINS(t.geom, ST_GEOGPOINT(d.pickup_longitude, d.pickup_latitude))
) AS subquery
WHERE ST_EQUALS(ST_GEOGPOINT(target.pickup_longitude, target.pickup_latitude), subquery.pickup_point);