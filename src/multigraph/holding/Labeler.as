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
    import flash.text.TextFormat;
	import mx.core.UIComponent;
	
	public class Labeler
	{
      protected var _spacing:Number;  // Number of axis relative spaces to place labels
      protected var _unit:String;     // Unit for each label (i.e., Hours, Days, Number)                                              
      protected var _formatString:String;   // Format string used to format the label on ouput. (ANSI C String format syntax)                 
      protected var _start:Number;    // Value used to begin labeling the axis                                                          
      protected var _px:Number;       // Offset in negative|positive x direction for the label only                                       
      protected var _py:Number ;      // Offset in negative|positive y direction for the label only                                         
      protected var _angle:Number;    // The angle of the label relative to its anchor point in degrees           
      protected var _ax:Number;       // x anchor point to a theoretical box around a label
      protected var _ay:Number;       // y anchor point to a theoretical box around a label

      protected var _textFormat:TextFormat;
      protected var _boldTextFormat:TextFormat;

      protected var _useBold:Boolean = false;
      
      public function Labeler(spacing:Number, unit:String, formatString:String, start:Number, px:Number, py:Number, angle:Number, ax:Number, ay:Number,
                              textFormat:TextFormat, boldTextFormat:TextFormat) {
        _spacing = spacing;
        _unit    = unit;
        _formatString = (formatString == null) ? "number" : formatString;
        _start  = start;
        _px     = px;
        _py     = py;
        _angle  = angle;
        _ax     = ax;
        _ay     = ay;

        _textFormat = textFormat;
        _boldTextFormat = boldTextFormat;
      }
      
      public function labelDensity(axis:Axis):Number { return 0; }
      public function renderLabel(sprite:UIComponent, axis:Axis, value:Number):void {}
	  public function prepare(dataMin:Number, dataMax:Number):void {}
	  public function hasNext():Boolean { return true; }
	  public function next():Number { return 0; }
      public function set useBold(b:Boolean):void { _useBold = b; }
      //public function set textFormat(newTextFormat:TextFormat) { _textFormat = newTextFormat; }
      public function get spacing():Number { return _spacing; }

	}
}

// Labeler:
// 
// A Labeler object renders text labels for values along an axis in a
// given format and at a given spacing from each other.  This is an
// abstract superclass; specific subclasses implement labelers for
// various specific data types such as number and datetime.
// 
//     labelDensity(axis:Axis)
//         Returns a number between 0 and 1 representing (an estimate
//         of) how "dense" the labels that this labeler would put on
//         the given axis would be, with 0 representing the least
//         density, i.e. no labels at all, and 1 meaning that the
//         labels completely run together, touching or overlapping
//         each other.  (This density refers to the text labels
//         themselves, not the tick marks.)
// 
//     prepare(dataMin:Number, dataMax:Number)
//         Prepares the labeler for stepping through a sequence of
//         labels in a given range of data values.
// 
//     hasNext()
//         Indicates whether there are any more values to be stepped
//         through in the range specified in the last call to
//         prepare(...).
// 
//     next()
//         Returns the next value in the sequence of values being
//         stepped through in the range specified in the last call to
//         prepare(...).
// 
//     renderLabel(sprite:Sprite, axis:Axis, value:Number)
//         Draws a text label at the given data value location, on the
//         given axis, in the given sprite.
