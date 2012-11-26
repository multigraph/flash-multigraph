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
        
  public class AxisBinding
  {
    private var _id:String;
    private var _axes:Array = [];
    public function get id():String { return _id; }

    public function AxisBinding(id:String):void {
      _id = id;
      _s_instances[id] = this;
    }

    public function addAxis(axis:Axis, min:Number, max:Number):void {
      this._axes.push({
          axis   : axis,
            factor : 1 / (max - min),
            offset : -min / (max - min),
            min    : min,
            max    : max
            });
    }

    public function removeAxis(axis:Axis):void {
      for (var i:int=0; i<this._axes.length(); ++i) {
        if (_axes[i].axis == axis) {
          _axes.splice(i,1);
          break;
        }
      }
    }

    public function setDataRange(initiatingAxis:Axis, min:Number, max:Number, dispatch:Boolean=true):void {
      var initiatingAxisIndex:int;
      for (var i:int=0; i<_axes.length; ++i) {
        if (_axes[i].axis == initiatingAxis) {
          initiatingAxisIndex = i;
          break;
        }
      }
      for (var j:int=0; j<_axes.length; ++j) {
        if (j==initiatingAxisIndex) {
          _axes[j].axis.setDataRangeNoBind(min, max, dispatch);
        } else {
          _axes[j].axis.setDataRangeNoBind(
                                           (min * _axes[initiatingAxisIndex].factor + _axes[initiatingAxisIndex].offset
                                            - _axes[j].offset)
                                           / _axes[j].factor,
                                           (max * _axes[initiatingAxisIndex].factor + _axes[initiatingAxisIndex].offset
                                            - _axes[j].offset)
                                           / _axes[j].factor,
										   dispatch
                                           );
        }
      }

    }

    ////////////////////////////////////////////////////////
    // (for use by external bindings:)
    //
    public static function setAxisBindingDataRangeNoBind(bindingId:String, min:Number, max:Number, factor:Number, offset:Number):void {
      var binding:AxisBinding = getInstanceById(bindingId);
      if (binding != null) {
        binding.setDataRangeNoBind(min, max, factor, offset);
      }
    }
    public function setDataRangeNoBind(min:Number, max:Number, factor:Number, offset:Number):void {
      for (var j:int=0; j<_axes.length; ++j) {
        _axes[j].axis.setDataRangeNoBind(
                                         (min * factor + offset - _axes[j].offset) / _axes[j].factor,
                                         (max * factor + offset - _axes[j].offset) / _axes[j].factor
                                         );
      }
    }
    //
    ////////////////////////////////////////////////////////

    private static var _s_instances:Array = [];

    public static function getInstanceById(id:String) {
      return _s_instances[id];
    }

    public static function findByIdOrCreateNew(id:String):AxisBinding {
      var binding:AxisBinding = getInstanceById(id);
      if (binding == null) {
        binding = new AxisBinding(id);
      }
      return binding;
    }
  }
}
