/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Graphics;
  import flash.display.Loader;
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.events.*;
  import flash.geom.Matrix;
  import flash.net.*;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.utils.*;
  
  import multigraph.data.*;
  import multigraph.debug.DebugWindow;
  import multigraph.debug.Debugger;
  import multigraph.debug.NetworkMonitor;
  import multigraph.format.*;
  import multigraph.renderer.*;
  
  import mx.controls.*;
  import mx.core.UIComponent;
  import mx.managers.CursorManager;
  import mx.managers.PopUpManager;
    
  /*
    import mx.containers.Panel;
    import mx.core.Application;
  */

  public class Graph extends UIComponent
  {
    private var _windowMargin : Insets;
    private var _border       : Insets;
    private var _padding      : Insets;
    private var _plotMargin   : Insets;
    private var _plotareaBorder : Number;
    private var _plotareaBorderColor : uint;
    private var _window       : Box;
    private var _paddingBox   : Box;
    private var _plotBox      : Box;
    public function get plotBox():Box { return _plotBox; }
    //private var haxis        : HorizontalAxis;
    private var _haxes        : Array = [];
    private var _vaxes        : Array = [];
    private var _axes         : Array = [];
    private var _selectedAxis : Axis = null;
    private var _legend      : Legend;
    private var _title       : Title;
    private var _toolbar	 : ToolBar;
    private var _toolbarState : String;
    public function set toolbarState(state:String):void {
    	_toolbarState = state;
    }
    public function get toolbarState():String { return _toolbarState; }
        
    private var _plots       : Array = [];
    private var _data        : Array = [];
    private var _paintNeeded : Boolean = false;
    private var _mouseLocation : PixelPoint = null;
    public function set paintNeeded(needed:Boolean):void { _paintNeeded = needed; }

    // Timer used to arrange for a call to prepareData() after user stops
    // zooming with keyboard shortcuts:
    private var _keyTimer    : Timer = null;
    // Delay, in milliseconds, before prepareData() should be called after
    // user stops zooming with keyboard shortcuts:
    private var _keyTimerDelay:int = 500;

    private var _bgSprite:MultigraphUIComponent;
    private var _divSprite:MultigraphUIComponent;
    private var _eventSprite:MultigraphUIComponent;
    private var _axisControlSprite:MultigraphUIComponent;
    private var _paddingBoxSprite:MultigraphUIComponent;
    private var _plotBoxSprite:MultigraphUIComponent;
    // There are 2 axis sprites: one below the plotBoxSprite, and one
    // above.  The one below (_axisSprite1) is where the axis grid
    // lines are drawn, so they appear below the data.  The one above
    // (_axisSprite2) is where the axes themselves, and their labels &
    // tic marks, appear, so that these things are drawn on top of the
    // data.
    private var _axisSprite1:MultigraphUIComponent;
    private var _axisSprite2:MultigraphUIComponent;

    private var _graphWidth:Number;
    private var _graphHeight:Number;
    private var _xml:XML;
    private var _config:Config;

    private var _constructorSize:Box;
    private var _swfname:String;
    public function get swfname():String { return _swfname; }
    private var _hostname:String;
    public function get hostname():String { return _hostname; }
    private var _pathname:String;
    public function get pathname():String { return _pathname; }
    private var _port:String;
    private var _proxy:String;
    public function get port():String { return _port; }
    private var _numCsvOutstanding = 0;
	
    // icon asset
    [Embed(source="assets/plus.PNG")]
      [Bindable]
      private var plusIcon:Class;
    
    [Embed(source="assets/minus.PNG")]
      [Bindable]
      private var minusIcon:Class;
      
    // Mouse cursor assets
    [Embed(source="assets/cursors/HandOpen.png")]
      [Bindable]
      private var mouseCursorGrab:Class;

    [Embed(source="assets/cursors/HandClosed.png")]
      [Bindable]
      private var mouseCursorGrabbing:Class;

    
    public function displayMessage(msg:String):void {
      //_app.displayMessage(msg);
    }

    public function Graph(xml:XML, swfname:String, hostname:String, pathname:String, port:String, proxy:String, width:int=-1, height:int=-1) {
      this._xml = xml;
      this._swfname  = swfname;
      this._hostname = hostname; 
      this._pathname = pathname; 
      this._port= port; 
      this._proxy = proxy;
      init(width, height);
    }       

    private function init(width:int, height:int):void {
      _graphWidth  = width;
      _graphHeight = height;
      init_phase1();
    }


//    private function doFirstFrame(event:Event):void {
//      removeEventListener(Event.ENTER_FRAME, doFirstFrame);
//      if (_constructorSize != null) {
//        _graphWidth  = _constructorSize.width;
//        _graphHeight = _constructorSize.height;
//      } else {
//        _graphWidth  = stage.stageWidth;
//        _graphHeight = stage.stageHeight;
//      }
//      init();
//      
//      addChild(_divSprite);
//      addChild(_eventSprite);  
//      //addChild(mouseControlSprite);    
//      addChild(_axisControlSprite);
//      addEventListener(Event.ENTER_FRAME, doEveryFrame);
//      prepareData();
//      _paintNeeded = true;
//    }
    
    private var _diagnosticWindow:DebugWindow = null;
    
    private var _networkMonitor:NetworkMonitor = null;
    private var _networkDots:Boolean = false;
    private var _debugger:Debugger = null;

    public function addDebuggerItem(debugable:Object):void {
      if (_debugger != null) {
        _debugger.addItem(debugable);
      }
    }
    
    public function diagnosticOutput(s:String):void {
      if (_diagnosticWindow != null) {
        _diagnosticWindow.append(s+'\n');
      }
    }    

    private function showDiagnostics():void {
      _diagnosticWindow = DebugWindow(PopUpManager.createPopUp(this, DebugWindow, false));
      _diagnosticWindow.width = 750;
      _diagnosticWindow.height = 300;
      _diagnosticWindow.title = "Diagnostics";
    }
    
    private function showNetworkMonitor():void {
      _networkMonitor = new NetworkMonitor();
      _networkMonitor.width = 750;
        
      var monitorPosition:String = _config.xmlvalue('networkmonitor', '@fixed');
      if (monitorPosition == 'true') {
        _networkMonitor.y = _graphHeight + 10;
        _networkMonitor.width = _graphWidth;
        _networkMonitor.height = _graphHeight;
        this.addChild(_networkMonitor);
      }
      else {
        PopUpManager.addPopUp(_networkMonitor, this, false);    
      }
    }
    
    private function showDebugger():void {
      _debugger = new Debugger();
      _debugger.width = _graphHeight;
        
      var debuggerPosition:String = _config.xmlvalue('debugger', '@fixed');
      if (debuggerPosition == 'true') {
        _debugger.x = _graphWidth + 10;
        _debugger.width = _graphHeight;
        _debugger.height = _graphHeight * 2 + 10;
        this.addChild(_debugger);
      } else {
        PopUpManager.addPopUp(_debugger, this, false);
      } 
    }

    public function networkMonitorStartRequest(networkable:Object):void {
      if (_networkMonitor != null) {
        _networkMonitor.startRequest(networkable);
      }
    }
    public function networkMonitorEndRequest(networkable:Object):void {
      if (_networkMonitor != null) {
        _networkMonitor.endRequest(networkable);
      }
    }

    private function init_phase1():void {
      _config = new Config(_xml);
	  
      
      var diagnosticsVisible:String = _config.xmlvalue('diagnostics', '@visible');
      if (diagnosticsVisible=='true') {
        showDiagnostics();
      }
      
      var networkVisible:String = _config.xmlvalue('networkmonitor', '@visible');
      if (networkVisible == 'true') {
        showNetworkMonitor();
      }
      
      var networkDotsString:String = _config.xmlvalue('networkdots', '@visible');
      _networkDots = (networkDotsString == 'true');
      
      var debuggerVisible:String = _config.xmlvalue('debugger', '@visible');
      if (debuggerVisible == 'true') {
        showDebugger();
      }
      
      // Initiate the cursor manager
      //_cursorManager = new CursorManager();
      
      _window = new Box(_graphWidth, _graphHeight);
      
      // Just a test
      var debugable:Object = {type:_window, data:"BALH"};
      addDebuggerItem(debugable);

      _windowMargin = new Insets(_config.value('window','@margin'));
      _border       = new Insets(_config.value('window','@border'));
      _padding      = new Insets(_config.value('window','@padding'));
      _paddingBox = new Box(_window.width
                           - ( _windowMargin.left + _border.left + _padding.left )
                           - ( _windowMargin.right + _border.right + _padding.right ),
                           _window.height
                           - ( _windowMargin.top + _border.top + _padding.top )
                           - ( _windowMargin.bottom + _border.bottom + _padding.bottom )
                           );


      _plotMargin = new Insets(_config.value('plotarea', '@margintop'),
                              _config.value('plotarea', '@marginleft'),
                              _config.value('plotarea', '@marginbottom'),
                              _config.value('plotarea', '@marginright'));

      _plotareaBorder = _config.value('plotarea', '@border');
      _plotareaBorderColor = parsecolor( _config.value('plotarea', '@bordercolor') );

      _plotBox = new Box(_paddingBox.width - ( _plotMargin.left + _plotMargin.right),
                         _paddingBox.height - ( _plotMargin.top + _plotMargin.bottom ));

      _divSprite = new MultigraphUIComponent();
	  _divSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, _graphHeight);
      
      /* Dropshadow filter over div sprite
      var shadow:DropShadowFilter = new DropShadowFilter();
      shadow.alpha = 0.4;
      shadow.distance = 0.5;
      
      _divSprite.filters = [shadow];
      */
	  
	  _bgSprite = new MultigraphUIComponent();
	  //_bgSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, _graphHeight);
	  //this.addChild(_bgSprite);



      
      _eventSprite = new MultigraphUIComponent();
      _eventSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, _graphHeight);
      
      _eventSprite.graphics.beginFill(0xffffff, 0);
      _eventSprite.graphics.drawRect(0,0,_graphWidth,_graphHeight);
      _eventSprite.graphics.endFill();
      _eventSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      _eventSprite.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp);
      _eventSprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      _eventSprite.addEventListener(MouseEvent.MOUSE_OUT,  onMouseOut);

	  // Remove the cursor if it moves outside of the graph window
	  _divSprite.addEventListener(MouseEvent.MOUSE_OUT, function (event:MouseEvent):void {
	  	CursorManager.removeAllCursors();
	  });
	  
      addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      addEventListener(KeyboardEvent.KEY_UP,   onKeyUp);

      _axisControlSprite = new MultigraphUIComponent();
      _axisControlSprite.transform.matrix = new Matrix(1, 0, 0, -1, 0, _graphHeight);
      
      var paddingBoxMask:Shape = new Shape();
      paddingBoxMask.graphics.beginFill(0x000000);
      paddingBoxMask.graphics.drawRect(_windowMargin.left + _border.left + _padding.left,
                                       _windowMargin.bottom + _border.bottom + _padding.bottom,
                                       _graphWidth - (_windowMargin.left + _border.left + _padding.left
                                                     + _windowMargin.right + _border.right + _padding.right),
                                       _graphHeight - (_windowMargin.bottom + _border.bottom + _padding.bottom
                                                      + _windowMargin.top + _border.top + _padding.top));
      paddingBoxMask.graphics.endFill();

      _paddingBoxSprite = new MultigraphUIComponent();
      _divSprite.addChild(paddingBoxMask);
      _divSprite.addChild(_paddingBoxSprite);
      _paddingBoxSprite.mask = paddingBoxMask;
      _paddingBoxSprite.x = _windowMargin.left + _border.left + _padding.left;
      _paddingBoxSprite.y = _windowMargin.bottom + _border.bottom + _padding.bottom;

      _axisSprite1 = new MultigraphUIComponent();
      _axisSprite1.x = _plotMargin.left;
      _axisSprite1.y = _plotMargin.bottom;
      
      _paddingBoxSprite.addChild(_axisSprite1);

      var plotBoxMask:Shape = new Shape();
      plotBoxMask.graphics.beginFill(0x000000);
      plotBoxMask.graphics.drawRect(_plotMargin.left, _plotMargin.bottom,
                                    _plotBox.width, _plotBox.height);
      plotBoxMask.graphics.endFill();

      _plotBoxSprite = new MultigraphUIComponent();
      _paddingBoxSprite.addChild(plotBoxMask);
      _paddingBoxSprite.addChild(_plotBoxSprite);
      _plotBoxSprite.mask = plotBoxMask;
      _plotBoxSprite.x = _plotMargin.left;
      _plotBoxSprite.y = _plotMargin.bottom;

      _axisSprite2 = new MultigraphUIComponent();
      _axisSprite2.x = _plotMargin.left;
      _axisSprite2.y = _plotMargin.bottom;
      _paddingBoxSprite.addChild(_axisSprite2);

	  var bgColorString:String = _config.xmlvalue('background', '@color');	 
	  if (bgColorString!=null && bgColorString!='') {
		  var bgColor:uint = parsecolor( bgColorString );
		  _bgSprite.graphics.beginFill(bgColor, 1);
		  _bgSprite.graphics.drawRect(_windowMargin.left, _windowMargin.bottom,
			  						  _graphWidth - _windowMargin.left - _windowMargin.right,
			  						  _graphHeight - _windowMargin.bottom - _windowMargin.top);		  
		  _bgSprite.graphics.endFill();
	  }
	  
	  var bgImageURL:String = _config.xmlvalue('background','img','@src');
	  
	  if (bgImageURL!=null && bgImageURL!='') {
		  var bgAnchor:Array    = _config.value('background', 'img', '@anchor').split(" ");
		  var bgBase:Array      = _config.value('background', 'img', '@base').split(" ");
		  var bgPosition:Array  = _config.value('background', 'img', '@position').split(" ");
		  var bgFrame:String    = _config.value('background', 'img', '@frame');
		  
		  var loader:Loader = new Loader();
		  loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
			  function(sprite:Sprite, anchor:Array, base:Array, position:Array, frameIsPlot:Boolean, windowMargin:Insets, border:Insets, plotMargin:Insets, plotBox:Box, paddingBox:Box):Function {
				  return function (event:Event):void {
					  var loader:Loader = Loader(event.target.loader);
					  var image:Bitmap = Bitmap(loader.content);
					  
					  var ax:Number = (Number(anchor[0])+1)*image.width/2;
					  var ay:Number = image.height - ((Number(anchor[1])+1)*image.height/2);
					  var bx:Number=0, by:Number=0;
					  if (frameIsPlot) {
						  bx = plotMargin.left + (Number(base[0])+1)*plotBox.width/2;
						  by = plotMargin.top + plotBox.height - ((Number(base[1])+1)*plotBox.height/2);
					  } else {
						  bx = windowMargin.left + border.left + (Number(base[0])+1)*paddingBox.width/2; 
						  by = windowMargin.top  + border.top + paddingBox.height - ((Number(base[1])+1)*paddingBox.height/2);
					  }
					  image.x = bx + Number(position[0]) - ax;
					  image.y = by + Number(position[1]) - ay;		  
					  sprite.addChild(image);
				  }
			  }(_bgSprite, bgAnchor, bgBase, bgPosition, bgFrame=="plot", _windowMargin, _border, _plotMargin, _plotBox, _paddingBox)
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
	  
      var numDataSections:int = _config.xmlvalue('data').length();
      var vars:Array;
      var haveCsv:Boolean = false;
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
          ++_numCsvOutstanding;
          _data[j] = new CSVFileArrayData( vars, Multigraph.proxiedUrl(_proxy, url), this, randomize, this.finishCsv );
		  haveCsv = true;
        } else if (_config.value('data', j, 'service') != null) {
          // The <data> section contains a <service> element, so the data is to be fetched
          // from a web service.  Use a Multigraph.WebServiceData object.
          vars = buildDataVariableArrayFromConfig(j);
          var url:String = _config.value('data', j, 'service','@location');
          diagnosticOutput('creating a web service data object with service location "'+url+'"');
          _data[j] = new WebServiceData( Multigraph.proxiedUrl(_proxy, url), vars, this );
        } else {
          trace("unknown data section type!");
        }
      }
      
      // temporarily disable delayed phase2 initialization because it does not seem to work when compiled with Flex 4 SDK.
      //    When fixing this, be sure to remove the early 'return' from finishCsv() below!
      //if (!haveCsv) {
        init_phase2();
      //}
      
    }
    
    private function finishCsv(data:CSVFileArrayData):void {
    	// temporarily disable delayed phase2 initialization because it does not seem to work when compiled with Flex 4 SDK
    	return;
    	--_numCsvOutstanding;
    	if (_numCsvOutstanding == 0) {
          init_phase2();
    	}
    }
    
    private function init_phase2():void {
      
      /// create horizontal axes
      _haxes = createAxes('horizontalaxis', HorizontalAxis);
      for (var i:int = 0; i<_haxes.length; ++i) {
        _axes.push(_haxes[i]);
      }

      /// create vertical axes
      _vaxes = createAxes('verticalaxis', VerticalAxis);
      for (i = 0; i<_vaxes.length; ++i) {
        _axes.push(_vaxes[i]);
      }
      
      ///
      /// create the plot objects
      ///
      // Set up the renderers for each plot, and create the corresponding Plot object
      var nplots:int = 1; // number of plots defaults to 1, in case no <plot> element is present in the xml file
      if (_config.xmlvalue('plot') != null) {
        nplots = _config.xmlvalue('plot').length();
      }

      for (i=0; i<nplots; ++i) {
        // 
        // get the plot's horizontal axis
        //
        var haxis:Axis = _haxes[0];

        //
        // get the plot's vertical axis...
        //
        // ... to the one specified in the xml file (<plot><verticalaxis ref="...">),
        // if any, or default to the first vertical axis if none is specified
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
                              legendLabel
                              );
        }
        
        //
        // and add it to our list
        //
        _plots.push( plot );

      }
      
      /**
       * This section is responsible for configuring the legends based upon the 
       * <legend .../> section of the mugl file.
       **/
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
        _legend = new Legend(_plots,
                             legendBase[0], 
                             legendBase[1], 
                             legendAnchor[0], 
                             legendAnchor[1], 
                             legendPosition[0], 
                             legendPosition[1], 
                             _plotBox,
                             _paddingBox,
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
                           _plotBox,
                           _paddingBox,
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
      
      var toolbarString:String = _config.xmlvalue("toolbar", 0, "@visible");
      var isToolbarVisible:Boolean = (toolbarString == "true");
      // Create the toolbar
      if(isToolbarVisible) {
      	_toolbar = new ToolBar(this,
      						 1, 1,
       					     1, 1,
       					     -7, -5,
       					     _plotBox,
       					     _window,
       					     false,
       					     0xFFFFFF,
       					     1,
       					     0x000000,
       					     1,
       					     0);
      }

      
      bindAxes(_vaxes, _config, 'verticalaxis', _swfname);
      bindAxes(_haxes, _config, 'horizontalaxis', _swfname);

      _keyTimer = new Timer(_keyTimerDelay, 1);
      _keyTimer.addEventListener("timer", keyTimerHandler);

      // phase3
      init_phase3();
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

    private function init_phase3():void {
	  addChild(_bgSprite);
	  addChild(_divSprite);
      addChild(_eventSprite);  
      addChild(_axisControlSprite);
      
      addEventListener(Event.ENTER_FRAME, doEveryFrame);
      prepareData();
      _paintNeeded = true;
    }

    private function keyTimerHandler(event:TimerEvent):void {
      prepareData();
    }

    private function createAxes(axistag:String, axisType:Object):Array {
      var formatter:Formatter;
      var numAxes:int = 1; // force at least one axis, in case none is specifed in the xml file
      if (_config.xmlvalue(axistag) != null) {
        numAxes = _config.xmlvalue(axistag).length();
      }

      var axes:Array = [];

      for(var i:int = 0; i < numAxes; ++i){
        /*
        var position:Number = _config.value(axistag, i, '@position');
        var positionbase:String = _config.value(axistag, i, '@positionbase');
        if (positionbase == 'right') {
          position = _plotBox.width + position;
        } else if (positionbase == 'top') {
          position = _plotBox.height + position;
        }
        */

        var titletext:String;
        if (_config.xmlvalue(axistag, i, '@title') == null) {
          titletext = null;
        } else {
          titletext = _config.value(axistag, i, '@title');
          if (titletext == undefined) {
            titletext = "";
          }
        }
        var type:int = -1;
        var axisTypeString:String = _config.value(axistag, i, '@type'); 
        switch (axisTypeString) {
        case "number":
          type = Axis.TYPE_NUMBER;
          break;
        case "datetime":
          type = Axis.TYPE_DATETIME;
          break;
        }
        
        var id:String        = _config.value(axistag, i, '@id');
        var min:String       = _config.value(axistag, i, '@min');
        var max:String       = _config.value(axistag, i, '@max');
        //var minoffset:String = _config.value(axistag, i, '@minoffset');
        //var maxoffset:String = _config.value(axistag, i, '@maxoffset');
        //var pregap:Number = _config.value(axistag,i,'@pregap');
        //var postgap:Number = _config.value(axistag,i,'@postgap');

        var minPosition:Displacement = Displacement.parse( _config.value(axistag, i, '@minposition') );
        var maxPosition:Displacement = Displacement.parse( _config.value(axistag, i, '@maxposition') );

        var position:String   = _config.value(axistag, i, '@position');
        var axisPosition:PixelPoint = PixelPoint.parse(position, (axisType==HorizontalAxis) ? 1 : 0);

        var base:String       = _config.value(axistag, i, '@base');

        //
        // code to handle deprecated "@positionbase" attribute; only has effect if "@base" is not specifed in xml
        //
        var xmlbase:String = _config.xmlvalue(axistag, i, '@base');
        if (xmlbase==null || xmlbase=="") {
          var positionbase:String = _config.xmlvalue(axistag, i, '@positionbase');
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

        var anchor:Number     = Number(_config.value(axistag, i, '@anchor'));

        var lengthDisplacement:Displacement = Displacement.parse( _config.value(axistag,i,'@length') );
        var length:Number = lengthDisplacement.calculateLength((axisType == HorizontalAxis) ? _plotBox.width : _plotBox.height );
        
        var parallelOffset:Number = 0;
		var perpOffset:Number = 0;

        if (axisType == HorizontalAxis) {
          parallelOffset = axisPosition.x + (axisBase.x + 1) * _plotBox.width/2 - (anchor + 1) * length / 2;
          perpOffset = axisPosition.y + (axisBase.y + 1) * _plotBox.height/2;
        } else {
          parallelOffset = axisPosition.y + (axisBase.y + 1) * _plotBox.height/2 - (anchor + 1) * length / 2;
          perpOffset = axisPosition.x + (axisBase.x + 1) * _plotBox.width/2;
        }

        var title:String  = _config.xmlvalue(axistag,i,'title');

        var titlePositionString:String = _config.xmlvalue(axistag,i,'title','@position');
        if (titlePositionString==null || titlePositionString=="") {
          if (axisType == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              titlePositionString = _config.value(axistag,i,'title','@position_horiz_top');
            } else {
              titlePositionString = _config.value(axistag,i,'title','@position_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              titlePositionString = _config.value(axistag,i,'title','@position_vert_right');
            } else {
              titlePositionString = _config.value(axistag,i,'title','@position_vert_left');
            }
          }
        }
        var titlePosition:PixelPoint = PixelPoint.parse( titlePositionString );

        var titleAnchorString:String = _config.xmlvalue(axistag,i,'title','@anchor');
        if (titleAnchorString==null || titleAnchorString=="") {
          if (axisType == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              titleAnchorString = _config.value(axistag,i,'title','@anchor_horiz_top');
            } else {
              titleAnchorString = _config.value(axistag,i,'title','@anchor_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              titleAnchorString = _config.value(axistag,i,'title','@anchor_vert_right');
            } else {
              titleAnchorString = _config.value(axistag,i,'title','@anchor_vert_left');
            }
          }
        }
        var titleAnchor:PixelPoint = PixelPoint.parse( titleAnchorString );

        var titleAngle:Number = parseFloat(_config.value(axistag,i,'title','@angle'));


        var grid:Boolean = (_config.xmlvalue(axistag,i,'grid') != null);
        var gridColor:uint = parsecolor( _config.value(axistag,i,'grid','@color') );

        var lineWidth:int = _config.value(axistag,i,'@linewidth');

        var tickMin:int = _config.value(axistag,i,'@tickmin');
        var tickMax:int = _config.value(axistag,i,'@tickmax');

        var highlightStyleString:String = _config.value(axistag,i,'@highlightstyle');
        var highlightStyle:int = Axis.HIGHLIGHT_AXIS;
        if (highlightStyleString == "labels") {
          highlightStyle = Axis.HIGHLIGHT_LABELS;
        } else if (highlightStyleString == "all") {
          highlightStyle = Axis.HIGHLIGHT_ALL;
        }

        var titleTextFormat:TextFormat = new TextFormat();
        titleTextFormat.font  = _config.value(axistag,i,'title','@fontname');
        titleTextFormat.size  = _config.value(axistag,i,'title','@fontsize');
        titleTextFormat.color = _config.value(axistag,i,'title','@fontcolor');
        titleTextFormat.align = TextFormatAlign.LEFT;

        var titleBoldTextFormat:TextFormat = new TextFormat();
        titleBoldTextFormat.font  = titleTextFormat.font + "Bold";
        titleBoldTextFormat.size  = titleTextFormat.size;
        titleBoldTextFormat.color = titleTextFormat.color;
        titleBoldTextFormat.align = titleTextFormat.align;

        axes[i] = new axisType(id,
                               this,
                               length,
                               parallelOffset,
                               perpOffset,
                               type,
                               0x000000,
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
                               highlightStyle,
                               titleTextFormat,
                               titleBoldTextFormat
                               );

        axes[i].panConfig.setConfig(_config.value(axistag, i, 'pan', '@allowed'),
                                    _config.value(axistag, i, 'pan', '@min'),
                                    _config.value(axistag, i, 'pan', '@max'));
                                       
        axes[i].zoomConfig.setConfig(_config.value(axistag, i, 'zoom', '@allowed'),
                                     _config.value(axistag, i, 'zoom', '@anchor'),
                                     _config.value(axistag, i, 'zoom', '@min'),
                                     _config.value(axistag, i, 'zoom', '@max'));
                                       
        // Setup the axis controls
        var axisControlsVisible:String = _config.value(axistag, i, 'axiscontrols', '@visible');
        if(axisControlsVisible == "true") {
          axes[i].hasAxisControls = true;
          axes[i].axisControl = new AxisControls(_axisControlSprite, axes[i], _config);
        }

        var labelPositionString:String = _config.xmlvalue(axistag, i, 'labels', '@position');
        if (labelPositionString==null || labelPositionString=="") {
          if (axisType == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              labelPositionString = _config.value(axistag,i,'labels','@position_horiz_top');
            } else {
              labelPositionString = _config.value(axistag,i,'labels','@position_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              labelPositionString = _config.value(axistag,i,'labels','@position_vert_right');
            } else {
              labelPositionString = _config.value(axistag,i,'labels','@position_vert_left');
            }
          }
        }
        var labelPosition:PixelPoint = PixelPoint.parse( labelPositionString );

        var labelAnchorString:String = _config.xmlvalue(axistag, i, 'labels', '@anchor');
        if (labelAnchorString==null || labelAnchorString=="") {
          if (axisType == HorizontalAxis) {
            if (perpOffset > _plotBox.height/2) {
              labelAnchorString = _config.value(axistag,i,'labels','@anchor_horiz_top');
            } else {
              labelAnchorString = _config.value(axistag,i,'labels','@anchor_horiz_bot');
            }
          } else {
            if (perpOffset > _plotBox.width/2) {
              labelAnchorString = _config.value(axistag,i,'labels','@anchor_vert_right');
            } else {
              labelAnchorString = _config.value(axistag,i,'labels','@anchor_vert_left');
            }
          }
        }
        var labelAnchor:PixelPoint = PixelPoint.parse( labelAnchorString );

        var labeler:Labeler;
        
        var labelerType:Object = (type == Axis.TYPE_DATETIME) ? DateLabeler : NumberLabeler;
        
        var spacingAndUnit:NumberAndUnit;
        if(_config.xmlvalue(axistag, i, 'labels', 'label') != null) {
          var nlabeltags:int = _config.xmlvalue(axistag, i, 'labels','label').length();
          for(var k:int = 0; k < nlabeltags; ++k) {
            var hlabelSpacings:Array = _config.value(axistag, i, 'labels', 'label', k, '@spacing').split(" ");
            var labelTextFormat:TextFormat = new TextFormat();
            labelTextFormat.font  = _config.value(axistag,i,'labels','label',k,'@fontname');
            labelTextFormat.size  = _config.value(axistag,i,'labels','label',k,'@fontsize');
            labelTextFormat.color = _config.value(axistag,i,'labels','label',k,'@fontcolor');
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
                                        _config.value(axistag, i, 'labels', 'label', k, '@format'),
                                        _config.value(axistag, i, 'labels', '@start'),
                                        labelPosition.x,
                                        labelPosition.y,
                                        _config.value(axistag, i, 'labels', '@angle'),
                                        labelAnchor.x, 
                                        labelAnchor.y,
                                        labelTextFormat,
                                        labelBoldTextFormat);
              axes[i].addLabeler(labeler);
            }
          } 
        } else {
          var hlabelSpacings:Array = _config.value(axistag, i, 'labels', '@spacing').split(" ");
          var labelTextFormat:TextFormat = new TextFormat();
          labelTextFormat.font  = _config.value(axistag,i,'labels','@fontname');
          labelTextFormat.size  = _config.value(axistag,i,'labels','@fontsize');
          labelTextFormat.color = _config.value(axistag,i,'labels','@fontcolor');
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
                                      _config.value(axistag, i, 'labels', '@format'),
                                      _config.value(axistag, i, 'labels', '@start'),  //parseFloat(_config.value(axistag, i, 'labels', '@start')),
                                      labelPosition.x,
                                      labelPosition.y,
                                      parseFloat(_config.value(axistag, i, 'labels','@angle')),
                                      labelAnchor.x,
                                      labelAnchor.y,
                                      labelTextFormat,
                                      labelBoldTextFormat);
            axes[i].addLabeler(labeler);
          }   
        }

      }
      return axes;
    }


    /*
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
     */
    public static function bindAxes(axes:Array, config:Config, axistag:String, swfname:String):void {
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

    var _frameCount:int;
    var _frameCountStartUp = 4;
    
    private function doEveryFrame(event:Event):void {
      if (_paintNeeded) {
        _paintNeeded = false;
        paint();
      }
      if (_frameCount < _frameCountStartUp) {
        ++_frameCount;
        _paintNeeded = true;
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
                                     Axis.parseType(_config.value('data', dataSection, 'variables', 'variable', i, '@type')),
                                     missingValue,
                                     missingOp)
                    );
        }
      } else {
        trace('got no vars!');
      }
      return vars;
    }

    public function axisXY(axis:Axis, event:MouseEvent):PixelPoint {
      return new PixelPoint(event.localX - ( _windowMargin.left
                                             + _border.left
                                             + _padding.left
                                             + _plotMargin.left ),
                            event.localY - ( _border.bottom
                                             + _windowMargin.bottom
                                             + _padding.bottom
                                             + _plotMargin.bottom )
                            )
        }
    
    public function selectAxis(axis:Axis):void {
      if (_selectedAxis == axis) { return; }
      if (_selectedAxis != null) {
        _selectedAxis.selected = false;
      }
      axis.selected = true;
      _selectedAxis = axis;
      _paintNeeded = true;
    }

    public function delegateMouseEventToAxis(method:String, event:MouseEvent):void {     
      var i:int;
      _mouseLocation = axisXY(_axes[i], event);
      var done:Boolean = false;
      for (i=0; i<_axes.length; ++i) {
        if (_axes[i].selected) {
          if (_axes[i][method](_mouseLocation, event)) {
            done = true;
          }
          break;
        }
      }
      if (!done) {
        for (i=0; i<_axes.length; ++i) {
          if (!_axes[i].selected) {
            if (_axes[i][method](_mouseLocation, event)) {
              done = true;
              break;
            }
          }
        }
      }
    }
  
    public function delegateKeyEventToAxis(method:String, event:KeyboardEvent):void {
      if (_mouseLocation == null) { return; }
      // only delegate key events to the selected axis
      if (_selectedAxis != null) {
        _selectedAxis[method](_mouseLocation, event);
      }
    }
    
    public function onMouseDown(event:MouseEvent):void {
      stage.focus = this;
      delegateMouseEventToAxis('handleMouseDown', event);
      
      if (_toolbarState != "zoom") {
      	this.cursorManager.removeAllCursors();
      	if (event.localX > _axisSprite1.x && event.localX < _plotBox.width + _plotMargin.left) {
      		if (event.localY > _axisSprite1.y && event.localY < _plotBox.height + _plotMargin.bottom) {
            	this.cursorManager.setCursor(mouseCursorGrabbing);
      		} 
      	}
      }
    }
        
    public function onMouseUp(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseUp', event);
      
      if (_toolbarState != "zoom") {
      	this.cursorManager.removeAllCursors();
      	if (event.localX > _axisSprite1.x && event.localX < _plotBox.width + _plotMargin.left) {
      		if (event.localY > _axisSprite1.y && event.localY < _plotBox.height + _plotMargin.bottom) {
            	this.cursorManager.setCursor(mouseCursorGrab);
      		} 
      	}
      } 
    }

    public function onMouseMove(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseMove', event);
     
      if (!event.buttonDown && _toolbarState != "zoom") {
      	this.cursorManager.removeAllCursors();
      	if (event.localX > _axisSprite1.x && event.localX < _plotBox.width + _plotMargin.left) {
          if (event.localY > _axisSprite1.y && event.localY < _plotBox.height + _plotMargin.bottom) {
          	if (event.buttonDown)
              this.cursorManager.setCursor(mouseCursorGrabbing);
          	else 
      	      this.cursorManager.setCursor(mouseCursorGrab);
      	  } else {
      	  	this.cursorManager.removeAllCursors();
      	  }	
      	} else {
      	  this.cursorManager.removeAllCursors();
      	}	
      }
    }

    public function onMouseOut(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseOut', event);
    }

    private var _aCharCode:uint = 'a'.charCodeAt();
    private var _zCharCode:uint = 'z'.charCodeAt();
    private var _ACharCode:uint = 'A'.charCodeAt();
    private var _ZCharCode:uint = 'Z'.charCodeAt();
    private var _qCharCode:uint = 'q'.charCodeAt();
    private var _QCharCode:uint = 'Q'.charCodeAt();
    private var _plusCharCode:uint = '+'.charCodeAt();
    private var _minusCharCode:uint = '-'.charCodeAt();
    private var _dCharCode:uint = 'd'.charCodeAt();
    private var _lessCharCode:uint = '<'.charCodeAt();
    private var _greaterCharCode:uint = '>'.charCodeAt();

    private var _upKeyCode:uint    = 38;
    private var _leftKeyCode:uint  = 37;
    private var _downKeyCode:uint  = 40;
    private var _rightKeyCode:uint = 39;

    public function onKeyDown(event:KeyboardEvent):void { 
     if (event.shiftKey && _toolbar != null) {
      	_toolbar.updateZoomIcon();
      }
      
      //trace('key down event: ' + event);

     if (event.charCode==0) {

       if (_selectedAxis != null && _selectedAxis.orientation==Axis.ORIENTATION_VERTICAL) {
         switch (event.keyCode) {
         case _upKeyCode:
           event.charCode = _greaterCharCode;
           break;
         case _downKeyCode:
           event.charCode = _lessCharCode;
           break;
         case _leftKeyCode:
           event.charCode = _minusCharCode;
           break;
         case _rightKeyCode:
           event.charCode = _plusCharCode;
           break;
         }
       } else {
         switch (event.keyCode) {
         case _upKeyCode:
           event.charCode = _plusCharCode;
           break;
         case _downKeyCode:
           event.charCode = _minusCharCode;
           break;
         case _leftKeyCode:
           event.charCode = _lessCharCode;
           break;
         case _rightKeyCode:
           event.charCode = _greaterCharCode;
           break;
         }
       }
     }

      switch (event.charCode) {
      case _aCharCode:
      case _zCharCode:
      case _ACharCode:
      case _ZCharCode:
      case _qCharCode:
      case _QCharCode:
      case _plusCharCode:
      case _minusCharCode:
      case _lessCharCode:
      case _greaterCharCode:
        _keyTimer.reset(); // reset to stop any already-started timer run
        delegateKeyEventToAxis('handleKeyDown', event); // act on the keystroke
        _keyTimer.start(); // start timer run to call prepareData() after delay
        break;
      default:
        break;
      }
    }
    
    public function onKeyUp(event:KeyboardEvent):void {
    	if (!event.shiftKey && _toolbar != null) _toolbar.resetZoomIcon();
    }
	
	
    public function paint():void {
      var i:int;
      var j:int;

      _divSprite.graphics.clear();
      if (_border.left > 0) {
        _divSprite.graphics.lineStyle(_border.left,0,1);
		_divSprite.graphics.drawRect(_windowMargin.left, _windowMargin.bottom,
			_graphWidth - _windowMargin.left - _windowMargin.right,
			_graphHeight - _windowMargin.bottom - _windowMargin.top);
      }
	  
	  /*
	  if (this.backgroundBitmap != null) {
		var matrix:Matrix = new Matrix();
		//matrix.scale(1,-1);
		_divSprite.graphics.beginBitmapFill(this.backgroundBitmap, null, false, false);
		_divSprite.graphics.drawRect(50, _windowMargin.bottom, 100, 100);
	  	_divSprite.graphics.endFill();
	  }
      */
	  
      var statusLists:Array = [];
      if (_networkDots) {
        for (i=0; i<_data.length; ++i) {
          statusLists[i] = _data[i].getStatus();
        }
      }
   
      // clear out the axis sprites
      _axisSprite1.graphics.clear();
      while (_axisSprite1.numChildren) { _axisSprite1.removeChildAt(0); }

      _axisSprite2.graphics.clear();
      while (_axisSprite2.numChildren) { _axisSprite2.removeChildAt(0); }

      // clear out the plotBox sprite
      _plotBoxSprite.graphics.clear();
      while (_plotBoxSprite.numChildren) { _plotBoxSprite.removeChildAt(0); }

      // draw the plotbox border, if any, in the padding box, so that its full linewidth shows up (if we draw
      // it in the plotbox, it gets clipped to the plotbox)
      if (_plotareaBorder > 0) {
        _axisSprite2.graphics.lineStyle(_plotareaBorder, _plotareaBorderColor, 1);
        _axisSprite2.graphics.drawRect(0, 0, _plotBox.width, _plotBox.height);
      }

      // render the axes' grid lines (axis render "step 0")
      for (i=0; i<_haxes.length; ++i) {
        _haxes[i].render(_axisSprite1, 0);
      }
      for (i=0; i<_vaxes.length; ++i) {
        _vaxes[i].render(_axisSprite1, 0);
      }

     
      // render the plots
      for (i=0; i<_plots.length; ++i) {
        _plots[i].render(_plotBoxSprite);
      }
      
      // render the axes themselves: (axis render "step 1")
      for (i=0; i<_haxes.length; ++i) {
        _haxes[i].render(_axisSprite2, 1);
      }
      for (i=0; i<_vaxes.length; ++i) {
        _vaxes[i].render(_axisSprite2, 1);
      }

      // render the legend
      if (_legend!=null) {
        _legend.render(_paddingBoxSprite, _plotBoxSprite);
      }

      // render the title
      if (_title!=null) {
        _title.render(_paddingBoxSprite, _plotBoxSprite);
      }
      
      // render the toolbar
      if (_toolbar != null) {
      	_toolbar.render(_axisControlSprite, _plotBoxSprite);
      }

      if (_networkDots) {
        var n:int;
        n = 0;
        var g:Graphics = _divSprite.graphics;
        for (i=0; i<statusLists.length; ++i) {
          for (j=0; j<statusLists[i].length; ++j) {
            if (statusLists[i][j] == Data.STATUS_CSV_WAITING) {
              // draw a little rectangle
              ++n;
              g.beginFill(_statusIconColor, 1);
              g.lineStyle(0, _statusIconColor, 1);
              g.drawRect(_statusIconSpacing*n,_statusIconVerticalOffset,_statusIconWidth,_statusIconHeight);
              g.endFill();
            } else if (statusLists[i][j] == Data.STATUS_WEB_WAITING) {
              // draw a little circle
              ++n;
              g.beginFill(_statusIconColor, 1);
              g.lineStyle(0, _statusIconColor, 1);
              g.drawCircle(_statusIconSpacing*n, _statusIconVerticalOffset+_statusIconHeight/2.0,
                           _statusIconWidth/2.0);
              g.endFill();
            } else if (statusLists[i][j] == Data.STATUS_COMPLETE) {
              // draw a little circle
              ++n;
              g.beginFill(0x00ff00, 1);
              g.lineStyle(0, 0x00ff00, 1);
              g.drawCircle(_statusIconSpacing*n, _statusIconVerticalOffset+_statusIconHeight/2.0,
                           _statusIconWidth/2.0);
              g.endFill();
            } else {
              // draw a little circle
              ++n;
              g.beginFill(0xff0000, 1);
              g.lineStyle(0, 0xff0000, 1);
              g.drawCircle(_statusIconSpacing*n, _statusIconVerticalOffset+_statusIconHeight/2.0,
                           _statusIconWidth/2.0);
              g.endFill();
            }
          }
        }
      }
      
    }
    private var _statusIconColor:uint            = 0x0000ff;
    private var _statusIconSpacing:Number        = 10;
    private var _statusIconVerticalOffset:Number = 5;
    private var _statusIconHeight:Number         = 7;
    private var _statusIconWidth:Number          = 7;

    /**
     * Do whatever prep work is needed to make sure that each plot is
     * ready for plotting all data along its current horizontal axis
     * extent.
     */
    public function prepareData(propagate:Boolean=true):void {
      for (i=0; i<_data.length; ++i) {
        _data[i].prepareDataReset();
      }    
      for (var i=0; i<_plots.length; ++i) {
        _plots[i].prepareData();
      }
      _paintNeeded = true;
    }
            
    public function drawBox(g:Graphics, x:Number, y:Number, w:Number, h:Number):void {
      g.moveTo(x-w/2, y-h/2);
      g.lineTo(x+w/2, y-h/2);
      g.lineTo(x+w/2, y+h/2);
      g.lineTo(x-w/2, y+h/2);
      g.lineTo(x-w/2, y-h/2);
      g.lineTo(x+w/2, y+h/2);
      g.moveTo(x-w/2, y+h/2);
      g.lineTo(x+w/2, y-h/2);
    }

    public function drawGrid(g:Graphics, cx:Number, cy:Number, gridSize:Number, halfWidth:Number):void {
      var x = cx - halfWidth*gridSize;
      for (var i=0; i<2*halfWidth+1; ++i) {
        g.moveTo(x, cy - halfWidth*gridSize);
        g.lineTo(x, cy + halfWidth*gridSize);
        x += gridSize;
      }
      var y = cy - halfWidth*gridSize;
      for (var i=0; i<2*halfWidth+1; ++i) {
        g.moveTo(cx - halfWidth*gridSize, y);
        g.lineTo(cx + halfWidth*gridSize, y);
        y += gridSize;
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
    
    /*
    import mx.graphics.codec.PNGEncoder;
    import mx.utils.Base64Encoder;
    import flash.display.BitmapData;
            
    public function takeSnapshot():void {
    	var bitmapData:BitmapData = new BitmapData(this._graphWidth, this._graphHeight, true, 0xffffff);
        bitmapData.draw(this);

		var pngCoder:PNGEncoder = new PNGEncoder();
                
        var bytes:ByteArray = pngCoder.encode(bitmapData);
            
        //var b64encoder:Base64Encoder = new Base64Encoder();
        //b64encoder.encodeBytes(bytes);

		var imageSnap:ImageSnapshot = new ImageSnapshot(this._graphWidth, this._graphHeight, bytes);
		var file:FileReference = new FileReference();
		file.save(imageSnap.data, "file.png");
    }
    */
  }
}
