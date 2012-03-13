/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	
	import multigraph.Axis;
	import mx.core.UIComponent;
    import multigraph.parsecolor;
    import multigraph.data.Data;
    import multigraph.NumberAndUnit;
	
  public class PointLine extends Renderer
  {
    static public var keyword:String = 'pointline';
    static public var description:String = 'Plot markers at data points, and lines connecting data points.  Both the markers and the lines are optional.';
    static public var options:String = '<ul>\
<li><b>linecolor</b> color to use for the lines; default is 0x000000 (black)\
<li><b>linewidth</b> width, in pixels, to use for the lines; default is 1\
<li><b>pointpixelthreshold</b> if specified, this should be a distance (possibly with units, in the case of a datetime axis) along the horizontal \
axis, and the renderer will only draw points if the width of a single pixel, measured in the data units of the horizontal axis, is greater than this \
distance.  The default value is 0, which means that points are always drawn.\
<li><b>pointsize</b> radius of the markers, in pixels; default is 0, which means do not draw markers\
<li><b>pointshape</b> shape to use for the markers; must be one of "circle", "square", "triangle", "diamond", "star", "+", or "x"; default is "circle"\
<li><b>pointcolor</b> color to use for the markers; default is 0x000000 (black)\
<li><b>pointopacity</b> opacity of points, in range 0.0 (completely transparent) to 1.0 (completely opaque); default is 1.0\
<li><b>pointoutlinewidth</b> width, in pixels, of outline to draw around markers; default is 0, which means draw no outline\
<li><b>pointoutlinecolor</b> color to use for outline around markers'
+optionsMissing+
'</ul>';

	// Mugl properties
	private var _linecolor:uint;
    private var _linewidth:Number;
    private var _pointsize:Number;
    private var _pointshape:Number;
    private var _pointcolor:uint;
    private var _pointopacity:Number;
    private var _pointoutlinewidth:Number;
    private var _pointoutlinecolor:uint;
    private var _pointpixelthreshold:String;

    private var _drawPoints:Boolean;

	private var _linecolor_str:String;
    private var _pointcolor_str:String = null;;
    private var _pointoutlinecolor_str:String = null;

    private static var CIRCLE_SHAPE:int   = 1;
    private static var SQUARE_SHAPE:int   = 2;
    private static var TRIANGLE_SHAPE:int = 3;
    private static var DIAMOND_SHAPE:int  = 4;
    private static var STAR_SHAPE:int     = 5;
    private static var PLUS_SHAPE:int     = 6;
    private static var X_SHAPE:int        = 7;


    private var points:Array;
    private var prevPoint:Array;

    public function get pointpixelthreshold ():String { return _pointpixelthreshold; }
    public function set pointpixelthreshold (value:String):void { _pointpixelthreshold = value; }

    public function set linecolor(color:String):void {
    	_linecolor_str = color;
    	_linecolor = parsecolor(color);
    }
    public function get linecolor():String {
    	return _linecolor_str;
    }
    
    public function set pointcolor(color:String):void {
    	_pointcolor_str = color;
    	_pointcolor = parsecolor(color);
    }
    public function get pointcolor():String {
    	return _pointcolor_str;
    }

    public function set pointoutlinecolor(color:String):void {
    	_pointoutlinecolor_str = color;
    	_pointoutlinecolor = parsecolor(color);
    }
    public function get pointoutlinecolor():String {
    	return _pointoutlinecolor_str;
    }
    
    public function get pointsize():String {
      return _pointsize+'';
    }
    
    public function set pointsize(size:String):void {
    	_pointsize = Number(size);
    }

    public function get pointopacity():String {
      return _pointopacity+'';
    }
    
    public function set pointopacity(opacity:String):void {
    	_pointopacity = Number(opacity);
    }

    public function get linewidth():String {
    	return _linewidth+'';
    }
    
    public function set linewidth(width:String):void {
    	_linewidth = Number(width);
    }

    public function get pointoutlinewidth():String {
    	return _pointoutlinewidth+'';
    }
    
    public function set pointoutlinewidth(width:String):void {
    	_pointoutlinewidth = Number(width);
    }

    public function set pointshape(s:String):void {
      if (s == "square") {
        _pointshape = SQUARE_SHAPE;
      } else if (s == "triangle") {
        _pointshape = TRIANGLE_SHAPE;
      } else if (s == "diamond") {
        _pointshape = DIAMOND_SHAPE;
      } else if (s == "star") {
        _pointshape = STAR_SHAPE;
      } else if (s == "+") {
        _pointshape = PLUS_SHAPE;
      } else if (s == "x") {
        _pointshape = X_SHAPE;
      } else {
        _pointshape = CIRCLE_SHAPE;
      }
    }
    public function get pointshape():String {
      if (_pointshape == CIRCLE_SHAPE) { return "circle"; }
      if (_pointshape == SQUARE_SHAPE) { return "square"; }
      if (_pointshape == TRIANGLE_SHAPE) { return "triangle"; }
      if (_pointshape == DIAMOND_SHAPE) { return "diamond"; }
      if (_pointshape == STAR_SHAPE) { return "star"; }
      if (_pointshape == PLUS_SHAPE) { return "+"; }
      if (_pointshape == X_SHAPE) { return "x"; }
      return "(unknown)";
    }


    public function PointLine(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
      super(haxis, vaxis, data, varids);
      _pointsize           = 0;
      _pointcolor          = 0x000000;
      _pointopacity        = 1.0;
      _pointoutlinewidth   = 1;
      _pointoutlinecolor   = 0x000000;
      _pointpixelthreshold = "0";
      _linewidth           = 1;
      _linecolor           = 0x000000;
      points      = [];
      prevPoint = null;
    }

    override public function begin(sprite:UIComponent):void {
      this.prevPoint = null;
      this.points      = [];
      if (_dataFilter != null) { _dataFilter.reset(_haxis, _vaxis); }

      var numberAndUnit:NumberAndUnit = NumberAndUnit.parse(_pointpixelthreshold);
      var msThreshold:Number;
            
      switch(numberAndUnit.unit){
      case "H":
        msThreshold = numberAndUnit.number * 3600000;
        break;
      case "D":
        msThreshold = numberAndUnit.number * 3600000 * 24;
        break;
      case "M":
        msThreshold = numberAndUnit.number * 3600000 * 24 * 30;
        break;
      case "Y":
        msThreshold = numberAndUnit.number * 3600000 * 24 * 365;
        break;
      case "m":
        msThreshold = numberAndUnit.number * 60000;
        break;
      default:
        msThreshold = numberAndUnit.number;
        break;
      }
            
      var thresholdPixelWidth:Number = msThreshold * _haxis.axisToDataRatio;
      _drawPoints = (thresholdPixelWidth >= 1);
    }

    override public function dataPoint(sprite:UIComponent, datap:Array):void {
      if (isMissing(datap[1],1)) {
        prevPoint = null;
      } else {
        var p:Array = [];
        transformPoint(p, datap);
        if (_dataFilter != null && _dataFilter.filter(datap, p)) { return; }
        if (_linewidth > 0 && prevPoint != null) {
          var g:Graphics = sprite.graphics;
          g.lineStyle(_linewidth, _linecolor, 1);
          g.moveTo(prevPoint[0], prevPoint[1]);
          g.lineTo(p[0], p[1]);
        }
        prevPoint = p;
        points.push(prevPoint);
      }
    }

    override public function end(sprite:UIComponent):void {
      if (_drawPoints  && (_pointsize > 0)) { // don't draw points if pointsize<=0, or if _drawPoints is false
        var g:Graphics = sprite.graphics;
        var p:Array;
        while(points.length > 0) {
          p = points.pop();
          drawPoint(g, p[0], p[1]);
        }
      }
      if (_dataFilter != null) { _dataFilter.draw(g); }
    }

    private function drawPoint(g:Graphics, x:Number, y:Number) {
      if (_pointoutlinewidth > 0) {
        g.lineStyle(_pointoutlinewidth, _pointoutlinecolor, 1);
      } else {
        g.lineStyle(0,0,0);
      }

      //
      // handle these shapes separately, since they involve no fill:
      //
      if (_pointshape == PLUS_SHAPE || _pointshape == X_SHAPE) {
        // With these shapes, if a pointcolor was specified and a
        // pointoutlinecolor was not, use pointcolor as the color for
        // the lines.
        if (_pointoutlinecolor_str == null && _pointcolor_str != null) {
          var w:int = _pointoutlinewidth > 0 ? _pointoutlinewidth : 1;
          g.lineStyle(w, _pointcolor, 1);
        }
        if (_pointshape == PLUS_SHAPE) {
          g.moveTo(x, y-_pointsize);
          g.lineTo(x, y+_pointsize);
          g.moveTo(x-_pointsize, y);
          g.lineTo(x+_pointsize, y);
        } else if (_pointshape == X_SHAPE) {
          var p:Number = 0.70710 * _pointsize;
          g.moveTo(x-p, y-p);
          g.lineTo(x+p, y+p);
          g.moveTo(x-p, y+p);
          g.lineTo(x+p, y-p);
        }
        return;
      }

      //
      // Other shapes involve fill, so start with beginFill() and end with endFill():
      //
      g.beginFill(_pointcolor, _pointopacity);
      if (_pointshape == SQUARE_SHAPE) {
        g.drawRect(x - _pointsize, y - _pointsize, 2*_pointsize, 2*_pointsize);
      } else if (_pointshape == TRIANGLE_SHAPE) {
        var p:Number = 1.5*_pointsize;
        var a:Number = 0.866025*p;
        var b:Number = 0.5*p;
        g.moveTo(x, y+p);
        g.lineTo(x+a, y-b);
        g.lineTo(x-a, y-b);
      } else if (_pointshape == DIAMOND_SHAPE) {
        var p:Number = 1.5*_pointsize;
        g.moveTo(x-_pointsize, y);
        g.lineTo(x, y+p);
        g.lineTo(x+_pointsize, y);
        g.lineTo(x, y-p);
      } else if (_pointshape == STAR_SHAPE) {
        var p:Number = 1.5*_pointsize;
        g.moveTo(x-p*0.0000, y+p*1.0000);
        g.lineTo(x+p*0.3536, y+p*0.3536);
        g.lineTo(x+p*0.9511, y+p*0.3090);
        g.lineTo(x+p*0.4455, y-p*0.2270);
        g.lineTo(x+p*0.5878, y-p*0.8090);
        g.lineTo(x-p*0.0782, y-p*0.4938);
        g.lineTo(x-p*0.5878, y-p*0.8090);
        g.lineTo(x-p*0.4938, y-p*0.0782);
        g.lineTo(x-p*0.9511, y+p*0.3090);
        g.lineTo(x-p*0.2270, y+p*0.4455);
      } else if (_pointshape == PLUS_SHAPE) {
        var p:Number = 1.5*_pointsize;
        g.moveTo(x-p*0.0000, y+p*1.0000);
        g.lineTo(x+p*0.3536, y+p*0.3536);
        g.lineTo(x+p*0.9511, y+p*0.3090);
        g.lineTo(x+p*0.4455, y-p*0.2270);
        g.lineTo(x+p*0.5878, y-p*0.8090);
        g.lineTo(x-p*0.0782, y-p*0.4938);
        g.lineTo(x-p*0.5878, y-p*0.8090);
        g.lineTo(x-p*0.4938, y-p*0.0782);
        g.lineTo(x-p*0.9511, y+p*0.3090);
        g.lineTo(x-p*0.2270, y+p*0.4455);
      } else { // CIRCLE_SHAPE:
        g.drawCircle(x, y, _pointsize);
      }
      g.endFill();
    }
    
    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {
      var g:Graphics = sprite.graphics;
      if (_linewidth > 0) {
    	g.lineStyle(_linewidth, _linecolor, 1, false, "normal", flash.display.CapsStyle.NONE, flash.display.JointStyle.ROUND);
    	g.moveTo(1, sprite.height / 2);
    	g.lineTo(sprite.width, sprite.height / 2);
      }
      if (_pointsize > 0) {
        drawPoint(g, sprite.width / 2, sprite.height / 2);
      }
    }
  }
}
