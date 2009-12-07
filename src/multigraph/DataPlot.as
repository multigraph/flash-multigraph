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
  import multigraph.data.Data;
  import multigraph.data.DataIterator;
  import multigraph.renderer.Renderer;

  public class DataPlot extends Plot
  {
    private var _data:Data;
    private var _varIds:Array;
    
    public function DataPlot(id:int, data:Data, varIds:Array, haxis:Axis, vaxis:Axis, renderer:Renderer, legendLabel:String):void {
      super(id, haxis, vaxis, renderer, legendLabel);
      _data     = data;
      _varIds   = varIds;
    }

	override public function prepareData():void {
		_data.prepareData(_haxis.dataMin, _haxis.dataMax, 1);	
	}

    override public function render(sprite:MultigraphUIComponent):void {
      var iter:DataIterator = _data.getIterator(_varIds, _haxis.dataMin, _haxis.dataMax, 1);
      if (iter != null) {
        _renderer.begin(sprite);
        while (iter.hasNext()) {
          var vals:Array = iter.next();
          _renderer.dataPoint(sprite, vals);
        }
        _renderer.end(sprite);
      }
    }
  }

}
