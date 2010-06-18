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
  import flash.events.*;
  import flash.net.*;
  import multigraph.format.DateFormatter;
	
  public class MockLoader
  {
    private var _min:String;
    private var _max:String;
    private var _df:DateFormatter;

    public function MockLoader(min:String, max:String) {
      _min = min;
      _max = max;
      _df = new DateFormatter('YMDHi');
    }

    public function getData():String {
      var t:Number = _df.parse(_min);
      var maxt:Number = _df.parse(_max);
      var ts:String;
      var h:String;
      var answer:String = '<mugl><data><values>\n';
      while (t<maxt) {
        ts = _df.format(t);
        h = ts.substring(8,10);
        answer += ts + ',' + h + '\n';
        t += 3600000;
      }
      answer += '</values></data></mugl>';
      return answer;
    }

    private function gethour(s:String) {
      return s.substring(8,10);
    }

  }

}
