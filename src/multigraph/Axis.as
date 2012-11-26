package multigraph
{
  import flash.events.EventDispatcher;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  
  import multigraph.format.DateFormatter;
  import multigraph.format.Formatter;
  
  import mx.core.UIComponent;

/**
 * Dispatched when the data range for this axis changes, either as a
 * result of the user panning or zooming, or as a result of
 * setDataRange() or setDataRangeFromStrings() being called.
 *
 *  @eventType multigraph.AxisEvent.CHANGE
 */
[Event(name="change", type="multigraph.AxisEvent")]

  public class Axis extends EventDispatcher
  {
    private var _graph          : Graph;
    private var _orientation    : AxisOrientation;
    private var _id             : String;
    private var _type           : DataType;
    private var _length         : Displacement;
    private var _pixelLength    : Number;
    private var _position       : DPoint;
    private var _base           : DPoint;
    private var _anchor         : Number;
    private var _linewidth      : Number;
    private var _color          : uint;
    private var _parallelOffset : Number;
    private var _perpOffset     : Number;
    private var _minposition    : Displacement;
    private var _maxposition    : Displacement;
    private var _minOffset      : Number;
    private var _maxOffset      : Number;
	private var _drawGrid       : Boolean;
	private var _gridColor      : uint;
    private var _tickmin        : Number;
    private var _tickmax        : Number;
	private var _tickcolor      : uint;
	private var _tickwidth      : Number;

    private var _parser         : Formatter = null;
    private var _geometryInitialized : Boolean = false;

    private var _title             : String;
    private var _titlePositionAttr : String;
    private var _titlePosition     : DPoint;
    private var _titleAnchorAttr   : String;
    private var _titleAnchor       : DPoint;
    private var _titleAngle        : Number;
    private var _titleTextFormat   : TextFormat;

    private var _labeler           : Labeler;
    private var _labelers          : Array;

    private var _zoomConfig:ZoomConfig;
    private var _panConfig:PanConfig;

    private var _binding:AxisBinding = null;

    // this gets set to true in initializeGeometry() if the data direction
    // of this axis is reversed from what you'd usually expect,
    // i.e. the location of the "min" data value is to the right, or
    // above, the location of the "max" data value.
    private var _reversed:Boolean = false;

    public function get id() : String {
      return _id;
    }
    public function get type() : DataType {
      return _type;
    }
    public function get orientation() : AxisOrientation {
      return _orientation;
    }
    public function get perpOffset() : Number {
      return _perpOffset;
    }
    public function get parallelOffset() : Number {
      return _parallelOffset;
    }
    public function get graph() : Graph {
      return _graph;
    }
    public function get pixelLength() : Number {
      return _pixelLength;
    }
    public function get zoomConfig() : ZoomConfig {
      return _zoomConfig;
    }
    public function get panConfig() : PanConfig {
      return _panConfig;
    }

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
      if (_haveDataMin && _haveDataMax && _geometryInitialized) {
        computeAxisToDataRatio();
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
      if (_haveDataMin && _haveDataMax && _geometryInitialized) {
        computeAxisToDataRatio();
      }
    }

    private var _axisToDataRatio:Number;
    /**
     * @private
     */
    public function get axisToDataRatio():Number { return _axisToDataRatio; }


    public function Axis(graph : Graph, orientation : AxisOrientation, config : Config, axisNumber : int = 0) {
      _graph = graph;
      _orientation = orientation;

      //
      // type
      //
      var typeAttr : String = config.value('@type');
      _type = DataType.parse( typeAttr );
      if (_type == DataType.UNKNOWN) {
        throwInvalidAttributeError("type", typeAttr);
      }

      // Establish a parser for converting this axis's data between strings and numeric values,  For a
      // number type axis there is no parser -- we simply cast back and forth.  For a "datetime" type
      // axis, the "parser" field is set to a DateParser object that has two methods: parse(), for
      // converting a string to a numeric value, and format(), for converting a numeric value to a string.
      _parser = null;
      if (_type == DataType.DATETIME) {
        _parser = new DateFormatter("YMDHs");
      }

      //
      // id
      //
      _id = config.value('@id');
      if (_id == null || _id == "") {
        _id = ((_orientation == AxisOrientation.HORIZONTAL) ? "x" : "y");
        if (axisNumber > 0) {
          _id = _id + axisNumber;
        }
      }
      _s_instances[id] = this;

      //
      // length
      //
      var lengthAttr : String = config.value('@length')
      try {
        _length = Displacement.parse( lengthAttr );
      } catch (e : ParseError) {
        throwInvalidAttributeError("length");
      }

      //
      // position
      //
      var positionAttr : String = config.value('@position');
      try {
        _position = DPoint.parseWithDefaultCoordinate(positionAttr, _orientation == AxisOrientation.HORIZONTAL ? 1 : 0);
      } catch (e : ParseError) {
        throwInvalidAttributeError("position");
      }

      //
      // base
      //
      var baseAttr : String = config.value('@base');
      /////////////////////////////////////////////////////////////
      // code to handle deprecated "@positionbase" attribute; only
      // has effect if "@base" is not specifed in xml
      var xmlbase:String = config.xmlvalue('@base');
      if (xmlbase==null || xmlbase=="") {
        var positionbase:String = config.xmlvalue('@positionbase');
        if (positionbase == 'right') {
          baseAttr = "1 -1";
        }
        if (positionbase == 'top') {
          baseAttr = "-1 1";
        }
      }
      // end of code to handle deprecated "@positionbase" attribute
      /////////////////////////////////////////////////////////////
      try {
        _base = DPoint.parse( baseAttr );
      } catch (e : ParseError) {
        throwInvalidAttributeError("base");
      }


      //
      // anchor
      //
      _anchor = parseFloat(config.value('@anchor'));
      if (isNaN(_anchor)) {
        throwInvalidAttributeError("anchor");
      }

      //
      // linewidth
      //
      _linewidth = parseFloat(config.value('@linewidth'));
      if (isNaN(_linewidth)) {
        throwInvalidAttributeError("linewidth");
      }

      //
      // color
      //
	  try {
        _color = parsecolor(config.value('@color'));
	  } catch (e : ParseError) {
	    throwInvalidAttributeError("color");
	  }


      //
      // minposition, maxposition
      //
      try {
        _minposition = Displacement.parse( config.value('@minposition') );
      } catch (e : ParseError) {
        throwInvalidAttributeError("minposition");
      }
      try {
        _maxposition = Displacement.parse( config.value('@maxposition') );
      } catch (e : ParseError) {
        throwInvalidAttributeError("maxposition");
      }

      //
      // min, max
      //
      var minAttr : String = config.value('@min');
      var maxAttr : String = config.value('@max');
      if (minAttr != "auto") {
		// NOTE: important to assign to "dataMin" here, not "_dataMin", so that we call the setter method!!
        dataMin = parse(minAttr);
        if (isNaN(_dataMin)) {
          throwInvalidAttributeError('min', minAttr);
        }
      }
      if (maxAttr != "auto") {
	    // NOTE: important to assign to "dataMax" here, not "_dataMax", so that we call the setter method!!
        dataMax = parse(maxAttr);
        if (isNaN(_dataMax)) {
          throwInvalidAttributeError('max', maxAttr);
        }
      }


      //
      // title
      //
      _title = config.xmlvalue('title');
	  if (_title == null) {
        // If _title is null here, it means that there was no <title> element in the mugl file,
        // so default the title to the axis id:
        _title = _id;
      } else if (_title == '') {
        // If _title is the empty string, it means that there was an empty <title/>
        // element in the mugl file, which means to show no title for this axis.  We
        // set the _title attribute to null to indicate this.
        _title = null;
      }
      // Note that the above logic uses a null value for _title to
      // mean two different things in different contexts.  In the
      // first one, a null value returned by config.xmlvalue('title')
      // means that there was no <title> element in the mugl file, in
      // which case we choose a default value (the axis id).  In the
      // second case, we assign a null value to _title as a way of
      // indicating the fact that no title should be drawn.  The first
      // meaning is only used temporarily; the second meaning is the
      // only one that persists after the code above has finished
      // executing.

      //
      // title position
      //
      _titlePositionAttr = config.xmlvalue('title','@position');
      if (_titlePositionAttr==null || _titlePositionAttr=="") {
        _titlePositionAttr = null;
      }
	  if (_titlePositionAttr != null) {
	      try {
        	_titlePosition = DPoint.parse( _titlePositionAttr );
      	} catch (e : ParseError) {
	        throwInvalidAttributeError("title position", _titlePositionAttr);
      	}
	  }


      //
      // title anchor
      //
      _titleAnchorAttr = config.xmlvalue('title','@anchor');
      if (_titleAnchorAttr==null || _titleAnchorAttr=="") {
        _titleAnchorAttr = null;
      }
	  if (_titleAnchorAttr != null) {
      	try {
	        _titleAnchor = DPoint.parse( _titleAnchorAttr );
      	} catch (e : ParseError) {
	        throwInvalidAttributeError("title anchor", _titleAnchorAttr);
      	}
	  }

      //
      // title angle
      //
      _titleAngle = parseFloat(config.value('title', '@angle'));
      if (isNaN(_titleAngle)) {
        throwInvalidAttributeError("title angle");
      }

      //
      // title fontname
      //
      var titleFontname : String = config.value('title','@fontname');
      // !!!!!  need to validate here !!!!!
      

      //
      // title fontsize
      //
      var titleFontsize : Number = parseFloat(config.value('title','@fontsize'));
      if (isNaN(titleFontsize)) {
        throwInvalidAttributeError("title fontsize");
      }

      //
      // title fontcolor
      //
      var titleFontcolor : uint;
	  try {
        titleFontcolor = parsecolor(config.value('title','@fontcolor'));
	  } catch (e : ParseError) {
	    throwInvalidAttributeError("title fontcolor");
	  }

	  _titleTextFormat       = new TextFormat();
	  _titleTextFormat.font  = titleFontname;
	  _titleTextFormat.size  = titleFontsize;
	  _titleTextFormat.color = titleFontcolor;
	  _titleTextFormat.align = TextFormatAlign.LEFT;


      //
      // grid stuff
      //
	  if (config.xmlvalue('grid') != null) {
		  // if the <grid> element is present, draw the grid unless its 'visible' attribute is 'false'
		  _drawGrid = config.xmlvalue('grid','@visible') != "false";
	  } else {
		  // if the <grid> element is not present at all, don't draw the grid
		  _drawGrid = false;
	  }
	  try {
		  _gridColor = parsecolor( config.value('grid','@color') );
	  } catch (e : ParseError) {
		  throwInvalidAttributeError("grid color");
	  }

      //
      // tickmin, tickmax, tickcolor, tickwidth:
      //
      _tickmin = parseFloat(config.value('@tickmin'));
      if (isNaN(_tickmin)) {
	    throwInvalidAttributeError("tickmin");
	  }
	  _tickmax = parseFloat(config.value('@tickmax'));
	  if (isNaN(_tickmax)) {
		  throwInvalidAttributeError("tickmax");
	  }
	  try {
		  _tickcolor = parsecolor( config.value('@tickcolor') );
	  } catch (e : ParseError) {
		  throwInvalidAttributeError("tick color");
	  }
	  _tickwidth = parseFloat(config.value('@tickwidth'));
	  if (isNaN(_tickwidth)) {
		  throwInvalidAttributeError("tickwidth");
	  }


      //
      // zoomconfig, panconfig:
      //
      _panConfig = new PanConfig('allowed', null, null, this);
      _panConfig.setConfig(config.value('pan', '@allowed'),
                           config.value('pan', '@min'),
                           config.value('pan', '@max'));
      _zoomConfig = new ZoomConfig('allowed', null, null, null, this);
      _zoomConfig.setConfig(config.value('zoom', '@allowed'),
                            config.value('zoom', '@anchor'),
                            config.value('zoom', '@min'),
                            config.value('zoom', '@max'));



      //
      // labels position attribute
      //
      var labelPosition : DPoint;
      var labelPositionAttr : String = config.xmlvalue('labels', '@position');
      if (labelPositionAttr!=null && labelPositionAttr!="") {
        try {
          labelPosition = DPoint.parse( labelPositionAttr );
        } catch ( e : ParseError ) {
          throwInvalidAttributeError("labels position");
        }
      } else {
        labelPosition = null; // pass null for labelPosition to indicate default
      }

      //
      // labels anchor attribute
      //
      var labelAnchor : DPoint;
      var labelAnchorAttr : String = config.xmlvalue('labels', '@anchor');
      if (labelAnchorAttr!=null && labelAnchorAttr!="") {
        try {
          labelAnchor = DPoint.parse( labelAnchorAttr );
        } catch ( e : ParseError ) {
          throwInvalidAttributeError("labels anchor");
        }
      } else {
        labelAnchor = null; // pass null for labelAnchor to indicate default
      }

      //
      // labelers
      //
      _labelers = new Array();
      var spacingAndUnit:NumberAndUnit;
      if(config.xmlvalue('labels', 'label') != null) {
        var nlabeltags:int = config.xmlvalue('labels','label').length();
        for(var k:int = 0; k < nlabeltags; ++k) {
          var hlabelSpacings:Array = config.value('labels', 'label', k, '@spacing').split(" ");
          var labelTextFormat:TextFormat = new TextFormat();
          labelTextFormat.font  = config.value('labels','label',k,'@fontname');
          labelTextFormat.size  = config.value('labels','label',k,'@fontsize');
          labelTextFormat.color = config.value('labels','label',k,'@fontcolor');
		  var densityFactor:Number = config.value('labels','label',k,'@densityfactor');
          labelTextFormat.align = TextFormatAlign.LEFT;
          for (var j:int=0; j<hlabelSpacings.length; ++j) {
            var spacing = hlabelSpacings[j];
            spacingAndUnit = NumberAndUnit.parse(spacing);
            
            var labeler : Labeler = Labeler.create(_type,
                                                   this,
                                                   spacingAndUnit.number,
                                                   spacingAndUnit.unit,
                                                   config.value('labels', 'label', k, '@format'),
                                                   config.value('labels', 'label', k, '@visible')=='true',
                                                   config.value('labels', '@start'),
                                                   labelPosition,
                                                   labelAnchor,
                                                   parseFloat(config.value('labels', '@angle')),
                                                   labelTextFormat,
												   densityFactor);
            _labelers.push(labeler);
          }
        } 
      } else {
        var hlabelSpacings:Array = config.value('labels', '@spacing').split(" ");
        var labelTextFormat:TextFormat = new TextFormat();
        labelTextFormat.font  = config.value('labels','@fontname');
        labelTextFormat.size  = config.value('labels','@fontsize');
        labelTextFormat.color = config.value('labels','@fontcolor');
		var densityFactor:Number = config.value('labels','@densityfactor');
        labelTextFormat.align = TextFormatAlign.LEFT;
        for (var k:int=0; k<hlabelSpacings.length; ++k) {
          var spacing = hlabelSpacings[k];
          spacingAndUnit = NumberAndUnit.parse(spacing);
          var labeler : Labeler = Labeler.create(_type,
                                                 this,
                                                 spacingAndUnit.number,
                                                 spacingAndUnit.unit,
                                                 config.value('labels', '@format'),
                                                 config.value('labels', '@visible')=='true',
                                                 config.value('labels', '@start'),
                                                 labelPosition,
                                                 labelAnchor,
                                                 parseFloat(config.value('labels','@angle')),
                                                 labelTextFormat,
		  										 densityFactor);
          _labelers.push(labeler);
        }   
      }
      
    }

    private function throwInvalidAttributeError(attr : String, value : String = null) : void {
      if (value != null) {
        throw new MuglError("Invalid " + attr + " attribute value ('" + value + "') for " + _orientation.toString() + " axis");
      } else {
        throw new MuglError("Invalid " + attr + " attribute for " + _orientation.toString() + " axis");
      }
    }
    
    private function computeAxisToDataRatio() : void {
      _axisToDataRatio = (_pixelLength - _maxOffset - _minOffset) / (_dataMax - _dataMin);
    }

    public function initializeGeometry() : void {
      _geometryInitialized = true;
      if (_orientation == AxisOrientation.HORIZONTAL) {
        _pixelLength = _length.calculateLength( _graph.plotBox.width );
        _parallelOffset = _position.x + (_base.x + 1) * _graph.plotBox.width/2 - (_anchor + 1) * _pixelLength / 2;
        _perpOffset = _position.y + (_base.y + 1) * _graph.plotBox.height/2;
      } else {
        _pixelLength = _length.calculateLength( _graph.plotBox.height );
        _parallelOffset = _position.y + (_base.y + 1) * _graph.plotBox.height/2 - (_anchor + 1) * _pixelLength / 2;
        _perpOffset = _position.x + (_base.x + 1) * _graph.plotBox.width/2;
      }
      if (_titlePositionAttr == null) {
        if (_orientation == AxisOrientation.HORIZONTAL) {
          if (_perpOffset > _graph.plotBox.height/2) {
            _titlePosition = Config.AXIS_TITLE_DEFAULT_POSITION_HORIZ_TOP;
          } else {
            _titlePosition = Config.AXIS_TITLE_DEFAULT_POSITION_HORIZ_BOT;
          }
        } else {
          if (_perpOffset > _graph.plotBox.width/2) {
            _titlePosition = Config.AXIS_TITLE_DEFAULT_POSITION_VERT_RIGHT;
          } else {
            _titlePosition = Config.AXIS_TITLE_DEFAULT_POSITION_VERT_LEFT;
          }
        }
      }
      if (_titleAnchorAttr == null) {
        if (_orientation == AxisOrientation.HORIZONTAL) {
          if (_perpOffset > _graph.plotBox.height/2) {
            _titleAnchor = Config.AXIS_TITLE_DEFAULT_ANCHOR_HORIZ_TOP;
          } else {
            _titleAnchor = Config.AXIS_TITLE_DEFAULT_ANCHOR_HORIZ_BOT;
          }
        } else {
          if (_perpOffset > _graph.plotBox.width/2) {
            _titleAnchor = Config.AXIS_TITLE_DEFAULT_ANCHOR_VERT_RIGHT;
          } else {
            _titleAnchor = Config.AXIS_TITLE_DEFAULT_ANCHOR_VERT_LEFT;
          }
        }
      }
      _minOffset = _minposition.calculateCoordinate(_pixelLength);
      _maxOffset = _pixelLength - _maxposition.calculateCoordinate(_pixelLength);
      _reversed = (_minOffset > _pixelLength - _maxOffset);
      if (_haveDataMin && _haveDataMax) {
        computeAxisToDataRatio();
      }
      for each ( var labeler : Labeler in _labelers ) {
          labeler.initializeGeometry();
      }
    }
	
    /**
     * @private
     */
    public function renderGrid(sprite:UIComponent):void {
      if (!_geometryInitialized) { return; }
		
      // Render the grid lines for this axis, if any

      //skip if we don't yet have data values
      if (!_haveDataMin || !_haveDataMax) { return; }

      prepareRender();

	  // skip if grid lines aren't turned on
	  if (!_drawGrid) { return ; }
	  
      if (_labelers.length > 0 && _currentLabelDensity <= 1.5) {
        _currentLabeler.prepare(dataMin, dataMax);
        while (_currentLabeler.hasNext()) {
          var v:Number = _currentLabeler.next();
          var a:Number = dataValueToAxisValue(v);
          sprite.graphics.lineStyle(1, _gridColor, 1);
          if (_orientation == AxisOrientation.HORIZONTAL) {
            sprite.graphics.moveTo(a, _perpOffset);
            sprite.graphics.lineTo(a, _graph.plotBox.height - _perpOffset);
          } else {
            sprite.graphics.moveTo(_perpOffset, a);
            sprite.graphics.lineTo(_graph.plotBox.width - _perpOffset, a);
          }
        }
      }
    }

	public function render(sprite : UIComponent) : void {
	  if (!_geometryInitialized) { return; }
      // render the axis line itself:
      if (_linewidth > 0) {
        sprite.graphics.lineStyle(_linewidth,_color,1);
        if (_orientation == AxisOrientation.HORIZONTAL) {
          sprite.graphics.moveTo(_parallelOffset, _perpOffset);
          sprite.graphics.lineTo(_parallelOffset + _pixelLength, _perpOffset);
        } else {
          sprite.graphics.moveTo(_perpOffset, _parallelOffset);
          sprite.graphics.lineTo(_perpOffset, _parallelOffset + _pixelLength);
        }
      }

      // render the axis title
      if (_title != null) {
        var titlePositionX : Number;
        var titlePositionY : Number;
        if (_orientation == AxisOrientation.HORIZONTAL) {
          titlePositionX = _parallelOffset + _pixelLength / 2 + _titlePosition.x
          titlePositionY = _perpOffset + _titlePosition.y;
        } else {
          titlePositionX = _perpOffset + _titlePosition.x
          titlePositionY = _parallelOffset + _pixelLength / 2 + _titlePosition.y
        }
        sprite.addChild(new TextLabel(_title,
                                      _titleTextFormat,
                                      titlePositionX, titlePositionY,
                                      _titleAnchor.x, _titleAnchor.y,
                                      _titleAngle));
      }

      // render the tick marks and labels
      if (_haveDataMin && _haveDataMax) { // but skip if we don't yet have data values
        if (_labelers.length > 0 && _currentLabelDensity <= 1.5) {
          _currentLabeler.prepare(dataMin, dataMax);
          while (_currentLabeler.hasNext()) {
            var v:Number = _currentLabeler.next();
            var a:Number = dataValueToAxisValue(v);
			if (_tickwidth > 0) {
			sprite.graphics.lineStyle(_tickwidth,_tickcolor,1);
            if (_orientation == AxisOrientation.HORIZONTAL) {
              sprite.graphics.moveTo(a, _perpOffset+_tickmax);
              sprite.graphics.lineTo(a, _perpOffset+_tickmin);
            } else {
              sprite.graphics.moveTo(_perpOffset+_tickmin, a);
              sprite.graphics.lineTo(_perpOffset+_tickmax, a);
            }
			}
            _currentLabeler.renderLabel(sprite, v);
          }
        }
      }

	  

	}


    /**
     * @private
     */
    public function parse(string : String) : Number {
	  if (_parser != null) {
		return _parser.parse(string);
  	  }
      return parseFloat(string);
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
    public var _currentLabeler:Labeler;
    /**
     * @private
     */
    public var _currentLabelDensity:Number;
    /**
     * @private
     */
    public function prepareRender() {
      // Decide which labeler to use: take the one with the largest density <= 0.8.
      // Unless all have density > 0.8, in which case we take the first one.  This assumes
      // that the labelers list is ordered in increasing order of label density.
      // This function sets the _currentLabeler and _currentLabelDensity private properties.
      _currentLabeler = _labelers[0];
      _currentLabelDensity = _currentLabeler.labelDensity();
      if (_currentLabelDensity < 0.8) {
        for (var i:uint = 1; i < _labelers.length; i++) {
          var density:Number = _labelers[i].labelDensity();
          if (density > 0.8) { break; }
          _currentLabeler = _labelers[i];
          _currentLabelDensity = density;
        }
      }
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
        var factor:Number = 10 * Math.abs(pixelDisplacement / (_pixelLength - _maxOffset - _minOffset));
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


    /**
     * @private
     */
    public function setDataRangeNoBind(min:Number,max:Number,dispatch:Boolean=true):void {
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
	  if (dispatch) {
		  dispatchEvent(new AxisEvent(AxisEvent.CHANGE,min,max));  
	  }
    }

    /**
     * Set the minimum and maximum data values for the axis.
     */
    public function setDataRange(min:Number,max:Number,dispatch:Boolean=true):void {
      if (_binding != null) {
        _binding.setDataRange(this, min, max, dispatch);
      } else {
        setDataRangeNoBind(min, max, dispatch);
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

    static private var _s_instances:Array = [];
    /**
     * @private
     */
    public static function getInstanceById(id:String):Axis {
      return _s_instances[id];
    }


  }
}
