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
  
  import mx.core.UIComponent;
  import multigraph.Axis;
  import multigraph.NumberAndUnit;
  import multigraph.parsecolor;
  import multigraph.data.Data;
    
  public class BarError extends Renderer
  {
    static public var keyword:String = 'barerror';
    static public var description:String = 'Standard bar graph';
    static public var options:String = '<ul>\
<li><b>barwidth</b>: the width of each bar, in pixels\
<li><b>baroffset</b>: the offset of the left edge of each bar from the corresponding data value\
<li><b>fillcolor</b>: the color to be used for the fill inside each bar\
<li><b>linecolor</b>: the color to be used for the outline around each bar\
</ul>';

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
        
    public function BarError (haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _fillcolor = 0x000000;
      _downfillcolor_str = null;
      _linecolor = 0x000000;
      _barwidth = "1";
      _baroffset = 0;
      _fillopacity = 1;
      _linethickness = 1;
      _barbaseIsSet = false;
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
    
    override public function dataPoint (sprite:UIComponent, datap:Array):void {
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
      
      // This section draws the error bars
      g.lineStyle(0, 0x000000, 1);
      // Draw first tic mark
      g.moveTo(p[0] - 3, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      g.lineTo(p[0] + 3, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      // Draw error bar
      g.moveTo(p[0], super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      g.lineTo(p[0], super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));
      // Draw second tic mark
      g.moveTo(p[0] - 3, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));
      g.lineTo(p[0] + 3, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));

	  g.beginFill(_fillcolor, 1);
      g.drawCircle(p[0], p[1], 3);
      g.endFill();

	  /**
	   * TODO: This will draw an interactive data point. Unfortunately
	   * due to the way that graphics are (re)painted through the primary 
	   * Graph, it appears that adding event listeners just to the idata point
	   * is not enough to simply add the interaction. 
	   * 
	   * 1. Look into moving where the data points are created. (Plot, Axis,
	   * 	just outside of the renderer. 
	   */
	   
/* 	   sprite.mouseChildren = true;
	  var iData:InteractiveDataPoint = new InteractiveDataPoint(p); 
	  iData.addEventListener(MouseEvent.CLICK, iData.drawPoint);
	  sprite.addChild(iData);
	  //_iDatas.push(iData);
	  trace(sprite.getChildAt(sprite.getChildIndex(iData)).width);
	  sprite.getChildAt(sprite.getChildIndex(iData)).addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
	  												trace("clicked main sprite");
	  											});
      _linePoints.push(p); */
    }
        
    override public function end(sprite:UIComponent):void {
	  var g:Graphics = sprite.graphics;
	  
	  //for each(var data:InteractiveDataPoint in _iDatas) {
	  	//sprite.addChild(data);
	  //}
	  
	  /**
	   * TODO: Figure out what is happening here.
 	   * It appears that if the shape being  
	   */            
      if (_barpixelWidth < 10) { 
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
    
    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {
    	
    }
  }
}
