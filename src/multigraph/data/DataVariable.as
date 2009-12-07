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
  import multigraph.Axis;
  import multigraph.format.*;
	
  public class DataVariable
  {
	private var _id:String;
	public function get id():String { return _id; }
		
	private var _column:int;
	public function get column():int { return _column; }
		
	private var _type:int;
	public function get type():int { return _type; }
		
	private var _parser:Formatter;
	public function get parser():Formatter { return _parser; }
		
	public function DataVariable(id:String, column:int, type:int)
	{
	  this._id = id;
	  this._column = column;
	  this._type = type;
			
	  switch (this.type) {
	  case Axis.TYPE_DATETIME:
		this._parser = new DateFormatter("YMDHis");
		break;
	  default:
		this._parser = null;
		break;
	  }
	}
  }

}
