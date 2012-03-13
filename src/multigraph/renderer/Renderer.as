/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
	import mx.core.UIComponent;
	import multigraph.Axis;
	import multigraph.data.Data;
	import mx.core.UIComponent;
	import multigraph.parsecolor;
    import multigraph.data.Data;
    import multigraph.DataFilter;

  public class Renderer
  {
  	protected var _haxis:Axis;
  	protected var _vaxis:Axis;
    protected var _data:Data;
    protected var _varids:Array;
    protected var _dataVariables:Array;
    protected var _dataFilter:DataFilter;

    static protected var optionsMissing:String = '\
<li><b>missingvalue</b>: value for "missing" data; default is none.  If either missingvalue or missingop are present, both must be present.\
<li><b>missingop</b>: operator to determine whether a data value is "missing"; should be one of "lt", "le", "eq", "ge", or "gt".  A data point is considered missing if and only if the expresion "{value} {missingop} {missingvalue}" is true.  For example, if missingvalue="-1" and missingop="lt", data values less than -1 are considered missing.  If missingvalue and missingop are not specified, no values are considered missing.  If either missingvalue or missingop are present, both must be present.';

    private var _missingvalue:Number;

    private var _missingop_str:String;
    private var _missingopNONE:int   = -10;
    private var _missingopLT:int     =  -2;
    private var _missingopLE:int     =  -1;
    private var _missingopEQ:int     =   0;
    private var _missingopGE:int     =   1;
    private var _missingopGT:int     =   2;
    private var _missingop:int       =  _missingopNONE;
    protected var _rangeOptions:Object = {};

    public function set missingvalue(value:Number):void {
      _missingvalue = value;
    }
    public function get missingvalue():Number {
      return _missingvalue;
    }

    public function set dataFilter(filter:DataFilter) {
      _dataFilter = filter;
    }
    public function get dataFilter():DataFilter {
      return _dataFilter;
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
    
    public function Renderer(haxis:Axis, vaxis:Axis, data:Data, varids:Array) {
    	_haxis         = haxis;
    	_vaxis         = vaxis;
        _data          = data;
        _varids        = varids;
        _dataVariables = [];
        _dataFilter    = null;
        for (var i:int=0; i<varids.length; ++i) {
          _dataVariables[i] = data.varIdToVar(varids[i]);
        }
    }

	// 'initialize()' is called after all the renderer's options are set; subclasses that need to do some processing
	// with option values can override this
    public function initialize():void {}
    
    public function begin(sprite:UIComponent):void {}
    public function dataPoint(sprite:UIComponent, p:Array):void {}
    public function end(sprite:UIComponent):void {}
    
    /** 
    * This function is responisble for drawing the legend icon for the specific renderer
    * as well as the text.
    * */
    public function renderLegendIcon(sprite:UIComponent, legendLabel:String, opacity:Number):void {}

	// The list of renderers is given as a static function here rather than a static
	// var, because using a static var in this way gives a bizarre error that I suspect
	// is an ActionScript bug.  It seems to have to do with the fact that the list
	// involves references to class names.  Anyway, doing it as a function like
	// this seems to work fine.
	// mbp Sat Jan 31 2009  11:41pm    
    public static function rendererList():Array {
      return [Line, Bar, Fill, /*RadarInv,*/ Point, LineError, BarError, PointLine, Band, RangeBar];
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
    /*
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
    */

  	public function transformPoint(output:Array, input:Array):void {
		output[0] = _haxis.dataValueToAxisValue(input[0]);
        for (var i:int = 1; i<input.length; ++i) {
            output[i] = _vaxis.dataValueToAxisValue(input[i]);
        }
  	}

    protected function isMissing(x:Number, vi:int=-1):Boolean {
      // x is the variable value that we want to test for missing
      // vi is the index of the corresponding variable in our list of data variables, or -1 if we don't know it.
      // (The only reason vi should ever be -1 is for backwards compatibility with old renderers that don't pass
      // it in.  Once migration is complete and all renderers pass in vi, code dealing with the -1 case can
      // be eliminated.)

      // If this renderer has an individual setting for _missingOp, use it instead of calling the
      // data variable's isMissing function.   This is for backwards compatibility to support old MUGL
      // files that use "missingop" and "missingvalue" renderer settings, rather than the new style
      // of associating missing info with the data variables.  This can be eliminated once we don't
      // need to support that any more.  (Also elimate all the associated code in this file.)
      if (_missingop != _missingopNONE) {
        if (_missingop == _missingopLT) { return x <  _missingvalue; }
        if (_missingop == _missingopLE) { return x <= _missingvalue; }
        if (_missingop == _missingopEQ) { return x == _missingvalue; }
        if (_missingop == _missingopGE) { return x >= _missingvalue; }
        if (_missingop == _missingopGT) { return x >  _missingvalue; }
      }
      if (vi <= -1 || vi >= _dataVariables.length) { return false; }
      return _dataVariables[vi].isMissing(x);
    }

//    var rangeOptions:Object = {
//      fillcolor : [
//      				{         max: -1, value: '0xee9944' },
//      				{ min:-1, max:  1, value: '0xee9944' },
//      				{ min: 1,          value: '0xee9944' }
//                  ]
//    };

    protected function getRangeOption(name:String, x:Number) {
      // for value x, use first rangeOption for which min < x <= max, if any.  If no
      // range option satisfies that, use the regular (attribute) option value
      var rOpts = _rangeOptions[name];
      var rOpt:Object;
      if (rOpts != undefined) {
        for (var i:int=0; i<rOpts.length; ++i) {
          rOpt = rOpts[i];
          if ( (rOpt.min == undefined || (rOpt.min < x)) && ((rOpt.max == undefined) || (x <= rOpt.max)) ) {
            return rOpt.value;
          }
        }
      }
      return this[name];
    }

    public function setRangeOption(name:String, value:Object, min:String, max:String) {
      var rOpt:Object = { 'value' : value };
      if (min != null) { rOpt.min = Number(min); }
      if (max != null) { rOpt.max = Number(max); }
      var oldRangeOptions:Array = [];
      if (_rangeOptions[name] != undefined) {
        oldRangeOptions = _rangeOptions[name];
      }
      _rangeOptions[name] = [];
      var rOptInserted:Boolean = false;
      for (var i:int=0; i<oldRangeOptions.length; ++i) {
        if (!rOptInserted && ((rOpt.min == undefined) || (rOpt.min < oldRangeOptions[i].min))) {
          _rangeOptions[name].push(rOpt);
          rOptInserted = true;
        }
        _rangeOptions[name].push(oldRangeOptions[i]);
      }
	  if (!rOptInserted) {
        _rangeOptions[name].push(rOpt);
      }
      
    }

  }
}
