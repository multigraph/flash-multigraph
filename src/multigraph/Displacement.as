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
   * A Displacement is a way of expressing either a length or a location along a direction,
   * in terms of two numbers:
   *       * a first number that is either a fraction of a length or a coordindate value
   *         in a coordinate system along a direction
   *       * a second number that is a pixel offset from the first
   *
   * Displacements can be represented by string expressions of the form "a+b" or "a-b", where
   * a is the first number (fraction or coordinate), and b is the second (pixel offset).
   * The parse() method converts a string of this format to a Displacement instance.
   *
   * The calculateLength() and calculateCoordinate() methods convert a Displacement
   * to pixel values.
   */
  public class Displacement
  {
    private static var _displacementRegExp:RegExp = /^([\+-]?[0-9\.]+)([+\-])([0-9\.+\-]+)$/;

    private var _a:Number;
    private var _b:Number;
		
    public function get a():Number { return _a; }
    public function get b():Number { return _b; }
		
    public function Displacement(a:Number, b:Number)
    {
      _a = a;
      _b = b;
    }


    /**
     * parse a string into a Displacement.  The string should be of one of the following forms:
     *     "A+B"  ==>  a=A  b=B
     *     "A-B"  ==>  a=A  b=-B
     *     "A"    ==>  a=A  b=0
     *     "+A"   ==>  a=A  b=0
     *     "-A"   ==>  a=-A b=0
     **/
    public static function parse(string:String):Displacement {
      var ar:Array = _displacementRegExp.exec(string);
      if (ar != null) {
        var a : Number = parseFloat(ar[1]);
        var b : Number = parseFloat(ar[3]);
        var sign : int;
        switch (ar[2]) {
        case "+":
          sign = 1;
          break;
        case "-":
          sign = -1;
          break;
        default:
          sign = 0;
          break;
        }
        if (isNaN(a) || sign == 0 || isNaN(b)) {
          throw new ParseError('parse error');
        }
        return new Displacement( a, sign * b );
      }
      var a : Number = parseFloat(string);
      if (isNaN(a)) {
          throw new ParseError('parse error');
      }
      return new Displacement( a, 0 );
    }


    public function calculateLength(totalLength:Number):Number {
      return _a * totalLength + _b;
    }

    public function calculateCoordinate(totalLength:Number):Number {
      return (_a + 1) * totalLength/2.0 + _b;
    }


  }
}
