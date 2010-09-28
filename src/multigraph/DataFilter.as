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

  public class DataFilter
  {
    public function reset(hAxis:Axis, vAxis:Axis):void {}
    public function filter(datap:Array, pixelp:Array):Boolean { return false; }
    public function draw(g:Graphics):void {}
  }
}
