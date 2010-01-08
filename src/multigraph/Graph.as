/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.events.*;
  import flash.geom.Matrix;
  import flash.net.*;
  import flash.utils.*;
  
  import multigraph.data.*;
  import multigraph.debug.DebugWindow;
  import multigraph.debug.Debugger;
  import multigraph.debug.NetworkMonitor;
  import multigraph.format.*;
  import multigraph.renderer.*;
  
  import mx.controls.*;
  import mx.core.UIComponent;
  import mx.graphics.ImageSnapshot;
  import mx.managers.CursorManager;
  import mx.managers.PopUpManager;
    
  /*
    import mx.containers.Panel;
    import mx.core.Application;
  */

  //[Embed(source="../../fonts/TIMES.TTF", fontName="DefaultFont", mimeType="application/x-font-truetype")]
  
  
  public class Graph extends UIComponent
  {
    private var _windowMargin : Insets;
    private var _border       : Insets;
    private var _padding      : Insets;
    private var _plotMargin   : Insets;
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

    private var _divSprite:MultigraphUIComponent;
    private var _eventSprite:MultigraphUIComponent;
    private var _axisControlSprite:MultigraphUIComponent;
    private var _paddingBoxSprite:MultigraphUIComponent;
    private var _plotBoxSprite:MultigraphUIComponent;
    private var _axisSprite:MultigraphUIComponent;

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
    public function get port():String { return _port; }

    // icon asset
    [Embed(source="assets/plus.PNG")]
      [Bindable]
      private var plusIcon:Class;
    
    [Embed(source="assets/minus.PNG")]
      [Bindable]
      private var minusIcon:Class;
      
    // Mouse cursor assets
    [Embed(source="assets/cursors/grab.png")]
      [Bindable]
      private var mouseCursorGrab:Class;

    [Embed(source="assets/cursors/grabbing.png")]
      [Bindable]
      private var mouseCursorGrabbing:Class;

    
    public function displayMessage(msg:String):void {
      //_app.displayMessage(msg);
    }

    public function Graph(xml:XML, swfname:String, hostname:String, pathname:String, port:String, width:int=-1, height:int=-1) {
      this._xml = xml;
      this._swfname  = swfname;
      this._hostname = hostname; 
      this._pathname = pathname; 
      this._port= port; 
      init_wrapper(width, height);

    }       

    private function init_wrapper(width:int, height:int):void {
      _graphWidth  = width;
      _graphHeight = height;

      init();
      
      addChild(_divSprite);
      addChild(_eventSprite);  
      addChild(_axisControlSprite);
      
      addEventListener(Event.ENTER_FRAME, doEveryFrame);
      prepareData();
      _paintNeeded = true;
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

    private function init():void {
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

      _axisSprite = new MultigraphUIComponent();
      _axisSprite.x = _plotMargin.left;
      _axisSprite.y = _plotMargin.bottom;
      
      _paddingBoxSprite.addChild(_axisSprite);

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
          _data[j] = new CSVFileArrayData( vars, url, this );

        } else if (_config.value('data', j, 'service') != null) {
          // The <data> section contains a <service> element, so the data is to be fetched
          // from a web service.  Use a Multigraph.WebServiceData object.
          vars = buildDataVariableArrayFromConfig(j);
          var url:String = _config.value('data', j, 'service','@location');
          diagnosticOutput('creating a web service data object with service location "'+url+'"');
          _data[j] = new WebServiceData( url, vars, this );
        } else {
          trace("unknown data section type!");
        }
        
      }
      
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
        // set the horizontal axis to the graph's one horizontal axis
        var haxis:Axis = _haxes[0];

        // set the plot's vertical axis to the one specified in the xml file (<plot><verticalaxis ref="...">),
        // if any, or default to the first vertical axis if none is specified
        var vaxis:Axis = Axis.getInstanceById( _config.xmlvalue('plot', i, 'verticalaxis', '@ref') );
        if (vaxis == null) {
          vaxis = _vaxes[0];
        }
         
        var type:String = _config.value('plot', i, 'renderer', '@type');
        var rendererType:Object = Renderer.getRenderer(type);
        // create the renderer object
        var renderer:Renderer = new rendererType(haxis, vaxis);

        // set any renderer options
        if (_config.value('plot', i, 'renderer', 'option') != null) {
          var noptions:int = _config.value('plot', i, 'renderer', 'option').length();
          for (var j:int=0; j<noptions; ++j) {
            var name:String = _config.value('plot', i, 'renderer', 'option', j, '@name');
            var value:String = _config.value('plot', i, 'renderer', 'option', j, '@value')  
              renderer[name] = value;
          }
        }

        var plotIsConstant:Boolean = false;
        var constantValue:Number;
        var data:Data;
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
          if (!haxis.haveDataMin || !haxis.haveDataMax) {
            var bounds:Array = data.getBounds(hvarid);
            if (!haxis.haveDataMin) {
              haxis.dataMin = bounds[0];
            }
            if (!haxis.haveDataMax) {
              haxis.dataMax = bounds[1];
            }
          }
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

          if (!vaxis.haveDataMin || !vaxis.haveDataMax) {
            var bounds:Array = data.getBounds(vvarid);
            if (!vaxis.haveDataMin) {
              vaxis.dataMin = bounds[0];
            }
            if (!vaxis.haveDataMax) {
              vaxis.dataMax = bounds[1];
            }
          }

        }
        
        // Determine this plot's legend label
        var legendLabel:String;

        var legendLabel:String = _config.value('plot', i, 'legend', '@label');
        if (legendLabel==null || legendLabel=="") {
          legendLabel = vvarid;
        }
        if (_config.value('plot', i, 'legend', '@visible')=="false") {
          legendLabel = null;
        }
        
        // finally, create the plot object
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
        
        // and add it to our list
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
      var legendBgColor:uint     = _config.value('legend', 0, '@color');
      var legendBorderColor:uint = _config.value('legend', 0, '@bordercolor');
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
      var titleBgColor:uint     = _config.value('title', 0, '@color');
      var titleBorderColor:uint = _config.value('title', 0, '@bordercolor');
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
        var position:Number = _config.value(axistag, i, '@position');
        var positionbase:String = _config.value(axistag, i, '@positionbase');
        if (positionbase == 'right') {
          position = _plotBox.width + position;
        } else if (positionbase == 'top') {
          position = _plotBox.height + position;
        }
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
        var minoffset:String = _config.value(axistag, i, '@minoffset');
        var max:String       = _config.value(axistag, i, '@max');
        var maxoffset:String = _config.value(axistag, i, '@maxoffset');
        var pregap:Number = _config.value(axistag,i,'@pregap');
        var postgap:Number = _config.value(axistag,i,'@postgap');

        var title:String  = _config.xmlvalue(axistag,i,'title');
        var titlePosition:PixelPoint = PixelPoint.parse(_config.value(axistag,i,'title','@position'));
        var titleAnchor:PixelPoint = PixelPoint.parse(_config.value(axistag,i,'title','@anchor'));
        var titleAngle:Number = parseFloat(_config.value(axistag,i,'title','@angle'));

        var labelPosition:PixelPoint;
        var labelAnchor:PixelPoint;

        var grid:Boolean = (_config.xmlvalue(axistag,i,'grid') != null);
        var gridColorString:String = _config.value(axistag,i,'grid','@color');
        var gridColor:uint = uint(gridColorString);

        axes[i] = new axisType(id,
                               this,
                               ((axisType == HorizontalAxis) ? _plotBox.width : _plotBox.height) - pregap - postgap,
                               pregap,
                               position,
                               type,
                               0x000000,
                               min,
                               minoffset,
                               max,
                               maxoffset,
                               title,
                               titlePosition.x,
                               titlePosition.y,
                               titleAnchor.x,
                               titleAnchor.y,
                               titleAngle,
                               grid,
                               gridColor
                               );

        axes[i].panConfig.setConfig(_config.value(axistag, i, 'pan', '@allowed'),
                                    _config.value(axistag, i, 'pan', '@min'),
                                    _config.value(axistag, i, 'pan', '@max'))
                                       
          axes[i].zoomConfig.setConfig(_config.value(axistag, i, 'zoom', '@allowed'),
                                       _config.value(axistag, i, 'zoom', '@anchor'));
                                       
        // Setup the axis controls
        var axisControlsVisible:String = _config.value(axistag, i, 'axiscontrols', '@visible');
        if(axisControlsVisible == "true") {
          axes[i].hasAxisControls = true;
          axes[i].axisControl = new AxisControls(_axisControlSprite, axes[i], _config);
        }
                                               
        labelPosition  = PixelPoint.parse(_config.value(axistag, i, 'labels', '@position'));
        labelAnchor = PixelPoint.parse(_config.value(axistag, i, 'labels', '@anchor'));
        var labeler:Labeler;
        
        var labelerType:Object = (type == Axis.TYPE_DATETIME) ? DateLabeler : NumberLabeler;
        
        var spacingAndUnit:NumberAndUnit;
        if(_config.xmlvalue(axistag, i, 'labels', '@label') != null) {
          var nlabelers:int = _config.xmlvalue(axistag, i, 'labels','@label').length();
          for(var k:int = 0; k < nlabelers; ++k) {
            spacingAndUnit = NumberAndUnit.parse(_config.value(axistag, i, 'labels', 'label', k, '@spacing'));
            //var spacingAndUnit:Array = parseSpacingAndUnit();
            labeler = new labelerType(spacingAndUnit.number,
                                      spacingAndUnit.unit,
                                      _config.value(axistag, i, 'labels', 'label', k, '@format'),
                                      _config.value(axistag, i, 'labels', '@start'),
                                      labelPosition.x,
                                      labelPosition.y,
                                      _config.value(axistag, i, 'labels', '@angle'),
                                      labelAnchor.x, 
                                      labelAnchor.y);
            axes[i].addLabeler(labeler);
          } 
        } else {
          var hlabelSpacings:Array = _config.value(axistag, i, 'labels', '@spacing').split(" ");
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
                                      labelAnchor.y);
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
          vars.push(new DataVariable(id,
                                     int(col),
                                     Axis.parseType(_config.value('data', dataSection, 'variables', 'variable', i, '@type'))));
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
      	if (event.localX > _axisSprite.x && event.localX < _plotBox.width + _plotMargin.left) {
      		if (event.localY > _axisSprite.y && event.localY < _plotBox.height + _plotMargin.bottom) {
            	this.cursorManager.setCursor(mouseCursorGrabbing);
      		} 
      	}
      }
    }
        
    public function onMouseUp(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseUp', event);
      
      if (_toolbarState != "zoom") {
      	this.cursorManager.removeAllCursors();
      	if (event.localX > _axisSprite.x && event.localX < _plotBox.width + _plotMargin.left) {
      		if (event.localY > _axisSprite.y && event.localY < _plotBox.height + _plotMargin.bottom) {
            	this.cursorManager.setCursor(mouseCursorGrab);
      		} 
      	}
      } 
    }

    public function onMouseMove(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseMove', event);
     
      if (!event.buttonDown && _toolbarState != "zoom") {
      	this.cursorManager.removeAllCursors();
      	if (event.localX > _axisSprite.x && event.localX < _plotBox.width + _plotMargin.left) {
          if (event.localY > _axisSprite.y && event.localY < _plotBox.height + _plotMargin.bottom) {
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



      var statusLists:Array = [];
      if (_networkDots) {
        for (i=0; i<_data.length; ++i) {
          statusLists[i] = _data[i].getStatus();
        }
      }
   
      // clear out the axis sprite
      _axisSprite.graphics.clear();
      while (_axisSprite.numChildren) { _axisSprite.removeChildAt(0); }
      
      // render the axes
      for (i=0; i<_haxes.length; ++i) {
        _haxes[i].render(_axisSprite);
      }
      for (i=0; i<_vaxes.length; ++i) {
        _vaxes[i].render(_axisSprite);
      }
      
      // clear out the plotBox sprite
      _plotBoxSprite.graphics.clear();
      
      // don't need this yet, but might in the future:
      //while (_plotBoxSprite.numChildren) { _plotBoxSprite.removeChildAt(0); }
      while (_plotBoxSprite.numChildren) { _plotBoxSprite.removeChildAt(0); }
      
      // render the plots
      for (i=0; i<_plots.length; ++i) {
        _plots[i].render(_plotBoxSprite);
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
