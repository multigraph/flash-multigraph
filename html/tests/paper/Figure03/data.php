<?php
$fp = fopen("php://stderr", "r+");

fputs($fp, "data.php starting\n");

header("Content-Type: text/xml");

// Explode the arguement string into an array
$components = array_filter(explode('/', $_SERVER['PATH_INFO']));

$times = explode(',', $components[1]);
$start = substr($times[0], 0, 12);
$end   = substr($times[1], 0, 12);

$minBuffer = 0;
$maxBuffer = 0;
if ($components[2] != null) {
  $bufarray = explode(',',$components[2]);
  $minBuffer = $bufarray[0];
  $maxBuffer = $bufarray[1];
}

fprintf($fp, "[start,end] = [%s,%s]\n", $start, $end);

$handle = fopen("../1026-T5-P5.csv", "r") or die("Can't open file.");
$done    = 0;
$inrange = 0;
while (!feof($handle) && !$done) {
  $line = fgetcsv($handle);
  if ($line[0] >= $start) {
	$inrange = 1;
  }
  if ($inrange) {
	printf("%s,%s\n", $line[0],$line[1]);
  }
  if ($inrange && ($line[0] >= $end)) {
	$done = 1;
  }
}
fclose($handle);

fputs($fp, "data.php done\n");
fclose($fp);
?>
