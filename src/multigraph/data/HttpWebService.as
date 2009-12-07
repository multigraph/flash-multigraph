/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.data
{
  import flash.events.*;
  import flash.net.*;
  
  import multigraph.Graph;

  public class HttpWebService extends WebService
  {
    private var _url:String;
    private var _graph:Graph;
    public function HttpWebService(url:String, graph:Graph) {
      _url = url;
      _graph = graph;
    }

    public override function request(variables:Array, min:Number, minBuffer:int,
    								 max:Number, maxBuffer:int,
    								 callback:Object):void {
      var vMin:String, vMax:String;
      if (variables[0].parser != null) {
        vMin = variables[0].parser.format(min);
        vMax = variables[0].parser.format(max);
      } else {
        vMin = '' + min;
        vMax = '' + max;
      }

      var url:String = _url + '/' + vMin + ',' + vMax;
      if (minBuffer>0 || maxBuffer>0) {
        url = url + '/' + minBuffer + ',' + maxBuffer;
      }
	    
      var loader:URLLoader = new URLLoader();
      var requestStart:String = new Date().toTimeString();
      var networkable:Object = {location:null, request:null, receive:null, status:null, http:null};
      
      networkable.location = url;
      networkable.request = requestStart;
      loader.dataFormat = "text";
      loader.addEventListener( Event.COMPLETE,
                               function(event:Event):void {
                                 callback(event.target.data);
                                 networkable.receive = new Date().toTimeString();
                                 networkable.status = event.type;
                                 _graph.networkMonitorEndRequest(networkable);
                               });
                               
      loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,
      							function(event:HTTPStatusEvent):void {
      								networkable.http = event.status;
      								_graph.networkMonitorEndRequest(networkable);
      							});
	  _graph.diagnosticOutput('requesting data from url "'+url+'"');
      loader.load( new URLRequest( url ) );
      
      _graph.networkMonitorStartRequest(networkable);
    }
  }
}
