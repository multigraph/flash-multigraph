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
  public class WebServiceDataIterator extends DataIterator
  {
	var _currentBlock:WebServiceDataCacheBlock;
	var _currentIndex:int;
	var _columnIndices:Array;
	
	var _initialBlock:WebServiceDataCacheBlock;
	var _finalBlock:WebServiceDataCacheBlock;
	var _initialIndex:int;
	var _finalIndex:int;

	public function WebServiceDataIterator(columnIndices:Array, 
										   initialBlock:WebServiceDataCacheBlock, initialIndex:int,
										   finalBlock:WebServiceDataCacheBlock,   finalIndex:int) {
		_currentBlock = initialBlock;										   
		_currentIndex = initialIndex;
		_initialBlock = initialBlock;										   
		_initialIndex = initialIndex;
		_finalBlock   = finalBlock;										   
		_finalIndex   = finalIndex;
		_columnIndices = columnIndices;
    }

    override public function hasNext():Boolean {
	    if (_currentBlock == null || _currentIndex < 0) { return false; }
	    if (_currentBlock != _finalBlock) {
	        return true;
	    }
	    return _currentIndex <= _finalIndex;
    }

    override public function next():Array {
	    var vals:Array = [];
	    if (_currentBlock == _finalBlock) {
	        if (_currentIndex > _finalIndex) { return null; }
	        for (var i=0; i<_columnIndices.length; ++i) {
		        vals.push(_currentBlock.data[_currentIndex][_columnIndices[i]]);
	        }
	        ++_currentIndex;
	        return vals;
	    } else {
	        for (var i=0; i<_columnIndices.length; ++i) {
		        vals.push(_currentBlock.data[_currentIndex][_columnIndices[i]]);
	        }
	        ++_currentIndex;
	        if (_currentIndex >= _currentBlock.data.length) {
		        _currentBlock = _currentBlock.dataNext;
		        _currentIndex = 0;
	        }
	        return vals;
	    }

    }

  }
}

