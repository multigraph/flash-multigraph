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
	
  public class LineError extends Renderer
  {
    static public var keyword:String = 'lineerror';
    static public var description:String = 'Standard line plot with optional dots at data points';
    static public var options:String = '<ul>\
<li><b>linecolor</b>: color to be used for the lines\
<li><b>linewidth</b>: width for lines\
<li><b>dotcolor</b>: color to be used for the dots\
<li><b>dotsize</b>: size for dots; default is 0, which means draw no dots\
</ul>';

	// Mugl properties
	private var _linecolor:uint;
	private var _linecolor_str:String;
    private var _dotcolor:uint;
    private var _dotcolor_str:String;
    private var _dotsize:Number;
    private var _dotsize_str:String;
    
    public var linewidth:Number;
    private var dots:Array;
    private var prevPoint:Array;
    
    public function set linecolor(color:String):void {
    	_linecolor_str = color;
    	_linecolor = parsecolor(color);
    }
    public function get linecolor():String {
    	return _linecolor_str;
    }
    
    public function set dotcolor(color:String):void {
    	_dotcolor_str = color;
    	_dotcolor = parsecolor(color);
    }
    public function get dotcolor():String {
    	return _dotcolor_str;
    }
    
    public function get dotsize():String {
    	return _dotsize_str;
    }
    
    public function set dotsize(size:String):void {
    	_dotsize_str = size;
    	_dotsize = Number(size);
    }
    
    public function LineError(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
      super(haxis, vaxis, data, varids);
      _linecolor = 0x000000;
      _dotcolor  = 0x000000;
      _dotsize   = 0;
      linewidth = 1;
      dots      = [];
      prevPoint = null;
    }

    override public function begin(sprite:UIComponent):void {
      this.prevPoint = null;
      this.dots      = [];
    }

    override public function dataPoint(sprite:UIComponent, datap:Array):void {
      var p:Array = [];
      var l:Array = [];
      transformPoint(p, datap);
      var g:Graphics = sprite.graphics;
        
      if (prevPoint != null) {
        g.lineStyle(linewidth, _linecolor, 1);
        g.moveTo(prevPoint[0], prevPoint[1]);
        g.lineTo(p[0], p[1]);
      }
      prevPoint = p;
	
      dots.push(prevPoint);
    }

    override public function end(sprite:UIComponent):void {
      if (_dotsize > 0) { // don't draw dots if dotsize<=0
        var g:Graphics = sprite.graphics;
        g.beginFill(_dotcolor);
        var p:Array;
        while(dots.length > 0) {
          p = dots.pop();
          g.drawCircle(p[0], p[1], _dotsize);
      	  
      	  // This section draws the error bars
      	  g.lineStyle(0, 0x000000, 1);
      	  // Draw first tic mark
      	  g.moveTo(p[0] - _dotsize / 2, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      	  g.lineTo(p[0] + _dotsize / 2, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      	  // Draw error bar
      	  g.moveTo(p[0], super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) + super._vaxis.axisValueToDataValue(p[2])));
      	  g.lineTo(p[0], super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));
      	  // Draw second tic mark
      	  g.moveTo(p[0] - _dotsize / 2, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));
      	  g.lineTo(p[0] + _dotsize / 2, super._vaxis.dataValueToAxisValue(super._vaxis.axisValueToDataValue(p[1]) - super._vaxis.axisValueToDataValue(p[2])));
        }
        g.endFill();
      }
    }
    
    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {
    	var g:Graphics = sprite.graphics;
    	
    	g.lineStyle(linewidth, _linecolor, 1, false, "normal", flash.display.CapsStyle.NONE, flash.display.JointStyle.ROUND);
    	g.moveTo(1, 15);
    	g.lineTo(40, 15);
    	
    	// Draw the error bars
    	g.lineStyle(0, 0x000000, 1);
    	g.moveTo(10, 25);
    	g.lineTo(10, 5);
    	g.moveTo(8, 25); // Error tics
    	g.lineTo(13, 25);
    	g.moveTo(8, 5);
    	g.lineTo(13, 5);
    	
    	g.moveTo(30, 25);
    	g.lineTo(30, 5);
    	g.moveTo(28, 25); // Error Tics
    	g.lineTo(33, 25);
    	g.moveTo(28, 5);
    	g.lineTo(33, 5);
    	
    	if (_dotsize > 0) {
    		g.beginFill(_dotcolor, 1);
    		g.drawCircle(10, 15, 3);
    		g.drawCircle(30, 15, 3);
    		g.endFill();
    	}
    	
    	// Draw the icon border    	
    	g.lineStyle(1, 0x000000, 1);
    	g.beginFill(0xFFFFFF, 0);
    	g.drawRect(0, 0, sprite.width, sprite.height);
    	g.endFill();
    }
  }
}
