package multigraph
{

  import multigraph.format.Formatter;
  
  import mx.utils.StringUtil;

  public class DataTipFormatter
  {
    private var _masterFormatString:String;
    private var _formatters:Array;
    private var _indices:Array;
	public var bgcolor:uint;
	public var bgalpha:Number;
	public var border:Number;
	public var pad:Number;
	public var bordercolor:uint;
	public var fontcolor:uint;
	public var fontsize:int;
	public var bold:Object;

    public function DataTipFormatter(masterFormatString:String) {
      _masterFormatString = masterFormatString;
      _formatters = [];
      _indices = [];
    }

    public function addFormatter(formatter:Formatter, index:int):void {
      _formatters.push(formatter);
      _indices.push(index);
    }

    public function format(values:Array):String {
      var args:Array = [ _masterFormatString ];
      for (var i:int=0; i<_formatters.length; ++i) {
        args.push( _formatters[i].format(values[i]));
      }
      return StringUtil.substitute.apply(this, args);
    }

  }

}
