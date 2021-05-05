<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Sky Camera - Image Display</title>
    <link rel="stylesheet" href="mgasc.css" type="text/css">
  </head>
<body>
<noscript>This page will only work when JavaScript is enabled</noscript>
<!-- This is how I want the screen to display the image and buttons -->
<!-- ----------------- -->
<!-- |   |       |   | -->
<!-- |   |       |   | -->
<!-- | L | IMAGE | R | -->
<!-- |   |       |   | -->
<!-- |   |       |   | -->
<!-- ----------------- -->

<div class = 'imageSection' id = 'imageSection'>
<img class = 'leftArrow' id = 'leftArrow' alt = 'Left arrow' title = 'Left arrow' onclick = 'displayPreviousImage()'>
<img class = 'image' id = 'image' alt = 'Image captured' title = 'Image captured'>
<img class = 'rightArrow' id = 'rightArrow' alt = 'Right arrow' title = 'Right arrow' onclick = 'displayNextImage()'>
</div>
</body>
</html>

<?php
// Pick up the passed parameters. Should really sanitise these, but should be ok not to
$source = $_GET["source"];
$period = $_GET["period"];
$image = $_GET["image"];

if ($period == "history") {
  $htmlPath = "history/".$source."/";
  $fullPath = "/var/www/html/history/".$source."/";
} else {
  $htmlPath = $source."/";
  $fullPath = "/var/www/html/".$source."/";
  $period = "current";
}

// Directory existance check
$dir = opendir($fullPath) or die("Cannot open directory ".$fullPath);

// First we have to read the file names into a table as they don't come back in order
while (!(($fileName = readdir($dir)) === false)) {
  // For some reason is_file doesn't show files as being files (see notes on www.php.net) But is_dir seems to work ok for our needs
  if (!is_dir("$fullPath/$fileName") && strstr($fileName, "webcam") && !strstr($fileName, "thumb")) {
    $fileList[] = $fileName;
  }
}

closedir($dir);

// We need the list in image order, same as in the shot list. And that alphanumeric order should coincide with the capture time
natsort($fileList);

// Use PHP to generate some of the JavaScript
print("<script>");
print("var arrFiles = [");
$firstDone = false;
foreach($fileList as $fileItem) {
  if ($firstDone == true) {
    print(",");
  } else {
    $firstDone = true;
  }
  print("'".$fileItem."'");
}
print("];");
print("var list = '$htmlPath';");
print("var image = '$image';");
print("</script>");
?>

<script>
// The image name is passed via the URL query string and through PHP to get here
var currentImageNumber = arrFiles.indexOf(image);

// Set initial state
document.getElementById("image").src = list + "/" + arrFiles[currentImageNumber];
checkArrowState();

function displayPreviousImage() {
  if (currentImageNumber - 1 >= 0) {
    document.getElementById("image").src = list + "/" + arrFiles[--currentImageNumber];
  }
  checkArrowState();
}

function displayNextImage() {
  if (currentImageNumber + 1 < arrFiles.length) {
    document.getElementById("image").src = list + "/" + arrFiles[++currentImageNumber];
  }
  checkArrowState();
}

function checkArrowState() {
  if (currentImageNumber > 0) {
    document.getElementById("leftArrow").src = "arrowLeftEnabled.gif";
  } else {
    document.getElementById("leftArrow").src = "arrowLeftDisabled.gif";
  }

  if (currentImageNumber < arrFiles.length - 1) {
    document.getElementById("rightArrow").src = "arrowRightEnabled.gif";
  } else {
    document.getElementById("rightArrow").src = "arrowRightDisabled.gif";
  }
}
</script>

