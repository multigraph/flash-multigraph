/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data
{
  /**
   * A WebServiceDataCacheBlock represents a single node in the
   * doubly-linked list holding the data for a WebServiceDataCache.  The
   * WebServiceDataCacheBlock has an array of data (which may actually be
   * null, if the block's data has not yet been loaded), next and prev
   * pointers to the next and previous nodes in the linked list, and
   * coveredMin and coveredMax values that indicate the min and max values
   * of the range of data requested for this node.  (The actual range of
   * data stored in the node may be different from the requested range.)
   */
  public class WebServiceDataCacheBlock
  {
    /**
     * The data array for this block; may be null
     */
    private var _data:Array;

    /**
     * The next and previous blocks in the cache's linked list
     */
    private var _next:WebServiceDataCacheBlock;
    private var _prev:WebServiceDataCacheBlock;

    /*
     * The min & max of the covered value range
     */
    private var _coveredMin:Number;
    private var _coveredMax:Number;
    
    /**
     * Public getter & setter for the data array
     */
    public function get data():Array { return _data; }
    public function set data(data:Array):void { _data = data; }

    public function get next():WebServiceDataCacheBlock { return _next; }
    public function set next(next:WebServiceDataCacheBlock):void { _next = next; }

    /**
     * Public getter that returns the next node in the cache that actually has data,
     * or null if none exists.
     */
    public function get dataNext():WebServiceDataCacheBlock {
      var block:WebServiceDataCacheBlock = _next;
      while (block != null && !block.hasData()) { block = block.next; }
      return block;
    }
    
    /**
     * Public getter & setter for the previous pointer
     */
    public function get prev():WebServiceDataCacheBlock { return _prev; }
    public function set prev(prev:WebServiceDataCacheBlock):void { _prev = prev; }
    /**
     * Public getter that returns the previous node in the cache that actually has data,
     * or null if none exists.
     */
    public function get dataPrev():WebServiceDataCacheBlock {
      var block:WebServiceDataCacheBlock = _prev;
      while (block != null && !block.hasData()) { block = block.prev; }
      return block;
    }
    
    /**
     * Public getters & setters for the coveredMin/coveredMax values
     */
    public function get coveredMin():Number { return _coveredMin; }
    public function set coveredMin(coveredMin:Number):void { _coveredMin = coveredMin; }
        public function get coveredMax():Number { return _coveredMax; }
    public function set coveredMax(coveredMax:Number):void { _coveredMax = coveredMax; }
    
    
    /**
     * Public getter to return the minimum data value for this node.  Only usable if
     * you already know that the node has data; will throw an exception if you try
     * to call this on a node that has no data.
     */
    public function get dataMin():Number {
      return _data[0][0];
    }

    /**
     * Public getter to return the maximum data value for this node.  Only usable if
     * you already know that the node has data; will throw an exception if you try
     * to call this on a node that has no data.
     */
    public function get dataMax():Number {
      return _data[_data.length-1][0];
    }
    
    /**
     * Return true if this node has data; false if not
     */
    public function hasData():Boolean {
      return _data!=null;
    }
    
    /**
     * Create a new WebServiceDataCacheBlock object.
     */
    public function WebServiceDataCacheBlock(coveredMin:Number, coveredMax:Number) {
      _coveredMin = coveredMin;
      _coveredMax = coveredMax;
      _prev = null;
      _next = null;
      _data = null;
    }
  }
}
