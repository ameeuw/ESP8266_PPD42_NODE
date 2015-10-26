<?php
// .../putData.php?sensor=s1$value=
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
if (file_exists($filename))
{
	$handle = fopen($filename, "a");
	$line = array($timestamp,$sensor, $value);
	fputcsv($handle, $line);
}
else
{
	$handle = fopen($filename, "a");
	$line = array('timestamp', 'sensor', 'value');
	fputcsv($handle, $line);
	$line = array($timestamp,$sensor, $value);
	fputcsv($handle, $line);
}
fclose($handle);
?>