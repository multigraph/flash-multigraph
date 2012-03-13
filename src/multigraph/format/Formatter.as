/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.format
{
	import multigraph.DataType;
	
	/*
		This class defines a formatter that can now be used to parse and format numberical values 
		into string values of arbitrary representation specified by the _formatString. As of 01/01/2009
		the multigraph.Formatter class is a merger of the previous multigraph.Formatter and multigraph.Parser.
	*/
  public class Formatter
  {
  	// The format string represents how a specific formatter will format its output
    protected var _formatString:String;
    
    public function Formatter(string:String)
    {
      _formatString = string;
    }
    
    public function format(value:Number):String { return ""; }
   	
   	public function parse(string:String):Number { return 0; } 
    
    public function getLength():int { return 5; }

    public static function create(type:DataType, string:String):Formatter {
      switch (type) {
        case DataType.NUMBER: return new NumberFormatter(string);
        case DataType.DATETIME: return new DateFormatter(string);
      }
      return null;
    }

  }
}
