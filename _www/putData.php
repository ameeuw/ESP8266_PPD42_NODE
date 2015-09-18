<?php
// Write values and sensor id into variables
$date = date_create();
$timestamp = date_timestamp_get($date);
$sensor = $_GET["s"];
$value = $_GET["v"];
$filename = 'val_'.$sensor.'.csv';

// Echo back filename, sensor id and value
echo "Writing Sensor data to ''".$filename."''<br>";
echo "Sensor: ";
echo $sensor;
echo "<br>Value: ";
echo $value;

// Open according datafile and append timestamp, sensor and value
$handle = fopen($filename, "a");
$line = array($timestamp,$sensor, $value);
fputcsv($handle, $line);
fclose($handle);
?>