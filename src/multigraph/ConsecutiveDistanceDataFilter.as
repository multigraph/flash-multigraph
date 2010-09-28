/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.display.Graphics;

  public class ConsecutiveDistanceDataFilter extends DataFilter
  {
    private var _prevPx:Number;
    private var _prevPy:Number;
    private var _havePrev:Boolean;
    private var _distance:int;

    public function ConsecutiveDistanceDataFilter(distance:int) {
      _distance    = distance;
    }

    override public function reset(hAxis:Axis, vAxis:Axis):void {
      _havePrev = false;
    }

    override public function filter(datap:Array, pixelp:Array):Boolean {
      var filterOut:Boolean = false;
      if (_havePrev) {
        var _dx:Number = Math.abs(pixelp[0] - _prevPx);
        var _dy:Number = Math.abs(pixelp[1] - _prevPy);
        filterOut = (_dx + _dy < _distance);
        if (!filterOut) {
	      _prevPx = pixelp[0];
      	  _prevPy = pixelp[1];
      	}
      } else {
      	_prevPx = pixelp[0];
      	_prevPy = pixelp[1];
      }
      _havePrev = true;
      return filterOut;
    }

  }
}
