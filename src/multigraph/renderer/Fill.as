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

	public class Fill extends Renderer
	{
      static public var keyword:String = 'fill';
      static public var description:String = 'Plot lines connecting data points, with a solid fill between the lines and the horizontal axis';
      static public var options:String = '<ul>\
<li><b>linecolor</b>: the color to be used for the lines\
<li><b>linethickness</b>: the thickness of the lines, in pixels\
<li><b>fillcolor</b>: the color to be used for the fill area\
<li><b>fillopacity</b>: the opacity to be used for the fill area'
+optionsMissing+
'</ul>';
		
		// Mugl properties
		private var _fillcolor:uint;
		private var _linecolor:uint;
		private var _linethickness:uint;
		private var _fillopacity:Number;
		
		
		public var _fillcolor_str:String;
		public var _linecolor_str:String;
		
		private var _points:String;
		private var _prevPoint:Array;
		private var _g:Graphics;
		
		public function get fillcolor():String { return _fillcolor+''; }
		public function set fillcolor(color:String):void {
			_fillcolor_str = color; 
			_fillcolor = parseColor(color);
		}
		
		public function get linecolor():String { return _linecolor+''; }
		public function set linecolor(color:String):void {
			_linecolor_str = color;
			_linecolor = parseColor(color);
		}
		
		public function get fillopacity ():String { return _fillopacity+''; }
		public function set fillopacity (opacity:String):void {
			_fillopacity = Number(opacity);
		}
		
		public function get linethickness ():String { return _linethickness+''; }
		public function set linethickness (thickness:String):void {
			_linethickness = uint(Number(thickness));
		}
		
		public function Fill(haxis:Axis, vaxis:Axis)
		{
			super(haxis, vaxis);
			_fillcolor = 0x000000;
			_linecolor = 0x000000;
			_linethickness = 1;
			_fillopacity = 1;
		}
		
		override public function begin(sprite:MultigraphUIComponent):void {
			_prevPoint = null;
			_g = sprite.graphics;
		}

		override public function dataPoint(sprite:MultigraphUIComponent, datap:Array):void {
		  var p:Array = [];
	      transformPoint(p, datap);


          if(_prevPoint != null) {
            _g.beginFill(_fillcolor, _fillopacity);
            _g.moveTo(_prevPoint[0], 0);
            _g.lineStyle(0, _fillcolor, _fillopacity);
            _g.lineTo(_prevPoint[0], _prevPoint[1]);
            _g.lineStyle(_linethickness, _linecolor, 1);
            _g.lineTo(p[0], p[1]);
            _g.lineStyle(0, _fillcolor, _fillopacity);
            _g.lineTo(p[0], 0);
            _g.lineStyle(0, _fillcolor, 0);
            _g.lineTo(_prevPoint[0], 0);
            _g.endFill();
          }
          _prevPoint = p;
          
          
              ///////////////////////////////////////


//          if (isMissing(datap[1])) {
//			if(_prevPoint != null) {
//              _g.moveTo(p[0], 0);
//            }
//            _prevPoint = null;
//          } else {
//			if(_prevPoint == null) {
//				_g.moveTo(p[0], 0);
//			}
//			_g.lineTo(p[0], p[1]);
//			_prevPoint = p;
//          }

		}
		
		override public function end(sprite:MultigraphUIComponent):void {
		}

//		override public function begin(sprite:MultigraphUIComponent):void {
//			_prevPoint = null;
//			_g = sprite.graphics;
//			_g.beginFill(_fillcolor, _fillopacity);
//			_g.lineStyle(_linethickness, _linecolor, 1);
//		}
//
//		override public function dataPoint(sprite:MultigraphUIComponent, datap:Array):void {
//		  var p:Array = [];
//	      transformPoint(p, datap);
//          if (isMissing(datap[1])) {
//			if(_prevPoint != null) {
//              _g.moveTo(p[0], 0);
//            }
//            _prevPoint = null;
//          } else {
//			if(_prevPoint == null) {
//				_g.moveTo(p[0], 0);
//			}
//			_g.lineTo(p[0], p[1]);
//			_prevPoint = p;
//          }
//		}
//		
//		override public function end(sprite:MultigraphUIComponent):void {
//			if(_prevPoint != null) {
//				_g.lineTo(_prevPoint[0], 0);	
//			}		
//			_g.endFill();
//		}

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
    	
	    	g.lineStyle(_linethickness, _linecolor, 1);
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
    		g.lineStyle(1, 0x000000, 1);
    		g.beginFill(0xFFFFFF, 0);
    		g.drawRect(0, 0, sprite.width, sprite.height);
    		g.endFill();
    	}
	}
}
