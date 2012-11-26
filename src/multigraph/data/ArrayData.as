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
  import multigraph.Axis;
  import multigraph.DataType;
	
  public class ArrayData extends Data
  {
	private var _values:Array;
	public function get values():Array { return _values; }
		
	public function ArrayData(variables: Array) {
	  super(variables);
	  _values = new Array();
	}

	/**
	 * @param {String} varid A variable id name
	 * @returns The pairing of min,max values
	 */
	override public function getBounds(varid:String):Array {
	  var j:int = varIdToColumn(varid);
	  var min:Number = _values[0][j];
	  var max:Number = min;
	  for (var i:int=1; i<_values.length; ++i) {
		if (_values[i][j] < min) {
		  min = _values[i][j];
		}
		if (_values[i][j] > max) {
		  max = _values[i][j];
		}
	  }
	  return [min,max];
	}

	/** Separates the list of possible values into an array of [column index (x value), y value, y2 value]
	 * @param {String} text The string of values to separate based on white space and comma separation
	 */
	public function parseText(text:String):void {
	  var lines:Array = text.split(/\n/); // -> var lines contains the string of x,y values or x, y, y
	  var nvars:int = 0;
	  for (var i:int=0; i<lines.length; ++i) {
		if (lines[i].match(/\d/)) {
		  var stringvals:Array = lines[i].replace(/\s+/,'').split(/,/);
		  var numvals:Array = [];
		  nvars = stringvals.length;
		  for (var j:int=0; j<nvars; ++j) {
			if (_variables[j] != null && _variables[j].parser != null) {
			  numvals[j] = _variables[j].parser.parse(stringvals[j]);
			} else {
			  numvals[j] = stringvals[j] - 0;
			}
		  }
		  _values.push( numvals );
		}
	  }

	  if (_variables.length == 0) {
		for (var i:int=0; i<nvars; ++i) {
		  var id:String;
		  if (i==0) {
			id = 'x';
		  } else if (i==1) {
			id = 'y';
		  } else {
			id = 'y' + (i-1);
		  }
		  _variables.push(new DataVariable(id, i, DataType.NUMBER));
		}
	  }
	}
	
    /** Constructs the corresponding array of column indicies to variable ids and creates a new {Multigraph.ArrayDataIterator} for the set of \
		columns
		* @param {String[]} variableIds Array of variable ids
		* @param {double} min Minimum value for this set of values
		* @param {double} max Maximum value for this set of values
		* @param {int} buffer Buffer before and after the min and max values respectively
		* @return The array data iterator for this data set
		*/
    override public function getIterator(variableIds:Array, min:Number, max:Number, buffer:int):DataIterator {

        // if min > max, swap them:
        if (min > max) {
          var tmp:Number = max;
          max = min;
          min = tmp;
        }

	  var columnIndices:Array = [];
	  for (var i:int=0; i<variableIds.length; ++i) {
		for (var j:int=0; j<_variables.length; ++j) {
		  if (variableIds[i] == _variables[j].id) {
			columnIndices.push(j);
			break;
		  }
	
		}
	  }
	  return new ArrayDataIterator(this, columnIndices, min, max, buffer);
    }

  }
}


  
