package multigraph
{
  import flash.events.Event;

  /**
   *  The AxisEvent class represents the event object passed to
   *  the event listener for the <code>change</code> event
   *  of the Axis class.
   *
   *  @see multigraph.Axis
   */
  public class AxisEvent extends Event
  {

    /**
     *  The <code>AxisEvent.CHANGE</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>change</code> event.
     *
     *  @eventType change
     */
    public static const CHANGE:String = "change";

    private var _min:Number;
    private var _max:Number;
    /**
     * The new data value corresponding to the minimum endpoint of the axis.
     */
    public function get min():Number { return _min; }
    public function set min(val:Number):void { _min = val; }
    /**
     * The new data value corresponding to the maximum endpoint of the axis.
     */
    public function get max():Number { return _max; }
    public function set max(val:Number):void { _max = val; }
    public function AxisEvent(type:String, min:Number, max:Number,
                              bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      _min = min;
      _max = max;
    }
  }
}
