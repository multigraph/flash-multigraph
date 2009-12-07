<?php

// This script takes URLs of the form
// 
//     http://linux0.nemac.unca.edu/swdev/mbp/trunk/tests/test4/data/YYYYMMDDHHmm,YYYYMMDDHHmm
// 
// and should return a response of the form
// 
//     <mugl>
//       <data>
//         <values>
//           YYYYMMDDHHmm,TEMP
//           ...
//         </values>
//       </data>
//     </mugl>
//  
//  where the contents "<values>" element consists of the data from the
//  file "data.csv" between the two timestamps in the URL.
//  
//  For example, the URL:
//  
//      http://linux0.nemac.unca.edu/swdev/mbp/trunk/tests/test4/data/200801010000,200801010100
//
//  should generate the response:
//      <mugl>
//        <data>
//          <values>
//            200801010000,6.8
//            200801010005,6.9
//            200801010010,7
//            200801010015,6.8
//            200801010020,6.5
//            200801010025,6.8
//            200801010030,6.7
//            200801010035,6.8
//            200801010040,6.7
//            200801010045,6.7
//            200801010050,6.8
//            200801010055,6.5
//            200801010100,6.6
//          </values>
//        </data>
//      </mugl>

$fp = fopen("php://stderr", "r+");

fputs($fp, "data.php starting\n");

header("Content-Type: text/xml");

// Explode the arguement string into an array
$components = array_filter(explode('/', $_SERVER['PATH_INFO']));

$times = explode(',', $components[1]);
$start = $times[0];
$end   = $times[1];

$start = substr($start, 0, 12);
$end   = substr($end,   0, 12);

$minBuffer = 0;
$maxBuffer = 0;
if ($components[2] != null) {
  $bufarray = explode(',',$components[2]);
  $minBuffer = $bufarray[0];
  $maxBuffer = $bufarray[1];
}

fprintf($fp, "[start,end] = [%s,%s]\n", $start, $end);

// print "\n\n";
// print "start = $start\n";
// print "end = $end\n";
// print "\n\n";

?>
<mugl>
  <data>
    <values>
<?

$handle = fopen("data.csv", "r") or die("Can't open file.");
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

?>
    </values>
  </data>
</mugl>

<?

fputs($fp, "data.php done\n");
fclose($fp);

// // Move all the elements into a new array so that the first index is 0
// for ($i = 0; $i < sizeOf($components); ++$i) {
//    $comp[$i] = $components[$i+1];
//    if (strstr($comp[$i], ",")) {
//        $cs = explode(',', $comp[$i]);
//        $comp["start"] = $cs[0];
//        $comp["end"] = $cs[1];
//    }
// }
// 
// // print_r($comp);
// // echo "<br><br>";
// 
// // Output will hold the final dataset, x is just a place holder
// $output; $x = 0;
// 
// // Open the file for reading only
// $handle = fopen("data.csv", "r") or die("Can't open file.");
// while (!feof($handle)) {
//   // Save the pointer to the previous line
//   $fpointer = ftell($handle);
//   $line = fgetcsv($handle);
// 
//   if($line[0] == $comp["start"]){
//     // Set the file pointer to the previous line
//     fseek($handle, $fpointer);
//     
//     // Copy the lines until the second timestamp argument is reached
//     while ($line[0] != $comp["end"]) {
//       $line = fgetcsv($handle);
//       $output[$x] = $line;
//       $x++;
//     }
//   }
// }
// fclose($handle);
// 
// header("Content-Type: text/xml");
// 
// echo <<<EOF
// <multigraph>
//   <data>
//     <format>
//       <variable id="xvar" column="0" type="datetime"/>
//       <variable id="yvar" column="1"/>
//     </format>
//     <values>
// EOF;
// 
// for ($x = 0; $x < sizeOf($output); $x++) {
//   echo $output[$x][0] . " " . $output[$x][1] . "\r\n";
// }
// 
// echo <<<EOF
//     </values>
//   </data>
// </multigraph>
// EOF;

?>
