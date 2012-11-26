/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
function MultigraphScriptLocation() {
    var scriptLocation = "";
    var scriptName = "Multigraph.js";
	
    var scripts = document.getElementsByTagName('script');
    for (var i = 0; i < scripts.length; i++) {
	var src = scripts[i].getAttribute('src');
	if (src) {
	    var index = src.lastIndexOf(scriptName);
	    // is it found, at the end of the URL?
	    if ((index > -1) && (index + scriptName.length == src.length)) {
		scriptLocation = src.slice(0, -scriptName.length);
		break;
	    }
	}
    }
    return scriptLocation;
}

//var multigraphSwfRelPath = "../bin-debug/";
var multigraphSwf        = "../bin-debug/MultigraphApp.swf";

var jsfiles = [ 'swfobject.js' ];
var allScriptTags = "";
var scriptLocation = MultigraphScriptLocation();
for (var i = 0; i < jsfiles.length; i++) {
    if (/MSIE/.test(navigator.userAgent) || /Safari/.test(navigator.userAgent)) {
	var currentScriptTag = "<script src='" + scriptLocation + jsfiles[i] + "'></script>";
	allScriptTags += currentScriptTag;
    } else {
	var s = document.createElement("script");
	s.src = scriptLocation + jsfiles[i];
	var h = document.getElementsByTagName("head").length ?
	    document.getElementsByTagName("head")[0] :
	    document.body;
	h.appendChild(s);
    }
}
if (allScriptTags) document.write(allScriptTags);

function Multigraph(divid, muglfile, size, options) {
    var default_options = {
    	hostname : window.location.hostname.toString(),
    	pathname : window.location.pathname.toString(),
    	port     : window.location.port.toString(),
    	test     : false
    };
    var options = options || {};
    for (option in options) {
    	if (typeof(options[option]) == "undefined") { options[option] = default_option[option]; }
    }
    this.scriptLocation = MultigraphScriptLocation();
    this.divid          = divid;
    this.muglfile       = muglfile;
    this.width          = size[0];
    this.height         = size[1];
    this.div            = document.getElementById(this.divid);
    this.div.innerHTML = '<a href="http://www.adobe.com/go/getflashplayer">'
	    + '<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />'
	    + '</a>'
	;
    var swfName = this.divid + 'SwfName';
    var flashvars = {
	    muglfile : this.muglfile,
	    hostname : options['hostname'],
	    pathname : options['pathname'],
	    port     : options['port'],
	    test     : options['test'],
        swfname : swfName
    };
    var params = {
	    menu : "false",
	    allowscriptaccess : "always"
    };
    var attributes = {
	    id : this.divid + 'FlashContentId',
        name: swfName
    };
    if (options['test']) {
        alert('This is Multigraph is test mode.  This message is being displayed by the Multigraph constructor.\n' +
			  'That means two things: (1) that Multigraph.js has been successfully loaded, and (2) that your\n' +
			  'call to "new Multigraph(...)" is executing.  After dismissing this message, you should see a message\n' +
			  'in the HTML page where the graph would normally appear.  The message will indicate the\n' +
			  'success/failure status of various aspects of this Multigraph deployment.  If you do not see a\n' +
			  'message at all, it means that the Multigraph SWF file was not successfully loaded.');
    }
    //alert('swfobject.embedSWF('+this.scriptLocation+multigraphSwf+', '+this.divid+', '+this.width+', '+this.height+', "9.0.0", "expressInstall.swf", '+flashvars+', '+params+', '+attributes+')');
    swfobject.embedSWF(this.scriptLocation+multigraphSwf, this.divid, this.width, this.height, "9.0.0", "expressInstall.swf", flashvars, params, attributes);
}

function thisMovie(movieName) {
    if (navigator.appName.indexOf("Microsoft") != -1) {
    	return window[movieName];
	} else {
        return document[movieName];
    }
}

var MultigraphAxisBindings = {};

function MultigraphAddAxisBinding(swfName, bindingId) {
    if (MultigraphAxisBindings[bindingId] == null) {
        MultigraphAxisBindings[bindingId] = {};
    }
//alert('binding "'+swfName+'" to bindingId "'+bindingId+'"');
    MultigraphAxisBindings[bindingId][swfName] = thisMovie(swfName);
}

function MultigraphDelete(divid) {
//alert('MultigraphDelete('+divid+')');
    var swfName = divid + 'SwfName';
    for (bindingId in MultigraphAxisBindings) {
        if (MultigraphAxisBindings[bindingId][swfName] != null) {
//alert('delete MultigraphAxisBindings['+bindingId+']['+swfName+']');
            delete MultigraphAxisBindings[bindingId][swfName];
        }
    }
}

function MultigraphPrepareData(initiatingSwfName) {
//alert('prepareData('+initiatingSwfName+')');
	var swfDone = {};
    for (bindingId in MultigraphAxisBindings) {
        for (swfName in MultigraphAxisBindings[bindingId]) {
            if (swfName != initiatingSwfName && !swfDone[swfName]) {
            	MultigraphAxisBindings[bindingId][swfName].prepareData();
            	swfDone[swfName] = 1;
			}
		}
    }
}

var dumpNo = 1;
function DumpBindings() {
    var msgmsg = document.getElementById('msgmsg');
    msgmsg.value += 'Bindings @'+dumpNo+':\n';
    ++dumpNo;
    for (bindingId in MultigraphAxisBindings) {
        msgmsg.value += bindingId + ': [';
        for (swfName in MultigraphAxisBindings[bindingId]) {
            msgmsg.value += swfName + ',';
        }
        msgmsg.value += '\n';
    }
}

function MultigraphSetAxisBindingDataRange(initiatingSwfName, bindingId, min, max, factor, offset) {
//var msgmsg = document.getElementById('msgmsg');
//msgmsg.value += 'MultigraphSetAxisBindingDataRange('+initiatingSwfName+','+bindingId+'...)';
    if (MultigraphAxisBindings[bindingId] != null) {
//msgmsg.value += 'By\n';
        for (swfName in MultigraphAxisBindings[bindingId]) {
            if (swfName != initiatingSwfName) {
                MultigraphAxisBindings[bindingId][swfName].setAxisBindingDataRangeNoBind(bindingId, min, max, factor, offset);
//msgmsg.value += '    '+swfName+'\n'
            }
        }
    } else {
//msgmsg.value += 'Bn\n';
    }
//msgmsg.scrollTop = msgmsg.scrollHeight;
}

function MultigraphRendererList(divid) {
    this.scriptLocation = MultigraphScriptLocation();
    this.divid          = divid;
    this.div            = document.getElementById(this.divid);
    this.div.innerHTML = (''
                          + '<table><tr><td>'
			  + '<div id="rendererlist314swf">'
			  + '<a href="http://www.adobe.com/go/getflashplayer">'
			  + '<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />'
			  + '</a>'
			  + '</div>'
                          + '</td></tr>'
                          + '<tr><td>'
			  + '<div id="rendererlist314"/>'
			  + '</td></tr>'
                          + '</table>'
                          );
    var flashvars = {
	rendererlist : "true"
    };
    var params = {
	menu : "false",
	allowscriptaccess : "always"
    };
    var attributes = {
	id : this.divid + 'FlashContentId'
    };
    swfobject.embedSWF(this.scriptLocation+multigraphSwf, 'rendererlist314swf', 1, 1, "9.0.0", "expressInstall.swf", flashvars, params, attributes);
}

function MultigraphDisplayRendererList(content) {
    var div = document.getElementById('rendererlist314');
    div.innerHTML = content;
}
