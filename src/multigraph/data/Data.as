/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data {

  /**
   * This is the (abstract) superclass for classes that Multigraph
   * uses for loading, storing, and managing data to be plotted.  When
   * drawing a plot, Multigraph accesses the data through methods of
   * this class.  Individual subclasses implement their own ways of
   * loading & managing data.
   */
  public class Data {

    /**
     * 'variables' is an array of DataVariable instances corresponding to the variables stored
     * in this data object.
     */
	public function get variables():Array { return _variables; }
	protected var _variables:Array;

    /**
     * Create a new Data object with the given array of DataVariable instances.
     */
    public function Data(variables:Array) {
      _variables = variables;
    }

    /**
     * Do whatever work is necessary, if any, to get the data object to load
     * data between min and max, with a given buffer (padding amount) on either
     * end.  Subclasses that actually need to do something for this method
     * should override it with an implementation that actually does something.
     * Implementations check the value of _prepareDataCalled, and should do
     * nothing if it is true.  If it is false, they should do whatever work
     * they need to do, and set _prepareDataCalled to true.
     */
	public function prepareData(min:Number, max:Number, buffer:int):void {}

    /**
     * Once prepareData has been called, additional calls to prepareData should
     * do nothing until prepareDataReset is called.
     */
    public function prepareDataReset():void { _prepareDataCalled = false; }
    protected var _prepareDataCalled:Boolean = false;


    public function getIterator(variableIds:Array, min:Number, max:Number, buffer:int):DataIterator { return null; }
	public function getBounds(varid:String):Array { return null; }
    //public function newRange():void {}
	//public static function findDataObjectContainingVariable(id:String):Data { return null;}

    /**
     * status stuff is used only by network monitor for debugging
     */
    public static var STATUS_COMPLETE:int    = 0;
    public static var STATUS_WEB_WAITING:int = 1;
    public static var STATUS_CSV_WAITING:int = 2;
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

	/**
     * Return one
     * of this Data object's variables, given a string containing a
     * variable id.  Returns null if there is no variable with the given
     * id in this data object.
	 */
	public function varIdToVar(id:String):DataVariable {
	  for (var j:int=0; j<_variables.length; ++j) {
		if (id == _variables[j].id) {
		  return _variables[j];
		}
	  }
	  return null;
	}
    	

  }

}
