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
  import multigraph.format.*;
	
  public class DataVariable
  {
	private var _id:String;
	public function get id():String { return _id; }
		
	private var _column:int;
	public function get column():int { return _column; }
		
	private var _type:DataType;
	public function get type():DataType { return _type; }
		
	private var _parser:Formatter;
	public function get parser():Formatter { return _parser; }
	
    private var _missingOpNONE:int   = -10;
    private var _missingOpLT:int     =  -2;
    private var _missingOpLE:int     =  -1;
    private var _missingOpEQ:int     =   0;
    private var _missingOpGE:int     =   1;
    private var _missingOpGT:int     =   2;
    private var _missingOp:int       =  _missingOpNONE;	
	private var _missingValue:Number;

	public function DataVariable(id:String, column:int, type:DataType, missingValue:Number=0, missingOpString:String=null)
	{
	  this._id           = id;
	  this._column       = column;
	  this._type         = type;
	  this._missingValue = missingValue;
	  this._missingOp    = missingOpStringToInt(missingOpString);
			
	  switch (this.type) {
	  case DataType.DATETIME:
		this._parser = new DateFormatter("YMDHis");
		break;
	  default:
		this._parser = null;
		break;
	  }
	}
	
    public function isMissing(x:Number):Boolean {
      if (_missingOp == _missingOpNONE) { return false; }
      if (_missingOp == _missingOpLT) { return x <  _missingValue; }
      if (_missingOp == _missingOpLE) { return x <= _missingValue; }
      if (_missingOp == _missingOpEQ) { return x == _missingValue; }
      if (_missingOp == _missingOpGE) { return x >= _missingValue; }
      if (_missingOp == _missingOpGT) { return x >  _missingValue; }
      return false;
    }

    private function missingOpStringToInt(op_str:String):int {
      if (op_str==null) { return _missingOpNONE; }
      op_str = op_str.toLowerCase();
      if (op_str == "lt") {
        return _missingOpLT;
      }
      else if (op_str == "le") {
        return _missingOpLE;
      }
      else if (op_str == "eq") {
        return _missingOpEQ;
      }
      else if (op_str == "ge") {
        return _missingOpGE;
      }
      else if (op_str == "gt") {
        return _missingOpGT;
      }
      return _missingOpNONE;
    }	
	
	
  }

}
