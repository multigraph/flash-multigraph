package multigraph.naui
{
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import multigraph.Axis;
  import multigraph.AxisController;
  import multigraph.AxisControls;
  import multigraph.Graph;
  import multigraph.PixelPoint;

  public class NearestAxisUIAxisController extends AxisController
  {
	private var _nearestAxisUIEventHandler:NearestAxisUIEventHandler = null;
    private var _graph : Graph = null;
        
    public function NearestAxisUIAxisController(nearestAxisUIEventHandler:NearestAxisUIEventHandler, graph:Graph, axis:Axis)
    {
      super(axis);
      this._graph = graph;
	  this._nearestAxisUIEventHandler = nearestAxisUIEventHandler;
    }

  }
        
}
