package multigraph.saui
{
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import multigraph.Axis;
  import multigraph.Graph;
  import multigraph.PixelPoint;
  import multigraph.UIEventHandler;

  public class SelectedAxisUIEventHandler extends UIEventHandler
  {

    // Mouse cursor assets
    [Embed(source="../../assets/cursors/HandOpen.png")]
      [Bindable]
      private var mouseCursorGrab:Class;

    [Embed(source="../../assets/cursors/HandClosed.png")]
      [Bindable]
      private var mouseCursorGrabbing:Class;

    private var _axisControllers : Array = [];

    private var _selectedAxis : SelectedAxisUIAxisController = null;
        
    // Timer used to arrange for a call to prepareData() after user stops
    // zooming with keyboard shortcuts:
    private var _keyTimer    : Timer = null;
    // Delay, in milliseconds, before prepareData() should be called after
    // user stops zooming with keyboard shortcuts:
    private var _keyTimerDelay:int = 500;       
        
    private var _mouseLocation : PixelPoint = null;

        
    public function SelectedAxisUIEventHandler(graph:Graph)
    {
      super(graph);
      _keyTimer = new Timer(_keyTimerDelay, 1);
      _keyTimer.addEventListener("timer", keyTimerHandler);         

      for (var i:int=0; i<_graph.axes.length; ++i) {
        _axisControllers.push(new SelectedAxisUIAxisController(this, _graph, _graph.axes[i]));
      }
    }
        
    public function onMouseDown(event:MouseEvent):void {
      _graph.stage.focus = _graph;
      delegateMouseEventToAxis('handleMouseDown', event);
            
      //if (_toolbarState != "zoom") {
      _graph.cursorManager.removeAllCursors();
      if (_graph.inPlotBox(event.localX, event.localY)) {
        _graph.cursorManager.setCursor(mouseCursorGrabbing);
      }
      //}

    }
        
    public function onMouseUp(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseUp', event);

      //if (_toolbarState != "zoom") {
      _graph.cursorManager.removeAllCursors();
      if (_graph.inPlotBox(event.localX, event.localY)) {
        _graph.cursorManager.setCursor(mouseCursorGrab);
      }
      //}

    }
        
    public function onMouseMove(event:MouseEvent):void {
      delegateMouseEventToAxis('handleMouseMove', event);

      if (!event.buttonDown /*&& _toolbarState != "zoom"*/) {
        _graph.cursorManager.removeAllCursors();
        if (_graph.inPlotBox(event.localX, event.localY)) {
          if (event.buttonDown) {
            _graph.cursorManager.setCursor(mouseCursorGrabbing);
          } else  {
            _graph.cursorManager.setCursor(mouseCursorGrab);
          }
        }
        //        if (event.localX > _axisSprite1.x && event.localX < _plotBox.width + _plotMargin.left) {
        //          if (event.localY > _axisSprite1.y && event.localY < _plotBox.height + _plotMargin.bottom) {
        //            if (event.buttonDown)
        //              _graph.cursorManager.setCursor(mouseCursorGrabbing);
        //            else 
        //              _graph.cursorManager.setCursor(mouseCursorGrab);
        //          } else {
        //            _graph.cursorManager.removeAllCursors();
        //          }   
        //        } else {
        //          this.cursorManager.removeAllCursors();
        //        }   
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
      /*
        if (event.shiftKey && _toolbar != null) {
        _toolbar.updateZoomIcon();
        }
      */
            
      //trace('key down event: ' + event);
            
      if (event.charCode==0) {
                
        if (_selectedAxis != null && _selectedAxis.axis.orientation==Axis.ORIENTATION_VERTICAL) {
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
      /*
        if (!event.shiftKey && _toolbar != null) _toolbar.resetZoomIcon();
      */
    }
        
    public function selectAxis(selectedAxisUIAxisController:SelectedAxisUIAxisController):void {
      if (_selectedAxis == selectedAxisUIAxisController) { return; }
      if (_selectedAxis != null) {
        _selectedAxis.selected = false;
      }
      selectedAxisUIAxisController.selected = true;
      _selectedAxis = selectedAxisUIAxisController;
      //_graph.paintNeeded = true;
	  _graph.invalidateDisplayList();
    }
        
    public function delegateMouseEventToAxis(method:String, event:MouseEvent):void {     
      var i:int;
      _mouseLocation = _graph.plotXY(event.localX, event.localY);
      var done:Boolean = false;
      for (i=0; i<_axisControllers.length; ++i) {
        if (_axisControllers[i].selected) {
          if (_axisControllers[i][method](_mouseLocation, event)) {
            done = true;
          }
          break;
        }
      }
      if (!done) {
        for (i=0; i<_axisControllers.length; ++i) {
          if (!_axisControllers[i].selected) {
            if (_axisControllers[i][method](_mouseLocation, event)) {
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
        

        
    private function keyTimerHandler(event:TimerEvent):void {
      _graph.prepareData();
    }       
        
  }
}
