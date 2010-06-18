/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  
  import multigraph.format.*;
  
  public class Axis
    /**
     * The Axis object encapsulates stuff related to a graph's axis, including
     *  - the axis's data type (number or datetime)
     *  - the mapping between pixels ("axis" values) and data values
     *  - information related to the visual display of the axis, such as position and length
     */
  {
	// id of the axis
    private var _id:String;
	public function get id():String { return _id; }

	// pixel length of the axis
    private var _length:int;
	public function get length():int { return _length; }

	
	// perpOffset and parallelOffset give the location of the axis in the graph,
	// relative to the plot area.  perpOffset and parallelOffset are pixel
	// values, and give the location of the lower left endpoint of the axis,
	// as a coordinate offset from the lower left corner of the plot area.
	// For a horizontal axis the lower left (i.e. left) endpoint of the
	// axis is (parallelOffset, perpOffset), and for a vertical axis the lower
	// left (i.e. lower) endpoint is (perpOffset, parallelOffset).
	// Note that axes are specified in
	// mugl files in terms of the "position", "positionbase",
	// "pregap", and "postgap" attributes; these are converted to
	// _length, _perpOffset, and _parallelOffset before the Axis() constructor
	// is called.
    private var _perpOffset:int;
	public function get perpOffset():int { return _perpOffset; }
    private var _parallelOffset:int;   
	public function get parallelOffset():int { return _parallelOffset; }
	
	
	// pixel offset, relative to the left or bottom end of the axis, of the point
	// on the axis corresponding to the min data point.  Positive offsets are
	// towards the center of the axis.
    private var _minOffset:int;
	//public function get minOffset():int { return _minOffset; }

	// pixel offset, relative to the right or top end of the axis, of the point
	// on the axis corresponding to the max data point.   Positive offsets are
	// towards the center of the axis.
    private var _maxOffset:int;
	//public function get maxOffset():int { return _maxOffset; }

	//
	// _dataMin is the min data value; access through dataMin getter/setter property in order to keep
	// record of whether it is set, and to update the axisToDataRatio accordingly.
	//
    private var _dataMin:Number;
    private var _haveDataMin:Boolean = false;
	public function get haveDataMin():Boolean { return _haveDataMin; }
	public function get dataMin():Number { return _dataMin; }
    public function set dataMin(min:Number):void {
      _dataMin = min;
	  _haveDataMin = true;
      if (_haveDataMin && _haveDataMax) {
        _axisToDataRatio = (_length - _maxOffset - _minOffset) / (_dataMax - _dataMin);
      }
    }

	//
	// _dataMax is the max data value; access through dataMax getter/setter property in order to keep
	// record of whether it is set, and to update the axisToDataRatio accordingly.
	//
    private var _dataMax:Number;
    private var _haveDataMax:Boolean = false;
	public function get haveDataMax():Boolean { return _haveDataMax; }
	public function get dataMax():Number { return _dataMax; }
    public function set dataMax(max:Number):void {
      _dataMax = max;
	  _haveDataMax = true;
      if (_haveDataMin && _haveDataMax) {
       _axisToDataRatio = (_length - _maxOffset - _minOffset) / (_dataMax - _dataMin);
      }
    }

    private var _axisToDataRatio:Number;
    public function get axisToDataRatio():Number { return _axisToDataRatio; }

    public static var TYPE_UNKNOWN:int = 0;
    public static var TYPE_NUMBER:int = 1;
    public static var TYPE_DATETIME:int = 2;

    private var _type:int;
    public function get type():int { return _type; }
    
    private var _title:String;
    public function get title():String { return _title; }
    private var _titlePx:Number;
    public function get titlePx():Number { return _titlePx; }
    private var _titlePy:Number;
    public function get titlePy():Number { return _titlePy; }
    private var _titleAx:Number;
    public function get titleAx():Number { return _titleAx; }
    private var _titleAy:Number;
    public function get titleAy():Number { return _titleAy; }
    private var _titleAngle:Number;
    public function get titleAngle():Number { return _titleAngle; }

    public static function parseType(string:String):int {
      switch (string) {
      case "number": return TYPE_NUMBER;
      case "datetime": return TYPE_DATETIME;
      }
      return TYPE_UNKNOWN;
    }
    
    public static var ORIENTATION_NONE:int = 0;
    public static var ORIENTATION_HORIZONTAL:int = 1;
    public static var ORIENTATION_VERTICAL:int = 2;

    private var _orientation:int = Axis.ORIENTATION_NONE;
	public function get orientation():int { return _orientation; }
	public function set orientation(o:int):void { _orientation = o; }
	
    private var _labelers:Array = [];
    public function get labelers():Array { return _labelers; }

    private var _parser:Formatter = null;
    //public function get parser():Formatter { return _parser; }

    private var _graph:Graph;
    public function get graph():Graph { return _graph; }

    private var _selected:Boolean = false;
    public function get selected():Boolean { return _selected; }
    public function set selected(v:Boolean):void { _selected = v; }
    
    private var _mouseDragBase:PixelPoint = null;
    
    private var _mouseLast:PixelPoint = null;
    
    private var _pixelSelectionDistance:int = 30;

    private var _panConfig:PanConfig;
    public function get panConfig():PanConfig { return _panConfig; }
    
    private var _zoomConfig:ZoomConfig;
    public function get zoomConfig():ZoomConfig { return _zoomConfig; }
      
    private var _binding:AxisBinding = null;
    public function get binding():AxisBinding { return _binding; }

	private var _grid:Boolean = false;
	public function get grid():Boolean { return _grid; }

	private var _gridColor:uint = 0x000000;
	public function get gridColor():uint { return _gridColor; }

	private var _color:uint = 0x000000;
	public function get color():uint { return _color; }

    private var _lineWidth:int;
    public function get lineWidth():int { return _lineWidth; }
	
    private var _tickMin:int;
    public function get tickMin():int { return _tickMin; }
	
    private var _tickMax:int;
    public function get tickMax():int { return _tickMax; }
	
    public static var HIGHLIGHT_AXIS:int = 1;
    public static var HIGHLIGHT_LABELS:int = 2;
    public static var HIGHLIGHT_ALL:int = 3;

    private var _highlightStyle:int;
    public function get highlightStyle():int { return _highlightStyle; }
	
	private var _axisControl:AxisControls = null;
	public function get axisControl():AxisControls { return _axisControl; }
	public function set axisControl(controls:AxisControls):void { _axisControl = controls; }
	
	private var _hasAxisControls:Boolean = false;
	public function get hasAxisControls():Boolean { return _hasAxisControls; }
	public function set hasAxisControls(condition:Boolean):void { _hasAxisControls = condition; } 

    private var _titleTextFormat:TextFormat;
    private var _titleBoldTextFormat:TextFormat;


    // this gets set to true in the constructor if the data direction
    // of this axis is reversed from what you'd usually expect,
    // i.e. the location of the "min" data value is to the right, or
    // above, the location of the "max" data value.
    private var _reversed:Boolean = false;

    public function Axis(id:String,
						 graph:Graph,
						 length:int,
						 parallelOffset:int,
						 perpOffset:int,
						 type:int,
		   				 color:uint,
						 min:String,
						 minoffset:int,
						 max:String,
						 maxoffset:int,
                         title:String,
                         titlePx:Number,
						 titlePy:Number,
                         titleAx:Number,
						 titleAy:Number,
                         titleAngle:Number,
						 grid:Boolean,
						 gridColor:uint,
                         lineWidth:int,
                         tickMin:int,
                         tickMax:int,
                         highlightStyle:int,
                         titleTextFormat:TextFormat,
                         titleBoldTextFormat:TextFormat
						 )   {
      _id              = id;
      _s_instances[id] = this;
      _length          = length;
      _parallelOffset  = parallelOffset;
      _perpOffset      = perpOffset;
      _type            = type;
      _minOffset       = minoffset;
      _maxOffset       = maxoffset;
      _graph           = graph;
      _title           = title;
      _titlePx         = titlePx;
      _titlePy         = titlePy;
      _titleAx         = titleAx;
      _titleAy         = titleAy;
      _titleAngle      = titleAngle;
	  _grid            = grid;
	  _gridColor       = gridColor;
	  _color           = color;
      _lineWidth       = lineWidth;
      _tickMin		   = tickMin;
      _tickMax		   = tickMax;
      _highlightStyle  = highlightStyle;

      _reversed = (_minOffset > _length - _maxOffset);

	  if (title == null) { _title = _id; }
      if (_title == '') { _title = null; }

      // Establish a parser for converting this axis's data between strings and numeric values,  For a
      // number type axis there is no parser -- we simply cast back and forth.  For a "datetime" type
      // axis, the "parser" field is set to a DateParser object that has two methods: parse(), for
      // converting a string to a numeric value, and format(), for converting a numeric value to a string.
      switch (type) {
      case TYPE_DATETIME:
        _parser = new DateFormatter("YMDHs");
        break;
      case TYPE_NUMBER:
        _parser = null;
        break;
      case TYPE_UNKNOWN:
      	_parser = null;
      	break;
      }
      
      // Set the _dataMin and _dataMax fields, if possible.
	  if (min != "auto") {
	  	dataMin = parse(min);
      }

	  if (max != "auto") {
	  	dataMax = parse(max);
      }
      
      _panConfig = new PanConfig('allowed', null, null, this);
      _zoomConfig = new ZoomConfig('allowed', null, null, null, this);

      this._titleTextFormat = titleTextFormat;
      this._titleBoldTextFormat = titleBoldTextFormat;
    }
    
    public function parse(string:String):Number {
	  if (_parser != null) {
		return _parser.parse(string);
  	  }
      return Number(string);
    }
    
    public function setDataRangeNoBind(min:Number,max:Number):void {
      dataMin = min;
      dataMax = max;
      if (_graph != null) {
		// Check to make sure _graph is nonnull so that this method will work when
		// used in a testing environment, where we have axes that aren't actually
		// associated with a Graph object.  In real use, however, _graph will always
		// be nonnull.
		_graph.paintNeeded = true;
	  }
    }
      
    public function setDataRange(min:Number,max:Number):void {
      if (_binding != null) {
        _binding.setDataRange(this, min, max);
      } else {
        setDataRangeNoBind(min, max);
      }
    }
    
    public function setDataRangeFromStrings(min:String, max:String):void {
      var minValue:Number = parse(min);
      var maxValue:Number = parse(max);
	  setDataRange(minValue, maxValue);
    }
    
    public function setBinding(binding:AxisBinding, min:String, max:String):void {
      _binding = binding;
      var minValue:Number = parse(min);
      var maxValue:Number = parse(max);
      binding.addAxis(this, minValue, maxValue);
      setDataRangeNoBind(minValue, maxValue);
    }

    public function dataValueToAxisValue(v:Number):Number {
      return _axisToDataRatio * ( v - _dataMin ) + _minOffset + _parallelOffset;
    }

    public function axisValueToDataValue(V:Number):Number {
      return (V - _minOffset - _parallelOffset) / _axisToDataRatio + _dataMin;
    }

    public function render(sprite:MultigraphUIComponent, step:int):void {
      // Render this axis in the given sprite.  Step is an integer
      // that says which step of the rendering should be done. There
      // are currently two steps: step 0, which consists of rendering
      // the axis's grid lines, and step 1, which renders everything
      // else.  These are separated into two steps so that all of a
      // graph's axis' grid lines can be rendered before any of the
      // axes themselves, in order to insure that no grid lines lie on
      // top of any axes.
      var g:Graphics = sprite.graphics;

      var titleTextFormat:TextFormat = _titleTextFormat;

      var useBold:Boolean =  (this.selected && (_highlightStyle==Axis.HIGHLIGHT_LABELS || _highlightStyle==Axis.HIGHLIGHT_ALL));

      if (useBold) {
        titleTextFormat = _titleBoldTextFormat;
      }

      switch (step) {
      case 0:  // in step 0, render the grid lines associated with this axis, if any
        prepareRender();
        if (grid) {
          if (labelers.length > 0 && _density <= 1.5) {
            _labeler.prepare(dataMin, dataMax);
            _labeler.useBold = useBold;
            while (_labeler.hasNext()) {
              var v:Number = _labeler.next();
              var a:Number = dataValueToAxisValue(v);
              g.lineStyle(1, gridColor, 1);
              if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
                g.moveTo(a, perpOffset);
                g.lineTo(a, graph.plotBox.height - perpOffset);
              } else {
                g.moveTo(perpOffset, a);
                g.lineTo(graph.plotBox.width - perpOffset, a);
              }
            }
          }
        }
        break;

      default:
      case 1:  // in step 1, render everything else
        // render the axis itself:
        if (_lineWidth > 0) {
          if (this.selected && (_highlightStyle==Axis.HIGHLIGHT_AXIS || _highlightStyle==Axis.HIGHLIGHT_ALL)) {
            g.lineStyle(_lineWidth+3,0,1);
          } else {
            g.lineStyle(_lineWidth,0,1);
          }
          if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
            g.moveTo(_parallelOffset, _perpOffset);
            g.lineTo(_parallelOffset + _length, _perpOffset);
          } else {
            g.moveTo(_perpOffset, _parallelOffset);
            g.lineTo(_perpOffset, _parallelOffset + _length);
          }
        }

        // render the axis title
        if (title != null) {
          if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
            sprite.addChild(new TextLabel(title,
                                          titleTextFormat,
                                          _parallelOffset + _length / 2 + titlePx,  _perpOffset + titlePy,
                                          titleAx, titleAy,
                                          titleAngle));
          } else {
            sprite.addChild(new TextLabel(title,
                                          titleTextFormat,
                                          _perpOffset + titlePx,  _parallelOffset + _length / 2 + titlePy,
                                          titleAx, titleAy,
                                          titleAngle));
          }
        }

        // render the tick marks and labels
        if (labelers.length > 0 && _density <= 1.5) {
          var tickThickness:int = 1;
          if (this.selected && (_highlightStyle==Axis.HIGHLIGHT_LABELS || _highlightStyle==Axis.HIGHLIGHT_ALL)) {
            tickThickness = 3;
          }
          _labeler.prepare(dataMin, dataMax);
          _labeler.useBold = useBold;
          while (_labeler.hasNext()) {
            var v:Number = _labeler.next();
            var a:Number = dataValueToAxisValue(v);
            g.lineStyle(tickThickness,0,1);
            if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
              g.moveTo(a, perpOffset+_tickMax);
              g.lineTo(a, perpOffset+_tickMin);
            } else {
              g.moveTo(perpOffset+_tickMin, a);
              g.lineTo(perpOffset+_tickMax, a);
            }
            _labeler.renderLabel(sprite, this, v);
          }
        }
        break;
      }

    }


    public function addLabeler(labeler:Labeler):void {
      _labelers.push(labeler);
    }
    
    public function handleMouseDown(p:PixelPoint, event:MouseEvent):Boolean {
      if(axisControl != null) axisControl.destroyAllControls();
      _mouseDragBase = p;
      _mouseLast     = _mouseDragBase;
      return true;
    }

    public function handleMouseUp(p:PixelPoint, event:MouseEvent):Boolean {
      _mouseDragBase = null;
      _graph.prepareData();
      return true;
    }

    public function handleMouseOut(p:PixelPoint, event:MouseEvent):Boolean {
      return handleMouseUp(p, event);
    }

    public function handleMouseMove(p:PixelPoint, event:MouseEvent):Boolean {
      if(_mouseDragBase == null) {
        // this is a real 'move' event --- not a 'drag'
        var d:Number;
        var e:Number;
        if (_orientation == Axis.ORIENTATION_VERTICAL) {
          d = p.x - _perpOffset;
          e = p.y - _parallelOffset;
        } else {
          d = p.y - _perpOffset;
          e = p.x - _parallelOffset;
        }
        if (
            ((e >= 0) && (e <= _length))
            &&
            (((d >= 0) && (d < _pixelSelectionDistance)) || ((d < 0) && (d > -_pixelSelectionDistance)))
            ) {
		  if (_graph != null) { _graph.selectAxis(this); }
	/*
          // change the mouse cursor
          if (_orientation == Axis.VERTICAL) {
            graph.div.style.cursor="n-resize";
          } else {
            graph.div.style.cursor="e-resize";
          }
    */
          return true;
        }
      } else {
        var dx:Number = p.x- _mouseLast.x;
        var dy:Number = p.y- _mouseLast.y;
        _mouseLast = p;
        handleMouseDrag(dx, dy, event);
        return true;
      }
      return false;
    }

    public function handleMouseDrag(dx:Number, dy:Number, event:MouseEvent):void {
      if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
        if (event.shiftKey || _graph.toolbarState == "zoom") {
          if (_zoomConfig.allowed) { zoom(_mouseDragBase.x, dx); }
        } else {
          if (_panConfig.allowed) {
            pan(-dx);
          } else {
            //zoom(_mouseDragBase.x, dx);
          }
        }
      } else {
        if (event.shiftKey || _graph.toolbarState == "zoom") {
          if (_zoomConfig.allowed) { zoom(_mouseDragBase.y, dy); }
        } else {
          if (_panConfig.allowed) {
            pan(-dy);
          } else {
            //zoom(_mouseDragBase.y, dy);
          }
        }
      }
      /*
      if (Math.abs(dx) > 2 || Math.abs(dy) > 2) {
      	if(axisControl != null) axisControl.destroyAllControls();
      }
      */
    }
  
	private var _aCharCode:uint = 'a'.charCodeAt();
	private var _zCharCode:uint = 'z'.charCodeAt();
	private var _ACharCode:uint = 'A'.charCodeAt();
	private var _ZCharCode:uint = 'Z'.charCodeAt();
	
	private var _qCharCode:uint = 'q'.charCodeAt();
	private var _QCharCode:uint = 'Q'.charCodeAt();
	
	private var _plusCharCode:uint = '+'.charCodeAt();
	private var _minusCharCode:uint = '-'.charCodeAt();

    private var _lessCharCode:uint = '<'.charCodeAt();
    private var _greaterCharCode:uint = '>'.charCodeAt();

    public function handleKeyDown(p:PixelPoint, event:KeyboardEvent):void {
      var pixAmount = 3;
      switch (event.charCode) {
      case _aCharCode:
      case _ACharCode:
      case _minusCharCode:
        if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
          zoom(p.x, -pixAmount);
        } else {
          zoom(p.y, -pixAmount);
        }
        break;
      case _zCharCode:
      case _ZCharCode:
      case _plusCharCode:
        if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
          zoom(p.x, pixAmount);
        } else {
          zoom(p.y, pixAmount);
        }
        break;

      case _lessCharCode:
          pan(5*pixAmount);
          break;

      case _greaterCharCode:
          pan(-5*pixAmount);
          break;
        
      // TODO: Should there be a way to pan by holding a key?
      case _qCharCode:
      case _QCharCode:
      	if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
      		pan(10);
      	} else {
      		pan(10);
      	}
      	break;
      }
    }

    public function pan(pixelDisplacement:int):void {
        if (!_panConfig.allowed) { return; }
        var offset:Number = pixelDisplacement / _axisToDataRatio;
        var newMin:Number = _dataMin + offset;
        var newMax:Number = _dataMax + offset;
        if (pixelDisplacement < 0 && _panConfig.haveMin && newMin < _panConfig.min) {
        	newMax += (_panConfig.min - newMin);
            newMin = _panConfig.min;
        }
        if (pixelDisplacement > 0 && _panConfig.haveMax && newMax > _panConfig.max) {
        	newMin -= (newMax - _panConfig.max);
            newMax = _panConfig.max;
        }
        setDataRange( newMin, newMax );
    }

    public function zoom(base:Number, pixelDisplacement:Number):void {
        if (!_zoomConfig.allowed) { return; }
        var dataBase:Number = axisValueToDataValue(base);
        if (_zoomConfig.haveAnchor) {
            dataBase = _zoomConfig.anchor;
        }
        var factor:Number = 10 * Math.abs(pixelDisplacement / (_length - _maxOffset - _minOffset));
        if (_reversed) { factor = -factor; }
        var newMin:Number, newMax:Number;
        if (pixelDisplacement <= 0) {
            newMin = (_dataMin - dataBase) * ( 1 + factor ) + dataBase;
            newMax = (_dataMax - dataBase) * ( 1 + factor ) + dataBase;
        } else {
            newMin = (_dataMin - dataBase) * ( 1 - factor ) + dataBase;
            newMax = (_dataMax - dataBase) * ( 1 - factor ) + dataBase;
        }
        if (_panConfig.haveMin && newMin < _panConfig.min) {
            newMin = _panConfig.min;
        }
        if (_panConfig.haveMax && newMax > _panConfig.max) {
            newMax = _panConfig.max;
        }

        if ((_dataMin <= _dataMax && newMin < newMax)
            ||
            (_dataMin >= _dataMax && newMin > newMax)) {

          if (_zoomConfig.haveMax && (newMax - newMin > _zoomConfig.max)) {
            var d:Number = (newMax - newMin - _zoomConfig.max) / 2;
            newMax -= d;
            newMin += d;
          } else if (_zoomConfig.haveMin && (newMax - newMin < _zoomConfig.min)) {
            var d:Number = (_zoomConfig.min - (newMax - newMin)) / 2;
            newMax += d;
            newMin -= d;
          }

          setDataRange( newMin, newMax );
        }
    }

    static private var _s_instances:Array = [];
    public static function getInstanceById(id:String):Axis {
      return _s_instances[id];
    }



    public var _labeler:Labeler;
    public var _density:Number;
    public function prepareRender() {
      // Decide which labeler to use: take the one with the largest density <= 0.8.
      // Unless all have density > 0.8, in which case we take the first one.  This assumes
      // that the labelers list is ordered in increasing order of label density.
      // This function sets the _labeler and _density private properties.
      _labeler = labelers[0];
      _density = _labeler.labelDensity(this);
      if (_density < 0.8) {
        for (var i:uint = 1; i < _labelers.length; i++) {
          var density:Number = labelers[i].labelDensity(this);
          if (density > 0.8) { break; }
          _labeler = labelers[i];
          _density = density;
        }
      }
    }



  }
}
