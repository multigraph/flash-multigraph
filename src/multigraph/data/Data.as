/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data {

  public class Data {

    public static var STATUS_COMPLETE:int    = 0;
    public static var STATUS_WEB_WAITING:int = 1;
    public static var STATUS_CSV_WAITING:int = 2;

	protected var _variables:Array;
	public function get variables():Array { return _variables; }
    public function Data(variables:Array) {
      _variables = variables;
    }
    protected var _prepareDataCalled:Boolean = false;
    public function prepareDataReset():void { _prepareDataCalled = false; }
	public function prepareData(min:Number, max:Number, buffer:int):void {}
    public function getIterator(variableIds:Array, min:Number, max:Number, buffer:int):DataIterator { return null; }
	public function getBounds(varid:String):Array { return null; }
    //public function newRange():void {}
	//public static function findDataObjectContainingVariable(id:String):Data { return null;}

    public function getStatus():Array { return []; }

    /**
     * Return the id of this data object's i-th variable (i.e. the
     * data variable whose column number is i).  Return null if there
     * is no i-th variable.
     */
    public function getVariableId(i:int):String {
      if (i < 0 || i >= _variables.length) {
        return null;
      }
      return _variables[i].id;
    }


	/**
     * Return the column number (index in the variables array) of one
     * of this Data object's variables, given a string containing a
     * variable id.  Returns -1 if there is no variable with the given
     * id in this data object.
	 */
	protected function varIdToColumn(id:String):int {
	  for (var j:int=0; j<_variables.length; ++j) {
		if (id == _variables[j].id) {
		  return j;
		}
	  }
	  return -1;
	}
    	

  }

}
