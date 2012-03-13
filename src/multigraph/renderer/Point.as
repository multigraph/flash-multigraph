/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
	import flash.display.Graphics;
	
	import multigraph.Axis;
	import mx.core.UIComponent;
    import multigraph.parsecolor;
    import multigraph.data.Data;
	
  public class Point extends PointLine
  {
    static public var keyword:String = 'point';
    static public var description:String = 'Draw a marker at the location of each data point';
    static public var options:String = '<ul>\
<li><b>pointsize</b> radius of the markers, in pixels; default is 1\
<li><b>pointshape</b> shape to use for the markers; must be one of "circle", "square", "triangle", "diamond", or "star"; default is "circle"\
<li><b>pointcolor</b> color to use for the markers; default is 0x000000 (black)\
<li><b>pointopacity</b> opacity of points, in range 0.0 (completely transparent) to 1.0 (completely opaque); default is 1.0\
<li><b>pointoutlinewidth</b> width, in pixels, of outline to draw around markers; default is 0, which means draw no outline\
<li><b>pointoutlinecolor</b> color to use for outline around markers\
<li><b>size</b> deprecated; sames as <b>pointsize</b>  \
<li><b>shape</b> deprecated; same as <b>pointshape</b> \
<li><b>color</b> deprecated; same as <b>pointcolor</b> \
<li><b>fillopacity</b> deprecated; sames as <b>pointopacity</b>  \
<li><b>linethickness</b> deprecated; same as <b>pointoutlinewidth</b> \
<li><b>linecolor</b> deprecated; same as <b>pointoutlinecolor</b>'
+optionsMissing+
'</ul>';

    public function set size(s:String):void { pointsize = s; }
    public function get size():String { return pointsize; }

    public function set shape(s:String):void { pointshape = s; }
    public function get shape():String { return pointshape; }

    public function set color(c:String):void { pointcolor = c; }
    public function get color():String { return pointcolor; }

    public function set linethickness(c:String):void { pointoutlinewidth = c; }
    public function get linethickness():String { return pointoutlinewidth; }

    override public function set linecolor(c:String):void { pointoutlinecolor = c; }
    override public function get linecolor():String { return pointoutlinecolor; }

    public function set fillopacity(o:String):void { pointopacity = o; }
    public function get fillopacity():String { return pointopacity; }

    public function Point(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
      super(haxis, vaxis, data, varids);
      // force linewidth = 0 to suppress drawing of lines
      linewidth = "0";
      // default pointsize = 1
      pointsize = "1";
    }
  }

}

