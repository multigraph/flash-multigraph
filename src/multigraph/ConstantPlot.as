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
  import mx.core.UIComponent;
  import multigraph.renderer.Renderer;

  public class ConstantPlot extends Plot
  {
    private var _constantValue:Number;
    
    public function ConstantPlot(id:int, constantValue:Number, haxis:Axis, vaxis:Axis, renderer:Renderer, legendLabel:String):void {
      super(id, haxis, vaxis, renderer, legendLabel);
      _constantValue = constantValue;
    }

    override public function render(sprite:UIComponent):void {
      _renderer.begin(sprite);
      var vals:Array = [_haxis.dataMin, _constantValue];
      _renderer.dataPoint(sprite, vals);
      vals[0] = _haxis.dataMax;
      _renderer.dataPoint(sprite, vals);
      _renderer.end(sprite);
    }

  }

}
