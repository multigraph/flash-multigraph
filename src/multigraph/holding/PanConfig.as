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
	public class PanConfig
	{
		private var _allowed:Boolean;
		private var _min:Number;
		private var _haveMin:Boolean;
		private var _max:Number;
		private var _haveMax:Boolean;
		private var _axis:Axis;
		
		public function get haveMin():Boolean { return _haveMin; }
		public function get haveMax():Boolean { return _haveMax; }
		public function get allowed():Boolean { return _allowed; }
		public function set allowed(allowed:Boolean):void { _allowed = allowed; }
		public function get min():Number { return _min; }
		public function get max():Number { return _max; }
		public function set min(val:Number):void { _min = val; }
		public function set max(val:Number):void { _max = val; }
		
		public function PanConfig(allowed:String, min:String, max:String, axis:Axis) {
			this._axis = axis;
			setConfig(allowed, min, max);
		}
		
		public function setConfig(allowed:String, min:String, max:String):void
		{
			if (allowed==null || allowed=='yes') {
				_allowed = true;
			} else {
				_allowed = false;
			}
			
			if (min==null || min=='') {
				_haveMin = false;
			} else {
				_haveMin = true;
				//_min = Number(min);
				_min = _axis.parse(min);
			}
			
			if (max==null || max=='') {
				_haveMax = false;
			} else {
				_haveMax = true;
				//_max = Number(max);
				_max = _axis.parse(max);
			}
			
		}

	}
}
