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
  
  import multigraph.format.DateFormatter;
  
  import mx.core.UIComponent;
  
  public class DateLabeler extends Labeler
  {
    private var _startUTCms:Number;
    private var _startTurboDate:TurboDate;
    private var _firstTickTurboDate:TurboDate;
    private var _currentUTCms:Number;
    private var _currentTurboDate:TurboDate;
    private var _end:Number;
    private var _step:int;
    
    private var _spacingPixels:Number;
    private var _labelWidthPixels:Number;
    private var _pixelsPerInchFactor:Number;
    
//  private var _lastTextLabelWidth:Number = 25;
//  private var _lastTextLabelHeight:Number = 25;
    
    public function DateLabeler(axis:Axis,
                                spacing:Number,
                                unit:String,
                                formatString:String,
                                visible:Boolean,
                                start:String, 
                                position:DPoint,
                                anchor:DPoint,
                                angle:Number,
                                textFormat:TextFormat,
								densityFactor:Number)
    {
      _formatter 			 = new DateFormatter(formatString);
      _startUTCms            = _formatter.parse(start);
      _startTurboDate        = new TurboDate(_startUTCms);
      super(axis,
            spacing,
            unit,
            formatString,
            visible,
            _startUTCms,
            position,
            anchor,
            angle,
            textFormat,
	  	    densityFactor);
      _currentUTCms 		 = null;
      _end 				     = null;
      _msSpacing 			 = null;
      _spacingPixels 		 = 0;
      _labelWidthPixels 	 = 0;
      _pixelsPerInchFactor = 0.8 * (60.0 / 72.0);
      _unit                  = unit;
      
      switch(unit){
      case "Y":
        _msSpacing = _spacing * 3600000 * 24 * 365;
        break;
      case "M":
        _msSpacing = _spacing * 3600000 * 24 * 30;
        break;
      case "D":
        _msSpacing = _spacing * 3600000 * 24;
        break;
      case "H":
        _msSpacing = _spacing * 3600000;
        break;
      case "m":
        _msSpacing = _spacing * 60000;
        break;
      case "s": // seconds
        _msSpacing = _spacing * 1000;
        break;
      case "v": // deciseconds
        _msSpacing = _spacing * 100;
        break;
      case "V": // centiseconds
        _msSpacing = _spacing * 10;
        break;
      case "q": // milliseconds
      default:
        _msSpacing = _spacing;
        break;
      }

    }

//  label density now computed by inherited function from Labeler.as
//    
//    override public function labelDensity(debug:Boolean):Number {
//      /*
//        var labelLength       = _formatter.getLength();
//        var labelHeightPixels = _fontSize * _pixelsPerInchFactor;
//        var labelWidthPixels  = labelLength * labelHeightPixels;
//        var absAngle          = Math.abs(_angle) * 3.14156 / 180;
//        var labelPixels       = (axis.orientation == Axis.ORIENTATION_HORIZONTAL)
//        ? labelHeightPixels * Math.sin(absAngle) + labelWidthPixels * Math.cos(absAngle)
//        : labelHeightPixels * Math.cos(absAngle) + labelWidthPixels * Math.sin(absAngle);
//      */
//	  var representativeValue:Number = this._axis.dataMin + 0.51234567 * ( this._axis.dataMax - this._axis.dataMin );
//	  var representativeValueString:String = _formatter.format(representativeValue);
//	  var fontSize = (_textFormat.size !== null) ? int(_textFormat.size) : 12;
//	  var representativeWidth = representativeValueString.length * fontSize * 0.66667;
//	  var representativeHeight = fontSize * 1.25;
//	  var absAngle:Number          = Math.abs(_angle) * 3.14156 / 180;
//	  var labelPixels:Number       = (_axis.orientation == AxisOrientation.HORIZONTAL)
//		  ? representativeHeight * Math.sin(absAngle) + representativeWidth * Math.cos(absAngle)
//		  : representativeHeight * Math.cos(absAngle) + representativeWidth * Math.sin(absAngle);
//	  /*
//	  var labelPixels:Number       = (_axis.orientation == AxisOrientation.HORIZONTAL)
//		  ? _lastTextLabelHeight * Math.sin(absAngle) + _lastTextLabelWidth * Math.cos(absAngle)
//		  : _lastTextLabelHeight * Math.cos(absAngle) + _lastTextLabelWidth * Math.sin(absAngle);
//	  */
//      var spacingPixels:Number     = _msSpacing * Math.abs(_axis.axisToDataRatio);
//      var density:Number           = _densityFactor * labelPixels / spacingPixels;
//      return density;
//    }
    
    override public function renderLabel(sprite:UIComponent, value:Number):void {
      var a:Number  = _axis.dataValueToAxisValue(value);
      
      var px:Number, py:Number;
      if (_axis.orientation == AxisOrientation.VERTICAL) {
        px = _axis.perpOffset + _position.x;
        py = a + _position.y;
      } else {
        px = a + _position.x;
        py = _axis.perpOffset + _position.y;
      }
      var tLabel:TextLabel = new TextLabel(_formatter.format(value),
                                           _textFormat,
                                           px, py,
                                           _anchor.x, _anchor.y,
                                           _angle);
      if (_visible) {
        sprite.addChild(tLabel);
      }
//    _lastTextLabelWidth  = tLabel.textWidth;   	
//    _lastTextLabelHeight = tLabel.textHeight;   	
    }
    
    override public function prepare(dataMin:Number, dataMax:Number):void {
      var direction:int = (dataMax >= dataMin) ? 1 : -1;
      var dataStartTurboDate:TurboDate = (direction > 0) ? new TurboDate(dataMin) : new TurboDate(dataMax);
      switch (_unit) {

      case "Y":
        _firstTickTurboDate = dataStartTurboDate.firstYearSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneDay * 365;
        break;
      case "M":
        _firstTickTurboDate = dataStartTurboDate.firstMonthSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneDay * 30;
        break;
      case "D":
        _firstTickTurboDate = dataStartTurboDate.firstDaySpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneDay;
        break;
      case "H":
        _firstTickTurboDate = dataStartTurboDate.firstHourSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneHour;
        break;
      case "m":
        _firstTickTurboDate = dataStartTurboDate.firstMinuteSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneMinute;
        break;
      case "s":
        _firstTickTurboDate = dataStartTurboDate.firstSecondSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneSecond;
        break;
      case "v":
        _firstTickTurboDate = dataStartTurboDate.firstDecisecondSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneDecisecond;
        break;
      case "V":
        _firstTickTurboDate = dataStartTurboDate.firstCentisecondSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing * TurboDate.millisecondsInOneCentisecond;
        break;
      case "q":
      default:
        _firstTickTurboDate = dataStartTurboDate.firstMillisecondSpacingTickAtOrAfter(_startTurboDate, _spacing);
        _msSpacing = _spacing;
        break;
      }
      _currentTurboDate = _firstTickTurboDate.clone();
      _currentUTCms = _currentTurboDate.getUTCMilliseconds();
      _end = (direction > 0) ? dataMax : dataMin;
      _step = 0;
    }
    
    override public function hasNext():Boolean {
      return _currentUTCms <= _end;
    }
    
    override public function next():Number {
      var val:Number = _currentUTCms;
      ++_step;
      _currentTurboDate = _firstTickTurboDate.clone();
      switch (_unit) {
      case "Y":
        _currentTurboDate.addYears(_step * _spacing);
        break;
      case "M":
        _currentTurboDate.addMonths(_step * _spacing);
        break;
      case "D":
        _currentTurboDate.addDays(_step * _spacing);
        break;
      case "H":
        _currentTurboDate.addHours(_step * _spacing);
        break;
      case "m":
        _currentTurboDate.addMinutes(_step * _spacing);
        break;
      case "s":
        _currentTurboDate.addMilliseconds(_step * _spacing*1000);
        break;
      case "v":
        _currentTurboDate.addMilliseconds(_step * _spacing*100);
        break;
      case "V":
        _currentTurboDate.addMilliseconds(_step * _spacing*10);
        break;
      case "q":
      default:
        _currentTurboDate.addMilliseconds(_step * _spacing);
        break;
      }
      _currentUTCms = _currentTurboDate.getUTCMilliseconds();
      return val;
    }		
  }
}
