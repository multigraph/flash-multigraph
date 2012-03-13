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
	
	public class CSVFileArrayData extends ArrayData
	{

      private var _haveData:Boolean;
      private var _url:String;
      private var _graph:Graph;
      private var _randomize:Boolean;
      private var _onLoadComplete:Function;

      public function CSVFileArrayData(variables:Array, url:String, graph:Graph, randomize:Boolean=false, onLoadComplete:Function=null)
      {
        super(variables);
        _url = url;
        _graph = graph;
        _randomize = randomize;
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = "text";
        loader.addEventListener( Event.COMPLETE, handleLoadComplete );
        _haveData = false;
        _onLoadComplete = onLoadComplete;
        var theUrl:String = url + (_randomize ? Math.floor(100000*Math.random()) : "");
        loader.load( new URLRequest( theUrl ) );
      }


      private function handleLoadComplete( event:Event ):void {
        parseText(event.target.data);
        _haveData = true;
        //_graph.paintNeeded = true;
		_graph.invalidateDisplayList();
        if (_onLoadComplete != null) {
        	_onLoadComplete(this);
        }
      }

      override public function getIterator(variableIds:Array, min:Number, max:Number, buffer:int):DataIterator {
        if (_haveData) {
          return super.getIterator(variableIds, min, max, buffer);
        } else {
          return null;
        }
      }

      override public function getStatus():Array {
        return [ _haveData ? Data.STATUS_COMPLETE : Data.STATUS_CSV_WAITING ];
      }
		
	}
}
