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
  public class ZoomConfig
  {
	private var _allowed:Boolean;
	public function get allowed():Boolean { return _allowed; }
	public function set allowed(allowed:Boolean):void { _allowed = allowed; }

	private var _haveAnchor:Boolean;
	public function get haveAnchor():Boolean { return _haveAnchor; }
	private var _anchor:Number;
	public function get anchor():Number { return _anchor; }
	public function set anchor(val:Number):void { _anchor = val; }
		
	public function ZoomConfig(allowed:String, anchor:String) {
	  setConfig(allowed, anchor);
	}
		
	public function setConfig(allowed:String, anchor:String):void
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
			
			
	}

  }

}

