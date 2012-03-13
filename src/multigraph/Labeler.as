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
      protected var _axis:Axis;       // the axis that this labeler is for
      protected var _spacing:Number;  // Number of axis relative spaces to place labels
      protected var _unit:String;     // Unit for each label (i.e., Hours, Days, Number)                                              
      protected var _formatString:String;   // Format string used to format the label on ouput. (ANSI C String format syntax)                 
      protected var _visible:Boolean; // whether or not to actually draw labels
      protected var _start:Number;    // Value used to begin labeling the axis                                                          
      protected var _position:DPoint; // Offset (position) for label
      protected var _anchor:DPoint;   // Anchor for label
      protected var _angle:Number;    // The angle of the label relative to its anchor point in degrees           

      protected var _textFormat:TextFormat;
	  protected var _densityFactor:Number=1;

      private var _positionWasNull : Boolean;
      private var _anchorWasNull : Boolean;
      
      public function Labeler(axis:Axis,
                              spacing:Number,
                              unit:String,
                              formatString:String,
                              visible:Boolean,
                              start:Number,
                              position:DPoint,
                              anchor:DPoint,
                              angle:Number,
                              textFormat:TextFormat,
	  						  densityFactor:Number) {
        _axis         = axis;
        _spacing      = spacing;
        _unit         = unit;
        _formatString = (formatString == null) ? "number" : formatString;
        _visible      = visible;
        _start        = start;
        _position     = position;
        _angle        = angle;
        _anchor       = anchor;
        _textFormat   = textFormat;
		_densityFactor = densityFactor;

        _positionWasNull = (_position == null);
        _anchorWasNull   = (_anchor   == null);
      }
      
      public function labelDensity():Number { return 0; }
      public function renderLabel(sprite:UIComponent, value:Number):void {}
	  public function prepare(dataMin:Number, dataMax:Number):void {}
	  public function hasNext():Boolean { return true; }
	  public function next():Number { return 0; }
      public function get spacing():Number { return _spacing; }

      public function initializeGeometry() : void {
        if (_positionWasNull) {
          if (_axis.orientation == AxisOrientation.HORIZONTAL) {
            if (_axis.perpOffset > _axis.graph.plotBox.height/2) {
              _position = Config.AXIS_LABEL_DEFAULT_POSITION_HORIZ_TOP;
            } else {
              _position = Config.AXIS_LABEL_DEFAULT_POSITION_HORIZ_BOT;
            }
          } else {
            if (_axis.perpOffset > _axis.graph.plotBox.width/2) {
              _position = Config.AXIS_LABEL_DEFAULT_POSITION_VERT_RIGHT;
            } else {
              _position = Config.AXIS_LABEL_DEFAULT_POSITION_VERT_LEFT;
            }
          }
        }
        if (_anchorWasNull) {
          if (_axis.orientation == AxisOrientation.HORIZONTAL) {
            if (_axis.perpOffset > _axis.graph.plotBox.height/2) {
              _anchor = Config.AXIS_LABEL_DEFAULT_ANCHOR_HORIZ_TOP;
            } else {
              _anchor = Config.AXIS_LABEL_DEFAULT_ANCHOR_HORIZ_BOT;
            }
          } else {
            if (_axis.perpOffset > _axis.graph.plotBox.width/2) {
              _anchor = Config.AXIS_LABEL_DEFAULT_ANCHOR_VERT_RIGHT;
            } else {
              _anchor = Config.AXIS_LABEL_DEFAULT_ANCHOR_VERT_LEFT;
            }
          }
        }
      }

      public static function create(type         : DataType,
                                    axis         : Axis,
                                    spacing      : Number,
                                    unit         : String,
                                    formatString : String,
                                    visible      : Boolean,
                                    start        : String, 
                                    position     : DPoint,
                                    anchor       : DPoint,
                                    angle        : Number,
                                    textFormat   : TextFormat,
	  								densityFactor : Number) : Labeler {
        if (type == DataType.DATETIME) {
          return new DateLabeler(axis,
                                 spacing,
                                 unit,
                                 formatString,
                                 visible,
                                 start,
                                 position,
                                 anchor,
                                 angle,
                                 textFormat,
								 densityFactor);
        } else {
          return new NumberLabeler(axis,
                                   spacing,
                                   unit,
                                   formatString,
                                   visible,
                                   parseFloat(start),
                                   position,
                                   anchor,
                                   angle,
                                   textFormat,
								   densityFactor);
        }
      }
          
          

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
