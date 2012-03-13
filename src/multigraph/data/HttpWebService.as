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
      
      //networkable.receive = new Date().toTimeString();
	  var spinnerIndex : int = _graph.startAvailableSpinner();

      loader.dataFormat = "text";
	  loader.addEventListener( Event.COMPLETE,
		  function(event:Event):void {
			  callback(event.target.data);
              _graph.stopSpinner(spinnerIndex);
		  });
	  loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,
		  function(event:Event):void {
              _graph.stopSpinner(spinnerIndex);
              _graph.multigraph.alert('HttpWebService Security Error', 'Error');
		  });
	  loader.addEventListener( IOErrorEvent.IO_ERROR,
		  function(event:Event):void {
              _graph.stopSpinner(spinnerIndex);
              _graph.multigraph.alert('HttpWebService IO Error', 'Error');
		  });
      
	  
	  //loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      //loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            //Event.COMPLETE
            //Event.OPEN
            //ProgressEvent.PROGRESS
            //HTTPStatusEvent.HTTP_STATUS

      /*
      loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,
      							function(event:HTTPStatusEvent):void {
      							});
      */
      loader.load( new URLRequest( url ) );
    }
  }
}
