/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer
{
  import flash.display.Graphics;
	
  import multigraph.Axis;
  import multigraph.MultigraphUIComponent;
  import multigraph.parsecolor;
  import multigraph.data.Data;

  public class Fill extends Renderer
  {
    static public var keyword:String = 'fill';
    static public var description:String = 'Plot lines connecting data points, with a solid fill between the lines and the horizontal axis';
    static public var options:String = '<ul>\
<li><b>linecolor</b>: the color to be used for the lines\
<li><b>linewidth</b>: the width of the lines, in pixels\
<li><b>linethickness</b>: deprecated; same as linewidth\
<li><b>fillcolor</b>: the color to be used for the fill area\
<li><b>fillopacity</b>: the opacity to be used for the fill area'
      +optionsMissing+
      '</ul>';
		
    // Mugl properties
    private var _fillcolor:uint;
    private var _linecolor:uint;
    private var _linewidth:uint;
    private var _fillopacity:Number;
		
		
    public var _fillcolor_str:String;
    public var _linecolor_str:String;
		
    private var _points:Array;
    private var _g:Graphics;
		
    public function get fillcolor():String { return _fillcolor+''; }
    public function set fillcolor(color:String):void {
      _fillcolor_str = color; 
      _fillcolor = parsecolor(color);
    }
		
    public function get linecolor():String { return _linecolor+''; }
    public function set linecolor(color:String):void {
      _linecolor_str = color;
      _linecolor = parsecolor(color);
    }
		
    public function get fillopacity ():String { return _fillopacity+''; }
    public function set fillopacity (opacity:String):void {
      _fillopacity = Number(opacity);
    }
		
    public function get linewidth ():String { return _linewidth+''; }
    public function set linewidth (width:String):void {
      _linewidth = uint(Number(width));
    }
    public function set linethickness (width:String):void { linewidth=width; } // for backwards compatibility
		
    public function Fill(haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _fillcolor = 0x000000;
      _linecolor = 0x000000;
      _linewidth = 1;
      _fillopacity = 1;
    }
		
    override public function begin(sprite:MultigraphUIComponent):void {
      _points = [];
      _g = sprite.graphics;
    }

    override public function dataPoint(sprite:MultigraphUIComponent, datap:Array):void {
      // The _points array holds a "run" of consecutive data points.  When/if we hit a missing value,
      // we render that run and reset the _points array to empty.
      if (isMissing(datap[1],1)) {
        if (_points.length > 0) {
          renderPoints();
          _points = [];
        }
      } else {
        // if this value is not missing, for now we just add it to the _points array
        var p:Array = [];
        transformPoint(p, datap);
        _points.push(p);
      }
    }
  

    override public function end(sprite:MultigraphUIComponent):void {
      // render any points currently in the _points array
      renderPoints();
    }

    // render a "run" of points in the _points array.  This consists of drawing the fill region
    // under the points, and the lines connecting the points.  We do this by tracing out the
    // fill region with lineTo() calls, using our specified line style when drawing between
    // the actual data points, and an invisible line style when drawing the vertical lines to/from
    // the horizontal axis, and along the horizontal axis.
    private function renderPoints():void {
      if (_points.length <= 0) { return; }
      _g.beginFill(_fillcolor, _fillopacity);
      // move to the position on the horiz axis under the first point in the run
      _g.moveTo(_points[0][0], 0);
      // draw (using invisible line style) vertical line up to the first point in the run
      _g.lineStyle(0, 0, 0);
      _g.lineTo(_points[0][0], _points[0][1]);
      // change to our specified line style and draw to each subsequent point in the run
      _g.lineStyle(_linewidth, _linecolor, 1);
      for (var i:int=1; i<_points.length; ++i) {
        _g.lineTo(_points[i][0], _points[i][1]);
      }
      // change back to invisible line style and draw vertical line down to position
      // on horizontal axis under the last point of the run
      _g.lineStyle(0, 0, 0);
      _g.lineTo(_points[_points.length-1][0], 0);
      // draw (still using invisible line style) horiz line along axis back to starting position
      _g.lineTo(_points[0][0], 0);
      // end the fill
      _g.endFill();
    }
          

    override public function renderLegendIcon(sprite:MultigraphUIComponent, legendLabel:String, opacity:Number):void {
      var g:Graphics = sprite.graphics;
	    	
      // Draw icon background (with opacity)
      g.lineStyle(1, 0xFFFFFF, opacity);
    		
      if (sprite.width < 10 || sprite.height < 10) {
        g.beginFill(_fillcolor, opacity);
      } else {
        g.beginFill(0xFFFFFF, opacity);
      }
    		
      g.drawRect(0, 0, sprite.width, sprite.height);
      g.endFill();
    	
      g.lineStyle(_linewidth, _linecolor, 1);
      g.beginFill(_fillcolor, _fillopacity);
      g.moveTo(0, 0);
	    	
      // Draw the middle range icon or the large range icon if the width and height allow it
      if (sprite.width > 10 || sprite.height > 10) {
        // Draw a more complex icon if the icons width and height are large enough
        if (sprite.width > 20 || sprite.height > 20) {
          g.lineTo(sprite.width / 6, sprite.height / 2);
          g.lineTo(sprite.width / 3, sprite.height / 4);
        }
        g.lineTo(sprite.width / 2, sprite.height - sprite.height / 4);
	    			
        if (sprite.width > 20 || sprite.height > 20) {
          g.lineTo(sprite.width - sprite.width / 3, sprite.height / 4);
          g.lineTo(sprite.width - sprite.width / 6, sprite.height / 2);
        }
      }
	    	
      g.lineTo(sprite.width, 0);
      g.endFill();
	    	
      // Draw the icon border    	
      //g.lineStyle(1, 0x000000, 1);
      //g.beginFill(0xFFFFFF, 0);
      //g.drawRect(0, 0, sprite.width, sprite.height);
      //g.endFill();
    }
  }
}
