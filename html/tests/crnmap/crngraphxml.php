<?
$components = array_filter(explode('/', $_SERVER['PATH_INFO']));
$station_id = $components[1];
$elements   = explode(',', $components[2]);
$times      = explode(',', $components[3]);
$start      = $times[0];
$end        = $times[1];

if ($end == "") {
  $end = gmdate("YmdH", strtotime("now"));
}
if ($start == "") {
  $YYYY = substr($end, 0, 4);
  $MM   = substr($end, 4, 2);
  $DD   = substr($end, 6, 2);
  $HH   = substr($end, 8, 2);
  $start  = gmdate("YmdH", gmmktime($HH, 0, 0, $MM, $DD, $YYYY) - 60*60*24);
}

$elementpresent = array();
for ($i=0; $i<count($elements); ++$i) {
  $elementpresent[$elements[$i]] = 1;
}

$axespresent = array();

$elements_5m = array();
if ($elementpresent[T5]) {
  array_push( $elements_5m, "T5" );
  $axespresent[temp] = 1;
}
if ($elementpresent[P5]) {
  array_push( $elements_5m, "P5" );
  $axespresent[precip] = 1;
}

$elements_1h = array();
if ($elementpresent[SOLARAD])  {
  array_push( $elements_1h, "SOLARAD" );
  $axespresent[solarad] = 1;
}
if ($elementpresent[SUR_TEMP]) {
  array_push( $elements_1h, "SUR_TEMP" );
  $axespresent[temp] = 1;
}
if ($elementpresent[WINDSPD])  {
  array_push( $elements_1h, "WINDSPD" );
  $axespresent[windspd] = 1;
}

$axes = array();
foreach ($axespresent as $axis => $value) {
  array_push($axes, $axis);
}

header('Content-type: text/xml');
print("<?xml version=\"1.0\"?>\n");

$marginright = 50;
if (count($axes) > 2) {
  $marginright += (count($axes)-2)*60;
}

?>
<mugl>
  <window margin="2" border="2" padding="5"/>
  <legend visible="true"/>
  <plotarea marginbottom="45" marginleft="60" marginright="<?=$marginright?>" margintop="5"/>
  <horizontalaxis id="time"
		  position="0"
		  pregap="0"
		  postgap="0"
		  type="datetime"
		  min="<?= $start ?>"
		  max="<?= $end ?>">
    <title/>
    <grid/>
    <labels format="%H:%i%L%n %d%L%Y" start="0" anchor="0 1" spacing="2M 1M 7D 5D 2D 24H 12H 6H 1H 30m 15m 10m 5m" />
    <binding id="timebinding" min="<?= $start ?>" max="<?= $end ?>"/>
  </horizontalaxis>
<? for ($i=0; $i<count($axes); ++$i) {
  $position = 0;
  $positionbase = "left";
  $labelposition = -10;
  $titleposition = -35;
  if ($i > 0) {
    $positionbase = "right";
    $labelposition = 30;
    $titleposition = 45;
    if ($i > 1) {
      $position += ($i-1)*60;
    }
  }
  if ($axes[$i] == "temp") {
?>
  <verticalaxis id="temp"
		position="<?=$position?>"
		positionbase="<?=$positionbase?>"
		pregap="0"
		postgap="0"
		type="number"
		min="0"
		max="20.5">
    <title angle="90" position="-45 0" anchor="0 -1">Temperature (C)</title>
    <labels format="%.1f" start="0" angle="0" position="-10 0" anchor="1 0" spacing="50 20 10 5 2 1 0.1 0.01"/>
    <binding id="tempbinding" min="0" max="1"/>
  </verticalaxis>
<? } else if ($axes[$i] == "precip") { ?>
  <verticalaxis id="precip"
		position="<?=$position?>"
		positionbase="<?=$positionbase?>"
		pregap="0"
		postgap="0"
		type="number"
		min="0"
		max="10.1">
    <title angle="90" position="25 0" anchor="0 1">Precip (mm)</title>
    <labels format="%.1f" start="0" angle="0" position="5 0" anchor="-1 0" spacing="50 20 10 5 2 1 0.1 0.01"/>
    <zoom anchor="0"/>
    <pan allowed="no"/>
    <binding id="precipbinding" min="0" max="1"/>
  </verticalaxis>
<? } else if ($axes[$i] == "solarad") {
  if ($labelposition > 0) { $labelposition += 5; }
  else { $labelposition -= 5; }
  if ($titleposition > 0) { $titleposition += 5; }
  else { $titleposition -= 5; }
  ?>
  <verticalaxis id="solarad"
		position="<?=$position?>"
		positionbase="<?=$positionbase?>"
		pregap="0"
		postgap="0"
		type="number"
		min="0"
		max="1100">
    <title angle="90" position="35 0" anchor="0 1">Solar Radiation (W/m^2)</title>
    <labels format="%1d" start="0" angle="0" position="5 0" anchor="-1 0" spacing="1000 500 200 50 20 10 5 2 1 0.1 0.01"/>
    <zoom anchor="0"/>
    <pan allowed="no"/>
    <binding id="solaradbinding" min="0" max="1"/>
  </verticalaxis>
<? } else if ($axes[$i] == "windspd") { ?>
  <verticalaxis id="windspd"
		position="<?=$position?>"
		positionbase="<?=$positionbase?>"
		pregap="0"
		postgap="0"
		type="number"
		min="0"
		max="15">
    <title angle="90" position="35 0" anchor="0 1">Wind (m/s)</title>
    <labels format="%.1f" start="0" angle="0" position="5 0" anchor="-1 0" spacing="1000 500 200 50 20 10 5 2 1 0.1 0.01"/>
    <zoom anchor="0"/>
    <pan allowed="no"/>
    <binding id="windspdbinding" min="0" max="1"/>
  </verticalaxis>
<? } ?>

<? } ?>

