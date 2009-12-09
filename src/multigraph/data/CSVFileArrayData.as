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
	
	public class CSVFileArrayData extends ArrayData
	{

      private var _haveData:Boolean;
      private var _url:String;
      private var _graph:Graph;

      public function CSVFileArrayData(variables:Array, url:String, graph:Graph)
      {
        super(variables);
        _url = url;
        _graph = graph;
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = "text";
        loader.addEventListener( Event.COMPLETE, handleLoadComplete );
        _haveData = false;
        loader.load( new URLRequest( url ) );
      }


      private function handleLoadComplete( event:Event ):void {
        parseText(event.target.data);
        _haveData = true;
        _graph.paintNeeded = true;
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
