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
    private var _axisControllers : Array = [];
	private var _mouseLocation : PixelPoint = null;	

	public function NearestAxisUIEventHandler(graph:Graph)
    {
      super(graph);
      for (var i:int=0; i<_graph.axes.length; ++i) {
        _axisControllers.push(new NearestAxisUIAxisController(this, _graph, _graph.axes[i]));
      }
    }
        
    public function onMouseDown(event:MouseEvent):void {
      _graph.stage.focus = _graph;
	  _mouseLocation = _graph.plotXY(event.localX, event.localY);
	  trace('mouse down at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
    }
        
    public function onMouseUp(event:MouseEvent):void {
		_mouseLocation = _graph.plotXY(event.localX, event.localY);
		trace('mouse up at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseUp', event);
    }
        
    public function onMouseMove(event:MouseEvent):void {
		_mouseLocation = _graph.plotXY(event.localX, event.localY);
		trace('mouse move at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseMove', event);
    }
        
    public function onMouseOut(event:MouseEvent):void {
		_mouseLocation = _graph.plotXY(event.localX, event.localY);
		trace('mouse out at ' + _mouseLocation.x + ', ' + _mouseLocation.y);
      //delegateMouseEventToAxis('handleMouseOut', event);
    }
        
  }
}
