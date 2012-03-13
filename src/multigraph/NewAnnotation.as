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
  import flash.geom.Matrix;
  import flash.filters.DropShadowFilter;
  
  import mx.core.UIComponent;

  /*
   * An Annotation is a rectangular region that holds some kind of
   * decoration, such as a text label, legend, or image, that is drawn on
   * top of the graph.  Annotation is an abstract superclass; there are no
   * instances of Annotation itself --- only of its subclasses.  The
   * current subclasses are Legend and Title; I may add an Image subclass
   * later.
   *
   * The usage for all Annoation subclasses is the same: this superclass
   * contains attributes that specify location of the annotation rectangle
   * using the standard base/anchor/position/frame (no angle) mechanism
   * used elsewhere in Multigraph, as well as attributes specifying the
   * annotation's background color, opacity, border color, border
   * thickness, and corner radius.
   * 
   * To use an Annotation, simply create an instance of one of its
   * subclasses, and then just call its render(...) method, which will add
   * the annotation to the graph's paddingBoxSprite.
   * 
   * To create a new subclass, just extend annotation, provide a
   * constructor that takes whatever argments are appropriate for the
   * subclass, and override the "createSprite" method, which should simply
   * create whatever UIComponent (the method really should be called
   * createUIComponent instead!) is desired.  The superclass "render"
   * method takes care of positioning the sprite, drawing its background
   * and border, and adding it to the graph's paddingBoxSprite.
   * 
   */
  public class NewAnnotation extends UIComponent
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
    
    private var _annotationSprite:UIComponent;

	private var _graph:Graph;
    
    private var _frameIsPlot:Boolean;
    
    private var _spritePosX:Number;
    private var _spritePosY:Number;

    private var _radius:Number;
    
    public function NewAnnotation(bx:Number, by:Number,
                               ax:Number, ay:Number,
                               px:Number, py:Number,
							   graph:Graph,
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

      _graph       = graph;
      
      _frameIsPlot = frameIsPlot;

      _color       = color;
      _border      = border;
      _borderColor = borderColor;
      _opacity     = opacity;
	  
	  _annotationSprite = null;
    }

    /*

      Subclasses should simply override createChildren(), and in
      createChildren(), they should set the width and height, and then
      call super.createChildren().  This class takes care of
      positioning via initializeGeometry().

    */

    override protected function createChildren():void {
      // The following seems backwards, but it's correct.  If
      // initializeGeometry() has already been called at this point,
      // call it again, because our subclass's createChildren()
      // probably set our width and height, so the geometry
      // calculations will need to be redone.
	  if (_geometryInitialized) {
	  	initializeGeometry();
	  }
    }

	var _geometryInitialized : Boolean = false;

    public function initializeGeometry():void {
      var ax:Number = (_ax+1)*this.width/2;
      var ay:Number = (_ay+1)*this.height/2;
      var bx:Number = _frameIsPlot ? (_bx+1)*_graph.plotBox.width/2 : (_bx+1)*_graph.paddingBox.width/2; 
      var by:Number = _frameIsPlot ? (_by+1)*_graph.plotBox.height/2 : (_by+1)*_graph.paddingBox.height/2;
      this.x = bx + _px - ax + (_frameIsPlot ? _graph.plotMargin.left   : 0);
      this.y = by + _py - ay + (_frameIsPlot ? _graph.plotMargin.bottom : 0);
      _geometryInitialized = true;
    }


    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      graphics.lineStyle(0, 0xFFFFFF, 0);
      graphics.beginFill(_color, _opacity);
      if (_radius > 0) {
        graphics.drawRoundRect(0, 0, this.width + _border / 2, this.height, _radius);
      } else {
        graphics.drawRect(0, 0, this.width + _border / 2, this.height);
      }
      graphics.endFill();
      if (_border > 0) {
        graphics.lineStyle(_border, _borderColor, 1);
        graphics.beginFill(0xFFFFFF, 0);
        if (_radius > 0) {
          graphics.drawRoundRect(0, 0, this.width + _border / 2, this.height, _radius);
        } else {
          graphics.drawRect(0, 0, this.width + _border / 2, this.height);
        }
        graphics.endFill();
      }
    }



  }
}
