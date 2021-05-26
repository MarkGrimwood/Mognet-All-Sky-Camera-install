<html>
  <head>
    <meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Sky Camera - Sun Rise and Set Times</title>
    <link rel="stylesheet" href="mgasc.css" type="text/css">
  </head>
</html>
<?php
include 'fileread.php';

// ***************************************************************
// Get the local gps coordinates
$gpsfile = fopen("gps", "r") or die("Unable to open file!");
$lat=trim(fgets($gpsfile));
$lon=trim(fgets($gpsfile));
fclose($gpsfile);
// ***************************************************************

echo "<h1>Sun Times - Camera & Video Modes</h1>";
echo date('D d M Y')." GPS: $lat, $lon";

// ***************************************************************
echo '
  <table>
    <tbody>
        <tr>
            <th class="tableitemleftalign">Sun Position</th>
            <th>Angle</th>
            <th>Mode</th>
            <th>HH:MM</th>
        </tr>
        <tr>
            <td class="tableitemleftalign">Astronomical Dawn</td>
            <td>-18&#176;</td>
            <td>N</td>
            <td>'.$ADawn.'</td>
        </tr>

        <tr>
            <td class="tableitemleftalign">Nautical Dawn</td>
            <td>-12&#176;</td>
            <td>N</td>
            <td>'.$NDawn.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Day Video start</td>
            <td></td>
            <td>D</td>
            <td>'.$VDay.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Civil Dawn</td>
            <td>-06&#176;</td>
            <td>D</td>
            <td>'.$CDawn.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Sunrise</td>
            <td>0&#176;</td>
            <td>D</td>
            <td>'.$SRise.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Sunset</td>
            <td>0&#176;</td>
            <td>D</td>
            <td>'.$SSet.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Civil Set</td>
            <td>-06&#176;</td>
            <td>N</td>
            <td>'.$CSet.'</td>
        </tr>
	<tr>
            <td class="tableitemleftalign">Night Video start</td>
            <td></td>
            <td>N</td>
            <td>'.$VNight.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Nautical Set</td>
            <td>-12&#176;</td>
            <td>N</td>
            <td>'.$NSet.'</td>
        </tr>
        <tr>
            <td class="tableitemleftalign">Astronomical Set</td>
            <td>-18&#176;</td>
            <td>N</td>
            <td>'.$ASet.'</td>
        </tr>
     </tbody>
</table>';
?>

<br>
Camera Mode: N=Night, D=Day<br>
<br>
<a href="https://www.timeanddate.com/sun/" target='_blank'>Find the true sun times where you are</a><br>
<a href="https://clearoutside.com/forecast/<?php
print((substr($lat,-1)=="N") ? substr($lat,0,-1) : -substr($lat,0,-1));
print("/");
print((substr($lon,-1)=="E") ? substr($lon,0,-1) : -substr($lon,0,-1));
print("/");
?>" target='_blank'>Clear Outside forecast for your location</a><br>
