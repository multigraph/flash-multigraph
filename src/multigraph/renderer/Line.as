/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
	import multigraph.Axis;
	import mx.core.UIComponent;
    import multigraph.parsecolor;
    import multigraph.data.Data;
	
  public class Line extends PointLine
  {
    static public var keyword:String = 'line';
    static public var description:String = 'Same as the <b>pointline</b> renderer';

    //
    // a couple of property aliases, for compatibility with deprecated values:
    //
    public function set dotcolor(c:String):void { pointcolor = c; }
    public function get dotcolor():String { return pointcolor; }
    public function set dotsize(s:String):void { pointsize = s; }
    public function get dotsize():String { return pointsize; }

    public function Line(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
      super(haxis, vaxis, data, varids);
    }

  }
}
