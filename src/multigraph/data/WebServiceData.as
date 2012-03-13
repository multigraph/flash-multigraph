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
  import multigraph.format.DateFormatter;
  
  public class WebServiceData extends Data
  {
    // The data cache
    private var _cache:WebServiceDataCache;

    // The graph associated with this data object
	private var _graph:Graph;
	
    // The web service object; this is the object that is responsible
    // for making the actual service requests.  That code is located
    // in a separate object, rather than included directly in methods
    // for this object, so that when testing, it can be replaced with
    // a mock object that doesn't actually do http requests.  (So that
    // the tests can be run without the need for an actual web
    // service.)
    private var _webService:WebService;

    public function WebServiceData(url:String, variables:Array /* array of DataVariable instances */, graph:Graph) {
      super(variables);
      _graph = graph;

	  /*
      var pageHost:String;
      var pagePath:String;
      var pagePort:String;
	  if (_graph != null) {
      	pageHost = _graph.hostname;
      	pagePath = _graph.pathname;
      	pagePort = _graph.port;
      }
      
      if (pagePort != '80') {
      	  pageHost += ':' + pagePort;
      }
*/
      var serviceUrl:String;
	  serviceUrl = url;
	  
	  //
	  // NOTE: this will currently only work if the url explicitly starts with http://; need to
	  // add code back to address relative URLs soon!!!
	  //

	  /*
      if (url.substring(0,4) == 'http') {
        serviceUrl = url;
      } else if (url.charAt(0) == '/') {
        serviceUrl = 'http://' + pageHost + url;
      } else {
        serviceUrl = 'http://' + pageHost + pagePath.replace(/\/[^\/]*$/,'/') + url;
      }
      //if (_graph != null) { _graph.diagnosticOutput('web service url is "' + serviceUrl + '"'); }
	  */

      _webService = new HttpWebService(serviceUrl, _graph);

      _cache = new WebServiceDataCache();
    }

    private function requestData(block:WebServiceDataCacheBlock,
                                 min:Number, minBuffer:int,
                                 max:Number, maxBuffer:int):void {
      _webService.request(_variables, min, minBuffer, max, maxBuffer,
                          function(dataText:String):void {
                          	//if (_graph!=null) { _graph.diagnosticOutput('got a data response of length ' + dataText.length); }
                            insertData(block, dataText);
                          }                    
                          );
    }
    
    private function insertData(block:WebServiceDataCacheBlock,
                                dataText:String):void {

	  var valuesText:String;
	  
	  if (dataText.indexOf("<mugl>") >= 0) {
		// If the response contains the string "<mugl>", assume it's a valid XML response of the form
	  	// <data><values>...</values></data>, and pull out the text of the <values> tag.
      	var xml = new XML( dataText );
        valuesText = xml.data.values;
      } else {
      	// Otherwise, assume that the response is the list of values without any surrounding XML
      	valuesText = dataText;
      }

      // Find the max value in the cache prior to this block (maxPrevValue), if any, and
      // the min value in the cache after this block (minNextValue)
      var b:WebServiceDataCacheBlock;
      var maxPrevValue:Number;
      var haveMaxPrevValue:Boolean = false;
      var minNextValue:Number;
      var haveMinNextValue:Boolean = false;

      b = block.dataPrev;
      if (b != null) {
        maxPrevValue = b.dataMax;
        haveMaxPrevValue = true;
      }
      b = block.dataNext;
      if (b != null) {
        minNextValue = b.dataMin;
        haveMinNextValue = true;
      }

      var data:Array = [];
      var lines:Array = valuesText.split(/\n/);
      for (var i:int=0; i<lines.length; ++i) {
        if (lines[i].match(/\d/)) {
          var vals = lines[i].replace(/\s+/,'').split(/,/);
          for (var j:int=0; j<_variables.length; ++j) {
            if (_variables[j].parser != null) {
              vals[j] = _variables[j].parser.parse(vals[j]);
            } else {
              vals[j] = vals[j] - 0;
            }
          }
          if ((!haveMaxPrevValue || vals[0]>maxPrevValue)
              &&
              (!haveMinNextValue || vals[0]<minNextValue)) {
            data.push( vals );
          }
        }
      }

      if (data.length == 0) {
		return;
      }

	  if (data[0][0] < block.coveredMin) { block.coveredMin = data[0][0]; }
	  if (data[data.length-1][0] > block.coveredMax) { block.coveredMax = data[data.length-1][0]; }
      block.data = data;
      if (_graph != null) {
        // (check for null _graph to allow for testing in an environment without a Graph object)
	    //_graph.paintNeeded = true;
		_graph.invalidateDisplayList();
      }
    }
    
    var _df = new DateFormatter('YMDHi');

    /**
     * Do any prep work needed to make sure that we have data between
     * the given min and max --- or rather, to at least make sure that
     * all data in the [min,max] interval has been requested.
     */
	override public function prepareData(min:Number, max:Number, buffer:int):void {
      var block:WebServiceDataCacheBlock;
      
      if (_prepareDataCalled) { return; }
      _prepareDataCalled = true;

	  if (_cache.isEmpty()) {
        block = new WebServiceDataCacheBlock(min, max);
        _cache.insertBlock(block);
		requestData(block, min, buffer, max, buffer);
	  } else {
		if (min < _cache.coveredMin) {
          block = new WebServiceDataCacheBlock(min, _cache.coveredMin);
          _cache.insertBlock(block);
		  requestData(block, min, buffer, _cache.coveredMin, 0);
		}
		if (max > _cache.coveredMax) {
          block = new WebServiceDataCacheBlock(_cache.coveredMax, max);
          _cache.insertBlock(block);
		  requestData(block, _cache.coveredMax, 0, max, buffer);
		}
	  }

	}
	
    override public function getIterator(variableIds:Array, min:Number, max:Number, buffer:int):DataIterator {

        // if min > max, swap them:
        if (min > max) {
          var tmp:Number = max;
          max = min;
          min = tmp;
        }

      if (_cache.isEmpty()) {
        return null;
      } else {
	    var columnIndices = [];
	    for (var i=0; i<variableIds.length; ++i) {
          for (var j=0; j<_variables.length; ++j) {
            if (variableIds[i] == _variables[j].id) {
              columnIndices.push(j);
              break;
            }
          }
	    }
	    return _cache.getIterator(columnIndices, min, max, buffer);
      }
    }
    
    override public function getBounds(varid:String):Array {
	  // a kludge for now...
	  return [0,10];
    }

    /**
     * Set the web service object.  This method is just used during testing, to replace
     * the default HttpWebService object with a mock one.
     */
    public function setWebService(webService:WebService) {
    	_webService = webService;
    }
	
    // This getter is just for testing --- so that the test function can inspect the cache object
    public function get cache():WebServiceDataCache { return _cache; }

    override public function getStatus():Array {
      return _cache.getStatus();
    }

  }

}
