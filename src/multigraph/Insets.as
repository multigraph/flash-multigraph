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
	public class Insets
	{
      // Top portion of an inset
      private var _top:Number;
      public function get top():Number { return _top; }
      
      // Left portion of an inset
      private var _left:Number;
      public function get left():Number { return _left; }
      
      // Bottom portion of an inset
      private var _bottom:Number;
      public function get bottom():Number { return _bottom; }
      
      // Right portion of an inset
      private var _right:Number;
      public function get right():Number { return _right; }

		public function Insets(... arguments)
		{
			if (arguments.length == 4) {		// new Insets(top, left, bottom, right)
				_top    = arguments[0];
				_left   = arguments[1];
				_bottom = arguments[2];
				_right  = arguments[3];
			} else if (arguments.length == 2) {	// new Insets(horizontal, vertical)
				_top    = arguments[1];
				_left   = arguments[0];
				_bottom = arguments[1];
				_right  = arguments[0];
			} else if (arguments.length == 1) {	// new Insets(amount)
				_top    = arguments[0];
				_left   = arguments[0];
				_bottom = arguments[0];
				_right  = arguments[0];
			} else {							// new Insets()
				_top    = 0;
				_left   = 0;
				_bottom = 0;
				_right  = 0;
			}

		}

	}
}
