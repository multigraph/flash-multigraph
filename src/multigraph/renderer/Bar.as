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
  import flash.events.*;
  
  import multigraph.HorizontalAxis;
  import multigraph.MultigraphUIComponent;
  import multigraph.NumberAndUnit;
  import multigraph.VerticalAxis;
    
  public class Bar extends Renderer
  {
    static public var keyword:String = 'bar';
    static public var description:String = 'Standard bar graph';
    static public var options:String = '<ul>\
<li><b>barwidth</b>: the width of each bar, in pixels\
<li><b>baroffset</b>: the offset of the left edge of each bar from the corresponding data value\
<li><b>fillcolor</b>: the color to be used for the fill inside each bar\
<li><b>linecolor</b>: the color to be used for the outline around each bar'
+optionsMissing+
'</ul>';

    // mugl properties
    private var _fillcolor:uint;
    private var _downfillcolor:uint;
    private var _linecolor:uint;
    private var _barwidth:String;
    private var _baroffset:Number;
    private var _fillopacity:Number;
    private var _linethickness:Number;
    private var _barbase:Number;
        
    // Accessible color properties
    public var _linecolor_str:String;   
    public var _fillcolor_str:String;
    public var _downfillcolor_str:String;
        
    private var _trueWidth:Number;
    private var _barpixelWidth:uint;
    private var _barpixelOffset:uint;
    private var _barbaseIsSet:Boolean;
    private var _barpixelBase:Number;
        
    private var _prevPoint:Array;
    private var _linePoints:Array;
    private var _iDatas:Array;
        
    private var _numberAndUnit:Object;
    
    public function get fillcolor ():String { return _fillcolor_str; }
    public function set fillcolor (color:String):void {
      _fillcolor_str = color;
      _fillcolor = parseColor(color); 
    }
        
    public function get downfillcolor ():String { return _downfillcolor_str; }
    public function set downfillcolor (color:String):void {
      _downfillcolor_str = color;
      _downfillcolor = parseColor(color); 
    }
        
    public function get linecolor ():String { return _linecolor_str; }
    public function set linecolor (color:String):void {
      _linecolor_str = color; 
      _linecolor = parseColor(color);
    }
        
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
        
    public function Bar (haxis:HorizontalAxis, vaxis:VerticalAxis)
    {
      super(haxis, vaxis);
      _fillcolor = 0x000000;
      _downfillcolor_str = null;
      _linecolor = 0x000000;
      _barwidth = "1";
      _baroffset = 0;
      _fillopacity = 1;
      _linethickness = 1;
      _barbaseIsSet = false;
    }
        
    override public function begin (sprite:MultigraphUIComponent):void {
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
            
      _prevPoint = null;
      _barpixelWidth = _trueWidth * _haxis.axisToDataRatio;
      if (_barpixelWidth < 1) { _barpixelWidth = 1; }
      _barpixelOffset = _barpixelWidth * _baroffset;
      _barpixelBase = 0;
      if (_barbaseIsSet) {
        _barpixelBase = _vaxis.dataValueToAxisValue(_barbase);
      }
      _linePoints = new Array();
    }
    
    override public function dataPoint (sprite:MultigraphUIComponent, datap:Array):void {
      if (isMissing(datap[1])) { return; }
      var p:Array = [];
      transformPoint(p, datap);
      var g:Graphics = sprite.graphics;
      //var gsprite:Sprite = sprite;
            
      if (_barbaseIsSet && _downfillcolor_str != null && p[1] < _barpixelBase) {
        g.beginFill(_downfillcolor, _fillopacity);
      } else {
        g.beginFill(_fillcolor, _fillopacity);
      }
      g.lineStyle(0,  1, 0);
      g.moveTo(p[0] - _barpixelOffset, _barpixelBase);
      g.lineTo(p[0] - _barpixelOffset, _barpixelBase);
      g.lineTo(p[0] - _barpixelOffset, p[1]);
      g.lineTo(p[0] - _barpixelOffset + _barpixelWidth, p[1]);
      g.lineTo(p[0] - _barpixelOffset + _barpixelWidth, _barpixelBase);
      g.endFill();
      _linePoints.push(p);
    }
        
    override public function end(sprite:MultigraphUIComponent):void {
	  var g:Graphics = sprite.graphics;
	           
      if (_barpixelWidth < _linethickness) { 
      	g.lineStyle(_linethickness, _fillcolor, _fillopacity);
      } else {
      	g.lineStyle(_linethickness, _linecolor, 1);
      }
      
      var x:int = _linePoints.length;
      for each (var p:Array in _linePoints) {
          g.moveTo(p[0] - _barpixelOffset, _barpixelBase);
          g.lineTo(p[0] - _barpixelOffset, p[1]);
          g.lineTo(p[0] - _barpixelOffset + _barpixelWidth, p[1]);
                
          if (_prevPoint != null) {
            if (p[0] - _barpixelOffset - _barpixelWidth > _prevPoint[0] - _barpixelOffset + _barpixelWidth) {
              g.moveTo(_prevPoint[0] - _barpixelOffset + _barpixelWidth, _prevPoint[1]);
              g.lineTo(_prevPoint[0] - _barpixelOffset + _barpixelWidth, _barpixelBase);
                        
            } else if(p[1] < _prevPoint[1]) {
              g.moveTo(p[0] - _barpixelOffset, _prevPoint[1]);
              g.lineTo(p[0] - _barpixelOffset, p[1]);
            }
          }
                
          // Draw the last line
          if (x == 1) {
            g.moveTo(p[0] - _barpixelOffset + _barpixelWidth, p[1]);
            g.lineTo(p[0] - _barpixelOffset + _barpixelWidth, _barpixelBase);   
          }
                
          x--;
          _prevPoint = p;
                
        }
    }
    
    override public function renderLegendIcon(sprite:MultigraphUIComponent, legendLabel:String, opacity:Number):void {   	
    	var g:Graphics = sprite.graphics;
    	
    	// Draw icon background (with opacity)
    	g.lineStyle(1, 0xFFFFFF, opacity);
    	g.beginFill(0xFFFFFF, opacity);
    	g.drawRect(0, 0, sprite.width, sprite.height);
    	g.endFill();
    	
    	g.beginFill(_fillcolor, _fillopacity);
    	if (_barpixelWidth < 10) { 
      		g.lineStyle(_linethickness, _fillcolor, _fillopacity);
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
