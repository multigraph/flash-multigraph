/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import flash.display.Graphics;

  public class GridDataFilter extends DataFilter
  {
    private var _rows:int;
    private var _columns:int;
    private var _width:int;
    private var _height:int;
    private var _grid:Array;
    private var _dx:Number;
    private var _dy:Number;
    private var _i:int;
    private var _j:int;
    private var _visible:Boolean;

    private var _hDataMin:Number;
    private var _hDataMax:Number;
    private var _vDataMin:Number;
    private var _vDataMax:Number;
    private var _hBase:Number;
    private var _vBase:Number;
    private var _hAxis:Axis;
    private var _vAxis:Axis;

    public function GridDataFilter(rows:int, columns:int, width:int, height:int, visible:Boolean) {
      _rows    = rows;
      _columns = columns;
      _width   = width;
      _height  = height;
      /*
      _dx      = Number(_width)  / Number(_columns);
      _dy      = Number(_height) / Number(_rows);
      */
      _grid    = new Array(_rows);
      _visible = visible;
      for (var i:int=0; i<_rows; ++i) {
        _grid[i] = new Array(_columns);
      }
    }

    override public function reset(hAxis:Axis, vAxis:Axis):void {
      _hDataMin = hAxis.dataMin;
      _hDataMax = hAxis.dataMax;
      _vDataMin = vAxis.dataMin;
      _vDataMax = vAxis.dataMax;
      _dx       = (_hDataMax - _hDataMin) / Number(_columns);
      _dy       = (_vDataMax - _vDataMin) / Number(_rows);
      _hAxis    = hAxis;
      _vAxis    = vAxis;
/*      
      _jBase    = int(hDataMin / _dx);
      _iBase    = int(vDataMin / _dy);
*/
      _hBase    = NumberLabeler.firstTick(_hDataMin, _hDataMax, _dx, 0); 
      _vBase    = NumberLabeler.firstTick(_vDataMin, _vDataMax, _dy, 0); 

      for (var i:int=0; i<_rows; ++i) {
        for (var j:int=0; j<_columns; ++j) {
          _grid[i][j] = false;
        }
      }
    }

    override public function filter(datap:Array, pixelp:Array):Boolean {
      
      _j = int( (datap[0]-_hBase) / _dx);
      _i = int( (datap[1]-_vBase) / _dy);
      if (_j < 0) { _j = 0; }
      if (_j >= _columns) { _j = _columns-1; }
      if (_i < 0) { _i = 0; }
      if (_i >= _rows) { _i = _rows-1; }
      if (_grid[_i][_j]) { return true; }
      _grid[_i][_j] = true;
      return false;



      /*
      _j = int(pixelp[0] / _dx);
      _i = int(pixelp[1] / _dy);
      if (_j < 0) { _j = 0; }
      if (_j >= _columns) { _j = _columns-1; }
      if (_i < 0) { _i = 0; }
      if (_i >= _rows) { _i = _rows-1; }
      if (_grid[_i][_j]) { return true; }
      _grid[_i][_j] = true;
      return false;
      */
    }

    override public function draw(g:Graphics):void {
      if (!_visible) { return; }
      g.lineStyle(1, 0xff0000, 1);
      for (var i:int=0; i<_rows; ++i) {
      	var y:Number = _vAxis.dataValueToAxisValue(_vBase + i*_dy);  
        g.moveTo(0,      y);
        g.lineTo(_width, y);
      }
      for (var j:int=0; j<_columns; ++j) {
      	var x:Number = _hAxis.dataValueToAxisValue(_hBase + j*_dx);
        g.moveTo(x, 0);
        g.lineTo(x, _height);
      }
    }

  }
}
