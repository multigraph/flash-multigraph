package multigraph
{

  public class AxisController
  {

    protected var _axis  : Axis  = null;
	
	public function get axis():Axis { return _axis; }

    public function AxisController(axis:Axis) {
      this._axis  = axis;
      axis.controller = this;
    }

    public function useBoldLabels():Boolean {
      return false;
    }

    public function useBoldAxis():Boolean {
      return false;
    }

  }
        
}
