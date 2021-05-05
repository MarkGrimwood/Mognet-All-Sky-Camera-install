<!DOCTYPE html>
<?php
include 'fileread.php';
?>
<html>
  <head>
    <meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Sky Camera</title>
    <link rel="stylesheet" href="mgasc.css" type="text/css">
  </head>
  <body>
    <h1>Raspberry Pi All Sky Camera</h1>
    <noscript>Some pages will only work correctly when JavaScript is enabled</noscript>
    <ul class='indexpage'>
      <li><a href="currentview.html">Current View</a><br>
      <li>
      <table>
        <th class='tableitemleftalign'>Period</th><th>Video</th><th>Images</th>
        <tr>
          <td class='tableitemleftalign'>Latest night</td>
          <td><a href="night/movienight.mp4">Video</a></td>
          <td><a href="shotlist.php?period=current&source=night">Images</a></td>
        </tr>
        <tr>
          <td class='tableitemleftalign'>Latest day</td>
          <td><a href="day/movieday.mp4">Video</a></td>
          <td><a href="shotlist.php?period=current&source=day">Images</a></td>
        </tr>
<?php
// Directory existance check
$dirPath = "/var/www/html/history";
$dir = opendir($dirPath) or die("Cannot open directory ".$dirPath);

// First we have to read the directory names into a table as they don't come back in order
while (!(($directoryName = readdir($dir)) === false)) {
  // For some reason is_file doesn't show files as being files (see notes on www.php.net) But is_dir seems to work ok for our needs
  if (is_dir($dirPath."/".$directoryName) && (strstr($directoryName, "day") || strstr($directoryName, "night"))) {
    $directoryList[] = $directoryName;
  }
}

// And close up now we've done reading the directory
closedir($dir);

rsort($directoryList, SORT_NATURAL);

foreach ($directoryList as $directoryItem) {
  print("<tr>");
  $fh = fopen($dirPath."/".$directoryItem."/info", "r") or die("Couldn't open info file for ".$directoryItem);
  $infoTimestamp = fgets($fh);
  fclose($fh);

  print("<td class='tableitemleftalign'>".(strstr($directoryItem, "night") ? "Night" : "Day")." starting ".(date('l jS \of F Y h:i A', substr($infoTimestamp, 6)))."</td>");
  print("<td><a href='history/".$directoryItem."/movie".(strstr($directoryItem, "night") ? "night" : "day").".mp4'>Video</a></td>");
  print("<td><a href='shotlist.php?period=history&source=".$directoryItem."'>Images</a></td>");
  print("</tr>");
}

?>
      </table>
      </li>
      <br>
      <li><a href="suntimes.php">Sunrise, Sunset & Twilight Times</a></li><br>
      <li><a href="about.html">About</a></li><br>
    </ul>
  </body>
</html>
