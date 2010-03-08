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
  	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import mx.controls.DateField;
	
  public class HorizontalAxis extends Axis
  {
    private var _textFormat:TextFormat;
	private static var _s_instance_number:int = 0;
	
    public function HorizontalAxis(id:String, graph:Graph, length:int, offset:int, position:int, type:int,
                                   color:uint,
								   min:String, minoffset:int, max:String, maxoffset:int,
                                   title:String,
                                   titlePx:Number, titlePy:Number,
                                   titleAx:Number, titleAy:Number,
                                   titleAngle:Number,
								   grid:Boolean,
								   gridColor:uint) {
      if (id == null) {
        if (_s_instance_number == 0) {
          id = 'x';
        } else{
          id = 'x' + _s_instance_number;
        }
      }
      ++_s_instance_number;
      super(id, graph, length, offset, position, type, color, min, minoffset, max, maxoffset,
            title, titlePx, titlePy, titleAx, titleAy, titleAngle, grid, gridColor)
      this.orientation = Axis.ORIENTATION_HORIZONTAL;
      _textFormat = new TextFormat(  );
      _textFormat.font = "DefaultFont";
      _textFormat.color = 0x000000;
      _textFormat.size = 12;
      _textFormat.align = TextFormatAlign.LEFT;
    }
    
    override public function render(sprite:MultigraphUIComponent):void {
      var g:Graphics = sprite.graphics;

      // render the axis itself
      if (this.selected) {
      	g.lineStyle(3,0,1);
      } else {
      	g.lineStyle(1,0,1);
      }
      g.moveTo(offset, position);
      g.lineTo(offset + length, position);

      // render title
      if (title != null) {
        sprite.addChild(new TextLabel(title,
                                      _textFormat,
                                      offset + length / 2 + titlePx,  position + titlePy,
                                      titleAx, titleAy,
                                      titleAngle));
      }
      
/*       // TODO: Add a DateField date chooser
      var dateField:DateField = new DateField();
      dateField.x = titlePx;
      dateField.y = titlePy;
      dateField.width = 100;
      dateField.height = 25;
      sprite.addChild(dateField); */

      // render labels
      if (labelers.length > 0) {
        //
        // Draw tics & labels & optional grid lines
        //
        //// First decide which labeler to use: take the one with the largest density <= 0.8.
        //// Unless all have density > 0.8, in which case we take the first one.  This assumes
        //// that the labelers list is ordered in increasing order of label density.
        var labeler:Labeler = labelers[0];
        var density:Number = labeler.labelDensity(this);
        if (density < 0.8) {
          for (var i:uint = 1; i < labelers.length; i++) {
            density = labelers[i].labelDensity(this);
            if (density > 0.8) { break; }
            labeler = labelers[i];
          }
        }

        if (density <= 1.5) {
	
          //// Now draw the tics and labels & grid lines
          labeler.prepare(dataMin, dataMax);
          while (labeler.hasNext()) {
            var v:Number = labeler.next();
            var a:Number = dataValueToAxisValue(v);
            g.lineStyle(1,0,1);
            g.moveTo(a, position+3);
            g.lineTo(a, position-3);
            labeler.renderLabel(sprite, this, v);
            if (grid) {
		  	  g.lineStyle(1, gridColor, 1);
			  g.moveTo(a, position);
			  g.lineTo(a, graph.plotBox.height - position);
            }			  
          }

        }

      }
    }
  }
}
