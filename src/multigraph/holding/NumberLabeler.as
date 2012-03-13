/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph
{
	import flash.text.TextFormat;
	import mx.core.UIComponent;	
	import multigraph.format.NumberFormatter;
	
    public class NumberLabeler extends Labeler
    {
      private var _formatter:NumberFormatter;
      
      private var _current:Number;
      private var _end:Number;
      
      private var _spacingPixels:Number;
      private var _labelWidthPixels:Number;
      private var _pixelsPerInchFactor:Number;
      
      private var _lastTextLabelWidth:Number  = 25;
      private var _lastTextLabelHeight:Number = 25;

      public function NumberLabeler(spacing:Number, unit:String, formatString:String, start:Number,
                                    px:Number, py:Number, angle:Number, ax:Number, ay:Number,
                                    textFormat:TextFormat, boldTextFormat:TextFormat) {
        super(spacing, unit, formatString, start, px, py, angle, ax, ay, textFormat, boldTextFormat);
        _current             = 0;
        _end                 = 0;
        _spacingPixels       = 0;
        _labelWidthPixels    = 0;
        _pixelsPerInchFactor = 60.0/ 72.0;
        _formatter           = new NumberFormatter(formatString);
        
      }

  	  override public function labelDensity(axis:Axis):Number {
  	  	/*
        var pow:Number               = Math.LOG10E * Math.log(Math.abs(axis.dataMax));
        var labelLength:Number       = (pow >= 0) ? 1 + pow  : 2 - pow;
        var labelHeightPixels:Number = _fontSize * _pixelsPerInchFactor;
        var labelWidthPixels:Number  = labelLength * labelHeightPixels;
        var absAngle:Number          = Math.abs(_angle) * 3.14156 / 180;
        var labelPixels:Number       = (axis.orientation == Axis.ORIENTATION_HORIZONTAL)
            ? labelHeightPixels * Math.sin(absAngle) + labelWidthPixels * Math.cos(absAngle)
            : labelHeightPixels * Math.cos(absAngle) + labelWidthPixels * Math.sin(absAngle);
        */
	    var absAngle          = Math.abs(_angle) * 3.14156 / 180;
	    var labelPixels       = (axis.orientation == Axis.ORIENTATION_HORIZONTAL)
	            ? _lastTextLabelHeight * Math.sin(absAngle) + _lastTextLabelWidth * Math.cos(absAngle)
	            : _lastTextLabelHeight * Math.cos(absAngle) + _lastTextLabelWidth * Math.sin(absAngle);
        var spacingPixels:Number     = _spacing * Math.abs(axis.axisToDataRatio);
        var density:Number           = labelPixels / spacingPixels;
        
        return density;
      }

      override public function renderLabel(sprite:UIComponent, axis:Axis, value:Number):void {
        var a:Number  = axis.dataValueToAxisValue(value);
        
        var px:Number, py:Number;
        if(axis.orientation == Axis.ORIENTATION_VERTICAL) {
        	px = axis.perpOffset + _px;
			py = a + _py;
        } else {
        	px = a + _px;
        	py = axis.perpOffset + _py;
        }
        var tLabel:TextLabel = new TextLabel(_formatter.format(value),
                                             _useBold ? _boldTextFormat :_textFormat,
        									 px, py,
        									 _ax, _ay,
        									 _angle);
        sprite.addChild(tLabel);  
		_lastTextLabelWidth  = tLabel.width;
		_lastTextLabelHeight = tLabel.height;

/*
      	sprite.graphics.lineStyle(1,0xff0000,1);
      	sprite.graphics.drawCircle(px, py, 15);
      	sprite.graphics.beginFill(0xff0000);
      	sprite.graphics.drawCircle(px,py, 2);
      	sprite.graphics.endFill();
*/      	

      }

      private function gmod(m:Number, n:Number):Number {
		var sign:int = 1;
		if (m < 0) {
	    	sign = -1;
	    	m = -m;
		}
		var f:Number = Math.floor(m/n);
		return sign * ( m - f * n );
      }

      override public function prepare(dataMin:Number, dataMax:Number):void {
        /*
		var F:int = 1.0;
		var f:Number;
        var dataStart:Number = (dataMax >= dataMin) ? dataMin : dataMax;
		if (dataStart >= _start) {
		    f = Math.floor( (dataStart - _start) / _spacing );
		    if (dataStart - _start > _spacing * f * F) {
				_current = _spacing * ( 1 + f ) + _start;
		    } else {
				_current = _spacing * f + _start;
		    }
		} else {
		    f = Math.floor( (_start - dataStart) / _spacing );
		    if (dataStart - _start > -_spacing * (f + 1) * F) {
				_current = -_spacing * (f) + _start;
		    } else {
				_current = -_spacing * (f - 1) + _start;
		    }
		}
        */
        _current = firstTick(dataMin, dataMax, _spacing, _start);
		_end = (dataMax >= dataMin) ? dataMax : dataMin;
      }

      public static function firstTick(dataMin:Number, dataMax:Number, spacing:Number, start:Number):Number {
		var F:int = 1.0;
		var f:Number;
        var dataStart:Number = (dataMax >= dataMin) ? dataMin : dataMax;
		if (dataStart >= start) {
		    f = Math.floor( (dataStart - start) / spacing );
		    if (dataStart - start > spacing * f * F) {
              return spacing * ( 1 + f ) + start;
		    } else {
              return spacing * f + start;
		    }
		} else {
		    f = Math.floor( (start - dataStart) / spacing );
		    if (dataStart - start > -spacing * (f + 1) * F) {
              return -spacing * (f) + start;
		    } else {
              return -spacing * (f - 1) + start;
		    }
		}
      }

      override public function hasNext():Boolean {
        return _current <= _end;
      }

      override public function next():Number {
        var val:Number = _current;
        _current += _spacing;    
        return val;
      }
    }
}
