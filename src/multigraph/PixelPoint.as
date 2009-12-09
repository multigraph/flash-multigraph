/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph
{
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
		
		public static function parse(string:String):PixelPoint {
			var t:String = trim(string);
			var fields:Array = t.split(/[\s,]+/);
			var f = fields[0];
			var fn = parseFloat(f);
			return new PixelPoint(parseFloat(fields[0]), parseFloat(fields[1]));
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
