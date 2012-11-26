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
   * A class for representing 2D points.  This class was originally intended specifically for points
   * that represent pixel coordinate, hence its name.  It has since been used for other kinds of points
   * as well --- in particular points whose coordinate are floating point numbers rather than integers.
   * Hence this class should probably be renamed to something like Point2D sometime in the future.
   */
  public class PixelPoint
  {
    private var _x:Number;
    private var _y:Number;
		
    public function get x():Number { return _x; }
    public function get y():Number { return _y; }
		
    public function PixelPoint(x:Number, y:Number)
    {
      _x = x;
      _y = y;
    }

    /**
     * parse a string into a PixelPoint.  The string should consist of either
     *   * a space or comma-separated pair of numbers, which are taken to be the
     *     coordinates of the PixelPoint, or
     *   * a single number, which is taken to be one of the coordinates of the PixelPoint;
     *     the other coordinate is assumed to be 0.  Which coordinate the number is
     *     taken to be is determined by the value of the defaultCoordinate argument.
     **/
    public static function parse(string:String, defaultCoordinate:int=0):PixelPoint {
      var t:String = trim(string);
      var fields:Array = t.split(/[\s,]+/);
      if (fields.length==1) {
        if (defaultCoordinate == 0) {
          return new PixelPoint(parseFloat(fields[0]), 0);
        } else {
          return new PixelPoint(0, parseFloat(fields[0]));
        }
      } else {
        return new PixelPoint(parseFloat(fields[0]), parseFloat(fields[1]));
      }
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
