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
  import flash.text.TextFormat;

    
  public class Legend extends Annotation
  {
    private var _plots:Array;
    
    private var _rows:int;
    public function get rows():int { return _rows; }
    public function set rows(numberOfRows:int):void { _rows = numberOfRows; }
    
    private var _columns:int;
    public function get columns():int { return _columns; }
    public function set columns(numberOfColumns:int):void { _columns = numberOfColumns; }
    
    private var _icon:Object;
    
    public function Legend(plots:Array,
                              bx:Number, by:Number,
                              ax:Number, ay:Number,
                              px:Number, py:Number,
                              plotBox:Box,
                              paddingBox:Box,
                              frameIsPlot:Boolean,
                              numberOfRows:int, numberOfColumns:int, color:uint, border:Number,
                           borderColor:uint, opacity:Number, icon:Object, radius:Number=0):void 
    {
      _plots       = plots;

      // if neither rows nor cols is specified, default to 1 col
      if (numberOfRows == -1 && numberOfColumns == -1) {
        numberOfColumns = 1;
      }

      // if only one of rows/cols is specified, compute the other
      if (numberOfColumns == -1) {
        numberOfColumns = _plots.length / numberOfRows + ( _plots.length % numberOfRows > 0 ? 1 : 0 );
      } else if  (numberOfRows == -1) {
        numberOfRows = _plots.length / numberOfColumns + ( _plots.length % numberOfColumns > 0 ? 1 : 0 );
      }

      _rows        = numberOfRows;
      _columns     = numberOfColumns;
      _icon        = icon;

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
    }

    override protected function createSprite():MultigraphUIComponent {
      var legendSprite = new MultigraphUIComponent();
        
      var textFormat:TextFormat = new TextFormat();
      textFormat.font = "DefaultFont";
      textFormat.color = 0x000000;
      textFormat.size = 12;
        
      var iconOffset:Number = 5;
      var height:Number = (_icon.height * _rows) + (iconOffset * _rows) + iconOffset + _border / 2;
      var width:Number  = 0;
        
      var labelOffset:Number = 5;
      var labelEnding:Number = 15;
      var widths:Array = new Array();
      var iconx:Number = iconOffset;
      var icony:Number = height - _icon.height - iconOffset - _border / 2;
        
      /**
       * These two for loops will go through the plots and create text labels.
       * I had to do this in order to obtain the maximum label length for an
       * undetermined number of labels. It's probably not the most resourceful 
       * way of doing this, but it works. Luckily the label that is generated by
       * these loops only stays in memory and is never drawn.
       * 
       * In order to make the most of the TextLabel class I had to recreate the
       * label in the bottom set of for loops. The labels position is calculated based
       * up the icon's position and offset. Without previously knowing the icon's position (x,y)
       * the anchoring aspects of the TextLabel class did not work properly.
       **/
      var numberOfPlots:Number = _plots.length - 1;
      var labelWidths:Array = new Array();
      for (var r:int = 0; r < _rows; r++) {         
        for (var c:int = 0; c < _columns; c++) {
          if (numberOfPlots < 0) {
            continue;
          }
                
          if (_plots[numberOfPlots].legendLabel != null) {
            var label:TextLabel = new TextLabel(_plots[numberOfPlots].legendLabel, textFormat, 0, 0, -1, 0, 0);
            labelWidths.push(label.width);
          }
          numberOfPlots--;
        }
      }
      // Get the max label width by sorting the array and then reversing it.
      labelWidths.sort(Array.NUMERIC);
      labelWidths.reverse();
      var maxLabelWidth:Number = labelWidths[0];
        
      /**
       * This section of the Legend class is responsible for actually getting the icon
       * ready to be drawn and rendering the label for that icon. 
       * 
       * In general this code will loop through hypothetical rows and columns in order
       * to calculate and plot each icon and label out in a grid-like fashion. 
       **/
      numberOfPlots = _plots.length - 1;
      for (var r:int = 0; r < _rows; r++) {         
        for (var c:int = 0; c < _columns; c++) {
          // Skip the rendering process if there is nothing else to be drawn
          if (numberOfPlots < 0) {
            continue;
          }
                
          if (_plots[numberOfPlots].legendLabel != null) {
            var iconSprite:MultigraphUIComponent = new MultigraphUIComponent();
            iconSprite.x = iconx;
            iconSprite.y = icony;
            iconSprite.width = _icon.width;
            iconSprite.height = _icon.height;
            _plots[numberOfPlots].renderer.renderLegendIcon(iconSprite, "Test", _opacity);
            var iconSpriteGraphics = iconSprite.graphics;

            // Draw the icon border     
            if (_icon.border > 0) {
              iconSpriteGraphics.lineStyle(_icon.border, _borderColor, 1);
              iconSpriteGraphics.beginFill(0xFFFFFF, 0);
              iconSpriteGraphics.drawRect(0, 0, iconSprite.width, iconSprite.height);
              iconSpriteGraphics.endFill();
            }
                            
            var label:TextLabel = new TextLabel(_plots[numberOfPlots].legendLabel, textFormat, iconSprite.x + (iconSprite.width) + labelOffset, iconSprite.y + (iconSprite.height / 2), -1, 0, 0);
            width += maxLabelWidth + labelOffset + labelEnding + iconSprite.width + iconOffset;
                    
            legendSprite.addChild(iconSprite);
            legendSprite.addChild(label);
                    
            iconx += iconSprite.width + iconOffset + labelOffset + labelEnding + maxLabelWidth;
          }
          numberOfPlots--;   
        }
        widths.push(width);
        width = 0;
            
        icony -= iconSprite.height + iconOffset;
        iconx = iconOffset;
      }
      widths.sort(Array.NUMERIC);
      widths.reverse();
      width = widths[0];
        
      // Set the x,y and width/height values for the legend sprite
      legendSprite.width = width;
      legendSprite.height = height;

      return legendSprite;
    }
  }
}
