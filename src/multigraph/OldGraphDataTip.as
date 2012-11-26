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
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  
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

  public class OldGraphDataTip extends UIComponent
  {

    private var _text:String = null;

    public static const LEFT:int   = 0;
    public static const BOTTOM:int = 1;
    public static const RIGHT:int  = 2;
    public static const TOP:int    = 3;
	
	public var _arrowSide:int = BOTTOM;

    public function set arrowSide(value:*):void {
      if (value is String) {
        var stringValue:String = (value as String).toUpperCase();
        switch (stringValue) {
        case "LEFT":
          _arrowSide = LEFT;
          break;
        case "BOTTOM":
          _arrowSide = BOTTOM;
          break;
        case "RIGHT":
          _arrowSide = RIGHT;
          break;
        case "TOP":
          _arrowSide = TOP;
          break;
        }
      } else {
        _arrowSide = value as int;
      }
      invalidateDisplayList();
    }
	
	public function set text(s:String):void {
      _text = s;
      if (_label != null) {
        setText(s);
      }
	}
	public function get text():String {
      return _text;
	}

    public function OldGraphDataTip()
    {
      super();
      mouseChildren = false;
      mouseEnabled = false;
    }

    private var _label:IUITextField;
    private var _format:TextFormat;
    private var _labelWidth:Number;
    private var _labelHeight:Number;

    override protected function createChildren():void
    {
      super.createChildren();

      // Create the TextField that displays the DataTip text.
      if (!_label)
        {
          _label = IUITextField(createInFontContext(UITextField));

          _label.x = getStyle("paddingLeft")
          _label.y = getStyle("paddingTop");
          _label.autoSize = TextFieldAutoSize.LEFT;
          _label.selectable = false;
          _label.multiline = true;
          _label.wordWrap = false;

          addChild(DisplayObject(_label));

          if (_text != null) {
            setText(_text);
          }
        }
    }

    override protected function measure():void
    {
      super.measure();

      var widthSlop:Number = 1;
      var heightSlop:Number = 1;

      _labelWidth = _label.width + widthSlop;
      _labelHeight = _label.height + heightSlop;
		
      measuredWidth = _labelWidth;
      measuredHeight = _labelHeight;

	  var R:Matrix = new Matrix(1,  0,
	  							0, -1,
	  							0, measuredHeight);
      this.transform.matrix = R;
    }

    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);

      var g:Graphics = graphics;
      g.clear();

      //		       3
      //    *------------------------*
      //    |0                      3|
      //    |                        |
      //  0 |                        | 2
      //    |                        |
      //    |1                      2|
      //    *------------------------*
      //                1

      var X:Array = [0, 0,              measuredWidth,  measuredWidth];
      var Y:Array = [0, measuredHeight, measuredHeight,             0];

      var s:int;
      var t:int;
      var W:int = 10;
      var L:int = 10;

      var xOffset:Array = [                L,  -measuredWidth/2,  -measuredWidth-L, -measuredWidth/2];
      var yOffset:Array = [-measuredHeight/2,  -measuredHeight-L, -measuredHeight/2,               L];

      var xOff:Number = xOffset[_arrowSide];
      var yOff:Number = yOffset[_arrowSide];

	  g.lineStyle(2, 0x000000, 1.0);
	  g.beginFill(0xcccccc, 1.0);
      g.moveTo(xOff + X[0], yOff + Y[0]);
      for (var i:int=0; i<4; ++i) {
        var inext:int = (i+1)%4;
        if (i == _arrowSide) {
          if (i==0 || i==3) {
            s = -1;
          } else {
            s	= 1;
          }
          if (i==0 || i==1) {
            t = 1;
          } else {
            t = -1;
          }
          if (i==0 || i==2) {
            g.lineTo( xOff + X[inext],     yOff + (Y[i]+Y[inext]-t*W)/2.0  );
            g.lineTo( xOff + X[inext]+s*L, yOff + (Y[i]+Y[inext]    )/2.0  );
            g.lineTo( xOff + X[inext],     yOff + (Y[i]+Y[inext]+t*W)/2.0  );
          } else {
            g.lineTo( xOff + (X[i]+X[inext]-t*W)/2.0,  yOff + Y[inext]     );
            g.lineTo( xOff + (X[i]+X[inext]    )/2.0,  yOff + Y[inext]+s*L );
            g.lineTo( xOff + (X[i]+X[inext]+t*W)/2.0,  yOff + Y[inext]     );
          }
        }
        g.lineTo(xOff + X[inext], yOff + Y[inext]);
      }
	  g.endFill();

      _label.x = xOff;
      _label.y = yOff;
    }

	
    private function setText(t:String):void
    {
      var _format:TextFormat = _label.getTextFormat();
      _format.leftMargin = 0;
      _format.rightMargin = 0;
      _label.defaultTextFormat = _format;
      _label.htmlText = t;
//trace('data tip text set to: ' + t);
      invalidateSize();
    }

  }

}
