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
	
  import multigraph.Axis;
  import mx.core.UIComponent;
  import multigraph.parsecolor;
  import multigraph.data.Data;

  public class Fill extends Renderer
  {
    static public var keyword:String = 'fill';
    static public var description:String = 'Plot lines connecting data points, with a solid fill between the lines and the horizontal axis, or between the lines and a specified horizontal base line';
    static public var options:String = '<ul>\
<li><b>linecolor</b>: the color to be used for the lines; default is black\
<li><b>linewidth</b>: the width of the lines, in pixels; default is 1\
<li><b>linethickness</b>: deprecated; same as linewidth\
<li><b>fillcolor</b>: the color to be used for the fill area; the default is grey\
<li><b>downfillcolor</b>: the color to be used for fill area that is below the fillbase, if a fillbase is specified.  If no downfillcolor is specifed, fillcolor will be used for all fill areas\
<li><b>fillopacity</b>: the opacity to be used for the fill area\
<li><b>fillbase</b>: the location along the plot\'s vertical axis of the horizontal line that defines the bottom (or top) of the filled region; if no fillbase is specified, the fill will extend down to the bottom of the plot area\
</ul>';
		
    // Mugl properties
    private var _fillcolor:uint;
    private var _downfillcolor:uint;
    private var _linecolor:uint;
    private var _downlinecolor:uint;
    private var _linewidth:uint;
    private var _fillopacity:Number;
    private var _fillbase:Number;
		
    // Accessible color properties
    public var _linecolor_str:String;   
    public var _downlinecolor_str:String = null;   
    public var _fillcolor_str:String;   
    public var _downfillcolor_str:String = null;   

    private var _points:Array;
    private var _fillbaseIsSet:Boolean;
    private var _fillpixelBase:Number;
    private var _prevp:Array = null;
    private var _currentfillcolor:uint;
    private var _currentlinecolor:uint;
    private var _g:Graphics;
		
    public function get fillcolor ():String { return _fillcolor_str; }
    public function set fillcolor (color:String):void {
      _fillcolor_str = color; 
      _fillcolor = parsecolor(color);
    }

    public function get downfillcolor ():String { return _downfillcolor_str; }
    public function set downfillcolor (color:String):void {
      _downfillcolor_str = color; 
      _downfillcolor = parsecolor(color);
    }

    public function get linecolor ():String { return _linecolor_str; }
    public function set linecolor (color:String):void {
      _linecolor_str = color; 
      _linecolor = parsecolor(color);
    }

    public function get downlinecolor ():String { return _downlinecolor_str; }
    public function set downlinecolor (color:String):void {
      _downlinecolor_str = color; 
      _downlinecolor = parsecolor(color);
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
		
    public function get fillbase ():Number { return _fillbase; }
    public function set fillbase (base:Number):void {
      _fillbase = base;
      _fillbaseIsSet = true;
    }

    public function Fill(haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _linewidth = 1;
      _fillopacity = 1;
      _fillbaseIsSet = false;
      _fillcolor_str = "0x999999";
      _fillcolor = parsecolor(_fillcolor_str);
      _linecolor_str = "0x000000";
      _linecolor = parsecolor(_linecolor_str);
    }
		
    private function clearPoints(nsave:int=1):void {
      var oldpoints:Array = _points;
      _points = [];
      for (var i:int=0; i<nsave; ++i) {
        _points[i] = oldpoints[oldpoints.length-nsave+i];
      }
    }

    override public function initialize():void {
      if (_downfillcolor_str == null) {
        _downfillcolor_str = _fillcolor_str;
        _downfillcolor = _fillcolor;
      }
      if (_downlinecolor_str == null) {
        _downlinecolor_str = _linecolor_str;
        _downlinecolor = _linecolor;
      }
    }

    override public function begin(sprite:UIComponent):void {
      clearPoints(0);
      _g = sprite.graphics;
      _fillpixelBase = 0;
      if (_fillbaseIsSet) {
        _fillpixelBase = _vaxis.dataValueToAxisValue(_fillbase);
      }
      _prevp = null;
    }

    private function interpolate(x1:Number, y1:Number, x2:Number, y2:Number, y:Number):Number {
      if (y1 == y2) { return (x1 + x2) / 2; }
      return x1 + ( y - y1 ) * ( x2 - x1 ) / ( y2 - y1 );
    }

    override public function dataPoint(sprite:UIComponent, datap:Array):void {

      if (isMissing(datap[1],1)) {
        if (_prevp != null) {
          _points.push( [_prevp[0], _fillpixelBase] );
          renderPoints(_currentfillcolor, _currentlinecolor);
          clearPoints(0);
          _prevp = null;
        }
        return;
      }

      var p:Array = [];
      transformPoint(p, datap);

      var fillcolor:uint;
      var linecolor:uint;
      if (datap[1] >= _fillbase) {
        fillcolor = _fillcolor;
        linecolor = _linecolor;
      } else {
        fillcolor = _downfillcolor;
        linecolor = _downlinecolor;
      }
      if (_points.length == 0) {
        _points.push( [p[0], _fillpixelBase] );
      } else {
        if (fillcolor != _currentfillcolor) {
          var x:Number = interpolate(_prevp[0], _prevp[1], p[0], p[1], _fillpixelBase);
          _points.push( [x, _fillpixelBase] );
          _points.push( [x, _fillpixelBase] );
          renderPoints(_currentfillcolor, _currentlinecolor);
          clearPoints(0);
          _points.push( [x, _fillpixelBase] );
          _points.push( [x, _fillpixelBase] );
        }
      }
      _currentfillcolor = fillcolor;
      _currentlinecolor = linecolor;
      _points.push(p);
      _prevp = p;

    }


    override public function end(sprite:UIComponent):void {
      // render any points currently in the _points array
      if (_points.length > 0) {
        _points.push( [_points[_points.length-1][0], _fillpixelBase] );
        renderPoints(_currentfillcolor, _currentlinecolor);
      }
    }

    // render a "run" of points in the _points array.  This consists of drawing the fill region
    // under the points, and the lines connecting the points.  We do this by tracing out the
    // fill region with lineTo() calls, using our specified line style when drawing between
    // the actual data points, and an invisible line style when drawing the vertical lines to/from
    // the horizontal axis, and along the horizontal axis.
    private function renderPoints(fillcolor:uint, linecolor:uint):void {
      if (_points.length <= 0) { return; }
      _g.beginFill(fillcolor, _fillopacity);
      // move to the first point, which is on the base line
      _g.moveTo(_points[0][0], _points[0][1]);
      // draw (using invisible line style) vertical line to the 2nd point
      _g.lineStyle(0, 0, 0);
      _g.lineTo(_points[1][0], _points[1][1]);
      // change to our specified line style and draw to each subsequent point in the run, up to but not including the last one
      _g.lineStyle(_linewidth, linecolor, _linewidth > 0 ? 1 : 0);
      for (var i:int=2; i<_points.length-1; ++i) {
        _g.lineTo(_points[i][0], _points[i][1]);
      }
      // change back to invisible line style and draw vertical line to last point, which is on base line
      _g.lineStyle(0, 0, 0);
      _g.lineTo(_points[_points.length-1][0], _points[_points.length-1][1]);
      // draw (still using invisible line style) horiz line along axis back to starting position
      _g.lineTo(_points[0][0], _fillpixelBase);
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
