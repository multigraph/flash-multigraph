<?php

// This script takes URLs of the form
// 
//     http://linux0.nemac.unca.edu/swdev/mbp/trunk/tests/test4/data/x0,x1
// 
// and should return a response of the form
// 
//     <mugl>
//       <data>
//         <values>
//           x,y
//           ...
//         </values>
//       </data>
//     </mugl>
//  

header("Content-Type: text/xml");

// Explode the arguement string into an array
$components = array_filter(explode('/', $_SERVER['PATH_INFO']));

$x  = explode(',', $components[1]);
$x0 = $x[0];
$x1 = $x[1];

$minBuffer = 0;
$maxBuffer = 0;
if ($components[2] != null) {
  $bufarray = explode(',',$components[2]);
  $minBuffer = $bufarray[0];
  $maxBuffer = $bufarray[1];
}

?>
<mugl>
  <data>
    <values>
<?

$i = floor($x0);
if ($i != $x0) { $i = $i + 1; }
$imax = floor($x1);

while ($i <= $imax) {
  printf("%1d,%f,%f\n", $i, sin($i), cos($i));
  $i = $i + 1;
}

?>
    </values>
  </data>
</mugl>
