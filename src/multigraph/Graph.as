package multigraph
{
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Loader;
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  
  import multigraph.controls.Spinner;
  import multigraph.data.*;
  import multigraph.format.*;
  import multigraph.naui.NearestAxisUIEventHandler;
  import multigraph.renderer.*;
  
  import mx.core.UIComponent;
  
  public class Graph extends UIComponent
  {
	private var _multigraph : Multigraph;
	public function get multigraph() : Multigraph { return _multigraph; }

    private var _isValidMugl : Boolean = false;
	
    private var _mugl : XML;
    public function get mugl() : XML {
      return _mugl;
    }
    public function set mugl( mugl : XML ) : void {
      _mugl = mugl;
      try {
        parseMugl();
        _isValidMugl = (_mugl != null);
      } catch (e : *) {
        if (e is MuglError) {
          _multigraph.alert(e.message, "MUGL Error");
        } else {
          _multigraph.alert(e.message, "Error");
        }
        _isValidMugl = false;
      }
      invalidateDisplayList();
    }

	private var _currentWidth  : int;
	private var _currentHeight : int;

    //private var _fillerBackgroundURL : String = "assets/MultigraphFiller.png";
	private var _fillerBackgroundURL : String = null;
    private var _fillerBackgroundImage : Bitmap = null;

    private var _windowMargin        : Insets;
	private var _backgroundColor     : uint;
	private var _backgroundOpacity   : Number;
	private var _border              : Number;
	private var _borderColor         : uint;
	private var _borderOpacity       : Number;
    private var _padding             : Insets;
    private var _plotMargin          : Insets;
    public function get plotMargin() : Insets { return _plotMargin; }
    private var _plotareaBorder      : Number;
    private var _plotareaBorderColor : uint;
    private var _window              : Box;
    private var _paddingBox          : Box;
	public function get paddingBox() : Box { return _paddingBox; }
    private var _plotBox             : Box;
	public function get plotBox() : Box { return _plotBox; }
		
    private var _divSprite           : UIComponent ;
    private var _bgSprite            : UIComponent ;
    private var _eventSprite         : UIComponent ;
    private var _axisControlSprite   : UIComponent ;
    private var _paddingBoxSprite    : UIComponent ;
    private var _axisSprite1         : UIComponent ;
    private var _plotBoxSprite       : UIComponent ;
	private var _axisSprite2         : UIComponent ;
    private var _paddingBoxMask      : Shape ;
    private var _plotBoxMask         : Shape ;

    private var _backgroundImage            : Bitmap = null;
    private var _backgroundImageAnchor      : Array  = null;
    private var _backgroundImageBase        : Array  = null;
    private var _backgroundImagePosition    : Array  = null;
    private var _backgroundImageFrameIsPlot : Boolean = false;

    private var _imageAnnotations    : Array = [];

	private var _spinnerSprite       : UIComponent ;
    private var _spinners            : Array;
    private var _spinnerMaxIndex     : int;
    private var _spinnerSize         : int = 28;
    private var _spinnerSeparation   : int =  5;
	
	private var _config              : Config;

    private var _haxes        : Array = [];
	public  function get haxes():Array { return _haxes; } 
    private var _vaxes        : Array = [];
	public  function get vaxes():Array { return _vaxes; } 
    private var _axes         : Array = [];
	public  function get axes():Array { return _axes; } 

    private var _data         : Array = [];
    private var _plots        : Array = [];

    private var _legend       : NewLegend;
    private var _title        : Title;


	private var _uiEventHandler:UIEventHandler;

    /**
     * The parseMugl function populates the property values of this
     * graph object by reading them out of its _mugl object.  This
     * isn't really parsing, in the sense of XML parsing --- that has
     * already happened by this point, when the _mugl XML object was
     * constructed.  But this is where the XML tree is interpreted and
     * values set for the graph.
     *
     * This is a purely internal function, intended only to be called
     * from the mugl= setter method.  This function, and the functions
     * it calls, throw various errors if a problem is encountered
     * while interpreting the MUGL.  It is up to whoever called this
     * function (the mugl= setter method) to deal with those errors.
     * It is also up to the caller to call invalidateDisplayList() to
     * cause the graph to be redrawn after this.
     *
     * The main point of all this is: don't call this function.  It is
     * intended specifically to work in the context of the mugl=
     * setter method.
     */
    private function parseMugl() : void {
      if (_mugl == null) {
        return;
      }
	  _config = new Config(_mugl);

	  this.x      = _config.value('window','@x');
	  this.y      = _config.value('window','@y');

      var percentRegexp : RegExp = /^([\+-]?[0-9\.]+)(%?)$/;
      var a:Array = percentRegexp.exec(_config.value('window','@width'));
      if (a != null) {
        if (a[2] == '%') {
		  this.percentWidth = a[1];
          if (isNaN(this.percentWidth)) { throw new MuglError('invalid window width attribute'); }
        } else {
          this.width = a[1];
          if (isNaN(this.width)) { throw new MuglError('invalid window width attribute'); }
        }
      }
      a = percentRegexp.exec(_config.value('window','@height'));
      if (a != null) {
        if (a[2] == '%') {
		  this.percentHeight = a[1];
          if (isNaN(this.percentHeight)) { throw new MuglError('invalid window height attribute'); }
        } else {
          this.height = a[1];
          if (isNaN(this.height)) { throw new MuglError('invalid window height attribute'); }
        }
      }

      //
      // window @margin attribute
      // 
      var windowMargin : Number = parseFloat(_config.value('window','@margin'));
      if (isNaN(windowMargin)) {
        throwInvalidError('window margin attribute');
      }
      _windowMargin = new Insets(windowMargin);

      //
      // window @border attribute
      //
	  _border = parseFloat(_config.value('window','@border'));
      if (isNaN(_border)) {
        throwInvalidError('window border attribute');
      }

      //
      // window @bordercolor attribute
      //
      try {
		  _borderColor = parsecolor( _config.value('window','@bordercolor') );
      } catch (e : ParseError) {
        throwInvalidError('window bordercolor attribute');
      }
	  _borderOpacity = _config.value('window','@borderopacity');

      //
      // window @padding attribute
      //
      var windowPadding : Number = parseFloat(_config.value('window','@padding'));
      if (isNaN(windowPadding)) {
        throwInvalidError('window padding attribute');
      }
      _padding = new Insets(windowPadding);


      //
      // plotarea @margintop, @marginleft, @marginbottom, @marginright attributes
      //
      var plotareaMargintop     : Number = parseFloat( _config.value('plotarea', '@margintop')    );
      if (isNaN(plotareaMargintop)) {
        throwInvalidError('plotarea margintop attribute');
      }
      var plotareaMarginleft    : Number = parseFloat( _config.value('plotarea', '@marginleft')   );
      if (isNaN(plotareaMarginleft)) {
        throwInvalidError('plotarea marginleft attribute');
      }
      var plotareaMarginbottom  : Number = parseFloat( _config.value('plotarea', '@marginbottom') );
      if (isNaN(plotareaMarginbottom)) {
        throwInvalidError('plotarea marginbottom attribute');
      }
      var plotareaMarginright   : Number = parseFloat( _config.value('plotarea', '@marginright')  );
      if (isNaN(plotareaMarginright)) {
        throwInvalidError('plotarea marginright attribute');
      }
      _plotMargin = new Insets(plotareaMargintop,
                               plotareaMarginleft,
                               plotareaMarginbottom,
                               plotareaMarginright);

      //
      // plotarea border attribute
      //
      _plotareaBorder = parseFloat(_config.value('plotarea', '@border'));
      if (isNaN(_plotareaBorder)) {
        throwInvalidError('plotarea border attribute');
      }

      //
      // plotarea bordercolor
      //
	  try {
		  _plotareaBorderColor = parsecolor( _config.value('plotarea', '@bordercolor') );
	  } catch (e : ParseError) {
		  throwInvalidError('plotarea bordercolor attribute');
	  }

      initializeBackground();
      initializeAxes();
      initializeDataSections();
      initializePlots();
      initializeLegend();
      initializeTitle();
      //initializeImageAnnotations();  // call in commitProperties instead!!!
      bindAxes(_vaxes, _config, 'verticalaxis');
      bindAxes(_haxes, _config, 'horizontalaxis');
      prepareData();

    }

    private function initializeBackground():void {
      //
      // background @color attribute
      //
      try {
		  _backgroundColor = parsecolor(_config.value('background','@color'));
      } catch (e : ParseError) {
        throwInvalidError('background color attribute');
      }
	  _backgroundOpacity = _config.value('background','@opacity');

	  var bgImageURL:String = _config.xmlvalue('background','img','@src');
	  
	  if (bgImageURL!=null && bgImageURL!='') {
        _backgroundImageAnchor      = _config.value('background', 'img', '@anchor').split(" ");
        _backgroundImageBase        = _config.value('background', 'img', '@base').split(" ");
        _backgroundImagePosition    = _config.value('background', 'img', '@position').split(" ");
        _backgroundImageFrameIsPlot = (_config.value('background', 'img', '@frame') == "plot");
		  
		  var loader:Loader = new Loader();
		  loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
              function (event:Event):void {
                var loader:Loader = Loader(event.target.loader);
                _backgroundImage = Bitmap(loader.content);
              }
          );
		  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
			  function(errmsg:String):Function {
				  return function(event:IOErrorEvent):void {
					  trace(errmsg);
				  }
			  }("Unable to load background image: " + bgImageURL)
		  );
		  loader.load(new URLRequest(bgImageURL));
	  }	  

    }

		
    public function Graph(multigraph : Multigraph) {
	  _multigraph      = multigraph;
	  _spinners        = new Array();
      _spinnerMaxIndex = -1;
      super();
    }
		
    override protected function commitProperties() : void {
      super.commitProperties();
      // call initializeEventHandler() here rather than in parseMugl, because commitProperties() is
      // called after createChildren(), and _eventSprite needs to exist before we can call
      // initializeEventHandler()
      initializeEventHandler();
	  initializeImageAnnotations();
    }

    public function findAvailableSpinnerIndex() : int {
      for (var i : int = 0; i < _spinnerMaxIndex; ++i) {
        if (_spinners[i] == null) {
          return i;
        }
      }
      ++_spinnerMaxIndex;
      return _spinnerMaxIndex;
    }

    public function startAvailableSpinner() : int {
      var spinnerIndex : int = findAvailableSpinnerIndex();
      startSpinner( spinnerIndex );
      return spinnerIndex;
    }
	
	public function startSpinner( i : int ) : void {
      _spinners[i] = new multigraph.controls.Spinner();
      _spinners[i].setStyle("tickColor", 0x000000);
      _spinners[i].size = _spinnerSize;
      _spinners[i].x = i * (_spinnerSeparation + _spinnerSize);
      _spinners[i].y = 0;  // unscaledHeight - 5 - _spinner.size;
	  if (_spinnerSprite != null) {
		  // only display the spinner if the _spinnerSprite has been created at this point
      	_spinnerSprite.addChild(_spinners[i]);
      	invalidateDisplayList();
	  }
	}
	
    public function stopSpinner( i : int ) : void {
      if (_spinners[i] != null) {
        _spinners[i].stop();
		if ((_spinnerSprite != null) && (_spinnerSprite.contains(_spinners[i]))) { 
        	_spinnerSprite.removeChild(_spinners[i]);
		}
        _spinners[i] = null;
      }
	}
	
	public function isSpinning( i : int ) : Boolean {
		return _spinners[i] != null;
	}
	
    override protected function createChildren() : void {
      super.createChildren();
	  _bgSprite                                     = new UIComponent();
      _divSprite                                    = new UIComponent();
      _eventSprite                                  = new UIComponent();
      _paddingBoxMask                               = new Shape();
      _paddingBoxSprite                             = new UIComponent();
      _axisSprite1                                  = new UIComponent();
      _plotBoxMask                                  = new Shape();
      _plotBoxSprite                                = new UIComponent();
      _axisSprite2                                  = new UIComponent();
	  _spinnerSprite                                = new UIComponent();

	  // display any spinners that may have already been created
	  for ( var i:int = 0; i<_spinnerMaxIndex; ++i) {
		  if (_spinners[i] != null) {
			  _spinnerSprite.addChild(_spinners[i]);
		  }
	  }
	  
      //_axisControlSprite                            = new UIComponent();

	  addChild(_bgSprite);
      addChild(_divSprite);
      _divSprite.addChild(_paddingBoxMask);
      _divSprite.addChild(_paddingBoxSprite);
      _paddingBoxSprite.mask = _paddingBoxMask;
      _paddingBoxSprite.addChild(_axisSprite1);


      _paddingBoxSprite.addChild(_plotBoxMask);
      _paddingBoxSprite.addChild(_plotBoxSprite);
      _plotBoxSprite.mask = _plotBoxMask;
      _paddingBoxSprite.addChild(_axisSprite2);
	  
	  addChild(_spinnerSprite);

      addChild(_eventSprite);
    }
	
	private var _forceInitializeGeometry : Boolean = false;
	
	public function reInitializeGeometry():void {
		_forceInitializeGeometry = true;
		invalidateDisplayList();
	}	

    override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number) : void  {
		
		var i : int;

		if (!_isValidMugl) {
			return;
		}
		
      if ((unscaledWidth != _currentWidth) || (unscaledHeight != _currentHeight) || (_forceInitializeGeometry)) {
        initializeGeometry(unscaledWidth, unscaledHeight);
        _currentWidth  = unscaledWidth;
        _currentHeight = unscaledHeight;
		_forceInitializeGeometry = false;
      }
      super.updateDisplayList(unscaledWidth, unscaledHeight);

      _divSprite.graphics.clear();
      _bgSprite.graphics.clear();

      /*
      // Fill the whole _divSprite with its background color
      _divSprite.graphics.beginFill(_backgroundColor, 1);
      _divSprite.graphics.drawRect(0, 0, _currentWidth, _currentHeight);
      _divSprite.graphics.endFill();
      */


      if (_border > 0) {
        // If there is a border, fill the part of the _divSprite that is inside the window margin with the border color
        _bgSprite.graphics.lineStyle(0,0x000000,_borderOpacity);
        _bgSprite.graphics.beginFill(_borderColor, _borderOpacity);
        _bgSprite.graphics.drawRect(_windowMargin.left, _windowMargin.right,
                                     _currentWidth - _windowMargin.left - _windowMargin.right,
                                     _currentHeight - _windowMargin.bottom - _windowMargin.top);
        _bgSprite.graphics.endFill();
      }
      // Fill part of the  _bgSprite that is inside the border with the background color
      _bgSprite.graphics.beginFill(_backgroundColor, _backgroundOpacity);
      _bgSprite.graphics.drawRect(_windowMargin.left + _border, _windowMargin.bottom + _border,
                                   _currentWidth  - _windowMargin.left   - _windowMargin.right - 2 * _border,
                                   _currentHeight - _windowMargin.bottom - _windowMargin.top - 2 * _border);


      ////////////////////////////////////////////////////////////////////////////////////////

      // clear out the axis sprites
      _axisSprite1.graphics.clear();
      while (_axisSprite1.numChildren) { _axisSprite1.removeChildAt(0); }

      _axisSprite2.graphics.clear();
      while (_axisSprite2.numChildren) { _axisSprite2.removeChildAt(0); }

      // clear out the plotBox sprite
      _plotBoxSprite.graphics.clear();
      while (_plotBoxSprite.numChildren) { _plotBoxSprite.removeChildAt(0); }

      //
      // Draw the filler background image; this is just for testing and should eventually be removed
      //
      if (_fillerBackgroundImage != null) {
        var box : Box               = _plotBox;
        var boxSprite : UIComponent = _plotBoxSprite;
        _fillerBackgroundImage.transform.matrix = new Matrix(1, 0, 0, -1, 0, box.height);
        _fillerBackgroundImage.x = 0;
        _fillerBackgroundImage.y = box.height;
        boxSprite.addChild(_fillerBackgroundImage);
      }

      // draw the plotbox border, if any, in the padding box, so that its full linewidth shows up (if we draw
      // it in the plotbox, it gets clipped to the plotbox)
      if (_plotareaBorder > 0) {
        _axisSprite2.graphics.lineStyle(_plotareaBorder, _plotareaBorderColor, 1);
        _axisSprite2.graphics.drawRect(0, 0, _plotBox.width, _plotBox.height);
      }

      // render the axes' grid lines, if any
      for each ( var axis : Axis in _axes ) {
        axis.renderGrid(_axisSprite1);
      }

      // render the plots
	  for each ( var plot : Plot in _plots ) {
		  plot.render(_plotBoxSprite);
	  }
      
      // render the axes themselves
      for each ( var axis : Axis in _axes ) {
        axis.render(_axisSprite1);
      }
	  

      // render the legend
      /*NewLegend doesn't need this:
      if (_legend!=null) {
        _legend.render(_paddingBoxSprite, _plotBoxSprite);
      }
      */

	  /*
      // render the title
      if (_title!=null) {
        _title.render(_paddingBoxSprite, _plotBoxSprite);
      }
      
      // render the toolbar
      if (_toolbar != null) {
      	_toolbar.render(_axisControlSprite, _plotBoxSprite);
      }
      */
      ////////////////////////////////////////////////////////////////////////////////////////

    }		

    private function initializeGeometry( width : int, height : int ):void {
      //
      // Construct internal geometry
      //
      _window = new Box(width, height);
      _paddingBox = new Box(_window.width
                            - ( _windowMargin.left + _border + _padding.left )
                            - ( _windowMargin.right + _border + _padding.right ),
                            _window.height
                            - ( _windowMargin.top + _border + _padding.top )
                            - ( _windowMargin.bottom + _border + _padding.bottom )
                            );
      _plotBox = new Box(_paddingBox.width - ( _plotMargin.left + _plotMargin.right),
                         _paddingBox.height - ( _plotMargin.top + _plotMargin.bottom ));


      //
      // set geometric properties of flex/flash child components from internal geometry objects
      //
	  _divSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, height);
      _paddingBoxMask.graphics.clear();
      _paddingBoxMask.graphics.beginFill(0x000000);
      _paddingBoxMask.graphics.drawRect(_windowMargin.left + _border + _padding.left,
                                        _windowMargin.bottom + _border + _padding.bottom,
                                        width - (_windowMargin.left + _border + _padding.left
                                                 + _windowMargin.right + _border + _padding.right),
                                        height - (_windowMargin.bottom + _border + _padding.bottom
                                                  + _windowMargin.top + _border + _padding.top));
      _paddingBoxMask.graphics.endFill();
      _paddingBoxSprite.x = _windowMargin.left + _border + _padding.left;
      _paddingBoxSprite.y = _windowMargin.bottom + _border + _padding.bottom;
	  
      _axisSprite1.x = _plotMargin.left;
      _axisSprite1.y = _plotMargin.bottom;
      _axisSprite1.graphics.clear();
	  
      _plotBoxMask.graphics.clear();
      _plotBoxMask.graphics.beginFill(0x000000);
      _plotBoxMask.graphics.drawRect(_plotMargin.left, _plotMargin.bottom,
                                     _plotBox.width, _plotBox.height);
      _plotBoxMask.graphics.endFill();
      _plotBoxSprite.x = _plotMargin.left;
      _plotBoxSprite.y = _plotMargin.bottom;
      _axisSprite2.x = _plotMargin.left;
      _axisSprite2.y = _plotMargin.bottom;

      _eventSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, height);
      _eventSprite.graphics.beginFill(0xffffff, 0);
      _eventSprite.graphics.drawRect(0,0,width,height);
      _eventSprite.graphics.endFill();

      _spinnerSprite.x = _spinnerSeparation;
      _spinnerSprite.y = _spinnerSeparation;

      for each (var axis : Axis in _axes) {
          axis.initializeGeometry();
      }

      if (_backgroundImage != null) {
        var ax:Number = (Number(_backgroundImageAnchor[0])+1)*_backgroundImage.width/2;
        var ay:Number = _backgroundImage.height - ((Number(_backgroundImageAnchor[1])+1)*_backgroundImage.height/2);
        var bx:Number=0, by:Number=0;
        if (_backgroundImageFrameIsPlot) {
          bx = _plotMargin.left + (Number(_backgroundImageBase[0])+1)*_plotBox.width/2;
          by = _plotMargin.top + _plotBox.height - ((Number(_backgroundImageBase[1])+1)*_plotBox.height/2);
        } else {
          bx = _windowMargin.left + _border + (Number(_backgroundImageBase[0])+1)*_paddingBox.width/2; 
          by = _windowMargin.top  + _border + _paddingBox.height - ((Number(_backgroundImageBase[1])+1)*_paddingBox.height/2);
        }
        _backgroundImage.x = bx + Number(_backgroundImagePosition[0]) - ax;
        _backgroundImage.y = by + Number(_backgroundImagePosition[1]) - ay;		  
        if (!_bgSprite.contains(_backgroundImage)) {
          // Hack to work around chicken-and-egg problem: at the time
          // that the _backgroundImage is loaded, the _bgSprite might
          // not have been created, because createChildren() might not
          // have been called.  But at the time that createChildren()
          // is called, the _backgroundImage might not have been
          // loaded yet.  So we can't add the _backgroundImage to the
          // _bgSprite in either of those locations.  This hack works
          // around this because this code here won't get executed
          // until both the _bgSprite has been created, and the
          // _backgroundImage has been loaded.  We use a Boolean to
          // make sure we only add the _backgroundImage once.
          _bgSprite.addChild(_backgroundImage);
        }
      }

	  if ( (_fillerBackgroundURL != null) && (_fillerBackgroundURL != "") && (_fillerBackgroundImage == null) ) {
        loadFillerBackground();
      }

      if (_legend != null) {
        _legend.initializeGeometry();
		if (!_paddingBoxSprite.contains(_legend)) {
          _paddingBoxSprite.addChild(_legend);
		}
      }

      for each ( var imageAnnotation : ImageAnnotation in _imageAnnotations ) {
		  //trace('imageAnnotation.initializeGeometry()');
        imageAnnotation.initializeGeometry();
		/*
        if (!_paddingBoxSprite.contains(imageAnnotation)) {
			//trace('_paddingBoxSprite.addChild(imageAnnotation)');
			_paddingBoxSprite.addChild(imageAnnotation);
        }
		*/
      }

      /*
        _axisControlSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, height);
      */
	  //trace('graph ' + this.width + ' X ' + this.height + ' @  (' + this.x + ',' + this.y + ')');
    }



    private function loadFillerBackground() : void {
      var loader:Loader = new Loader();
	  var box : Box               = _plotBox;
	  var boxSprite : UIComponent = _plotBoxSprite;
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
                                                function():Function {
                                                  return function (event:Event):void {
                                                    var loader:Loader = Loader(event.target.loader);
                                                    _fillerBackgroundImage = Bitmap(loader.content);
													invalidateDisplayList();
                                                  }
                                                }()
                                                );
      loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
                                                function(errmsg:String):Function {
                                                  return function(event:IOErrorEvent):void {
                                                    trace(errmsg);
                                                  }
                                                }("Unable to load background image: " + _fillerBackgroundURL)
                                                );
      loader.load(new URLRequest(_fillerBackgroundURL));
    }


    private function initializeAxes():void {
      /// create horizontal axes
      _haxes = createAxes(AxisOrientation.HORIZONTAL);
      for (var i:int = 0; i<_haxes.length; ++i) {
        _axes.push(_haxes[i]);
      }

      /// create vertical axes
      _vaxes = createAxes(AxisOrientation.VERTICAL);
      for (i = 0; i<_vaxes.length; ++i) {
        _axes.push(_vaxes[i]);
      }
    }

    private function createAxes(orientation : AxisOrientation):Array {
      //var formatter:Formatter;
	  var axistag : String = orientation == AxisOrientation.HORIZONTAL ? "horizontalaxis" : "verticalaxis";
      var numAxes:int = 1; // force at least one axis, in case none is specifed in the xml file
      if (_config.xmlvalue(axistag) != null) {
        numAxes = _config.xmlvalue(axistag).length();
      }
      var axes:Array = [];
      for(var i:int = 0; i < numAxes; ++i){
		var axisconf : Config = _config.subconfig(axistag, i);
		axes[i] = new Axis(this, orientation, axisconf, i);
      }
      return axes;
    }


    private function initializeDataSections():void {
      var numDataSections:int = _config.xmlvalue('data').length();
      var vars:Array;
      for (var j:int=0; j<numDataSections; ++j) {
        // Determine where to get the data for this data section...
        if (_config.value('data', j, 'values') != null) {
          // The <data> section contains a <values> element, so the data is given directly
          // in the xml document.  Use an ArrayData object to store it.
          vars = buildDataVariableArrayFromConfig(j);
          _data[j] = new ArrayData( vars );
          _data[j].parseText(_config.value('data', j, 'values'));
        } else if (_config.value('data', j, 'csv') != null) {
          // The <data> section contains a <csv> element, so the data is in
          // a separate csv file.  Read that file now and store the data
          // in a Multigraph.ArrayData object.
          vars = buildDataVariableArrayFromConfig(j);
          var url:String = _config.value('data', j, 'csv','@location');
          var randomize:Boolean = (_config.xmlvalue('data', j, 'csv','@randomize') == "true");
          _data[j] = new CSVFileArrayData( vars, url, this, randomize );
        } else if (_config.value('data', j, 'service') != null) {
          // The <data> section contains a <service> element, so the data is to be fetched
          // from a web service.  Use a Multigraph.WebServiceData object.
          vars = buildDataVariableArrayFromConfig(j);
          var url:String = _config.value('data', j, 'service','@location');
          _data[j] = new WebServiceData( url, vars, this );
        } else {
			throw new MuglError('<data> section has no <values>, <csv>, or <service> section');
        }
      }
    }

    private function buildDataVariableArrayFromConfig(dataSection:int):Array {
      var vars:Array = [];
      var xmlvarlist = _config.xmlvalue('data', dataSection, 'variables', 'variable');
      if (xmlvarlist != null) {
        var nvars:int = xmlvarlist.length();
        for (var i:int=0; i<nvars; ++i) {
          var col:String = _config.value('data', dataSection, 'variables','variable',i,'@column');
          if (col == null) { col = i+''; }
          var id:String = _config.value('data', dataSection, 'variables', 'variable', i, '@id');
          if (id == null) { id = 'var' + col; }
          var missingOp:String = _config.value('data', dataSection, 'variables', 'variable', i, '@missingop');
          var missingValueString:String = _config.value('data', dataSection, 'variables', 'variable', i, '@missingvalue');
          // if no missingValue was specified for this variable (or inherited from <variables>), set its missingOp to null
          var missingValue:Number = 0;
          if (missingValueString==null || missingValueString=="") {
            missingOp=null;
          } else {
            missingValue = Number(missingValueString);
          }
          vars.push(new DataVariable(id,
                                     int(col),
                                     DataType.parse(_config.value('data', dataSection, 'variables', 'variable', i, '@type')),
                                     missingValue,
                                     missingOp)
                    );
        }
      } else {
		// don't throw an error here after all --- need to support the case where entire <variables> section is missing
		// maybe it will just work  :-)
        //throw new MuglError('missing <variables><variable> metadata in <data> section');
      }
      return vars;
    }

    private function initializePlots():void {

      _plots = new Array();

      ///
      /// create the plot objects
      ///
      // Set up the renderers for each plot, and create the corresponding Plot object
      var nplots:int = 1; // number of plots defaults to 1, in case no <plot> element is present in the xml file
      if (_config.xmlvalue('plot') != null) {
        nplots = _config.xmlvalue('plot').length();
      }

      for (var i:int=0; i<nplots; ++i) {
        // 
        // get the plot's horizontal axis
        //
        var haxis:Axis = _haxes[0];

        //
        // get the plot's vertical axis...
        //
        // ... to the one specified in the xml file (<plot><verticalaxis ref="...">),
        // if any, or default to the first vertical axis if none is specified
        //var vaxis:Axis = Axis.getInstanceById( _config.xmlvalue('plot', i, 'verticalaxis', '@ref') );
        var vaxis:Axis = Axis.getInstanceById( _config.xmlvalue('plot', i, 'verticalaxis', '@ref') );
        if (vaxis == null) {
          vaxis = _vaxes[0];
        }
         
        //
        // get the plot's data object (or constant)
        //
        var plotIsConstant:Boolean = false;
        var constantValue:Number;
        var data:Data = null;
        var varids:Array = [];
        var vartypes:Array = [];
        if (_config.xmlvalue('plot', i, 'verticalaxis', 'constant') != null) {
          plotIsConstant = true;
          constantValue = _config.xmlvalue('plot', i, 'verticalaxis', 'constant', '@value');
        } else {
          plotIsConstant = false;

          // construct the plot's list of variables...
          //   ... first comes a single horizontal variable, which is either given by
          //       <plot><horizontalaxis><variable ref="..."> in the xml file...
          var hvarid:String;
          if (_config.xmlvalue('plot', i, 'horizontalaxis', 'variable') != null) {
            hvarid = _config.value('plot', i, 'horizontalaxis', 'variable', '@ref');
            data = findDataObjectContainingVariable(hvarid);
          } else {
            // ... or defaults to the first variable in the first data section if not specified
            //     in the xml file
            hvarid = _data[0].getVariableId(0);
            data = _data[0];
          }
          varids.push( hvarid );
          vartypes.push( haxis.type );
          setAxisBoundsIfNeeded(haxis, data, hvarid);

          //   ... next comes a list of vertical variables (one or more), specified either
          //       by <plot><verticalaxis><variable ref="..."> elements, or...
          var vvarid;
          if (_config.xmlvalue('plot', i, 'verticalaxis', 'variable') != null) {
            var nvars = _config.xmlvalue('plot', i, 'verticalaxis', 'variable').length();
            for (var j=0; j<nvars; ++j) {
              var varid = _config.value('plot', i, 'verticalaxis', 'variable', j, '@ref');
              varids.push( varid );
              if (j==0) {
                vvarid = varid;
              }
            }
          } else {
            // ... defaults to the 2nd variable in the data if none specified in the xml file
            vvarid = _data[0].getVariableId(1);
            varids.push( vvarid );
          }
          vartypes.push( vaxis.type );
          setAxisBoundsIfNeeded(vaxis, data, vvarid);
        }

        //
        // create the plot's renderer
        //
        var type:String = _config.value('plot', i, 'renderer', '@type');
        var rendererType:Object = Renderer.getRenderer(type);
        // create the renderer object
        var renderer:Renderer = new rendererType(haxis, vaxis, data, varids);

        // set any renderer options
        if (_config.value('plot', i, 'renderer', 'option') != null) {
          var noptions:int = _config.value('plot', i, 'renderer', 'option').length();
          for (var j:int=0; j<noptions; ++j) {
            var name:String  = _config.value('plot', i, 'renderer', 'option', j, '@name');
            var value:String = _config.value('plot', i, 'renderer', 'option', j, '@value');
            var min:String   = _config.value('plot', i, 'renderer', 'option', j, '@min');
            var max:String   = _config.value('plot', i, 'renderer', 'option', j, '@max');
            if (min != null || max != null) {
              renderer.setRangeOption(name, value, min, max);
            } else {
              renderer[name] = value;
            }
          }
        }

        // set the data filter, if any
        var filterType:String = _config.value('plot', i, 'filter', '@type');
        if (filterType == "grid") {
          var rows:int    = 100;
          var columns:int = 100;
          var visible:Boolean = false;
          var noptions:int = _config.value('plot', i, 'filter', 'option').length();
          for (var j:int=0; j<noptions; ++j) {
            var name:String  = _config.value('plot', i, 'filter', 'option', j, '@name');
            var value:String = _config.value('plot', i, 'filter', 'option', j, '@value');
            if (name=="rows") { rows = int(value); }
            if (name=="columns") { columns = int(value); }
            if (name=="visible") { visible = (value=="true"); }
          }
          renderer.dataFilter = new GridDataFilter(rows, columns, _plotBox.width, _plotBox.height, visible);
        } else if (filterType == "consecutivedistance") {
          var distance:int    = 5;
		  var noptions:int = _config.value('plot', i, 'filter', 'option').length();
		  for (var j:int=0; j<noptions; ++j) {
			  var name:String  = _config.value('plot', i, 'filter', 'option', j, '@name');
            var value:String = _config.value('plot', i, 'filter', 'option', j, '@value');
            if (name=="distance") { distance = int(value); }
          }
          renderer.dataFilter = new ConsecutiveDistanceDataFilter(distance);
        }

        renderer.initialize();

        //
        // determine this plot's legend label
        //
        var legendLabel:String = _config.value('plot', i, 'legend', '@label');
        if (legendLabel==null || legendLabel=="") {
          legendLabel = vvarid;
        }
        if (_config.value('plot', i, 'legend', '@visible')=="false") {
          legendLabel = null;
        }
		
		//
		// determine whether this plot wants to show data tips:
		//
		var showDataTips:Boolean = ((_config.xmlvalue('plot', i, 'datatips') != null)
									&&
									(_config.xmlvalue('plot', i, 'datatips', '@visible')!='false'));
		// Note: we check !=false above, rather than ==true, so that data tips will be shown
		// in the case where there is a <datatip> tag without a 'visible' attribute.
        if (showDataTips) {
			var masterFormat:String = _config.xmlvalue('plot', i, 'datatips', '@format');
          if (masterFormat == null) {
			throw new MuglError('<datatips> section for plot #'+i+' missing required "format" attribute');
          }
          var dataTipFormatter:DataTipFormatter = new DataTipFormatter(masterFormat);
		  
		  try {
			  dataTipFormatter.bgcolor = parsecolor( _config.value('plot', i, 'datatips', '@bgcolor') );
		  } catch (e : ParseError) {
			  throwInvalidError('plot #'+i+' <datatip> "bgcolor" attribute');
		  }
		  dataTipFormatter.bgalpha   = _config.value('plot', i, 'datatips', '@bgalpha');
		  dataTipFormatter.border    = _config.value('plot', i, 'datatips', '@border');
		  dataTipFormatter.pad       = _config.value('plot', i, 'datatips', '@pad');
		  dataTipFormatter.fontcolor = _config.value('plot', i, 'datatips', '@fontcolor');
		  dataTipFormatter.fontsize  = _config.value('plot', i, 'datatips', '@fontsize');
		  dataTipFormatter.bold      = (_config.value('plot', i, 'datatips', '@bold') == "true") ? true : null;
		  try {
			  dataTipFormatter.bordercolor = parsecolor( _config.value('plot', i, 'datatips', '@bordercolor') );
		  } catch (e : ParseError) {
			  throwInvalidError('plot #'+i+' <datatip> "bordercolor" attribute');
		  }
		  
          var nvars:int = _config.value('plot', i, 'datatips', 'variable').length();
          for (var j:int=0; j<nvars; ++j) {
			var format:String  = _config.value('plot', i, 'datatips', 'variable', j, '@format');
            if (format == null) {
              throw new MuglError('<variable> #'+j+' in <datatips> section for plot #'+i+' missing required "format" attribute');
            }
            var formatter:Formatter = Formatter.create(vartypes[j], format);
			dataTipFormatter.addFormatter(formatter, j);
          }
        }

        //
        // finally, create the plot object
        //
        var plot:Plot;
        if (plotIsConstant) {
          plot = new ConstantPlot(_config.value('plot', i, '@id'),
                                  constantValue,
                              	  haxis,
                              	  vaxis,
                              	  renderer,
                              	  legendLabel
                                  );
        } else {
          plot = new DataPlot(_config.value('plot', i, '@id'),
                              data,
                              varids,
                              haxis,
                              vaxis,
                              renderer,
                              legendLabel,
							  showDataTips,
							  dataTipFormatter
                              );
        }
        
        //
        // and add it to our list
        //
        _plots.push( plot );

      }
    }

    private function findDataObjectContainingVariable(id:String):Data {
      for (var i:int=0; i<_data.length; ++i) {
        for (var j:int=0; j<_data[i].variables.length; ++j) {
          if (id == _data[i].variables[j].id) {
            return _data[i];
          }
        }
      }
      return null;
    }

    private function setAxisBoundsIfNeeded(axis:Axis, data:Data, varid:String):void {
      if (!axis.haveDataMin || !axis.haveDataMax) {
        var bounds:Array = data.getBounds(varid);
        if (!axis.haveDataMin) {
          axis.dataMin = bounds[0];
        }
        if (!axis.haveDataMax) {
          axis.dataMax = bounds[1];
        }
      }
    }

    /**
     * Do whatever prep work is needed to make sure that each plot is
     * ready for plotting all data along its current horizontal axis
     * extent.
	 * 
	 * @private
     */
    public function prepareData(propagate:Boolean=true):void {
      for each ( var data : Data in _data ) {
        data.prepareDataReset();
      }
      for each (var plot : Plot in _plots ) {
        plot.prepareData();
      }
      invalidateDisplayList();
    }
	
	/**
	 * @private
	 */
	public function plotXY(x:Number, y:Number):DPoint {
		return new DPoint(x - ( _windowMargin.left   + _border   + _padding.left   + _plotMargin.left   ),
			              y - ( _windowMargin.bottom + _border   + _padding.bottom + _plotMargin.bottom ));
	}	
	
	
	/**
	 * @private
	 */
	public function inPlotBox(x:Number, y:Number):Boolean {
		return ( (x > _axisSprite1.x                       ) &&
			(x < _plotBox.width + _plotMargin.left    ) &&
			(y > _axisSprite1.y                       ) &&
			(y < _plotBox.height + _plotMargin.bottom ) );
	}


    private function throwInvalidError(attr : String) : void {
      throw new MuglError('Invalid ' + attr);
    }

    private function initializeEventHandler():void {
      _uiEventHandler = new NearestAxisUIEventHandler(this);
      /*
      var uieh:String = _config.value('ui', '@eventhandler');
      if (uieh == "naui") {
        this._uiEventHandler = new NearestAxisUIEventHandler(this);
      } else {
        this._uiEventHandler = new SelectedAxisUIEventHandler(this);
      }
      */

	  if ('onMouseDown' in _uiEventHandler) { _eventSprite.addEventListener(MouseEvent.MOUSE_DOWN, _uiEventHandler['onMouseDown']); }
	  if ('onMouseUp'   in _uiEventHandler) { _eventSprite.addEventListener(MouseEvent.MOUSE_UP,   _uiEventHandler['onMouseUp']);   }
	  if ('onMouseMove' in _uiEventHandler) { _eventSprite.addEventListener(MouseEvent.MOUSE_MOVE, _uiEventHandler['onMouseMove']); }
	  if ('onMouseOut'  in _uiEventHandler) { _eventSprite.addEventListener(MouseEvent.MOUSE_OUT,  _uiEventHandler['onMouseOut']);  }
	  if ('onKeyDown'   in _uiEventHandler) { addEventListener(KeyboardEvent.KEY_DOWN,             _uiEventHandler['onKeyDown']);   }
	  if ('onKeyUp'     in _uiEventHandler) { addEventListener(KeyboardEvent.KEY_UP,               _uiEventHandler['onKeyUp']);     }
    }

    /**
     * For an axis with a binding, there are (potentially) 2 pairs of min/max values:
     *    1. the axis's own min/max attributes
     *    2. the min/max attributes for the binding
     * 
     * Both pairs are optional.
     * 
     * When the axis min/max value are present, after binding is performed on
     * all axes, the data range for each bound axis is set to the axis's
     * min/max values.  This is done in the order in which the axes are
     * specified in the mugl file, so axes that appear later in the file take
     * "precedence" over earlier ones which share the same binding.
     * 
     * The binding min/max values, if present, are used only to determing how
     * an axis is mapped in the binding.  If the binding min/max values are
     * not present, the axis min/max values are used.  (i.e. the binding
     * min/max values default to the axis min/max values.)
     * 
     * If the axis min/max values are not present, they default to "auto",
     * which means that their values are determined from the data.  After the
     * axis min/max values have been set, axis binding happens exactly as
     * above.
     *
     * @private
     */
    public static function bindAxes(axes:Array, config:Config, axistag:String):void {
      var i:int;
      var bindingId:String;
      var binding:AxisBinding;
      var min:String, max:String;
      for(i = 0; i < axes.length; ++i){
        bindingId = config.xmlvalue(axistag,i,'binding','@id');
        if (bindingId != null) {
          binding = AxisBinding.findByIdOrCreateNew(bindingId);
          min = config.xmlvalue(axistag, i, 'binding', '@min');
          if (min == null) {
            min = axes[i].dataMin.toString();
          }
          max = config.xmlvalue(axistag, i, 'binding', '@max');
          if (max == null) {
            max = axes[i].dataMax.toString();
          }
          axes[i].setBinding(binding, min, max);
        }
      }

      for(i = 0; i < axes.length; ++i){
        bindingId = config.xmlvalue(axistag,i,'binding','@id');
        if (bindingId != null) {
          min = config.xmlvalue(axistag, i, '@min');
          max = config.xmlvalue(axistag, i, '@max');
          if (min != null && max != null) {
            axes[i].setDataRangeFromStrings(min, max);
          }
        }
      }

      
    }

    private function initializeLegend():void {
      /*
       * This section is responsible for configuring the legends based upon the 
       * <legend .../> section of the mugl file.
       */
      // Positioning
      
      var legendPosition:Array   = _config.value('legend', 0, '@position').split(" ");
	  var legendAnchor:Array     = _config.value('legend', 0, '@anchor').split(" ");
      var legendBase:Array       = _config.value('legend', 0, '@base').split(" ");
      var legendFrame:String     = _config.value('legend', 0, '@frame');
      var legendBorder:Number    = _config.value('legend', 0, '@border');    
      var legendRows:Number      = _config.value('legend', 0, '@rows');     
      var legendColumns:Number   = _config.value('legend', 0, '@columns');
	  var legendBgColor:uint     = parsecolor( _config.value('legend', 0, '@color') );
      var legendBorderColor:uint = parsecolor( _config.value('legend', 0, '@bordercolor') );
      var legendOpacity:Number   = _config.value('legend', 0, '@opacity');
      var legendRadius:Number    = _config.value('legend', 0, '@cornerradius');
      var icon:Object = {
        width  : _config.value('legend', 'icon', 0, '@width'),
        height : _config.value('legend', 'icon', 0, '@height'),
        border : _config.value('legend', 'icon', 0, '@border')
      };

      var legendVisible:String = _config.value('legend', 0, '@visible');
      var isLegendVisible:Boolean;
      if (legendVisible == null || legendVisible == "") {
        // if legend visibility is not explicitly specified, default to true if
        // there are 2 or more plots, otherwise false
        isLegendVisible = (_plots.length >= 2);
      } else {
        isLegendVisible = (legendVisible=="true");
      }

      if (isLegendVisible) {
        _legend = new NewLegend(_plots,
                             legendBase[0], 
                             legendBase[1], 
                             legendAnchor[0], 
                             legendAnchor[1], 
                             legendPosition[0], 
                             legendPosition[1], 
							 this,
                             legendFrame=="plot",
                             legendRows, 
                             legendColumns, 
                             legendBgColor, 
                             legendBorder, 
                             legendBorderColor, 
                             legendOpacity,
                             icon,
                             legendRadius);
      } else {
        _legend = null;
      }
    }


    private function initializeTitle():void {
      var titlePosition:Array   = _config.value('title', 0, '@position').split(" ");
      var titleAnchor:Array     = _config.value('title', 0, '@anchor').split(" ");
      var titleBase:Array       = _config.value('title', 0, '@base').split(" ");
      var titleFrame:String     = _config.value('title', 0, '@frame');
      var titleBorder:Number    = _config.value('title', 0, '@border');    
      var titleBgColor:uint     = parsecolor( _config.value('title', 0, '@color') );
      var titleBorderColor:uint = parsecolor( _config.value('title', 0, '@bordercolor') );
      var titleOpacity:Number   = _config.value('title', 0, '@opacity');
      var titleFontSize:uint    = _config.value('title', 0, '@fontsize');
      var titlePadding:Number   = _config.value('title', 0, '@padding');
      var titleRadius:Number    = _config.value('title', 0, '@cornerradius');

      var titleString:String = _config.xmlvalue('title');
      if (titleString != null && titleString != "") {
        _title = new Title(titleString,
                           titleBase[0], 
                           titleBase[1], 
                           titleAnchor[0], 
                           titleAnchor[1], 
                           titlePosition[0], 
                           titlePosition[1], 
                           this,
                           titleFrame=="plot",
                           titleBgColor, 
                           titleBorder, 
                           titleBorderColor, 
                           titleOpacity,
                           titleFontSize,
                           titlePadding,
                           titleRadius);
      } else {
        _title = null;
      }
    }

    private function initializeImageAnnotations():void {
      var nImages:int = 0;
      if (_config.xmlvalue('img') != null) {
        nImages = _config.xmlvalue('img').length();
      }
      for (var i:int=0; i<nImages; ++i) {
        var url:String          = _config.xmlvalue('img', i, '@src');
        var anchor:Array        = _config.value('img', i, '@anchor').split(" ");
        var base:Array          = _config.value('img', i, '@base').split(" ");
        var position:Array      = _config.value('img', i, '@position').split(" ");
        var frameIsPlot:Boolean = (_config.value('img', i, '@frame') == "plot");
		var opacity:Number      = _config.value('img', i, '@opacity');
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
                                                  function (base:Array, anchor:Array, position:Array, graph:Graph, frameIsPlot:Boolean, opacity:Number):Function {
                                                    return function (event:Event):void {
                                                      var loader:Loader = Loader(event.target.loader);
                                                      var bitmap:Bitmap = Bitmap(loader.content);
													  bitmap.alpha = opacity;
                                                      var imageAnnotation:ImageAnnotation = new ImageAnnotation(bitmap,
                                                                                                                base[0], base[1],
                                                                                                                anchor[0], anchor[1],
                                                                                                                position[0], position[1],
                                                                                                                graph,
                                                                                                                frameIsPlot);
                                                      graph.addImageAnnotation(imageAnnotation);
                                                    }
                                                  }(base, anchor, position, this, frameIsPlot, opacity)
                                                  );
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
                                                  function(errmsg:String):Function {
                                                    return function(event:IOErrorEvent):void {
                                                      trace(errmsg);
                                                    }
                                                  }("Unable to load image annotation: " + url)
                                                  );
		//trace('issuing call to load imageAnnotation');
        loader.load(new URLRequest(url));
      }
    }

    public function addImageAnnotation(imageAnnotation:ImageAnnotation):void {
		//trace('pushing imageAnnotation onto _imageAnnotations list');
      _imageAnnotations.push(imageAnnotation);
	  _paddingBoxSprite.addChild(imageAnnotation);
	  reInitializeGeometry();
    }

	public function showTips(mouseLocation:DPoint):void {
		// As we loop over all plots, use dataTipShown boolean var to keep track of whether a plot has shown
		// a dataTip.  plot.showTip() returns true if it shows a dataTip; we pass dataTipShown as the
		// final arg to plot.showTip, and if that arg is false, the plot does not actually show a dataTip,
		// but rather just hides any previously shown tip.  This way, at most only one tip is shown, no matter
		// how many plots there are.
		var dataTipShown:Boolean = false;
		for each ( var plot : Plot in _plots ) {
			if (plot.showTip(mouseLocation, _plotBoxSprite, _plotBox, dataTipShown)) {
				dataTipShown = true;
			}
		}
	}
	public function hideTips():void {
		for each ( var plot : Plot in _plots ) {
			plot.hideTip();
		}
	}
		
  }
}
