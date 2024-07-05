<!DOCTYPE html>
<?php
include 'fileread.php';

// Get the list and location from the URL parameter. Only requires one to be entered
$source = $_GET["source"];
$period = $_GET["period"];

if (strstr($source, "night")) {
  $displaySource = "Night";
} else {
  $displaySource = "Day";
}

if ($period == "history") {
  $htmlPath = "history/".$source."/";
  $fullPath = "/var/www/html/history/".$source."/";
} else {
  $htmlPath = $source."/";
  $fullPath = "/var/www/html/".$source."/";
  $period = "current";
}

?>
<html>
  <head>
    <meta charset="UTF-8">
    <name="viewport" content="width=device-width, initial-scale=1.0">
<?php print("<title>".$displaySource." Shot List</title>"); ?>
    <link rel="stylesheet" href="mgasc.css" type="text/css">
  </head>
<body>
<?php
print("<h1>".$displaySource." Photos</h1>");

// Directory existance check
$dir = opendir($fullPath) or die("Cannot open directory ".$fullPath);

// First we have to read the file names into a table as they don't come back in order
while (!(($fileName = readdir($dir)) === false)) {
  // For some reason is_file doesn't show files as being files (see notes on www.php.net) But is_dir seems to work ok for our needs
  if (!is_dir($fullPath."/".$fileName) && strstr($fileName, "webcam") && !strstr($fileName, "thumb")) {
    $fileList[] = $fileName;
  }
}

// And close the directory
closedir($dir);

natsort($fileList);

print(count($fileList)." images were taken during the $displaySource<br><br>");

if (count($fileList) > 0) {
  print("<section>");
  foreach($fileList as $fileItem) {
    $captureDate = date("H:i", substr($fileItem, strlen("webcam".$displaySource), 10));
    print("<div class='shotlist'>");
    print("<p class='shotlisttext'>".$captureDate."</p>");
    print("<a href='imagedisplay.php?period=$period&source=$source&image=$fileItem' title='$captureDate'><img class='shotlistimage' src='$htmlPath/thumb$fileItem' width='80' height='60'></a>");
    print("</div>");
  }
  print("</section");
}
?>

</body>
</html>
