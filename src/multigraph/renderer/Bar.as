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
  import flash.events.*;
  
  import multigraph.Axis;
  import mx.core.UIComponent;
  import multigraph.NumberAndUnit;
  import multigraph.data.Data;
  import multigraph.parsecolor;
    
  public class Bar extends Renderer
  {
    static public var keyword:String = 'bar';
    static public var description:String = 'Standard bar graph';
    static public var options:String = '<ul>\
<li><b>barwidth</b>: the width of each bar, in pixels\
<li><b>baroffset</b>: the offset of the left edge of each bar from the corresponding data value\
<li><b>barbase</b>: the location, relative to the plot\'s vertical axis, of the bottom of the bar; if no barbase is specified, the bars will extend down to the bottom of the plot area\
<li><b>fillcolor</b>: the color to be used for the fill inside each bar; if barbase is specified, this color is used only for bars that extend above the base\
<li><b>linecolor</b>: the color to be used for the outline around each bar\
<li><b>hidelines</b>: hide bar outlines when the bars are less wide than this number of pixels; default is 2'
+optionsMissing+
'</ul>';

    // mugl properties
    public var fillcolor;
    private var _linecolor:uint;
    private var _barwidth:String;
    private var _baroffset:Number;
    private var _fillopacity:Number;
    private var _linethickness:Number;
    private var _barbase:Number;

    // _hidelines is the threshold, measured in pixels, for drawing outlines around bars; the outlines
    // are drawn when the bar widths are greater than this threshold.
    private var _hidelines:int = 2;
        
    // Accessible color properties
    public var _linecolor_str:String;   
        
    private var _trueWidth:Number;
    private var _barpixelWidth:uint;
    private var _barpixelOffset:uint;
    private var _barbaseIsSet:Boolean;
    private var _barpixelBase:Number;
        
    private var _barGroups:Array;
    private var _currentBarGroup:Array;
    private var _prevCorner:Array;
    private var _drawLines:Boolean;

    // _pixelEdgeTolerance is the threshold, measured in pixels, for which bars are considered adjacent; bars
    // that are this close or closer are considered to be adjacent, for the purpose of drawing bar outlines.
    private var _pixelEdgeTolerance:int = 1;

        
    private var _numberAndUnit:Object;
    
    public function get linecolor ():String { return _linecolor_str; }
    public function set linecolor (color:String):void {
      _linecolor_str = color; 
      _linecolor = parsecolor(color);
    }
        
    public function get hidelines ():int { return _hidelines; }
    public function set hidelines (width:int):void { _hidelines = width; }

    public function get barwidth ():String { return _barwidth; }
    public function set barwidth (width:String):void { _barwidth = width; }
        
    public function get baroffset ():Number { return _baroffset; }
    public function set baroffset (offset:Number):void { _baroffset = offset; }

    public function get barbase ():Number { return _barbase; }
    public function set barbase (base:Number):void {
      _barbase = base;
      _barbaseIsSet = true;
    }
        
    public function get fillopacity ():String { return _fillopacity+''; }
    public function set fillopacity (opacity:String):void {
      _fillopacity = Number(opacity);
    }
        
    public function get linethickness ():String { return _linethickness+''; }
    public function set linethickness (thickness:String):void {
      _linethickness = Number(thickness);
    }
        
    public function Bar (haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _linecolor = 0x000000;
      _barwidth = "1";
      _baroffset = 0;
      _fillopacity = 1;
      _linethickness = 1;
      _barbaseIsSet = false;
    }
        
    override public function initialize():void {
    	
      if (fillcolor is String) {
        fillcolor = parsecolor(fillcolor);
      }

      var option:String;
      for (option in _rangeOptions) {
        if (option == "fillcolor" || option == "linecolor") {
          for (var i:int=0; i<_rangeOptions[option].length; ++i) {
            if (_rangeOptions[option][i].value is String) {
              _rangeOptions[option][i].value = parsecolor(_rangeOptions[option][i].value);
            }
          }
        }
      }

    }    
        
    override public function begin (sprite:UIComponent):void {

      var g:Graphics = sprite.graphics;
      _numberAndUnit = NumberAndUnit.parse(_barwidth);
            
      switch(_numberAndUnit.unit){
      case "H":
        _trueWidth = _numberAndUnit.number * 3600000;
        break;
      case "D":
        _trueWidth = _numberAndUnit.number * 3600000 * 24;
        break;
      case "M":
        _trueWidth = _numberAndUnit.number * 3600000 * 24 * 30;
        break;
      case "Y":
        _trueWidth = _numberAndUnit.number * 3600000 * 24 * 365;
        break;
      case "m":
        _trueWidth = _numberAndUnit.number * 60000;
        break;
      default:
        _trueWidth = _numberAndUnit.number;
        break;
      }
            
      _barpixelWidth = _trueWidth * _haxis.axisToDataRatio;
      if (_barpixelWidth < 1) { _barpixelWidth = 1; }
      _barpixelOffset = _barpixelWidth * _baroffset;
      _barpixelBase = 0;
      if (_barbaseIsSet) {
        _barpixelBase = _vaxis.dataValueToAxisValue(_barbase);
      }
      _barGroups = [];
      _currentBarGroup = null;
      _prevCorner = null;
      if (_barpixelWidth > _hidelines) {
        _drawLines = true;
      } else {
        _drawLines = false;
      }
    }

    // This bar renderer uses a somewhat sophisticated technique when drawing
    // the outlines around the bars, in order to make sure that it only draws
    // one vertical line between two bars that share an edge.  If a complete
    // outline were drawn around each bar separately, the common edge between
    // adjacent bars would get drawn twice, once for each bar, possibly in
    // slightly different locations on the screen due to roundoff error,
    // thereby making some of the outline lines appear thicker than others.
    // 
    // In order to avoid this roundoff artifact, this render only draws the
    // bars (the filled region of the bar, that is) in its dataPoint() method,
    // and keeps a record of the bar locations and heights so that it can draw all
    // of the bar outlines at once, in its end() method.  The bar locations and
    // heights are stored in an array called _barGroups, which is an array of
    // "bar group" objects.  Each "bar group" corresponds to a sequence of adjacent
    // bars --- two bars are considered to be adjacent if the right edge of the left
    // bar is within _pixelEdgeTolerance pixels of the left edge of the right bar.
    // A "bar group" is represented by an array of points representing the pixel
    // coordinates of the upper left corners of all the bars in the group, followed by
    // the pixel coordinates of the upper right corner of the right-most bar in the group.
    // (The last, right-most, bar is the only one whose upper right corner is included
    // in the list).  So, for example, the following bar group
    // 
    //        *--*
    //        |  |--*
    //     *--*  |  |
    //     |  |  |  |
    //     |  |  |  |
    //   ---------------
    //     1  2  3  4
    // 
    // would be represented by the array
    //
    //    [ [1,2], [2,3], [3,3], [4,3] ]
    //
    
    override public function dataPoint (sprite:UIComponent, datap:Array):void {
      if (isMissing(datap[1],1)) { return; }
      var p:Array = [];
      transformPoint(p, datap);
      var g:Graphics = sprite.graphics;
      
      var fillcolor:uint = getRangeOption("fillcolor", datap[1]);
      g.beginFill(fillcolor, _fillopacity);

      var x0:int = p[0] - _barpixelOffset;
      var x1:int = p[0] - _barpixelOffset + _barpixelWidth;

      // draw the bar one pixel wider than its actual dimensions, to make sure that adjacent bars have no gap between them.
      var x0minus1:int = x0 - 1;
      var x1plus1:int  = x1 + 1;
      g.lineStyle(0,  1, 0);
      g.moveTo(x0minus1, _barpixelBase);
      g.lineTo(x0minus1, p[1]);
      g.lineTo(x1plus1, p[1]);
      g.lineTo(x1plus1, _barpixelBase);
      g.endFill();

      if (_drawLines) {
        if (_prevCorner == null) {
          _currentBarGroup = [ [x0,p[1]] ];
        } else {
          if (Math.abs(x0 - _prevCorner[0]) <= _pixelEdgeTolerance) {
            _currentBarGroup.push( [x0,p[1]] );
          } else {
            _currentBarGroup.push( [_prevCorner[0], _prevCorner[1]] );
            _barGroups.push( _currentBarGroup );
            _currentBarGroup = [ [x0,p[1]] ];
          }
        }
        _prevCorner = [x1,p[1]];
      }
    }
        
    override public function end(sprite:UIComponent):void {
   	  if (_linethickness <= 0) { return; }

      if (_prevCorner != null && _currentBarGroup != null) {
          _currentBarGroup.push( [_prevCorner[0], _prevCorner[1]] );
          _barGroups.push( _currentBarGroup );
      }        

	  var g:Graphics = sprite.graphics;
      g.lineStyle(_linethickness, _linecolor, 1);
      for each (var barGroup:Array in _barGroups) {
          var n:int = barGroup.length;
          if (n < 2) { return; } // this should never happen

          // For the first point, draw 3 lines:
          //
          //       y |------
          //         |
          //         |
          //    base |------
          //         ^     ^
          //         x     x(next)
          //

          //   horizontal line @ y from x(next) to x
          g.moveTo(barGroup[1][0], barGroup[0][1]);
          g.lineTo(barGroup[0][0], barGroup[0][1]);
          //   vertical line @ x from y to base
          g.lineTo(barGroup[0][0], _barpixelBase);
          //   horizontal line @ base from x to x(next)
          g.lineTo(barGroup[1][0], _barpixelBase);

          for (var i:int=1; i<n-1; ++i) {
            // For intermediate points, draw 3 lines:
            //
            //       y |
            //         |
            //         |
            //         |------ y(next)
            //         |
            //         |
            //         |------ base
            //         ^     ^
            //         x     x(next)
            //
            //   vertical line @ x from min to max of (y, y(next), base)
            g.moveTo(barGroup[i][0], Math.min(barGroup[i-1][1], barGroup[i][1], _barpixelBase));
            g.lineTo(barGroup[i][0], Math.max(barGroup[i-1][1], barGroup[i][1], _barpixelBase));
            //   horizontal line @ y(next) from x to x(next)
            g.moveTo(barGroup[i][0],   barGroup[i][1]);
            g.lineTo(barGroup[i+1][0], barGroup[i][1]);
            //   horizontal line @ base from x to x(next)
            g.moveTo(barGroup[i][0],   _barpixelBase);
            g.lineTo(barGroup[i+1][0], _barpixelBase);
          }
          // For last point, draw one line:
          //
          //       y |
          //         |
          //         |
          //    base |
          //         ^     ^
          //         x     x(next)
          //
          //   vertical line @ x from base to y
          g.moveTo(barGroup[n-1][0], barGroup[n-1][1]);
          g.lineTo(barGroup[n-1][0], _barpixelBase);
      }
    }
    
    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {   	
    	var g:Graphics = sprite.graphics;
    	
    	// Draw icon background (with opacity)
    	g.lineStyle(1, 0xFFFFFF, opacity);
    	g.beginFill(0xFFFFFF, opacity);
    	g.drawRect(0, 0, sprite.width, sprite.height);
    	g.endFill();

		var fc = getRangeOption("fillcolor", 0);
		if (fc is String) {
			fc = parsecolor(fc);
		}
        var fillcolor:uint = fc;
    	
    	g.beginFill(fillcolor, _fillopacity);
    	if (_barpixelWidth < 10) { 
      		g.lineStyle(_linethickness, fillcolor, _fillopacity);
      	} else {
      		g.lineStyle(_linethickness, _linecolor, 1);
      	}
      	
      	// Adjust the width of the icons bars based upon the width and height of the icon Ranges: {20, 10, 0}
      	var barwidth:Number;
      	if (sprite.width > 20 || sprite.height > 20) {
      		barwidth = sprite.width / 6;	
      	} else if(sprite.width > 10 || sprite.height > 10) {
      		barwidth = sprite.width / 4;
      	} else {
      		barwidth = sprite.width / 4;
      	}
      	
      	// If the icon is large enough draw extra bars
      	if (sprite.width > 20 && sprite.height > 20) {
    		g.drawRect(sprite.width / 4 - barwidth / 2, 0, barwidth, sprite.height / 2);
    		g.drawRect(sprite.width - sprite.width / 4 - barwidth / 2, 0, barwidth, sprite.height / 3);
      	}
      	
    	g.drawRect(sprite.width / 2 - barwidth / 2, 0, barwidth, sprite.height - sprite.height / 4);
    	
    	g.endFill();
    	
    	// Draw the icon border    	
    	//g.lineStyle(1, 0x000000, 1);
    	//g.beginFill(0xFFFFFF, 0);
    	//g.drawRect(0, 0, sprite.width, sprite.height);
    	//g.endFill();
    }
  }
}
