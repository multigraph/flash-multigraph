<?
$components = array_filter(explode('/', $_SERVER['PATH_INFO']));
$station_id = $components[1];
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

header('Content-type: text/xml');
print("<?xml version=\"1.0\"?>\n");

?>
<mugl>
  <window margin="2" border="2" padding="5"/>
  <plotarea marginbottom="45" marginleft="5" marginright="5" margintop="5"/>
  <horizontalaxis id="datetime"
		    type="datetime"
		    min="200902010000"
		    max="200902080000">
    <title/>
    <labels format="%H:%i%L%n %d%L%Y" start="0" anchor="0 1" spacing="2M 1M 7D 5D 2D 24H 12H 6H 1H 30m 15m 10m 5m 2m 1m" />
    <binding id="timebinding" min="200902010000" max="200902080000"/>
  </horizontalaxis>
  <verticalaxis id="inv"
		type="number"
		min="0"
		max="26">

    <title/>
    <labels format="" start="0" spacing="50 20 10 5 2 1 0.1 0.01"/>
    <binding id="invbinding" min="0" max="1"/>
  </verticalaxis>
  <plot>
    <horizontalaxis ref="datetime">
      <variable ref="datetime"/>
    </horizontalaxis>
    <verticalaxis ref="inv">
      <variable ref="inv"/>
    </verticalaxis>
    <renderer type="radarinv">
      <option name="linethickness" value="2"/>
    </renderer>
  </plot>
  <data>
    <variables>
      <variable id="datetime" type="datetime"/>

      <variable id="inv"/>
      <variable id="vcp"/>
    </variables>
    <csv location="http://www.multigraph.org/examples/radarinv/data/<?= $station_id ?>.csv"/>
  </data>
</mugl>
