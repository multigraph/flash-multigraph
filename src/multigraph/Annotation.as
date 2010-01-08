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
  import flash.filters.DropShadowFilter;

  /*
   * An Annotation is a rectangular region that holds some kind of
   * decoration, such as a text label, legend, or image, that is drawn on
   * top of the graph.  Annotation is an abstract superclass; there are no
   * instances of Annotation itself --- only of its subclasses.  The
   * current subclasses are Legend and Title; I may add an Image subclass
   * later.
   */
  public class Annotation
  {
    // Position and anchoring
    
    private var _px:Number;
    public function get px():Number { return _px; }
    public function set px(positionX:Number):void { _px = positionX; }
    
    private var _py:Number;
    public function get py():Number { return _py; }
    public function set py(positionY:Number):void { _py = positionY; }
    
    private var _ax:Number;
    public function get ax():Number { return _ax; }
    public function set ax(anchorX:Number):void { _ax = anchorX; }
    
    private var _ay:Number;
    public function get ay():Number { return _ay; }
    public function set ay(anchorY:Number):void { _ay = anchorY; }

    private var _bx:Number;
    public function get bx():Number { return _bx; }
    public function set bx(baseX:Number):void { _bx = baseX; }
    
    private var _by:Number;
    public function get by():Number { return _by; }
    public function set by(baseY:Number):void { _by = baseY; }
    
    // Formatting
    protected var _border:Number;
    protected var _borderColor:uint;
    protected var _borderColor_str:String;
    protected var _color:uint;
    protected var _color_str:uint;    
    protected var _opacity:Number;
    
    private var _annotationSprite:MultigraphUIComponent;

    private var _plotBox:Box;
    private var _paddingBox:Box;
    
    private var _frameIsPlot:Boolean;
    
    private var _spritePosX:Number;
    private var _spritePosY:Number;

    private var _radius:Number;
    
    public function Annotation(bx:Number, by:Number,
                               ax:Number, ay:Number,
                               px:Number, py:Number,
                               plotBox:Box,
                               paddingBox:Box,
                               frameIsPlot:Boolean,
                               color:uint,
                               border:Number,
                               borderColor:uint,
                               opacity:Number,
                               radius:Number):void 
    {
      _bx          = bx;
      _by          = by;
      _ax          = ax;
      _ay          = ay;
      _px          = px;
      _py          = py;
      _radius      = radius;

      _plotBox = plotBox;
      _paddingBox = paddingBox;
      
      _frameIsPlot = frameIsPlot;

      _color       = color;
      _border      = border;
      _borderColor = borderColor;
      _opacity     = opacity;
      createAndDecorateSprite();
    }

    // subclasses should override this method with one that creates the sprite they want:
    protected function createSprite():MultigraphUIComponent {
      return new MultigraphUIComponent();
    }

    private function createAndDecorateSprite() {
      _annotationSprite = createSprite();
        
      var ax:Number = (_ax+1)*_annotationSprite.width/2;
      var ay:Number = (_ay+1)*_annotationSprite.height/2;
      var bx:Number = _frameIsPlot ? (_bx+1)*_plotBox.width/2 : (_bx+1)*_paddingBox.width/2; 
      var by:Number = _frameIsPlot ? (_by+1)*_plotBox.height/2 : (_by+1)*_paddingBox.height/2;
      _spritePosX =  bx + _px - ax;
      _spritePosY =  by + _py - ay;

      // Draw the border around the sprite and its now present items
      var g:Graphics = _annotationSprite.graphics;      
      g.lineStyle(0, 0xFFFFFF, 0);
      g.beginFill(_color, _opacity);
      if (_radius > 0) {
        g.drawRoundRect(0, 0, _annotationSprite.width + _border / 2, _annotationSprite.height, _radius);
      } else {
        g.drawRect(0, 0, _annotationSprite.width + _border / 2, _annotationSprite.height);
      }
      g.endFill();
      if (_border > 0) {
        g.lineStyle(_border, _borderColor, 1);
        g.beginFill(0xFFFFFF, 0);
        if (_radius > 0) {
          g.drawRoundRect(0, 0, _annotationSprite.width + _border / 2, _annotationSprite.height, _radius);
        } else {
          g.drawRect(0, 0, _annotationSprite.width + _border / 2, _annotationSprite.height);
        }
        g.endFill();
      }

    }

    public function render(paddingBoxSprite:MultigraphUIComponent, plotBoxSprite:MultigraphUIComponent):void {
      //var shadow:DropShadowFilter = new DropShadowFilter();
      //shadow.alpha = 0.5;
      //shadow.distance = 1;
      
      _annotationSprite.x = _spritePosX + (_frameIsPlot ? plotBoxSprite.x : 0);
      _annotationSprite.y = _spritePosY + (_frameIsPlot ? plotBoxSprite.y : 0);
      //_annotationSprite.filters = [shadow];
      paddingBoxSprite.addChild(_annotationSprite);
    } 
  }
}
