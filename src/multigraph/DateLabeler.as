/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph 
{
	import flash.text.TextFormat;
	
	import multigraph.format.DateFormatter;
	
	public class DateLabeler extends Labeler
	{
		private var _fontSize:uint;
		private var _current:Number;
		private var _end:Number;
		private var _formatter:DateFormatter;
		private var _textFormat:TextFormat;
		
		private var _msSpacing:Number;
		private var _spacingPixels:Number;
		private var _labelWidthPixels:Number;
		private var _pixelsPerInchFactor:Number;
		
		private var _lastTextLabelWidth:Number = 25;
		private var _lastTextLabelHeight:Number = 25;
				
		public function DateLabeler(spacing:Number, unit:String, formatString:String, start:Number, 
									px:Number, py:Number, angle:Number, ax:Number, ay:Number)
		{
			super(spacing, unit, formatString, start, px, py, angle, ax, ay);
			_fontSize 			 = 12;
			_current 			 = null;
			_end 				 = null;
			_formatter 			 = new DateFormatter(formatString);
			_msSpacing 			 = null;
			_spacingPixels 		 = 0;
			_labelWidthPixels 	 = 0;
			_pixelsPerInchFactor = 0.8 * (60.0 / 72.0);
			
			_textFormat = new TextFormat();
			_textFormat.font = "DefaultFont";
			_textFormat.color = 0x000000;
			_textFormat.size = _fontSize;
			
			switch(unit){
	        case "H":
	            _msSpacing = spacing * 3600000;
	            break;
	        case "D":
	            _msSpacing = spacing * 3600000 * 24;
	            break;
	        case "M":
	            _msSpacing = spacing * 3600000 * 24 * 30;
	            break;
	        case "Y":
	            _msSpacing = spacing * 3600000 * 24 * 365;
	            break;
	        case "m":
	            _msSpacing = spacing * 60000;
	            break;
	        default:
	            _msSpacing = spacing;
	            break;
	        }
		}
		
		override public function labelDensity(axis:Axis):Number {
			/*
	        var labelLength       = _formatter.getLength();
	        var labelHeightPixels = _fontSize * _pixelsPerInchFactor;
	        var labelWidthPixels  = labelLength * labelHeightPixels;
	        var absAngle          = Math.abs(_angle) * 3.14156 / 180;
	        var labelPixels       = (axis.orientation == Axis.ORIENTATION_HORIZONTAL)
	            ? labelHeightPixels * Math.sin(absAngle) + labelWidthPixels * Math.cos(absAngle)
	            : labelHeightPixels * Math.cos(absAngle) + labelWidthPixels * Math.sin(absAngle);
	        */
	        var absAngle:Number          = Math.abs(_angle) * 3.14156 / 180;
	        var labelPixels:Number       = (axis.orientation == Axis.ORIENTATION_HORIZONTAL)
	            ? _lastTextLabelHeight * Math.sin(absAngle) + _lastTextLabelWidth * Math.cos(absAngle)
	            : _lastTextLabelHeight * Math.cos(absAngle) + _lastTextLabelWidth * Math.sin(absAngle);
	        var spacingPixels:Number     = _msSpacing * axis.axisToDataRatio;
	        var density:Number           = labelPixels / spacingPixels;
	
	        return density;
      	}
      	
      	override public function renderLabel(sprite:MultigraphUIComponent, axis:Axis, value:Number):void {
	        var a:Number  = axis.dataValueToAxisValue(value);
	        
	        var px:Number, py:Number;
	        if(axis.orientation == Axis.ORIENTATION_VERTICAL) {
	        	px = axis.position + _px;
				py = a + _py;
	        } else {
	        	px = a + _px;
	        	py = axis.position + _py;
	        }
	        var tLabel:TextLabel = new TextLabel(_formatter.format(value),
	        									 _textFormat,
	        									 px, py,
	        									 _ax, _ay,
	        									 _angle);
	        sprite.addChild(tLabel);
	        _lastTextLabelWidth  = tLabel.textWidth;   	
	        _lastTextLabelHeight = tLabel.textHeight;   	
        }
        
        override public function prepare(dataMin:Number, dataMax:Number):void {
			_current = dataMin + ( _msSpacing - ( (dataMin - _start - 1) % _msSpacing + 1 ) );
        	_end = dataMax;
		}
	
      	override public function hasNext():Boolean {
        	return _current <= _end;
      	}

      	override public function next():Number {
        	var val:Number = _current;
        	_current += _msSpacing;
        	return val;
      	}		
	}
}
