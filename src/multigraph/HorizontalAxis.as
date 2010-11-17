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
  	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import mx.controls.DateField;
	
  public class HorizontalAxis extends Axis
  {
	private static var _s_instance_number:int = 0;
	
    public function HorizontalAxis(id:String,
    							   graph:Graph, 
    							   length:int, 
    							   offset:int, 
    							   position:int, 
    							   type:int,
                                   color:uint,
								   min:String, minoffset:int, max:String, maxoffset:int,
                                   title:String,
                                   titlePx:Number, titlePy:Number,
                                   titleAx:Number, titleAy:Number,
                                   titleAngle:Number,
								   grid:Boolean,
								   gridColor:uint,
                                   lineWidth:int,
                                   tickMin:int,
                                   tickMax:int,
                                   /*highlightStyle:int,*/
                                   titleTextFormat:TextFormat,
                                   titleBoldTextFormat:TextFormat,
								   clientData:Object
                                   ) {
      if (id == null) {
        if (_s_instance_number == 0) {
          id = 'x';
        } else{
          id = 'x' + _s_instance_number;
        }
      }
      ++_s_instance_number;
      super(id, graph, length, offset, position, type, color, min, minoffset, max, maxoffset,
            title, titlePx, titlePy, titleAx, titleAy, titleAngle, grid, gridColor,
            lineWidth, tickMin, tickMax, /*highlightStyle,*/
            titleTextFormat,
            titleBoldTextFormat,
			clientData
            );
      this.orientation = Axis.ORIENTATION_HORIZONTAL;
    }
  }
}
