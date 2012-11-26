package multigraph.saui
{
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import multigraph.Axis;
  import multigraph.AxisController;
  import multigraph.Graph;
  import multigraph.PixelPoint;

  public class SelectedAxisUIAxisController extends AxisController
  {

    public static var HIGHLIGHT_AXIS:int = 1;
    public static var HIGHLIGHT_LABELS:int = 2;
    public static var HIGHLIGHT_ALL:int = 3;

    private var _highlightStyle:int;
    public function get highlightStyle():int { return _highlightStyle; }
	
	private var _selectedAxisUIEventHandler:SelectedAxisUIEventHandler = null;

    private var _graph : Graph = null;
    private var _mouseDragBase:PixelPoint = null;
    private var _mouseLast:PixelPoint = null;
    private var _pixelSelectionDistance:int = 30;
        
    private var _selected:Boolean = false;
    public function get selected():Boolean { return _selected; }
    public function set selected(v:Boolean):void { _selected = v; }

    public function SelectedAxisUIAxisController(selectedAxisUIEventHandler:SelectedAxisUIEventHandler, graph:Graph, axis:Axis)
    {
      super(axis);
      this._graph = graph;
	  this._selectedAxisUIEventHandler = selectedAxisUIEventHandler;
      this._highlightStyle = (int)(axis.clientData);
    }
/*    
	private var _axisControl:AxisControls = null;
	public function get axisControl():AxisControls { return _axisControl; }
	public function set axisControl(controls:AxisControls):void { _axisControl = controls; }
	private var _hasAxisControls:Boolean = false;
	public function get hasAxisControls():Boolean { return _hasAxisControls; }
	public function set hasAxisControls(condition:Boolean):void { _hasAxisControls = condition; } 
*/
	
    public function handleMouseDown(p:PixelPoint, event:MouseEvent):Boolean {
      //if(axisControl != null) axisControl.destroyAllControls();
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
        if (_axis.orientation == Axis.ORIENTATION_VERTICAL) {
          d = p.x - _axis.perpOffset;
          e = p.y - _axis.parallelOffset;
        } else {
          d = p.y - _axis.perpOffset;
          e = p.x - _axis.parallelOffset;
        }
        if (
            ((e >= 0) && (e <= _axis.length))
            &&
            (((d >= 0) && (d < _pixelSelectionDistance)) || ((d < 0) && (d > -_pixelSelectionDistance)))
            ) {
		  //if (_graph != null) { (SelectedAxisUIEventHandler)(_graph.uiEventHandler).selectAxis(this); }
		  if (_graph != null) { _selectedAxisUIEventHandler.selectAxis(this); }
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
      if (_axis.orientation == Axis.ORIENTATION_HORIZONTAL) {
        if (event.shiftKey /*|| _graph.toolbarState == "zoom"*/ ) {
          if (_axis.zoomConfig.allowed) { _axis.zoom(_mouseDragBase.x, dx); }
        } else {
          if (_axis.panConfig.allowed) {
            _axis.pan(-dx);
          } else {
            //zoom(_mouseDragBase.x, dx);
          }
        }
      } else {
        if (event.shiftKey /*|| _graph.toolbarState == "zoom"*/) {
          if (_axis.zoomConfig.allowed) { _axis.zoom(_mouseDragBase.y, dy); }
        } else {
          if (_axis.panConfig.allowed) {
            _axis.pan(-dy);
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
        if (_axis.orientation == Axis.ORIENTATION_HORIZONTAL) {
          _axis.zoom(p.x, -pixAmount);
        } else {
          _axis.zoom(p.y, -pixAmount);
        }
        break;
      case _zCharCode:
      case _ZCharCode:
      case _plusCharCode:
        if (_axis.orientation == Axis.ORIENTATION_HORIZONTAL) {
          _axis.zoom(p.x, pixAmount);
        } else {
          _axis.zoom(p.y, pixAmount);
        }
        break;

      case _lessCharCode:
          _axis.pan(5*pixAmount);
          break;

      case _greaterCharCode:
          _axis.pan(-5*pixAmount);
          break;
        
      // TODO: Should there be a way to pan by holding a key?
      case _qCharCode:
      case _QCharCode:
      	if (_axis.orientation == Axis.ORIENTATION_HORIZONTAL) {
      		_axis.pan(10);
      	} else {
      		_axis.pan(10);
      	}
      	break;
      }
    }

    override public function useBoldLabels():Boolean {
      return (this.selected && (_highlightStyle==HIGHLIGHT_LABELS || _highlightStyle==HIGHLIGHT_ALL));
    }

    override public function useBoldAxis():Boolean {
      return (this.selected && (_highlightStyle==HIGHLIGHT_AXIS || _highlightStyle==HIGHLIGHT_ALL));
    }

  }
        
}
