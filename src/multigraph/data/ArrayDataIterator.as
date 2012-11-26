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
	public class ArrayDataIterator extends DataIterator
	{
		private var _columnIndices:Array;
		private var _data:ArrayData;
		private var _dataMin:Number;
		private var _dataMax:Number;
		private var _indexMin:int;
		private var _indexMax:int;
		private var _index:int;
		
		
	  public function ArrayDataIterator(data:ArrayData, columnIndices:Array,
                                        min:Number, max:Number, buffer:Number)
	  {
		_columnIndices  = columnIndices;
		_data     = data;
		_dataMin  = min;
		_dataMax  = max;
		_indexMin = 0;

        while ((_indexMin < _data.values.length)
               &&
               (_data.values[_indexMin][0] < _dataMin)) {
		  ++_indexMin;
        }

        if ((_indexMin >= _data.values.length) || (_data.values[_indexMin][0] > _dataMax)) {
          _indexMax = -1;
        } else {
          _indexMax = _indexMin;
          while ((_indexMax < _data.values.length-1)
                 &&
                 (_data.values[_indexMax+1][0] <= _dataMax)) {
            ++_indexMax;
          }
        }

        _indexMin -= buffer;
        _indexMax += buffer;
        if (_indexMin < 0) { _indexMin = 0; }
        if (_indexMax >= _data.values.length) { _indexMax = _data.values.length-1; }

        _index = _indexMin;
	  }
			
	  override public function hasNext():Boolean {
        return _index <= _indexMax;
	  }
/*
	  public function ArrayDataIterator(data:ArrayData, columnIndices:Array,
                                        min:Number, max:Number, buffer:Number)
	  {
		_columnIndices  = columnIndices;
		_data     = data;
		_dataMin  = min;
		_dataMax  = max;
		_indexMin = -1;

		while ((_indexMin < _data.values.length-1)
			   &&
			   (_data.values[_indexMin+1][0] < _dataMin)) {
		  ++_indexMin;
        }

        _indexMax = _indexMin;

        while ((_indexMax < _data.values.length-1)
			   &&
			   (_data.values[_indexMax+1][0] < _dataMax)) {
		  ++_indexMax;
        }

        _indexMin -= buffer;
        _indexMax += buffer;
        if (_indexMin < 0) { _indexMin = 0; }
        if (_indexMax >= _data.values.length) { _indexMax = _data.values.length-1; }
        _index = _indexMin;
	  }
			
	  override public function hasNext():Boolean {
        return _index <= _indexMax;
	  }
*/
	  override public function next():Array {
        if (_index > _indexMax) { return null; }
        var vals:Array = [];
        for (var i:int=0; i<_columnIndices.length; ++i) {
		  vals.push(_data.values[_index][_columnIndices[i]]);
        }
        ++_index;
        return vals;
	  }

	}
}
