/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.renderer {
  //import mx.controls.TextArea;
  import flash.external.ExternalInterface;
  public class RendererList //extends TextArea
  {
    public function RendererList() {
    	var htmlText:String = '';
    	htmlText += '<table border="1"><tr>';
    	htmlText += '<td><b>keyword</b></td>';
    	htmlText += '<td><b>description</b></td>';
    	htmlText += '<td><b>options</b></td>';
    	htmlText += '</tr>';
    	var renderers:Array = Renderer.rendererList();
    	for (var i:int=0; i<renderers.length; ++i) {
    		htmlText += '<tr>';
    		htmlText += '<td valign="top"><b>' + renderers[i].keyword + '</b></td>';
    		htmlText += '<td valign="top">' + renderers[i].description + '</td>';
    		htmlText += '<td valign="top">' + renderers[i].options + '</td>';
    		htmlText += '</tr>';
    	}
    	htmlText += '</tr></table>';

    	ExternalInterface.call('MultigraphDisplayRendererList', htmlText);
    }
  }
}
