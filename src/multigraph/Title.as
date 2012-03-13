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
  import flash.text.TextFormat;
  
  import mx.core.UIComponent;
    
  public class Title extends Annotation
  {
    private var _string:String;
    private var _fontsize:uint;
    private var _padding:Number;

    public function Title(string:String,
                          bx:Number, by:Number,
                          ax:Number, ay:Number,
                          px:Number, py:Number,
                          graph:Graph,
                          frameIsPlot:Boolean,
                          color:uint, border:Number,
                          borderColor:uint, opacity:Number, fontsize:uint, padding:Number=0, radius:Number=0):void 
    {
      _string = string;
      _fontsize = fontsize;
      _padding = padding;

      super(bx, by,
            ax, ay,
            px, py,
            graph,
            frameIsPlot,
            color,
            border,
            borderColor,
            opacity,
            radius);
    }

    override protected function createSprite():UIComponent {
      var titleSprite = new UIComponent();
        
      var textFormat:TextFormat = new TextFormat();
      textFormat.font = "default";
      textFormat.color = 0x000000;
      textFormat.size = _fontsize;
        
      var iconOffset:Number = 5;

      var label:TextLabel = new TextLabel(_string, textFormat,
                                          0, 0,  // position (x,y)
                                          -1, -1, // anchor (x,y)
                                          0);    // rotation (degrees)

      var descent = label.getLineMetrics(0).descent;

      label = new TextLabel(_string, textFormat,
                            _padding + 0, _padding + descent,  // position (x,y)
                            -1, -1, // anchor (x,y)
                            0);    // rotation (degrees)

      titleSprite.addChild(label);
      titleSprite.width = label.width + 2*_padding;
      titleSprite.height = label.height + 2*_padding;

      return titleSprite;
    }
  }
}
