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
    
  public class RangeBar extends Renderer
  {
    static public var keyword:String = 'rangebar';
    static public var description:String = 'bar plot with two variables: 1st var is bottom of bar, 2nd var is top of bar';
    static public var options:String = '<ul>\
<li><b>barwidth</b>: the width of each bar, in pixels\
<li><b>baroffset</b>: the offset of the left edge of each bar from the corresponding data value\
<li><b>fillcolor</b>: the color to be used for the fill inside each bar; if barbase is specified, this color is used only for bars that extend above the base\
<li><b>linecolor</b>: the color to be used for the outline around each bar\
<li><b>hidelines</b>: hide bar outlines when the bars are less wide than this number of pixels; default is 2\
</ul>';

    // mugl properties
    public  var _fillcolor:uint;
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
    public var _fillcolor_str:String;
        
    private var _trueWidth:Number;
    private var _barpixelWidth:uint;
    private var _barpixelOffset:uint;
        
    private var _numberAndUnit:Object;
    
    public function get linecolor ():String { return _linecolor_str; }
    public function set linecolor (color:String):void {
      _linecolor_str = color; 
      _linecolor = parsecolor(color);
    }
    public function get fillcolor ():String { return _fillcolor_str; }
    public function set fillcolor (color:String):void {
      _fillcolor_str = color; 
      _fillcolor = parsecolor(color);
    }
        
    public function get barwidth ():String { return _barwidth; }
    public function set barwidth (width:String):void { _barwidth = width; }
        
    public function get baroffset ():Number { return _baroffset; }
    public function set baroffset (offset:Number):void { _baroffset = offset; }

    public function get fillopacity ():String { return _fillopacity+''; }
    public function set fillopacity (opacity:String):void {
      _fillopacity = Number(opacity);
    }
        
    public function RangeBar (haxis:Axis, vaxis:Axis, data:Data, varids:Array)
    {
      super(haxis, vaxis, data, varids);
      _linecolor = 0x000000;
      _barwidth = "1";
      _baroffset = 0;
      _fillopacity = 1;
    }
        
    override public function begin (sprite:UIComponent):void {

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

    }
    
    override public function dataPoint (sprite:UIComponent, datap:Array):void {
      if (isMissing(datap[1],1) || isMissing(datap[2],2)) { return; }
      var p:Array = [];
      transformPoint(p, datap);
      var g:Graphics = sprite.graphics;


      var x0:int = p[0] - _barpixelOffset;
      var x1:int = p[0] - _barpixelOffset + _barpixelWidth;

      g.beginFill(_fillcolor, _fillopacity);
      g.lineStyle(0,  0, 0);
      g.moveTo(x0, p[1]);
      g.lineTo(x0, p[2]);
      g.lineTo(x1, p[2]);
      g.lineTo(x1, p[1]);
      g.lineTo(x0, p[1]);
      g.endFill();

    }
        
    override public function end(sprite:UIComponent):void {
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
		  g.drawRect(sprite.width/4 - barwidth/2,                    sprite.height/8,  barwidth,  sprite.height/2);
		  g.drawRect(sprite.width - sprite.width/4 - barwidth/2,     sprite.height/4,  barwidth,  sprite.height/3);
	  }
	  
	  g.drawRect(sprite.width/2 - barwidth/2,                    0,  barwidth,  sprite.height-sprite.height/4);
	  
	  
	  g.endFill();
	  
  }
}
  
}
