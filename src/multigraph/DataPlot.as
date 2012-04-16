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
  import multigraph.data.Data;
  import multigraph.data.DataIterator;
  import multigraph.renderer.Renderer;
  
  import mx.core.UIComponent;

  public class DataPlot extends Plot
  {
    private var _data:Data;
    private var _varIds:Array;
	private var _dataTip:GraphDataTip = null;
	private var _showDataTips:Boolean = false;
    private var _dataTipFormatter:DataTipFormatter = null;
    
    public function DataPlot(id:int, data:Data, varIds:Array, haxis:Axis, vaxis:Axis, renderer:Renderer, legendLabel:String,
                             showDataTips:Boolean, dataTipFormatter:DataTipFormatter):void {
      super(id, haxis, vaxis, renderer, legendLabel);
      _data     = data;
      _varIds   = varIds;
	  _showDataTips = showDataTips;
      _dataTipFormatter = dataTipFormatter;
    }

	override public function prepareData():void {
		_data.prepareData(_haxis.dataMin, _haxis.dataMax, 1);	
	}
	
	override public function showTip(mouseLocation:DPoint, component:UIComponent, plotBox:Box, hideOnly:Boolean):Boolean {
		if (!_showDataTips) { return false; }
		var foundDataTip:Boolean = false;
		if (!hideOnly) {
			var dataLocation:Array = [];
			var epsilon:Number = 4;
			var iter:DataIterator = _data.getIterator(_varIds, _haxis.dataMin, _haxis.dataMax, 1);
			if (iter != null) {
				while (iter.hasNext()) {
					var vals:Array = iter.next();
					_renderer.transformPoint(dataLocation, vals);
					if ((Math.abs(mouseLocation.x - dataLocation[0]) <= epsilon)
						&&
						(Math.abs(mouseLocation.y - dataLocation[1]) <= epsilon)) {
						if (_dataTip == null) {
							_dataTip = new GraphDataTip();
						}
						if (!component.contains(_dataTip)) {
							component.addChild(_dataTip);
						}
						
						var tipArrowSide:int;
						if (dataLocation[0] < plotBox.width/3) {
							tipArrowSide = GraphDataTip.LEFT;
						} else if (dataLocation[0] > 2*plotBox.width/3) {
							tipArrowSide = GraphDataTip.RIGHT;
						} else if (dataLocation[1] < plotBox.height/2) {
							tipArrowSide = GraphDataTip.BOTTOM;
						} else {
							tipArrowSide = GraphDataTip.TOP;
						}
						_dataTip.bgalpha = _dataTipFormatter.bgalpha;
						_dataTip.bgcolor = _dataTipFormatter.bgcolor;
						_dataTip.border = _dataTipFormatter.border;
						_dataTip.bordercolor = _dataTipFormatter.bordercolor;
						_dataTip.pad         = _dataTipFormatter.pad;
						_dataTip.fontcolor   = _dataTipFormatter.fontcolor;
						_dataTip.fontsize    = _dataTipFormatter.fontsize;
						_dataTip.bold        = _dataTipFormatter.bold;
						_dataTip.x = dataLocation[0];
						_dataTip.y = dataLocation[1];
						_dataTip.arrowSide = tipArrowSide;
						_dataTip.text  = _dataTipFormatter.format(vals);
						_dataTip.visible = true;
						_dataTip.invalidateDisplayList();
						foundDataTip = true;
						break;
					}
				}
			}
		}
		if (!foundDataTip) {
			hideTip();
		}
		return foundDataTip;
	}
	
	override public function hideTip():void {
		if (_showDataTips && _dataTip != null) {
			//_dataTipParent.removeChild(_dataTip);
			_dataTip.visible = false;
		}
	}

    override public function render(sprite:UIComponent):void {
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
