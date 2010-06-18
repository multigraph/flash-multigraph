/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph {
  import mx.core.UIComponent;
    
  public class Cursor
  {
    public static var STATE_DEFAULT:int                    =  0;
    public static var STATE_PAN_HORIZONTAL_INACTIVE:int    =  1;
    public static var STATE_PAN_HORIZONTAL_ACTIVE:int      =  2;
    public static var STATE_PAN_VERTICAL_INACTIVE:int      =  3;
    public static var STATE_PAN_VERTICAL_ACTIVE:int        =  4;
    public static var STATE_ZOOM_HORIZONTAL_INACTIVE:int   =  5;
    public static var STATE_ZOOM_HORIZONTAL_ACTIVE:int     =  6;
    public static var STATE_ZOOM_VERTICAL_INACTIVE:int     =  7;
    public static var STATE_ZOOM_VERTICAL_ACTIVE:int       =  8;

    [Embed(source="assets/cursors/HandClosed.png")]
      [Bindable]
      private var cursorHandClosed:Class;

    [Embed(source="assets/cursors/HandOpen.png")]
      [Bindable]
      private var cursorHandOpen:Class;

    [Embed(source="assets/cursors/Horizontal.png")]
      [Bindable]
      private var cursorHorizontal:Class;

    [Embed(source="assets/cursors/Vertical.png")]
      [Bindable]
      private var cursorVertical:Class;

    [Embed(source="assets/cursors/MagnifierMinusHorizontal.png")]
      [Bindable]
      private var cursorMagnifierMinusHorizontal:Class;

    [Embed(source="assets/cursors/MagnifierMinusVertical.png")]
      [Bindable]
      private var cursorMagnifierMinusVertical:Class;

    [Embed(source="assets/cursors/MagnifierPlusHorizontal.png")]
      [Bindable]
      private var cursorMagnifierPlusHorizontal:Class;

    [Embed(source="assets/cursors/MagnifierPlusVertical.png")]
      [Bindable]
      private var cursorMagnifierPlusVertical:Class;

    private var _owner : UIComponent;
    private var _state : int;
    private var _cursor : Class;

  public function Cursor(owner:UIComponent) {
    this._owner  = owner;
    this._state  = STATE_DEFAULT;
    this._cursor = null;
  }

  public function setState(state : int):void {
    if (state != this._state) {
      var cursor : Class = null;
      switch (state) {
      case STATE_PAN_HORIZONTAL_INACTIVE:
      case STATE_PAN_HORIZONTAL_ACTIVE:
        cursor = cursorHorizontal;
        break;
      case STATE_PAN_VERTICAL_INACTIVE:
      case STATE_PAN_VERTICAL_ACTIVE:
        cursor = cursorVertical;
        break;
      case STATE_ZOOM_HORIZONTAL_INACTIVE:
      case STATE_ZOOM_HORIZONTAL_ACTIVE:
        cursor = cursorMagnifierPlusHorizontal;
        break;
      case STATE_ZOOM_VERTICAL_INACTIVE:
      case STATE_ZOOM_VERTICAL_ACTIVE:
        cursor = cursorMagnifierPlusVertical;
        break;
      default:
      case STATE_DEFAULT:
        cursor = null;
        break;
      }
      this._state = state;
      if (cursor == null) {
        this._owner.cursorManager.removeAllCursors();
      } else if (cursor != this._cursor) {
        this._owner.cursorManager.setCursor(cursor);
      }
      this._cursor = cursor;
    }
  }

}
}
