package multigraph.naui
{
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import multigraph.Axis;
  import multigraph.AxisOrientation;
  import multigraph.Graph;
  import multigraph.DPoint;
  import multigraph.UIEventHandler;

  public class NearestAxisUIEventHandler extends UIEventHandler
  {
    private var _axes : Array = [];
	private var _mouseLocation : DPoint = new DPoint(0,0);
	private var _mouseDragBase : DPoint = new DPoint(0,0);

    private var _mouseIsDown : Boolean = false;
    private var _dragStarted : Boolean = false;

    private var _dragOrientation : AxisOrientation = AxisOrientation.HORIZONTAL;

    private var _targetAxis : Axis = null;

	public function NearestAxisUIEventHandler(graph:Graph)
    {
      super(graph);
      for each ( var axis : Axis in _graph.axes ) {
        _axes.push(axis);
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
      var prevLocation:DPoint = _mouseLocation;
      _mouseLocation = _graph.plotXY(event.localX, event.localY);
      var dx:int = _mouseLocation.x - prevLocation.x;
      var dy:int = _mouseLocation.y - prevLocation.y;
      if (_mouseIsDown) {
        if (!_dragStarted) {
          if (Math.abs(dx) > Math.abs(dy)) {
            _dragOrientation = AxisOrientation.HORIZONTAL;
          } else {
            _dragOrientation = AxisOrientation.VERTICAL;
          }
		  _targetAxis = findNearestAxis(_mouseLocation.x, _mouseLocation.y, _dragOrientation, event);
		  if (_targetAxis == null) {
			  _dragOrientation = _dragOrientation.orthogonal
			  _targetAxis = findNearestAxis(_mouseLocation.x, _mouseLocation.y, _dragOrientation, event);
		  }
          //trace('starting ' + _dragOrientation + ' mouse drag by ' + dx + ', ' + dy);
        } else {
          //trace('continuing ' + _dragOrientation + ' mouse drag by ' + dx + ', ' + dy);
        }
        handleMouseDrag(_targetAxis, dx, dy, event);
        _dragStarted = true;
      } else {
		  _graph.showTips(_mouseLocation);
        //trace('mouse move at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      }
      //delegateMouseEventToAxis('handleMouseMove', event);
    }

    private function findNearestAxis(x:Number, y:Number, orientation:AxisOrientation, event:MouseEvent):Axis {
      var foundAxis:Axis = null;
      var mindist:Number = 9999;
      for each (var axis : Axis in _axes ) {
        if ( (axis.orientation == orientation)
			&& ( (axis.panConfig.allowed && !event.shiftKey) || (axis.zoomConfig.allowed && event.shiftKey) ) ) {
          var d:Number = axisDistanceToPoint(axis, x, y);
          if (foundAxis==null || d < mindist) {
            foundAxis = axis;
            mindist = d;
          }
        }
      }
      return foundAxis;
    }

    private function axisDistanceToPoint(axis:Axis, x:Number, y:Number):Number {
      var perpCoord:Number     = axis.orientation==AxisOrientation.HORIZONTAL ? y : x;
      var parallelCoord:Number = axis.orientation==AxisOrientation.HORIZONTAL ? x : y;
      if (parallelCoord < axis.parallelOffset) {
        return l2dist(parallelCoord, perpCoord, axis.parallelOffset, axis.perpOffset);
      }
      if (parallelCoord > axis.parallelOffset + axis.pixelLength) {
        return l2dist(parallelCoord, perpCoord, axis.parallelOffset+axis.pixelLength, axis.perpOffset);
      }
      return Math.abs(perpCoord - axis.perpOffset);
    }

    private function l2dist(x1:Number, y1:Number, x2:Number, y2:Number):Number {
      var dx:Number = x1 - x2;
      var dy:Number = y1 - y2;
      return Math.sqrt(dx*dx + dy*dy);
    }

    private function handleMouseDrag(axis:Axis, dx:Number, dy:Number, event:MouseEvent):void {
      if (axis.orientation == AxisOrientation.HORIZONTAL) {
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
	  _graph.hideTips();
      //trace('mouse out at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseOut', event);
    }
        
  }
}
