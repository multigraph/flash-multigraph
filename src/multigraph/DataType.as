package multigraph
{
  public final class DataType
  {
    public static const NUMBER:DataType   = new DataType("number");
    public static const DATETIME:DataType = new DataType("datetime");
    public static const UNKNOWN:DataType  = new DataType("unknown");

    private var _stringValue:String;

    public function DataType(stringValue : String) {
      this._stringValue = stringValue;
    }

    public function toString() : String {
      return _stringValue;
    }

    public static function parse(string : String) : DataType {
      switch (string) {
      case "number":
        return DataType.NUMBER;
      case "datetime":
        return DataType.DATETIME;
      default:
        return DataType.UNKNOWN;
      }
    }

  }
}
