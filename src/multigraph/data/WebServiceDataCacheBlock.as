/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data
{
  public class WebServiceDataCacheBlock
  {
    private var _data:Array;
    private var _next:WebServiceDataCacheBlock;
    private var _prev:WebServiceDataCacheBlock;
	private var _coveredMin:Number;
	private var _coveredMax:Number;

    public function get data():Array { return _data; }
    public function set data(data:Array):void { _data = data; }

    public function get next():WebServiceDataCacheBlock { return _next; }
    public function set next(next:WebServiceDataCacheBlock):void { _next = next; }
    public function get dataNext():WebServiceDataCacheBlock {
      var block:WebServiceDataCacheBlock = _next;
      while (block != null && !block.hasData()) { block = block.next; }
      return block;
	}

    public function get prev():WebServiceDataCacheBlock { return _prev; }
    public function set prev(prev:WebServiceDataCacheBlock):void { _prev = prev; }
    public function get dataPrev():WebServiceDataCacheBlock {
      var block:WebServiceDataCacheBlock = _prev;
      while (block != null && !block.hasData()) { block = block.prev; }
      return block;
    }

	public function get coveredMin():Number { return _coveredMin; }
	public function set coveredMin(coveredMin:Number):void { _coveredMin = coveredMin; }

	public function get coveredMax():Number { return _coveredMax; }
	public function set coveredMax(coveredMax:Number):void { _coveredMax = coveredMax; }


	public function get dataMin():Number {
	  return _data[0][0];
	}
	public function get dataMax():Number {
	  return _data[_data.length-1][0];
	}

    public function hasData():Boolean {
      return _data!=null;
    }

    public function WebServiceDataCacheBlock(coveredMin:Number, coveredMax:Number) {
      _coveredMin = coveredMin;
      _coveredMax = coveredMax;
      _prev = null;
      _next = null;
      _data = null;
    }
  }
}
