<?php
$myfile = fopen("daily", "r") or die("Unable to open times file!");

$ADawn    = substr(fgets($myfile),0,5);  //substr($myfile, 0, 5);
$NDawn    = substr(fgets($myfile),0,5);  //substr($myfile, 6, 5);
$CDawn    = substr(fgets($myfile),0,5);  //substr($myfile, 12, 5);
$SRise    = substr(fgets($myfile),0,5);  //substr($myfile, 18, 5);
$SSet     = substr(fgets($myfile),0,5);  //substr($myfile, 24, 5);
$CSet     = substr(fgets($myfile),0,5);  //substr($myfile, 30, 5);
$NSet     = substr(fgets($myfile),0,5);  //substr($myfile, 36, 5);
$ASet     = substr(fgets($myfile),0,5);  //substr($myfile, 42, 5);
$VDay     = substr(fgets($myfile),0,5);  //substr($myfile, 52, 5);
$VNight   = substr(fgets($myfile),0,5);  //substr($myfile, 58, 5);
$VidAM    = $VNight;  //substr($myfile, 58, 5);
$VidPM    = $VNight;  //substr($myfile, 58, 5);
$CamAM    = substr(fgets($myfile),0,5);  //substr($myfile, 64, 5);
$CamPM    = substr(fgets($myfile),0,5);  //substr($myfile, 70, 5);
$ShotTime = substr(fgets($myfile),0,5);  //substr($myfile, 79, 1);

fclose($myfile);

function getCPUTemperature() {
  // Get the CPU temperature
  $f = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
  $CPUtemp = fgets($f);
  $CPUtemp = round($CPUtemp / 1000, PHP_ROUND_HALF_UP); //round the results
  fclose($f);

  return $CPUtemp;
}

// This requires the one wire temperature module (which I haven't got, but should get for testing, etc)
function getOutsideTemperature() {
  // Get the outside temperature.  Comment this section out if you are not using a DS18B20 sensor
  $handle = fopen("/sys/bus/w1/devices/w1_bus_master1/w1_master_slaves", "r");
  if ($handle) {
    while (($sensors = fgets($handle)) !== false) {
      $sensor = "/sys/bus/w1/devices/".trim($sensors)."/w1_slave";
      $sensorhandle = fopen($sensor, "r");
      if ($sensorhandle) {
        $thermometerReading = fread($sensorhandle, filesize($sensor));
        // We want the value after the t= on the 2nd line
        preg_match("/t=(.+)/", preg_split("/\n/", $thermometerReading)[1], $matches);
        $celsius = round($matches[1] / 1000, PHP_ROUND_HALF_UP); //round the results
        $fahrenheit = round($celsius * 9 / 5 + 32, PHP_ROUND_HALF_UP);
        echo "Outside Temp: $celsius &deg;C / $fahrenheit &deg;F";
        $sensors++;
      } else {
//      print "No temperature read!";
      }
      fclose($sensorhandle);
    }
    fclose($handle);
  } else {
      print "No sensors found!";
  }
}
?>
