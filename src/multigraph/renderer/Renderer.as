/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
	import multigraph.Axis;
	import multigraph.MultigraphUIComponent;

  public class Renderer
  {
  	protected var _haxis:Axis;
  	protected var _vaxis:Axis;

    static protected var optionsMissing:String = '\
<li><b>missingvalue</b>: value for "missing" data; default is none.  If either missingvalue or missingop are present, both must be present.\
<li><b>missingop</b>: operator to determine whether a data value is "missing"; should be one of "lt", "le", "eq", "ge", or "gt".  A data point is considered missing if and only if the expresion "{value} {missingop} {missingvalue}" is true.  For example, if missingvalue="-1" and missingop="lt", data values less than -1 are considered missing.  If missingvalue and missingop are not specified, no values are considered missing.  If either missingvalue or missingop are present, both must be present.';

    private var _missingvalue:Number;

    private var _missingop_str:String;
    private var _missingopNONE:int = -10;
    private var _missingopLT:int   =  -2;
    private var _missingopLE:int   =  -1;
    private var _missingopEQ:int   =   0;
    private var _missingopGE:int   =   1;
    private var _missingopGT:int   =   2;
    private var _missingop:int     =  _missingopNONE;
  	
    public function set missingvalue(value:Number):void {
      _missingvalue = value;
    }
    public function get missingvalue():Number {
      return _missingvalue;
    }

    public function set missingop(op_str:String):void {
      op_str = op_str.toLowerCase();
      if (op_str == "lt") {
        _missingop = _missingopLT;
      }
      else if (op_str == "le") {
        _missingop = _missingopLE;
      }
      else if (op_str == "eq") {
        _missingop = _missingopEQ;
      }
      else if (op_str == "ge") {
        _missingop = _missingopGE;
      }
      else if (op_str == "gt") {
        _missingop = _missingopGT;
      } else {
        return;
      }
      _missingop_str = op_str;
    }
    public function get missingop():String {
      return _missingop_str;
    }
    
    public function Renderer(haxis:Axis, vaxis:Axis) {
    	_haxis = haxis;
    	_vaxis = vaxis;
    }
    
    public function begin(sprite:MultigraphUIComponent):void {}
    public function dataPoint(sprite:MultigraphUIComponent, p:Array):void {}
    public function end(sprite:MultigraphUIComponent):void {}
    
    /** 
    * This function is responisble for drawing the legend icon for the specific renderer
    * as well as the text.
    * */
    public function renderLegendIcon(sprite:MultigraphUIComponent, legendLabel:String, opacity:Number):void {}

	// The list of renderers is given as a static function here rather than a static
	// var, because using a static var in this way gives a bizarre error that I suspect
	// is an ActionScript bug.  It seems to have to do with the fact that the list
	// involves references to class names.  Anyway, doing it as a function like
	// this seems to work fine.
	// mbp Sat Jan 31 2009  11:41pm    
    public static function rendererList():Array {
      return [Line, Bar, Fill, /*RadarInv,*/ Point, LineError, BarError, PointLine];
      /*
      return [{'class': Bar,   'keyword': Bar.keyword,  'description': Bar.description,  'options': Bar.options  },
              {'class': Line,  'keyword': Line.keyword, 'description': Line.description, 'options': Line.options },
              {'class': Fill,  'keyword': Fill.keyword, 'description': Fill.description, 'options': Fill.options }
              ];
      */
    }
    
    public static function getRenderer(string:String):Object {
    	var renderers:Array = rendererList();
    	for (var i:int=0; i<renderers.length; ++i) {
    		if (string == renderers[i]['keyword']) {
    			return renderers[i];
    		}
    	}
    	return null;
    }
    
    /**
    * This function can be used by the renderer whenever setting any of the color options. In most cases
    * experienced users will probably want to supply a hex set for a specific color. The follow function 
    * takes several popular color names and returns the hex uint code for that color.
    * */
    protected function parseColor(color:String):uint {
		switch(color) {
			case "black":   return 0x000000;
    		case "red":     return 0xFF0000;
    		case "green":   return 0x00FF00;
    		case "blue":    return 0x0000FF;
    		case "cyan":    return 0x00FFFF;
    		case "yellow":  return 0xFFFF00;
    		case "magenta": return 0xFF00FF;
    		case "skyblue": return 0x87CEEB;
    		case "khaki":   return 0xF0E68C;
    		case "orange":  return 0xFFA500;
    		case "salmon":  return 0xFA8072;
    		case "olive":   return 0x9ACD32;
    		case "sienna":  return 0xA0522D;
    		case "pink":    return 0xFFB5C5;
    		case "violet":  return 0xEE82EE;
		}
		return uint(color);
	}

  	public function transformPoint(output:Array, input:Array):void {
		output[0] = _haxis.dataValueToAxisValue(input[0]);
        for (var i:int = 1; i<input.length; ++i) {
            output[i] = _vaxis.dataValueToAxisValue(input[i]);
        }
  	}

    protected function isMissing(x:Number):Boolean {
      if (_missingop == _missingopNONE) { return false; }
      if (_missingop == _missingopLT) { return x <  _missingvalue; }
      if (_missingop == _missingopLE) { return x <= _missingvalue; }
      if (_missingop == _missingopEQ) { return x == _missingvalue; }
      if (_missingop == _missingopGE) { return x >= _missingvalue; }
      if (_missingop == _missingopGT) { return x >  _missingvalue; }
      return false;
    }

  }
}
