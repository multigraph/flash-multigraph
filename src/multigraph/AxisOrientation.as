package multigraph
{
  public final class AxisOrientation
  {
    public static const HORIZONTAL:AxisOrientation = new AxisOrientation("horizontal");
    public static const VERTICAL:AxisOrientation   = new AxisOrientation("vertical");
    public static const UNKNOWN:AxisOrientation    = new AxisOrientation("unknown");

    private var _stringValue:String;

    public function AxisOrientation(stringValue : String) {
      this._stringValue = stringValue;
    }

    public function toString() : String {
      return _stringValue;
    }
	
	public function get orthogonal() : AxisOrientation {
		switch (_stringValue) {
			case "horizontal":
				return AxisOrientation.VERTICAL;
			case "vertical":
				return AxisOrientation.HORIZONTAL;
			default:
				return AxisOrientation.UNKNOWN;
		}
	} 

    public static function parse(string : String) : AxisOrientation {
		switch (string) {
			case "horizontal":
				return AxisOrientation.HORIZONTAL;
			case "vertical":
				return AxisOrientation.VERTICAL;
			default:
				return AxisOrientation.UNKNOWN;
		}
    }

  }
}
