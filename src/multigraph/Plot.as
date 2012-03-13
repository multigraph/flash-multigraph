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
  import multigraph.renderer.Renderer;
  
  import mx.core.UIComponent;

  public class Plot
  {
    protected var _id:int;
    protected var _haxis:Axis;
    protected var _vaxis:Axis;
    protected var _legendLabel:String;
    
    public function get legendLabel():String {
    	return _legendLabel;
    }
    
    protected var _renderer:Renderer;
    public function get renderer():Renderer {
    	return _renderer;
    }

    public function Plot(id:int, haxis:Axis, vaxis:Axis, renderer:Renderer, legendLabel:String):void {
      _id       = id;
      _haxis    = haxis;
      _vaxis    = vaxis;
      _renderer = renderer;
      _legendLabel = legendLabel;
    }

    /**
     * Do any prep work needed to make sure that this plot's data
     * object is ready for plotting all the data along the current
     * extent of its horizontal axis.
     */
	public function prepareData():void {}

	public function showTip(mouseLocation:DPoint, component:UIComponent, plotBox:Box):void {}
	public function hideTip():void {}

    public function render(sprite:UIComponent):void {}

  }

}
