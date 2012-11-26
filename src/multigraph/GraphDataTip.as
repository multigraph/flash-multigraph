////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package multigraph
{

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.InteractiveObject;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.filters.DropShadowFilter;
  
  import mx.charts.HitData;
  import mx.charts.styles.HaloDefaults;
  import mx.core.IDataRenderer;
  import mx.core.IFlexModuleFactory;
  import mx.core.IUITextField;
  import mx.core.UIComponent;
  import mx.core.UITextField;
  import mx.events.FlexEvent;
  import mx.graphics.IFill;
  import mx.graphics.SolidColor;
  import mx.graphics.SolidColorStroke;
  import mx.styles.CSSStyleDeclaration;

  public class GraphDataTip extends UIComponent
  {
    private var _textFormat:TextFormat = null;
    private var _textLabel:TextLabel = null;

	public var arrowSide:int = LEFT; // indicates which side of the callout box the arrow should be on.
    // if you want to set arrowSide to something other than the default, do so before setting the 'text' property!

    private var _coordinates:Array = null; // this array holds the coordinates of the vertices of the callout box
	private var _center:Array = null; // coordinates of the "center" of the callout box
	
	private var _hpad:Number = 2; // horizontal pixel padding amount left and right of text in callout box
	private var _vpad:Number = 2; // vertical pixel padding amount above and below text in callout box
	public function set hpad(value:Number):void { _hpad = value; }
	public function set vpad(value:Number):void { _vpad = value; }
	public function set pad(value:Number):void { _hpad = value; _vpad = value; }
	
	private var _bgcolor:uint = 0xcccccc;
	public function set bgcolor(value:uint):void { _bgcolor = value; }
	
	private var _bgalpha:Number = 0.0;
	public function set bgalpha(value:Number):void { _bgalpha = value; }
	
	private var _border:Number = 1.0;
	public function set border(value:Number):void { _border = value; }

	private var _bordercolor:uint = 1.0;
	public function set bordercolor(value:uint):void { _bordercolor = value; }
	
	private var _fontsize:int = 12;
	public function set fontsize(value:int):void {
			_fontsize = value;
			_textFormat.size = value;
	}

	private var _fontcolor:int = 0x000000;
	public function set fontcolor(value:uint):void {
		_fontcolor = value;
		_textFormat.color = value;
	}

	private var _bold:Object= false;
	public function set bold(value:Object):void {
		_bold = value;
		_textFormat.bold = value;
	}

    // The next two variables determine the shape of the callout box arrow.  The callout box is a rectangle with
    // a triangle sticking out from the center of one of its sides.
    private var arrowLengthPixels    = 10; // distance, in pixels, from edge of callout retangle to tip of triangle
    private var arrowBaseWidthPixels = 10; // width, in pixels, of base of triangle along edge of callout rectangle

	public function set text(s:String):void {
      if (_textLabel != null && this.contains(_textLabel)) {
        this.removeChild(_textLabel);
      }

      // dummy TextField used just for sizing:
	  var dummy:TextField = new TextField();
	  dummy.text = s;
	  dummy.setTextFormat(_textFormat);
	  dummy.autoSize = TextFieldAutoSize.LEFT;
	  dummy.embedFonts = true;
	  dummy.selectable = false;	  

      // compute the callout box vertex and center coordinates (depends on text size):
      computeCoordinates(dummy.textWidth + 6 + 2*_hpad, dummy.textHeight + 2*_vpad, arrowBaseWidthPixels, arrowLengthPixels);
      // Note: the +6 that is added to the horiz width above is a fudge factor determined by trial and error
      // because apparently we're not really correctly computing the text size!

      // create and add the text label:
	  _textLabel = new TextLabel(s,
                                 _textFormat,
                                 _center[0]-3, //positionX:Number,
                                 _center[1]+2, //positionY:Number,
                                 0, //anchorX:Number,
                                 0, // anchorY:Number,
                                 0  // degreesRotation:Number
                                 );
	  addChild(_textLabel);
	}

    public function GraphDataTip()
    {
      super();

      _textFormat = new TextFormat();
      _textFormat.font  = "default";
	  _textFormat.bold  = null;
      _textFormat.size  = 12;
      _textFormat.color = 0x000000;
      _textFormat.align = TextFormatAlign.LEFT;
	  
	  // Apply the drop shadow filter to the box.
	  var shadow:DropShadowFilter = new DropShadowFilter();
	  shadow.color = 0x666666;
	  shadow.distance = 2;
	  shadow.angle = 45;
	  
	  this.filters = [shadow];
    }

    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
	  graphics.clear();
      if (_coordinates != null) {
		graphics.beginFill(_bgcolor, _bgalpha);
        graphics.lineStyle(_border, _bordercolor);
        graphics.moveTo(_coordinates[0][0], _coordinates[0][1]);
        for (var i:int=1; i<_coordinates.length; ++i) {
          graphics.lineTo(_coordinates[i][0], _coordinates[i][1]);
        }
        graphics.endFill();
	  }
	  //graphics.lineStyle(1,0x0000ff);
	  //graphics.drawCircle(_center[0], _center[1], 3);
    }

	public static const BOTTOM:int = 0;
	public static const RIGHT:int  = 1;
	public static const TOP:int    = 2;
	public static const LEFT:int   = 3;


    private function computeCoordinates(W:Number, H:Number, B:Number, L:Number) {
      //                                    
      //                                          arrowSide=2: TOP
      //                                    
      //                                                10
      //                                                 *
      //                                                / \
      //                          12                   /   \                   8
      //                            *-----------------*     *-----------------*
      //                            |                11     9                 |
      //                            |                                         |
      //                         13 *                                         * 7
      //                           /                                           \
      //      arrowSide=3:        /                                             \         arrowSide=1:
      //        LEFT          14 *                                               * 6         RIGHT
      //                          \                                             /
      //                           \                                           /
      //                         15 *                                         * 5
      //                            |                                         |
      //                            |                 1     3                 |
      //                            *-----------------*     *-----------------*
      //                           0                   \   /                   4
      //                                                \ /
      //                                                 *
      //                                                 2
      //                    
      //                                        arrowSide=0: BOTTOM
      //
      var w2:Number = W/2;
      var h2:Number = H/2;
      var b2:Number = B/2;

      switch (arrowSide) {
      case BOTTOM:
        _center = [  0  ,  h2+L];  // 2
        break;
      case RIGHT:
        _center = [-w2-L,   0  ];  // 6
        break;
      case TOP:
        _center = [  0  , -h2-L];  // 10
        break;
      case LEFT:
        _center = [ w2+L,  0   ];  // 14
        break;
      }

      _coordinates = [];
      // bottom side:
      _coordinates.push(  [-w2     + _center[0], -h2     + _center[1]  ]);  // 0
      if (arrowSide==BOTTOM) {
        _coordinates.push([-b2     + _center[0], -h2     + _center[1]  ]);  // 1
        _coordinates.push([  0     + _center[0], -h2 - L + _center[1]]);  // 2
        _coordinates.push([ b2     + _center[0], -h2     + _center[1]]);  // 3
      }
              
      // right side:
      _coordinates.push(  [ w2     + _center[0], -h2     + _center[1]]);  // 4
      if (arrowSide==RIGHT) {
        _coordinates.push([ w2     + _center[0], -b2     + _center[1]]);  // 5
        _coordinates.push([ w2 + L + _center[0],   0     + _center[1]]);  // 6
        _coordinates.push([ w2     + _center[0],  b2     + _center[1]]);  // 7
      }
              
      // top side:
      _coordinates.push(  [ w2     + _center[0],  h2     + _center[1]]);  // 8
      if (arrowSide==TOP) {
        _coordinates.push([ b2     + _center[0],  h2     + _center[1]]);  // 9
        _coordinates.push([  0     + _center[0],  h2 + L + _center[1]]);  // 10
        _coordinates.push([-b2     + _center[0],  h2     + _center[1]]);  // 11
      }
              
      // left side:
      _coordinates.push(  [-w2     + _center[0],  h2     + _center[1]]);  // 12
      if (arrowSide==LEFT) {
        _coordinates.push([-w2     + _center[0],  b2     + _center[1]]);  // 13
        _coordinates.push([-w2 - L + _center[0],  0      + _center[1]]);  // 14
        _coordinates.push([-w2     + _center[0], -b2     + _center[1]]);  // 15
      }
      _coordinates.push(  [-w2     + _center[0], -h2     + _center[1]]);  // 0
    }      
      
      

  }

    
}
