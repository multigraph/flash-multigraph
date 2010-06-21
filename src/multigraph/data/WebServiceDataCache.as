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
  public class WebServiceDataCache
  {
    private var _head:WebServiceDataCacheBlock;
    private var _tail:WebServiceDataCacheBlock;
    
    public function WebServiceDataCache() {
      _head = null;
      _tail = null;
    }
    
    public function isEmpty():Boolean {
      return _head==null;
    }
    
    public function dataHead():WebServiceDataCacheBlock {
      if (_head.hasData()) { return _head; }
      return _head.dataNext;
    }
    
    public function dataTail():WebServiceDataCacheBlock {
      if (_tail.hasData()) { return _tail; }
      return _tail.dataPrev;
    }
    
    public function get coveredMin():Number {
      /*
    	if (_head == null) { return NaN; }
    	return _head.coveredMin;
    	*/
      var b:WebServiceDataCacheBlock = dataHead();
      if (b==null) { return NaN; }
      return b.coveredMin;
    }

    public function get coveredMax():Number {
      /*
    	if (_tail == null) { return NaN; }
    	return _tail.coveredMax;
    	*/
      var b:WebServiceDataCacheBlock = dataTail();
      if (b==null) { return NaN; }
      return b.coveredMax;
    }

    public function insertBlock(block:WebServiceDataCacheBlock):void {
      if (_head==null) {
        _head = block;
        _tail = block;
      } else {
        if (block.coveredMin < _head.coveredMin) {
          block.next = _head;
          _head.prev = block;
          _head = block;
        } else {
          block.prev = _tail;
          _tail.next = block;
          _tail = block;
        }
      }
    }
    
    public function getIterator(columnIndices:Array, min:Number, max:Number, buffer:int):WebServiceDataIterator {
      
      var initialBlock:WebServiceDataCacheBlock;
      var initialIndex:int;
      var n:int;
      var finalBlock:WebServiceDataCacheBlock;
      var finalIndex:int;
      var b:WebServiceDataCacheBlock;
      
      // find the data block containing the 'min' value
      initialBlock = dataHead();
      while ((initialBlock != null)
             &&
             (initialBlock.dataNext != null)
             &&
             (min > initialBlock.dataMax)) {
        initialBlock = initialBlock.dataNext;
      }
      
      
      if (initialBlock==null || !initialBlock.hasData()) {
        initialIndex = -1;
      } else {
        initialIndex = 0;
        // find the index within the initial block corresponding to the 'min' value
        while ((initialIndex < initialBlock.data.length-1)
               &&
               (initialBlock.data[initialIndex][columnIndices[0]] < min)) {
          ++initialIndex;
        }
	
        // back up 'buffer' steps, being careful not to go further back than the first element of the head block
        n = 0;
        while (n<buffer) {
          --initialIndex;
          if (initialIndex<0) {
            b = initialBlock.dataPrev;
            if (b != null) {
              initialBlock = b;
              initialIndex = initialBlock.data.length-1;
            } else {
              initialIndex = 0;
              break;
            }
          }
          ++n;
        }
	
	
        // find the data block containing the 'max' value
        finalBlock = initialBlock;
        while ( (max > finalBlock.dataMax)
                &&
                (finalBlock.dataNext != null) ) {
          finalBlock = finalBlock.dataNext;
        }
	
        // find the index within the final block corresponding to the 'max' value
        finalIndex = 0;
        if (finalBlock == initialBlock) {
          finalIndex = initialIndex;
        }
        while ((finalIndex < finalBlock.data.length-1)
               &&
               (finalBlock.data[finalIndex][columnIndices[0]] < max)) {
          ++finalIndex;
        }
	
        // go forward 'buffer' more steps, being careful not to go further than the last element of the tail
        n = 0;
        //while (n<buffer && !(finalBlock==_tail && finalIndex<finalBlock.data.length)) {
        while (n<buffer) {
          ++finalIndex;
          if (finalIndex>=finalBlock.data.length) {
            b = finalBlock.dataNext;
            if (b != null) {
              finalBlock = b;
              finalIndex = 0;
            } else {
              finalIndex = finalBlock.data.length-1;
              break;
            }
          }
          ++n;
        }
	
      }
      
      return new WebServiceDataIterator(columnIndices, initialBlock, initialIndex, finalBlock, finalIndex);
      
    }
    
    public function getStatus():Array {
      var stati:Array = [];
      var b:WebServiceDataCacheBlock = _head;
      while (b != null) {
        if (b.hasData()) {
          stati.push(Data.STATUS_COMPLETE);
        } else {
          stati.push(Data.STATUS_WEB_WAITING);
        }
        b = b.next;
      }
      return stati;
    }
    
    
  }
}
