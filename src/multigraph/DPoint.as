/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph
{
  /**
   * A class for representing 2D points.  The name DPoint is borrowed from the Java version 
   * of Multigraph, where the point coordinates are of type "double".  This class was called
   * PixelPoint in versions of Multigraph prior to 4.0.
   */
  public class DPoint
  {
    private var _x:Number;
    private var _y:Number;
		
    public function get x():Number { return _x; }
    public function get y():Number { return _y; }
		
    public function DPoint(x:Number, y:Number)
    {
      _x = x;
      _y = y;
    }

    /**
     * Parse a string into a DPoint.  The string should consist of 
     * a space or comma-separated pair of numbers, which are taken to be the
     * coordinates of the DPoint
     */
    public static function parse(string:String) : DPoint {
      var t:String = trim(string);
      var fields:Array = t.split(/[\s,]+/);
      if (fields.length != 2) {
        throw new ParseError();
      }
      var parsedX : Number = parseFloat(fields[0]);
      var parsedY : Number = parseFloat(fields[1]);
      if (isNaN(parsedX) || isNaN(parsedY)) {
        throw new ParseError();
      }
      return new DPoint(parsedX, parsedY);
    }

    /**
     * parse a string into a DPoint.  The string should consist of either
     *   * a space or comma-separated pair of numbers, which are taken to be the
     *     coordinates of the DPoint, or
     *   * a single number, which is taken to be one of the coordinates of the DPoint;
     *     the value of other coordinate is assumed to be 0.  Which coordinate the number is
     *     taken to be is determined by the value of the defaultCoordinate argument.
     **/
    public static function parseWithDefaultCoordinate(string:String, defaultCoordinate:int=0):DPoint {
      var t:String = trim(string);
      var fields:Array = t.split(/[\s,]+/);
      if (fields.length == 1) {
        var parsedValue : Number = parseFloat(fields[0]);
        if (isNaN(parsedValue)) {
          throw new ParseError();
        }
        if (defaultCoordinate == 0) {
          return new DPoint(parsedValue, 0);
        } else {
          return new DPoint(0, parsedValue);
        }
      } else if (fields.length == 2) {
        var parsedX : Number = parseFloat(fields[0]);
        var parsedY : Number = parseFloat(fields[1]);
        if (isNaN(parsedX) || isNaN(parsedY)) {
          throw new ParseError();
        }
        return new DPoint(parsedX, parsedY);
      } else {
          throw new ParseError();
      }
    }


    public static function parseFloatArray(string : String) : Array {
      var t : String = trim(string);
      var fields : Array = t.split(/[\s,]+/);
      var floatArray : Array = new Array();
      for each (var field : String in fields) {
          floatArray.push( parseFloat(field) );
      }
	  return floatArray;
    }

    private static function trim(string:String):String {
      if (string == null) { return null; }
      var i0:int = 0;
      var c:String;
      while (i0<string.length) {
        c = string.charAt(i0);
        if (c==' ' || c=='\t' || c=='\n') {
          ++i0;
        } else {
          break;
        }
      }
      var i1:int = string.length-1;
      while (i1>=0) {
        c = string.charAt(i1);
        if (c==' ' || c=='\t' || c=='\n') {
          --i1;
        } else {
          break;
        }
      }
      return string.substring(i0, i1+1);
    }

  }
}
