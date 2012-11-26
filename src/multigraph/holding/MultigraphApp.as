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
	import flash.external.ExternalInterface;
	
	public class MultigraphApp
	{
		private var _swfname:String;
		private var _graphs:Array;
		
		public function MultigraphApp(swfname:String)
		{
			_swfname = swfname;
			_graphs = [];
		}

	public function addGraph(graph:Graph):void {
		_graphs.push(graph);
    }

	public function prepareData(initiatingGraph:Graph=null):void {
		for (var i:int=0; i<_graphs.length; ++i) {
			if (initiatingGraph==null || _graphs[i]!=initiatingGraph) {
				_graphs[i].prepareData(false);
            }
        }
        if (initiatingGraph != null) {
		    ExternalInterface.call('MultigraphPrepareData', this._swfname);
        }
    }

	}
}
