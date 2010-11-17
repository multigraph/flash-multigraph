package multigraph.naui
{
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import multigraph.Axis;
  import multigraph.Graph;
  import multigraph.PixelPoint;
  import multigraph.UIEventHandler;

  public class NearestAxisUIEventHandler extends UIEventHandler
  {
    private var _axes : Array = [];
	private var _mouseLocation : PixelPoint = new PixelPoint(0,0);
	private var _mouseDragBase : PixelPoint = new PixelPoint(0,0);

    private var _mouseIsDown : Boolean = false;
    private var _dragStarted : Boolean = false;

    private var _dragOrientation : int = 0;

    private var _targetAxis : Axis = null;

    private function dirString():String {
      if (_dragOrientation == Axis.ORIENTATION_HORIZONTAL) {
        return "HORIZONTAL";
      } else {
        return "VERTICAL";
      }
    }

	public function NearestAxisUIEventHandler(graph:Graph)
    {
      super(graph);
      for (var i:int=0; i<_graph.axes.length; ++i) {
        _axes.push(_graph.axes[i]);
      }
    }
        
    public function onMouseDown(event:MouseEvent):void {
      _graph.stage.focus = _graph;
      _mouseIsDown = true;
      _dragStarted = false;
	  _mouseLocation = _graph.plotXY(event.localX, event.localY);
      _mouseDragBase = _mouseLocation;
	  //trace('mouse down at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
    }
        
    public function onMouseUp(event:MouseEvent):void {
      _mouseLocation = _graph.plotXY(event.localX, event.localY);
      _mouseIsDown = false;
      _graph.prepareData();
      //trace('mouse up at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseUp', event);
    }
        
    public function onMouseMove(event:MouseEvent):void {
      var prevLocation:PixelPoint = _mouseLocation;
      _mouseLocation = _graph.plotXY(event.localX, event.localY);
      var dx:int = _mouseLocation.x - prevLocation.x;
      var dy:int = _mouseLocation.y - prevLocation.y;
      if (_mouseIsDown) {
        if (!_dragStarted) {
          if (Math.abs(dx) > Math.abs(dy)) {
            _dragOrientation = Axis.ORIENTATION_HORIZONTAL;
          } else {
            _dragOrientation = Axis.ORIENTATION_VERTICAL;
          }
          _targetAxis = findNearestAxis(_mouseLocation.x, _mouseLocation.y, _dragOrientation);
          //trace('starting ' + dirString() + ' mouse drag by ' + dx + ', ' + dy);
        } else {
          //trace('continuing ' + dirString() + ' mouse drag by ' + dx + ', ' + dy);
        }
        handleMouseDrag(_targetAxis, dx, dy, event);
        _dragStarted = true;
      } else {
        //trace('mouse move at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      }
      //delegateMouseEventToAxis('handleMouseMove', event);
    }

    private function findNearestAxis(x:Number, y:Number, orientation:int):Axis {
      var axis:Axis = null;
      var mindist:Number = 9999;
      for (var i:int = 0; i<_axes.length; ++i) {
        if (_axes[i].orientation == orientation) {
          var d:Number = axisDistanceToPoint(_axes[i], x, y);
          if (axis==null || d < mindist) {
            axis = _axes[i];
            mindist = d;
          }
        }
      }
      return axis;
    }

    private function axisDistanceToPoint(axis:Axis, x:Number, y:Number):Number {
      var perpCoord:Number     = axis.orientation==Axis.ORIENTATION_HORIZONTAL ? y : x;
      var parallelCoord:Number = axis.orientation==Axis.ORIENTATION_HORIZONTAL ? x : y;
      if (parallelCoord < axis.parallelOffset) {
        return l2dist(parallelCoord, perpCoord, axis.parallelOffset, axis.perpOffset);
      }
      if (parallelCoord > axis.parallelOffset + axis.length) {
        return l2dist(parallelCoord, perpCoord, axis.parallelOffset+axis.length, axis.perpOffset);
      }
      return Math.abs(perpCoord - axis.perpOffset);
    }

    private function l2dist(x1:Number, y1:Number, x2:Number, y2:Number):Number {
      var dx:Number = x1 - x2;
      var dy:Number = y1 - y2;
      return Math.sqrt(dx*dx + dy*dy);
    }

    private function handleMouseDrag(axis:Axis, dx:Number, dy:Number, event:MouseEvent):void {
      if (axis.orientation == Axis.ORIENTATION_HORIZONTAL) {
        if (event.shiftKey /*|| _graph.toolbarState == "zoom"*/ ) {
          if (axis.zoomConfig.allowed) { axis.zoom(_mouseDragBase.x, dx); }
        } else {
          if (axis.panConfig.allowed) {
            axis.pan(-dx);
          } else {
            axis.zoom(_mouseDragBase.x, dx);
          }
        }
      } else {
        if (event.shiftKey /*|| _graph.toolbarState == "zoom"*/) {
          if (axis.zoomConfig.allowed) { axis.zoom(_mouseDragBase.y, dy); }
        } else {
          if (axis.panConfig.allowed) {
            axis.pan(-dy);
          } else {
            axis.zoom(_mouseDragBase.y, dy);
          }
        }
      }
    }
        
    public function onMouseOut(event:MouseEvent):void {
      _mouseLocation = _graph.plotXY(event.localX, event.localY);
      _mouseIsDown = false;
      //trace('mouse out at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseOut', event);
    }
        
  }
}
