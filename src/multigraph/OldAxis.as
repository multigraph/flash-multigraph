/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.display.Graphics;
  import flash.events.EventDispatcher;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import mx.core.UIComponent;

  import multigraph.format.*;

/**
 * Dispatched when the data range for this axis changes, either as a
 * result of the user panning or zooming, or as a result of
 * setDataRange() or setDataRangeFromStrings() being called.
 *
 *  @eventType multigraph.AxisEvent.CHANGE
 */
[Event(name="change", type="multigraph.AxisEvent")]

  /**
   * <p>The Axis object encapsulates everything related to an axis in a Graph, including:</p>
   *
   * <ul>
   *    <li>the axis's data type (number or datetime)</li>
   *    <li>the mapping between pixels ("axis" values) and data values</li>
   *    <li>information related to the visual display of the axis, such as position, length, color, etc</li>
   *    <li>handling of events related to the user panning or zooming along the axis</li>
   * </ul>
   *
   * <p>The Axis class may not be instantiated outside of Multigraph; do not attempt to
   * call the Axis() constructor to create new Axis objects.  You may use the methods
   * documented here, however, to interact with an existing Axis object that is contained
   * in a Graph (and accessed via the Graph.axes property).</p>
   *
   * <p>The Axis class may not be used directly in MXML code; the only multigraph object that
   * can be directly created via MXML is the Multigraph.</p>
   */
  public class Axis extends EventDispatcher
  {
	// id of the axis
    private var _id:String;
    /**
     * @private
     */
	public function get id():String { return _id; }

	// pixel length of the axis
    private var _length:int;
    /**
     * @private
     */
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
    /**
     * @private
     */
	public function get perpOffset():int { return _perpOffset; }
    private var _parallelOffset:int;
    /**
     * @private
     */
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
    /**
     * @private
     */
	public function get haveDataMin():Boolean { return _haveDataMin; }
    /**
     * The data value corresponding to the minimum endpoint of the axis.  If the axis is of
     * type datetime, this value is the internal microsecond value corresponding to the
     * date/time.
     */
	public function get dataMin():Number { return _dataMin; }
    /**
     * @private
     */
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
    /**
     * @private
     */
	public function get haveDataMax():Boolean { return _haveDataMax; }
    /**
     * The data value corresponding to the maximum endpoint of the axis.  If the axis is of
     * type datetime, this value is the internal microsecond value corresponding to the
     * date/time.
     */
	public function get dataMax():Number { return _dataMax; }
    /**
     * @private
     */
    public function set dataMax(max:Number):void {
      _dataMax = max;
	  _haveDataMax = true;
      if (_haveDataMin && _haveDataMax) {
       _axisToDataRatio = (_length - _maxOffset - _minOffset) / (_dataMax - _dataMin);
      }
    }

    private var _axisToDataRatio:Number;
    /**
     * @private
     */
    public function get axisToDataRatio():Number { return _axisToDataRatio; }

    /**
     * @private
     */
    public static var TYPE_UNKNOWN:int = 0;
    /**
     * The value of the <i>type</i> property for axes of type "number".
     */
    public static var TYPE_NUMBER:int = 1;
    /**
     * The value of the <i>type</i> property for axes of type "datetime".
     */
    public static var TYPE_DATETIME:int = 2;

    private var _type:int;
    /**
     * The type of this axis.
     */
    public function get type():int { return _type; }

    private var _title:String;
    /**
     * @private
     */
    public function get title():String { return _title; }
    private var _titlePx:Number;
    /**
     * @private
     */
    public function get titlePx():Number { return _titlePx; }
    private var _titlePy:Number;
    /**
     * @private
     */
    public function get titlePy():Number { return _titlePy; }
    private var _titleAx:Number;
    /**
     * @private
     */
    public function get titleAx():Number { return _titleAx; }
    private var _titleAy:Number;
    /**
     * @private
     */
    public function get titleAy():Number { return _titleAy; }
    private var _titleAngle:Number;
    /**
     * @private
     */
    public function get titleAngle():Number { return _titleAngle; }

    private var _controller : AxisController = null;
    public function set controller(newcontroller:AxisController) { this._controller = newcontroller; }
    public function get controller():AxisController { return _controller; }

    private var _clientData : Object = null;
    /**
     * @private
     */
    public function get clientData():Object { return _clientData; }

    /**
     * @private
     */
    public static function parseType(string:String):int {
      switch (string) {
      case "number": return TYPE_NUMBER;
      case "datetime": return TYPE_DATETIME;
      }
      return TYPE_UNKNOWN;
    }

    /**
     * @private
     */
    public static var ORIENTATION_NONE:int = 0;

    /**
     * The value of the <i>orientation</i> property for horizontal axes.
     */
    public static var ORIENTATION_HORIZONTAL:int = 1;

    /**
     * The value of the <i>orientation</i> property for vertical axes.
     */
    public static var ORIENTATION_VERTICAL:int = 2;

    private var _orientation:int = Axis.ORIENTATION_NONE;
    /**
     * The orientation of this axis.
     */
	public function get orientation():int { return _orientation; }
    /**
     * @private
     */
	public function set orientation(o:int):void { _orientation = o; }

    private var _labelers:Array = [];
    /**
     * @private
     */
    public function get labelers():Array { return _labelers; }

    private var _parser:Formatter = null;
    //public function get parser():Formatter { return _parser; }

    private var _graph:Graph;
    /**
     * @private
     */
    public function get graph():Graph { return _graph; }

    private var _panConfig:PanConfig;
    /**
     * @private
     */
    public function get panConfig():PanConfig { return _panConfig; }

    private var _zoomConfig:ZoomConfig;
    /**
     * @private
     */
    public function get zoomConfig():ZoomConfig { return _zoomConfig; }

    private var _binding:AxisBinding = null;
    /**
     * @private
     */
    public function get binding():AxisBinding { return _binding; }

	private var _grid:Boolean = false;
    /**
     * @private
     */
	public function get grid():Boolean { return _grid; }

	private var _gridColor:uint = 0x000000;
    /**
     * @private
     */
	public function get gridColor():uint { return _gridColor; }

	private var _color:uint = 0x000000;
    /**
     * @private
     */
	public function get color():uint { return _color; }

    private var _lineWidth:int;
    /**
     * @private
     */
    public function get lineWidth():int { return _lineWidth; }

    private var _tickMin:int;
    /**
     * @private
     */
    public function get tickMin():int { return _tickMin; }

    private var _tickMax:int;
    /**
     * @private
     */
    public function get tickMax():int { return _tickMax; }

	/*
	private var _axisControl:AxisControls = null;
	public function get axisControl():AxisControls { return _axisControl; }
	public function set axisControl(controls:AxisControls):void { _axisControl = controls; }
	private var _hasAxisControls:Boolean = false;
	public function get hasAxisControls():Boolean { return _hasAxisControls; }
	public function set hasAxisControls(condition:Boolean):void { _hasAxisControls = condition; }
    */
	
    private var _titleTextFormat:TextFormat;
    private var _titleBoldTextFormat:TextFormat;


    // this gets set to true in the constructor if the data direction
    // of this axis is reversed from what you'd usually expect,
    // i.e. the location of the "min" data value is to the right, or
    // above, the location of the "max" data value.
    private var _reversed:Boolean = false;

    /**
     * @private
     */
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
                         /*highlightStyle:int,*/
                         titleTextFormat:TextFormat,
                         titleBoldTextFormat:TextFormat,
                         clientData
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
      _clientData      = clientData;
      /*_highlightStyle  = highlightStyle;*/

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

    /**
     * @private
     */
    public function parse(string:String):Number {
	  if (_parser != null) {
		return _parser.parse(string);
  	  }
      return Number(string);
    }

    /**
     * @private
     */
    public function setDataRangeNoBind(min:Number,max:Number):void {
      dataMin = min;
      dataMax = max;
      if (_graph != null) {
		// Check to make sure _graph is nonnull so that this method will work when
		// used in a testing environment, where we have axes that aren't actually
		// associated with a Graph object.  In real use, however, _graph will always
		// be nonnull.
		//_graph.paintNeeded = true;
		_graph.invalidateDisplayList();
	  }
	  if (_onSetDataRange != null) {
		  _onSetDataRange(min,max);
	  }
	  dispatchEvent(new AxisEvent(AxisEvent.CHANGE,min,max));
    }

	private var _onSetDataRange:Function = null;
    /**
     * @private
     */
	public function get onSetDataRange():Function { return _onSetDataRange; }
    /**
     * @private
     */
	public function set onSetDataRange(func:Function):void { _onSetDataRange = func; }

    /**
     * Set the minimum and maximum data values for the axis.
     */
    public function setDataRange(min:Number,max:Number):void {
      if (_binding != null) {
        _binding.setDataRange(this, min, max);
      } else {
        setDataRangeNoBind(min, max);
      }
    }

    /**
     * Set the minimum and maximum data values for the axis, using string values
     * that can be of the form "YYYYMMDDHHmmss" (or any meaningful prefix thereof)
     * for axes of type datetime.
     */
    public function setDataRangeFromStrings(min:String, max:String):void {
      var minValue:Number = parse(min);
      var maxValue:Number = parse(max);
	  setDataRange(minValue, maxValue);
    }

    /**
     * @private
     */
    public function setBinding(binding:AxisBinding, min:String, max:String):void {
      _binding = binding;
      var minValue:Number = parse(min);
      var maxValue:Number = parse(max);
      binding.addAxis(this, minValue, maxValue);
      setDataRangeNoBind(minValue, maxValue);
    }

    /**
     * @private
     */
    public function dataValueToAxisValue(v:Number):Number {
      return _axisToDataRatio * ( v - _dataMin ) + _minOffset + _parallelOffset;
    }

    /**
     * @private
     */
    public function axisValueToDataValue(V:Number):Number {
      return (V - _minOffset - _parallelOffset) / _axisToDataRatio + _dataMin;
    }

    /**
     * @private
     */
    public function renderGrid(sprite:UIComponent):void {
      // Render the grid lines for this axis, if any

      // skip if grid lines aren't turned on
      if (!_grid) { return ; }

      //skip if we don't yet have data values
      if (!_haveDataMin || !_haveDataMax) { return; }

      var g:Graphics = sprite.graphics;
      prepareRender();

      if (labelers.length > 0 && _density <= 1.5) {
        _labeler.prepare(dataMin, dataMax);
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


    /**
     * @private
     */
    public function render(sprite:UIComponent):void {
      // Render the axis line, tick marks, labels, and title
      // (everything other than the grid)
      var g:Graphics = sprite.graphics;

      var titleTextFormat:TextFormat = _titleTextFormat;

      //var useBold:Boolean =  (this.selected && (_highlightStyle==Axis.HIGHLIGHT_LABELS || _highlightStyle==Axis.HIGHLIGHT_ALL));
      var useBold:Boolean = _controller!=null && _controller.useBoldLabels();

      if (useBold) {
        titleTextFormat = _titleBoldTextFormat;
      }

      // render the axis line itself:
      if (_lineWidth > 0) {
        if (_controller!=null && _controller.useBoldAxis()) {
          g.lineStyle(_lineWidth+3,_color,1);
        } else {
          g.lineStyle(_lineWidth,_color,1);
        }
        if (_orientation == Axis.ORIENTATION_HORIZONTAL) {
          g.moveTo(_parallelOffset, _perpOffset);
          g.lineTo(_parallelOffset + _length, _perpOffset);
        } else {
          g.moveTo(_perpOffset, _parallelOffset);
          g.lineTo(_perpOffset, _parallelOffset + _length);
        }
      }

      //>>>>>>>>>>>>>>>>
      return;   // stop at this point for now   <<<<<<<<<<<<<<
      //>>>>>>>>>>>>>>>>

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
      if (_haveDataMin && _haveDataMax) { // but skip if we don't yet have data values
        if (labelers.length > 0 && _density <= 1.5) {
          var tickThickness:int = 1;
          if (_controller!=null && _controller.useBoldLabels()) {
            tickThickness = 3;
          }
          _labeler.prepare(dataMin, dataMax);
          _labeler.useBold = useBold;
          while (_labeler.hasNext()) {
            var v:Number = _labeler.next();
            var a:Number = dataValueToAxisValue(v);
            g.lineStyle(tickThickness,_color,1);
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
      }

    }

    /**
     * @private
     */
    public function addLabeler(labeler:Labeler):void {
      _labelers.push(labeler);
    }

    /**
     * @private
     */
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

    /**
     * @private
     */
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
    /**
     * @private
     */
    public static function getInstanceById(id:String):Axis {
      return _s_instances[id];
    }



    /**
     * @private
     */
    public var _labeler:Labeler;
    /**
     * @private
     */
    public var _density:Number;
    /**
     * @private
     */
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

    private function computeDims() : void {
      var plotBox : Box = _graph.plotBox;
      _length = _lengthDisplacement.calculateLength((axisClass == HorizontalAxis) ? _plotBox.width : _plotBox.height );
    }

    private var _lengthDisplacement : Displacement;

    public static function create(graph : Graph, axisClass : Object, config : Config) : Axis {

        var type:int = -1;
        var axisTypeString:String = config.value('@type'); 
        switch (axisTypeString) {
        case "number":
          type = Axis.TYPE_NUMBER;
          break;
        case "datetime":
          type = Axis.TYPE_DATETIME;
          break;
        }
        
        var id:String        = config.value('@id');
        var min:String       = config.value('@min');
		var max:String       = config.value('@max');
        //var minoffset:String = config.value('@minoffset');
        //var maxoffset:String = config.value('@maxoffset');
        //var pregap:Number = config.value('@pregap');
        //var postgap:Number = config.value('@postgap');

        var minPosition:Displacement = Displacement.parse( config.value('@minposition') );
        var maxPosition:Displacement = Displacement.parse( config.value('@maxposition') );

        var position:String   = config.value('@position');
        var axisPosition:PixelPoint = PixelPoint.parse(position, (axisClass==HorizontalAxis) ? 1 : 0);

        var base:String       = config.value('@base');

        //
        // code to handle deprecated "@positionbase" attribute; only has effect if "@base" is not specifed in xml
        //
        var xmlbase:String = config.xmlvalue('@base');
        if (xmlbase==null || xmlbase=="") {
          var positionbase:String = config.xmlvalue('@positionbase');
          if (positionbase == 'right') {
            base = "1 -1";
          }
          if (positionbase == 'top') {
            base = "-1 1";
          }
        }
        //
        // end of code to handle deprecated "@positionbase" attribute
        //

        var axisBase:PixelPoint = PixelPoint.parse(base);

        var anchor:Number     = Number(config.value('@anchor'));

        _lengthDisplacement:Displacement = Displacement.parse( config.value('@length') );
        
        var parallelOffset:Number = 0;
		var perpOffset:Number = 0;

        if (axisClass == HorizontalAxis) {
          parallelOffset = axisPosition.x + (axisBase.x + 1) * _plotBox.width/2 - (anchor + 1) * length / 2;
          perpOffset = axisPosition.y + (axisBase.y + 1) * _plotBox.height/2;
        } else {
          parallelOffset = axisPosition.y + (axisBase.y + 1) * _plotBox.height/2 - (anchor + 1) * length / 2;
          perpOffset = axisPosition.x + (axisBase.x + 1) * _plotBox.width/2;
        }

        var title:String  = config.xmlvalue('title');

        var titlePositionString:String = config.xmlvalue('title','@position');
        if (titlePositionString==null || titlePositionString=="") {
          if (axisClass == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              titlePositionString = config.value('title','@position_horiz_top');
            } else {
              titlePositionString = config.value('title','@position_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              titlePositionString = config.value('title','@position_vert_right');
            } else {
              titlePositionString = config.value('title','@position_vert_left');
            }
          }
        }
        var titlePosition:PixelPoint = PixelPoint.parse( titlePositionString );

        var titleAnchorString:String = config.xmlvalue('title','@anchor');
        if (titleAnchorString==null || titleAnchorString=="") {
          if (axisClass == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              titleAnchorString = config.value('title','@anchor_horiz_top');
            } else {
              titleAnchorString = config.value('title','@anchor_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              titleAnchorString = config.value('title','@anchor_vert_right');
            } else {
              titleAnchorString = config.value('title','@anchor_vert_left');
            }
          }
        }
        var titleAnchor:PixelPoint = PixelPoint.parse( titleAnchorString );

        var titleAngle:Number = parseFloat(config.value('title','@angle'));

		var color:uint = parsecolor( config.value('@color') );

        var grid:Boolean = (config.xmlvalue('grid') != null);
		var gridColor:uint = parsecolor( config.value('grid','@color') );

        var lineWidth:int = config.value('@linewidth');

        var tickMin:int = config.value('@tickmin');
        var tickMax:int = config.value('@tickmax');

        var highlightStyleString:String = config.value('@highlightstyle');
        var highlightStyle:int = SelectedAxisUIAxisController.HIGHLIGHT_AXIS;
        if (highlightStyleString == "labels") {
          highlightStyle = SelectedAxisUIAxisController.HIGHLIGHT_LABELS;
        } else if (highlightStyleString == "all") {
          highlightStyle = SelectedAxisUIAxisController.HIGHLIGHT_ALL;
        }
		
        var titleTextFormat:TextFormat = new TextFormat();
        titleTextFormat.font  = config.value('title','@fontname');
        titleTextFormat.size  = config.value('title','@fontsize');
        titleTextFormat.color = config.value('title','@fontcolor');
        titleTextFormat.align = TextFormatAlign.LEFT;

        var titleBoldTextFormat:TextFormat = new TextFormat();
        titleBoldTextFormat.font  = titleTextFormat.font + "Bold";
        titleBoldTextFormat.size  = titleTextFormat.size;
        titleBoldTextFormat.color = titleTextFormat.color;
        titleBoldTextFormat.align = titleTextFormat.align;

        var axis : Axis = new axisClass(id,
                               this,
                               length,
                               parallelOffset,
                               perpOffset,
                               type,
                               color, //0x000000,
                               min,
                               minPosition.calculateCoordinate(length), //minoffset,
                               max,
                               length - maxPosition.calculateCoordinate(length), //maxoffset,
                               title,
                               titlePosition.x,
                               titlePosition.y,
                               titleAnchor.x,
                               titleAnchor.y,
                               titleAngle,
                               grid,
                               gridColor,
                               lineWidth,
                               tickMin,
                               tickMax,
                               titleTextFormat,
                               titleBoldTextFormat,
                               highlightStyle
                               );

        axis.panConfig.setConfig(config.value('pan', '@allowed'),
                                    config.value('pan', '@min'),
                                    config.value('pan', '@max'));
                                       
        axis.zoomConfig.setConfig(config.value('zoom', '@allowed'),
                                     config.value('zoom', '@anchor'),
                                     config.value('zoom', '@min'),
                                     config.value('zoom', '@max'));

		/*
        // Setup the axis controls
        var axisControlsVisible:String = config.value('axiscontrols', '@visible');
        if(axisControlsVisible == "true") {
          axis.hasAxisControls = true;
          axis.axisControl = new AxisControls(_axisControlSprite, axis, _config);
        }
		*/

        var labelPositionString:String = config.xmlvalue('labels', '@position');
        if (labelPositionString==null || labelPositionString=="") {
          if (axisClass == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              labelPositionString = config.value('labels','@position_horiz_top');
            } else {
              labelPositionString = config.value('labels','@position_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              labelPositionString = config.value('labels','@position_vert_right');
            } else {
              labelPositionString = config.value('labels','@position_vert_left');
            }
          }
        }
        var labelPosition:PixelPoint = PixelPoint.parse( labelPositionString );

        var labelAnchorString:String = config.xmlvalue('labels', '@anchor');
        if (labelAnchorString==null || labelAnchorString=="") {
          if (axisClass == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              labelAnchorString = config.value('labels','@anchor_horiz_top');
            } else {
              labelAnchorString = config.value('labels','@anchor_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              labelAnchorString = config.value('labels','@anchor_vert_right');
            } else {
              labelAnchorString = config.value('labels','@anchor_vert_left');
            }
          }
        }
        var labelAnchor:PixelPoint = PixelPoint.parse( labelAnchorString );

        var labeler:Labeler;
        
        var labelerType:Object = (type == Axis.TYPE_DATETIME) ? DateLabeler : NumberLabeler;
        
        var spacingAndUnit:NumberAndUnit;
        if(config.xmlvalue('labels', 'label') != null) {
          var nlabeltags:int = config.xmlvalue('labels','label').length();
          for(var k:int = 0; k < nlabeltags; ++k) {
            var hlabelSpacings:Array = config.value('labels', 'label', k, '@spacing').split(" ");
            var labelTextFormat:TextFormat = new TextFormat();
            labelTextFormat.font  = config.value('labels','label',k,'@fontname');
            labelTextFormat.size  = config.value('labels','label',k,'@fontsize');
            labelTextFormat.color = config.value('labels','label',k,'@fontcolor');
            labelTextFormat.align = TextFormatAlign.LEFT;
            
            var labelBoldTextFormat:TextFormat = new TextFormat();
            labelBoldTextFormat.font  = labelTextFormat.font + "Bold";
            labelBoldTextFormat.size  = labelTextFormat.size;
            labelBoldTextFormat.color = labelTextFormat.color;
            labelBoldTextFormat.align = labelTextFormat.align;
            for (var j:int=0; j<hlabelSpacings.length; ++j) {
              var spacing = hlabelSpacings[j];
              spacingAndUnit = NumberAndUnit.parse(spacing);

              labeler = new labelerType(spacingAndUnit.number,
                                        spacingAndUnit.unit,
                                        config.value('labels', 'label', k, '@format'),
                                        config.value('labels', '@start'),
                                        labelPosition.x,
                                        labelPosition.y,
                                        config.value('labels', '@angle'),
                                        labelAnchor.x, 
                                        labelAnchor.y,
                                        labelTextFormat,
                                        labelBoldTextFormat);
              axis.addLabeler(labeler);
            }
          } 
        } else {
          var hlabelSpacings:Array = config.value('labels', '@spacing').split(" ");
          var labelTextFormat:TextFormat = new TextFormat();
          labelTextFormat.font  = config.value('labels','@fontname');
          labelTextFormat.size  = config.value('labels','@fontsize');
          labelTextFormat.color = config.value('labels','@fontcolor');
          labelTextFormat.align = TextFormatAlign.LEFT;
          
          var labelBoldTextFormat:TextFormat = new TextFormat();
          labelBoldTextFormat.font  = labelTextFormat.font + "Bold";
          labelBoldTextFormat.size  = labelTextFormat.size;
          labelBoldTextFormat.color = labelTextFormat.color;
          labelBoldTextFormat.align = labelTextFormat.align;
          for (var k:int=0; k<hlabelSpacings.length; ++k) {
            var spacing = hlabelSpacings[k];
            spacingAndUnit = NumberAndUnit.parse(spacing);
            labeler = new labelerType(spacingAndUnit.number,
                                      spacingAndUnit.unit,
                                      config.value('labels', '@format'),
                                      config.value('labels', '@start'),  //parseFloat(config.value('labels', '@start')),
                                      labelPosition.x,
                                      labelPosition.y,
                                      parseFloat(config.value('labels','@angle')),
                                      labelAnchor.x,
                                      labelAnchor.y,
                                      labelTextFormat,
                                      labelBoldTextFormat);
            axis.addLabeler(labeler);
          }   
        }

        return axis;
    }




  }
}
