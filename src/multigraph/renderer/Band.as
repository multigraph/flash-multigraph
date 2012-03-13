/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer
{
  import flash.display.Graphics;
  import mx.core.UIComponent;
  import multigraph.Axis;
  import multigraph.parsecolor;
  import multigraph.data.Data;

  public class Band extends Renderer
  {
    static public var keyword:String = 'band';
    static public var description:String = 'Plot a filled band between pairs of data values; similar to the fill renderer, but with filled region between two arbitrary values, rather than between one value and the horizontal axis.  This renderer requires two vertical axis variables; for each data point, the first variable should be less than or equal to the second one.';
    static public var options:String = '<ul>\
<li><b>line1color</b>: the color to be used for the line connecting the values of the first variable\
<li><b>line2color</b>: the color to be used for the line connecting the values of the second variable\
<li><b>linecolor</b>: the color to be used for both of the above lines (use instead of line1color and line2color if you want both lines the same color)\
<li><b>line1width</b>: the width (in pixels) of the lines connecting the values of the first variable\
<li><b>line2width</b>: the width (in pixels) of the lines connecting the values of the second variable\
<li><b>linewidth</b>: the width to be used for both of the above lines (use instead of line1width and line2width if you want both lines the same width)\
<li><b>fillcolor</b>: the color to be used for the filled area between the two lines\
<li><b>fillopacity</b>: the opacity to be used for the filled area\
</ul>';
		
    // Mugl properties
    private var _line1color:uint;
    private var _line1width:uint;
    private var _line2color:uint;
    private var _line2width:uint;
    private var _fillcolor:uint;
    private var _fillopacity:Number;
		
		
    public var _fillcolor_str:String;
    public var _line1color_str:String;
    public var _line2color_str:String;
		
    private var _points:Array;
    private var _g:Graphics;
		
    public function get fillcolor():String { return _fillcolor+''; }
    public function set fillcolor(color:String):void {
      _fillcolor_str = color; 
      _fillcolor = parsecolor(color);
    }
		
    public function get line1color():String { return _line1color+''; }
    public function set line1color(color:String):void {
      _line1color_str = color;
      _line1color = parsecolor(color);
    }

    public function get line2color():String { return _line2color+''; }
    public function set line2color(color:String):void {
      _line2color_str = color;
      _line2color = parsecolor(color);
    }

    public function set linecolor(color:String):void {
      line1color = color;
      line2color = color;
    }

		
    public function get fillopacity ():String { return _fillopacity+''; }
    public function set fillopacity (opacity:String):void {
      _fillopacity = Number(opacity);
    }
		
    public function get line1width ():String { return _line1width+''; }
    public function set line1width (width:String):void {
      _line1width = uint(Number(width));
    }

    public function get line2width ():String { return _line2width+''; }
    public function set line2width (width:String):void {
      _line2width = uint(Number(width));
    }

    public function set linewidth (width:String):void {
      line1width = width;
      line2width = width;
    }
		
    public function Band(haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _fillcolor = 0x000000;
      _fillopacity = 1;
      _line1color = 0x000000;
      _line1width = 1;
      _line2color = 0x000000;
      _line2width = 1;
    }
		
    override public function begin(sprite:UIComponent):void {
      _points = [];
      _g = sprite.graphics;
    }

    override public function dataPoint(sprite:UIComponent, datap:Array):void {
      // The _points array holds a "run" of consecutive data points.  When/if we hit a missing value,
      // we render that run and reset the _points array to empty.
      if (isMissing(datap[1],1) || isMissing(datap[2],2)) {
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
  

    override public function end(sprite:UIComponent):void {
      // render any points currently in the _points array
      renderPoints();
    }

    // render a "run" of points in the _points array.  This consists of drawing the fill region
    // under the points, and the lines connecting the points.  We do this by tracing out the
    // fill region with lineTo() calls, using our specified line style when drawing between
    // the actual data points, and an invisible line style when drawing the vertical lines to/from
    // the horizontal axis
    private function renderPoints():void {
      if (_points.length <= 0) { return; }
      _g.beginFill(_fillcolor, _fillopacity);
      // move to the lower value of the first point
      _g.moveTo(_points[0][0], _points[0][1]);
      // draw (using invisible line style) vertical line up to the upper value of the first point
      _g.lineStyle(0, 0, 0);
      _g.lineTo(_points[0][0], _points[0][2]);
      // change to our specified line style for the upper line and draw to the upper value of each point in the run;
      // this traces out the top of the band
      _g.lineStyle(_line2width, _line2color, _line2width > 0 ? 1 : 0);
      for (var i:int=1; i<_points.length; ++i) {
        _g.lineTo(_points[i][0], _points[i][2]);
      }
      // change to invisible line style and draw vertical line down to the lower value
      // of the last point in the run
      _g.lineStyle(0, 0, 0);
      var i:int = _points.length - 1;
      _g.lineTo(_points[i][0], _points[i][1]);
      // change to our specified line style for the lower line and draw to the lower value of each point in the run;
      // this traces out the bottom of the band
      _g.lineStyle(_line1width, _line1color, _line1width > 0 ? 1 : 0);
      while (i>0) {
        --i;
        _g.lineTo(_points[i][0], _points[i][1]);
      }
      // end the fill
      _g.endFill();
    }
          

    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {
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
    	
      g.lineStyle(_line2width, _line2color, 1);
      g.beginFill(_fillcolor, _fillopacity);

	  g.moveTo(0,            2*sprite.height/8);
	  g.lineTo(0,            6*sprite.height/8);
	  g.lineTo(sprite.width, 7*sprite.height/8);
	  g.lineTo(sprite.width, 3*sprite.height/8);
	  g.lineTo(0,            2*sprite.height/8);
	  
	  g.endFill();
	    	
    }
  }
}
