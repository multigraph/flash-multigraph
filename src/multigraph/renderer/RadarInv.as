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
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import multigraph.Axis;
	import multigraph.TextLabel;
	import multigraph.format.DateFormatter;
    import multigraph.parsecolor;
    import multigraph.data.Data;

	
	import mx.controls.Button;
	
  public class RadarInv extends Renderer
  {
    static public var keyword:String = 'radarinv';
    static public var description:String = 'Radar Inventory Plot - for specialized by NCDC';
    static public var options:String = '<ul>' + 
    		'<li><b>linethickness</b> - pixel thickness of lines to draw; default is 1'
    		'</ul>'
    		;

	// Mugl properties
	private var _clearmodecolor:uint   = 0x0000ff; // mode==1
	private var _precipmodecolor:uint  = 0xff0000; // mode==2
	private var _maintmodecolor:uint   = 0x00ff00; // mode=23
	private var _unknownmodecolor:uint = 0x000000; // mode=other
	private var _linethickness:int     = 1;
	
    private var _lineheight:int;
    private var _dateFormat:String = 'H:i n d';
    private var _dateFormatter:DateFormatter;
    private var _textFormat:TextFormat;
	
	public function set linethickness(h:String):void { _linethickness = int(h); }
	public function get linethickness():String { return _linethickness.toString(); }

    public function RadarInv(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
      super(haxis, vaxis, data, varids);
      _dateFormatter = new DateFormatter(_dateFormat);
      _textFormat = new TextFormat();
      _textFormat.font = "default";
      _textFormat.color = 0x000000;
      _textFormat.size = 12;
      _lineheight = _haxis.graph.plotBox.height - 15;
    }

    override public function begin(sprite:UIComponent):void {
    }

	private var p:Array = [];
    override public function dataPoint(sprite:UIComponent, datap:Array):void {
      transformPoint(p, datap);
      var g:Graphics = sprite.graphics;
	  if (datap[1] == 1) {
	  	g.lineStyle(_linethickness, _clearmodecolor, 1);
	  } else if (datap[1] == 2) {
		g.lineStyle(_linethickness, _precipmodecolor, 1);
	  } else if (datap[1] == 23) {
		g.lineStyle(_linethickness, _maintmodecolor, 1);
	  } else {
		g.lineStyle(_linethickness, _unknownmodecolor, 1);
	  }
	  g.moveTo(p[0], 0);
	  g.lineTo(p[0], _lineheight); // graph.plotBox.height - position
    }

    override public function end(sprite:UIComponent):void {
      var minDateString:String = _dateFormatter.format(_haxis.dataMin);
      var px = _haxis.dataValueToAxisValue(_haxis.dataMin);
      var py = _haxis.graph.plotBox.height + 5;
      var minTextLabel:TextLabel = new TextLabel(minDateString,
	        									 _textFormat,
	        									 px, py,
	        									 -1, 1,
	        									 0);
      sprite.addChild(minTextLabel);

      var maxDateString:String = _dateFormatter.format(_haxis.dataMax);
      px = _haxis.dataValueToAxisValue(_haxis.dataMax);
      var maxTextLabel:TextLabel = new TextLabel(maxDateString,
	        									 _textFormat,
	        									 px, py,
	        									 1.05, 1,
	        									 0);
      sprite.addChild(maxTextLabel);
    }
    
    override public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {
    	
    }
  }
}
