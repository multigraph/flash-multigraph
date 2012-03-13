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
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.controls.Button;
	import mx.styles.CSSStyleDeclaration;
	
	public class ToolBar extends Annotation
	{
		[Embed(source="assets/toolbar/searchers.png")]
			[Bindable]
			private var zoomIcon:Class;
			
		[Embed(source="assets/cursors/HandOpen.png")]
			[Bindable]
			private var panCursor:Class;
			
		[Embed(source="assets/cursors/searcher.png")]
			[Bindable]
			private var zoomCursor:Class;
			
		[Embed(source="assets/toolbar/panners.png")]
			[Bindable]
			private var panIcon:Class;
			
		private var _graph:Graph;
		private var _panIcon:Button;
		private var _zoomIcon:Button;
		private var _zoomIconSelected:Boolean;
		
		public function ToolBar(graph:Graph, bx:Number, by:Number,
                              ax:Number, ay:Number,
                              px:Number, py:Number,
                              plotBox:Box,
                              paddingBox:Box,
                              frameIsPlot:Boolean,
                              color:uint, border:Number,
                              borderColor:uint, opacity:Number, radius:Number=0):void {
                              	
        	super(bx, by,
            ax, ay,
            px, py,
            plotBox,
            paddingBox,
            frameIsPlot,
            color,
            border,
            borderColor,
            opacity,
            radius);
            
            _graph = graph;
		}
		
		override protected function createSprite():MultigraphUIComponent {
			var toolbarSprite:MultigraphUIComponent = new MultigraphUIComponent();
			var panIconStyle:CSSStyleDeclaration = new CSSStyleDeclaration("panIconStyle");
			var zoomIconStyle:CSSStyleDeclaration = new CSSStyleDeclaration("zoomIconStyle");
			
			toolbarSprite.width = 48;
			toolbarSprite.height = 25;
			
			_panIcon = new Button();
			_zoomIcon = new Button();
			_zoomIconSelected = false;
			_panIcon.width = 22;
			_panIcon.height = 22;
			_zoomIcon.width = 22;
			_zoomIcon.height = 22;
			_panIcon.transform.matrix = new Matrix(1, 0, 0, -1, 0, _panIcon.height);
			_zoomIcon.transform.matrix = new Matrix(1, 0, 0, -1, 0, _zoomIcon.height);
			
			panIconStyle.setStyle("icon", panIcon);
			panIconStyle.setStyle("themeColor", "haloBlue");
			zoomIconStyle.setStyle("icon", zoomIcon);
			zoomIconStyle.setStyle("themeColor", "haloBlue");
			
			_panIcon.styleName = panIconStyle;
			_zoomIcon.styleName = zoomIconStyle;
									
			_panIcon.x = 2;
			_panIcon.y = _panIcon.height + 1;
			
			_zoomIcon.x = _panIcon.width + 3;
			_zoomIcon.y = _zoomIcon.height + 1;
			
			_panIcon.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				_graph.cursorManager.removeAllCursors();
				_graph.cursorManager.setCursor(panCursor);
				_panIcon.setStyle("borderColor", "haloOrange");
				_zoomIcon.setStyle("borderColor", "haloSilver");
				_graph.toolbarState = "pan";
				//_graph.takeSnapshot();
			});
			
			_zoomIcon.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				_graph.cursorManager.removeAllCursors();
				_graph.cursorManager.setCursor(zoomCursor, 1, -15, -15);
				_zoomIcon.setStyle("borderColor", "haloOrange");
				_panIcon.setStyle("borderColor", "haloSilver");
				_graph.toolbarState = "zoom";
			});
			
			toolbarSprite.addChild(_panIcon);
			toolbarSprite.addChild(_zoomIcon);
			return toolbarSprite;	
		}
		
		public function updateZoomIcon():void {
			_graph.cursorManager.removeAllCursors();
			_graph.cursorManager.setCursor(zoomCursor);
			_zoomIcon.setStyle("borderColor", "haloOrange");
		}
		
		public function resetZoomIcon():void {
			_graph.cursorManager.removeAllCursors();
			_zoomIcon.setStyle("borderColor", "haloSilver");	
		}
	}
}
