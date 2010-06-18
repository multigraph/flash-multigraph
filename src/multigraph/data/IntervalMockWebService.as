/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data
{
  /**
   * Mock web service object for use in testing.  Returns the given value for
   * integer values in the interval [min,max].  Returns no data outside that interval.
   */
  public class IntervalMockWebService extends WebService
  {
    private var _intervalMin:Number;
    private var _intervalMax:Number;
    private var _intervalValue:Number;
    public function IntervalMockWebService(min:Number, max:Number, value:Number) {
      _intervalMin   = min;
      _intervalMax   = max;
      _intervalValue = value;
    }
    public override function request(variables:Array, min:Number, minBuffer:int,
    								 max:Number, maxBuffer:int,
    								 callback:Object):void {

      if (min != int(min)) {
        if (min > 0) {
          min = int(min+1);
        } else {
          min = -int(-min);
        }
      }

      if (max != int(max)) {
        if (max > 0) {
          max = int(max);
        } else {
          max = -int(1-max);
        }
      }

      min -= minBuffer;
      max += maxBuffer;

      var answer:String = '<mugl><data><values>\n';
      for (var x:Number=min; x<=max; x+=1) {
        if (x>=_intervalMin && x<=_intervalMax) {
          answer += x + ',' + _intervalValue + '\n';
        }
      }
      answer += '</values></data></mugl>\n';
      callback(answer);
    }
  }
}
