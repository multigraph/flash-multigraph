package multigraph
{
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  
  import mx.containers.Canvas;
  import mx.controls.Alert;
  import mx.controls.Label;
  import mx.core.Container;
  import mx.core.UIComponent;
  
  import spark.components.Group;
  	
  //
  // The Multigraph class extends Canvas rather than UIComponent
  // because it needs to be a Container in order for its child classes
  // to correctly work with percentWidth/percentHeight values.
  // Having it inherit from Container (the abstract parent class of Canvas)
  // causes it to check each of its children whenever it is resized to
  // see if their height or width are specified in terms of percentHeight
  // or percentWidth, and if so, to resize them accordingly.
  //
  // If it's a UIComponent, though (the parent class of Container, which is what
  // the rest of the Multigraph components (Graph and its children) are), then
  // percentage sizes don't work correctly.
  //
  /**
   * Dispatched when the data range for this axis changes, either as a
   * result of the user panning or zooming, or as a result of
   * setDataRange() or setDataRangeFromStrings() being called.
   *
   *  @eventType multigraph.AxisEvent.CHANGE
   */
  [Event(name="parseMugl",      type="multigraph.MultigraphEvent")]
  [Event(name="parseMuglError", type="multigraph.MultigraphEvent")]
  [Event(name="muglIOError",    type="multigraph.MultigraphEvent")]
  [Event(name="muglError",      type="multigraph.MultigraphEvent")]
  
  public class Multigraph extends Canvas
  {
    [Embed(mimeType='application/x-font', source="../assets/fonts/myriadweb.ttf",                         fontName="default")]
      private static var fontDefault:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/myriadwebbol.ttf",   fontWeight="bold", fontName="defaultBold")]
      private static var fontDefaultBold:Class;

	  /*
    [Embed(mimeType='application/x-font', source="../assets/fonts/TIMES.TTF",                             fontName="DefaultFont")]
	  private static var fontDefaultFont:Class;
	  
    [Embed(mimeType='application/x-font', source="../assets/fonts/myriadweb.ttf",                         fontName="myriad")]
      private static var fontMyriad:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/myriadwebbol.ttf",   fontWeight="bold", fontName="myriadBold")]
      private static var fontMyriadBold:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/ARIAL.TTF",                             fontName="arial")]
      private static var fontArial:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/ARIALBD.TTF",        fontWeight="bold", fontName="arialBold")]
      private static var fontArialBold:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/FreeSans.ttf",                          fontName="freesans")]
      private static var fontFreesans:Class;

    [Embed(mimeType='application/x-font', source="../assets/fonts/FreeSansBold.ttf",   fontWeight="bold", fontName="freesansBold")]
      private static var fontFreesansBold:Class;
    */


    private var _mugl:XML;
    private var _graphs : Array;
	public function get graphs() : Array { return _graphs; }
	private var _currentWidth : int;
	private var _currentHeight : int;

	  //[Bindable]
	  public function get mugl() : Object
	  {
		  return _mugl;
	  }
	  
	  public function set mugl( mugl : Object ) : void
	  {
		  if (mugl == null || (mugl == "")) { return; }
		  if (mugl is XML) {
			  _mugl = mugl as XML;
		  } else {
		  	_mugl = XML(mugl);
		  }
		  parseMugl();
	  }
	  
	  public function set muglurl( url : String ) {
		  if (url == null || url == "") { return; }
		  var loader:URLLoader = new URLLoader();
		  loader.dataFormat = "text";
		  var httpStatus:int = -1;
		  var completionHandler : Function = function(event:Event):void {
			  try {
				  mugl = new XML( event.target.data );
			  } catch (e : Error) {
				  //alert(e.message, "MUGL Parse Error");
				  var ev : MultigraphEvent = new MultigraphEvent(MultigraphEvent.PARSE_MUGL_ERROR);
				  ev.httpStatus = httpStatus;
				  ev.message    = e.message;
				  dispatchEvent(ev);
			  }
		  }
		  var errorHandler : Function = function(event):void {
			  var e : MultigraphEvent = new MultigraphEvent(MultigraphEvent.MUGL_IO_ERROR);
			  e.httpStatus = httpStatus;
			  dispatchEvent(e);
		  }

	      var httpStatusHandler : Function = function(evt:HTTPStatusEvent):void {
			  httpStatus = evt.status;
		  }		  
			  
		  loader.addEventListener(Event.COMPLETE,                    completionHandler);
		  loader.addEventListener(IOErrorEvent.IO_ERROR,             errorHandler);
		  loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		  loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,       httpStatusHandler );
		  
		  loader.load( new URLRequest( url ) );
	  }
	  
	  public function alert(text : String, title : String):void {
		  Alert.show(text, title);
	  }
	  
	  private function parseMugl() : void
	  {
		  var i : int;
		  var g : Graph;
		  
		  if (_mugl == null) {
			  return;
		  }
		  
		  if (_mugl.localName() == "muglerror" || _mugl.localName() == "error") {
			  var ev : MultigraphEvent = new MultigraphEvent(MultigraphEvent.MUGL_ERROR);
			  ev.message    = _mugl.toString();
			  dispatchEvent(ev);
			  return;
		  }

		  // remove any existing Graph children:
		  for (i = numChildren-1; i >= 0; --i) {
			  var child : DisplayObject = getChildAt(i); 
			  if (child is Graph) {
				  removeChildAt(i);
			  }
		  }

          _graphs = new Array();
		  if (_mugl.graph.length() > 0) {
            // If the MUGL file contains <graph> subelements nested
            // inside the <mugl> element, create one Graph child for
            // each one of them
		  	for (i = 0; i<_mugl.graph.length(); ++i) {
			  var gxml : XML  = _mugl.graph[i];
			  g = new Graph(this);
			  g.mugl = gxml;
			  addElement(g);
              _graphs.push(g);
		  	}
		  } else {
            // Otherwise, there are no <graph> subelements, so create
            // one single Graph child
			g = new Graph(this);
			g.mugl = _mugl;
			addElement(g);
            _graphs.push(g);
		  }
		  invalidateDisplayList();
		  dispatchEvent(new MultigraphEvent(MultigraphEvent.PARSE_MUGL));
	  }

	  public function Multigraph()
      {
		  super();
      }
	  
	  override protected function commitProperties() : void {
		  super.commitProperties();
	  }
	  
	  //private var _sizeLabel : Label;
	  
      override protected function createChildren() : void
	  {
		  super.createChildren();
      }

      override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number) : void 
	  {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if ((unscaledWidth != _currentWidth) || (unscaledHeight != _currentHeight)) {
          _currentWidth  = unscaledWidth;
          _currentHeight = unscaledHeight;
        }
	  }

  }
  
}
