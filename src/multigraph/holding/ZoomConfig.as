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
  public class ZoomConfig
  {
    private var _axis:Axis;

	private var _allowed:Boolean;
	public function get allowed():Boolean { return _allowed; }
	public function set allowed(allowed:Boolean):void { _allowed = allowed; }

	private var _haveAnchor:Boolean;
	public function get haveAnchor():Boolean { return _haveAnchor; }
	private var _anchor:Number;
	public function get anchor():Number { return _anchor; }
	public function set anchor(val:Number):void { _anchor = val; }

    private var _min:Number;
    private var _haveMin:Boolean;
    private var _max:Number;
    private var _haveMax:Boolean;
    
    public function get haveMin():Boolean { return _haveMin; }
    public function get haveMax():Boolean { return _haveMax; }
    public function get min():Number { return _min; }
    public function get max():Number { return _max; }
    public function set min(val:Number):void { _min = val; }
    public function set max(val:Number):void { _max = val; }
		
	public function ZoomConfig(allowed:String, anchor:String, min:String, max:String, axis:Axis) {
      this._axis = axis;
	  setConfig(allowed, anchor, min, max);
	}
		
	public function setConfig(allowed:String, anchor:String, min:String, max:String):void
	{
	  if (allowed==null || allowed=='yes') {
		_allowed = true;
	  } else {
		_allowed = false;
	  }
			
	  if (anchor==null || anchor=='') {
		_haveAnchor = false;
	  } else {
		_haveAnchor = true;
		_anchor = Number(anchor);
	  }

      if (min==null || min=='') {
        _haveMin = false;
      } else {
        _haveMin = true;
        _min = _axis.parse(min);
      }
      
      if (max==null || max=='') {
        _haveMax = false;
      } else {
        _haveMax = true;
        _max = _axis.parse(max);
      }
			
	}

  }

}

