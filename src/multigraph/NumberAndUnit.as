/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {

  /*
   * This class represents a combination of a number and a unit, such
   * as 'hours', 'days', 'years', etc.  The number can be any number,
   * and the unit can be any string.  The 'parse' method takes a
   * string containing a number followed by a unit, with no space in
   * between, and returns an instance of this class representing the
   * given combination.
   */
  public class NumberAndUnit
  {
    private var _number:Number;
    private var _unit:String;

    public function get number():Number { return _number; }
    public function get unit():String { return _unit; }

    public function NumberAndUnit(number:Number, unit:String) {
      _number = number;
      _unit = unit;
    }

    public static function parse(string:String) {
      var j = -1;
      for (var i:int=0; i<string.length; ++i) {
        var c = string.charAt(i);
        if ( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ) {
          j = i;
          i = string.length;
        }
      }
      if (j > 0) {
        return new NumberAndUnit( parseFloat(string.substring(0,j)), string.substring(j,string.length) );
      } else {
        return new NumberAndUnit( parseFloat(string), null );
      }
    }

  }
}

