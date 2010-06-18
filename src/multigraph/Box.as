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
	public class Box
	{
		// The width of a box
		private var _width:Number;
		public function get width():Number { return _width; }
		
		// The height of a box
		private var _height:Number;
		public function get height():Number { return _height; }
		
		public function Box(... arguments)
		{
			if (arguments.length == 2) {		// new Box(width, height)
				_width  = arguments[0];
				_height = arguments[1];
			} else if (arguments.length == 1) {	// new Box(dim)
				_width  = arguments[0];
				_height = arguments[0];
			} else {							// new Box()
				_width  = 0;
				_height = 0;
			}

		}

	}
}
