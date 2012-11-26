package multigraph
{
  import flash.events.Event;

  public class MultigraphEvent extends Event
  {
    public static const PARSE_MUGL:String       = "parseMugl";
	public static const PARSE_MUGL_ERROR:String = "parseMuglError";
	public static const MUGL_IO_ERROR:String    = "muglIOError";
	public static const MUGL_ERROR:String       = "muglError";
	
	public var message : String = null;
	public var httpStatus:int = -1;

    public function MultigraphEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
    }
  }
}