<? if ($elementpresent[SOLARAD]) { ?>
  <plot>
    <horizontalaxis ref="xaxis">
      <variable ref="time_1h"/>
    </horizontalaxis>
    <verticalaxis ref="solarad">
      <variable ref="solarad"/>
    </verticalaxis>
    <renderer type="fill">
      <option name="linecolor" value="black"/>
      <option name="fillcolor" value="pink"/>
    </renderer>
  </plot>
<? } ?>

<? if ($elementpresent[P5]) { ?>
  <plot>
    <horizontalaxis ref="xaxis">
      <variable ref="time_5m"/>
    </horizontalaxis>
    <verticalaxis ref="precip">
      <variable ref="precip"/>
    </verticalaxis>
    <renderer type="bar">
      <option name="fillcolor"  value="green"/>
      <option name="barwidth" value="5m"/>
      <option name="baroffset" value="0"/>
      <option name="linecolor" value="black"/>
    </renderer>
  </plot>
<? } ?>

<? if ($elementpresent[T5]) { ?>
  <plot>
    <horizontalaxis ref="xaxis">
      <variable ref="time_5m"/>
    </horizontalaxis>
    <verticalaxis ref="temp">
      <variable ref="temp"/>
    </verticalaxis>
    <renderer type="line">
      <option name="linecolor" value="blue"/>
      <option name="dotcolor"  value="black"/>
      <option name="dotsize"   value="0"/>
      <option name="linewidth" value="3"/>
    </renderer>
  </plot>
<? } ?>

<? if ($elementpresent[SUR_TEMP]) { ?>
  <plot>
    <horizontalaxis ref="xaxis">
      <variable ref="time_1h"/>
    </horizontalaxis>
    <verticalaxis ref="temp">
      <variable ref="sur_temp"/>
    </verticalaxis>
    <renderer type="line">
      <option name="linecolor" value="red"/>
      <option name="dotcolor"  value="black"/>
      <option name="dotsize"   value="0"/>
      <option name="linewidth" value="3"/>
    </renderer>
  </plot>
<? } ?>

<? if ($elementpresent[WINDSPD]) { ?>
  <plot>
    <horizontalaxis ref="xaxis">
      <variable ref="time_1h"/>
    </horizontalaxis>
    <verticalaxis ref="windspd">
      <variable ref="windspd"/>
    </verticalaxis>
    <renderer type="line">
      <option name="linecolor" value="black"/>
    </renderer>
  </plot>
<? } ?>

<? if ($elementpresent[T5] || $elementpresent[P5]) { ?>

  <data>
    <variables>
      <variable id="time_5m" type="datetime"/>
<? if ($elementpresent[T5]) { ?>
      <variable id="temp"/>
<? } ?>
<? if ($elementpresent[P5]) { ?>
      <variable id="precip"/>
<? } ?>
    </variables>
    <service location="http://www.multigraph.org/examples/crnmap/crndata.cgi/<?= $station_id ?>/<?= join(",",$elements_5m) ?>"/>
  </data>
<? } ?>

<? if ($elementpresent[SOLARAD] || $elementpresent[SUR_TEMP] || $elementpresent[WINDSPD]) { ?>
  <data>
    <variables>
      <variable id="time_1h" type="datetime"/>
<? if ($elementpresent[SOLARAD]) { ?>
      <variable id="solarad"/>
<? } ?>
<? if ($elementpresent[SUR_TEMP]) { ?>
      <variable id="sur_temp"/>
<? } ?>
<? if ($elementpresent[WINDSPD]) { ?>
      <variable id="windspd"/>
<? } ?>
    </variables>
    <service location="http://www.multigraph.org/examples/crnmap/crndata.cgi/<?= $station_id ?>/<?= join(",",$elements_1h) ?>"/>
  </data>
<? } ?>

</mugl>
