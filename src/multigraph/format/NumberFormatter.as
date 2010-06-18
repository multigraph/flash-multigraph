/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.format
{
  import multigraph.printf;
  
  public class NumberFormatter extends Formatter
  {
  	private var _widthFlag:int;
  	private var _precisionSize:int;
  	
	public function NumberFormatter(string:String)
    {
      	super(string);
    }
    
    override public function format(value:Number):String {
    	var s:String = printf(_formatString, value);
    	return s;
    }
    
    override public function getLength():int {
    	printf(_formatString, 0);
    	if(_widthFlag > 0) {
    		return _widthFlag;	
    	}
    	else {
    		return _precisionSize;	
    	}
    }
/*     
    private function printf(fstring:String, value:Number):String {
        var pad = function(str,ch,len) {
            var ps='';
            for(var i=0; i<Math.abs(len); i++) ps+=ch;
            return len>0?str+ps:ps+str;
        }

        var processFlags = function(flags,width,rs,value) {
        	_widthFlag = width;
            var pn = function(flags,value,rs) {
                if(value>=0) {
                    if(flags.indexOf(' ')>=0) rs = ' ' + rs;
                    else if(flags.indexOf('+')>=0) rs = '+' + rs;
                } else {
                    rs = '-' + rs;
                }
                return rs;
            }

            var iWidth:int = parseInt(width,10);
            if(width.charAt(0) == '0') {
                var ec:int=0;
                if(flags.indexOf(' ')>=0 || flags.indexOf('+')>=0) ec++;
                if(rs.length<(iWidth-ec)) rs = pad(rs,'0',rs.length-(iWidth-ec));
                return pn(flags,value,rs);
            }

            rs = pn(flags,value,rs);
            if(rs.length<iWidth) {
                if(flags.indexOf('-')<0) rs = pad(rs,' ',rs.length-iWidth);
                else rs = pad(rs,' ',iWidth - rs.length);
            }
            return rs;
        }

        var converters:Array = new Array();

        converters['c'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            if(typeof(value) == 'number') return String.fromCharCode(value);
            if(typeof(value) == 'string') return value.charAt(0);
            return '';
        }

        converters['d'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            return converters['i'](flags,width,precision,value);
        }

        converters['u'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            return converters['i'](flags,width,precision,Math.abs(value));
        }

        converters['i'] =  function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision=parseInt(precision);
            var rs = ((Math.abs(value)).toString().split('.'))[0];
            if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
            return processFlags(flags,width,rs,value);
        }

        converters['E'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            return (converters['e'](flags,width,precision,value)).toUpperCase();
        }

        converters['e'] =  function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision = parseInt(precision);
            if(isNaN(iPrecision)) iPrecision = 6;
            var rs = (Math.abs(value)).toExponential(iPrecision);
            if(rs.indexOf('.')<0 && flags.indexOf('#')>=0) rs = rs.replace(/^(.*)(e.*)$/,'$1.$2');
            return processFlags(flags,width,rs,value);
        }

        converters['f'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision = parseInt(precision);
            if(isNaN(iPrecision)) iPrecision = 6;
            var rs = (Math.abs(value)).toFixed(iPrecision);
            if(rs.indexOf('.')<0 && flags.indexOf('#')>=0) rs = rs + '.';
            return processFlags(flags,width,rs,value);
        }

        converters['G'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            return (converters['g'](flags,width,precision,value)).toUpperCase();
        }

        converters['g'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision = parseInt(precision);
            var absArg = Math.abs(value);
            var rse = absArg.toExponential();
            var rsf = absArg.toFixed(6);

            if(!isNaN(iPrecision)) {
                var rsep = absArg.toExponential(iPrecision);
                rse = rsep.length < rse.length ? rsep : rse;
                var rsfp = absArg.toFixed(iPrecision);
                rsf = rsfp.length < rsf.length ? rsfp : rsf;
            }

            if(rse.indexOf('.')<0 && flags.indexOf('#')>=0) rse = rse.replace(/^(.*)(e.*)$/,'$1.$2');
            if(rsf.indexOf('.')<0 && flags.indexOf('#')>=0) rsf = rsf + '.';
            var rs = rse.length<rsf.length ? rse : rsf;
            return processFlags(flags,width,rs,value);
        }

        converters['o'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision=parseInt(precision);
            var rs = Math.round(Math.abs(value)).toString(8);
            if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
            if(flags.indexOf('#')>=0) rs='0'+rs;
            return processFlags(flags,width,rs,value);
        }

        converters['X'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            return (converters['x'](flags,width,precision,value)).toUpperCase();
        }

        converters['x'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision=parseInt(precision);
            value = Math.abs(value);
            var rs = Math.round(value).toString(16);
            if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
            if(flags.indexOf('#')>=0) rs='0x'+rs;
            return processFlags(flags,width,rs,value);
        }

        converters['s'] = function(flags,width,precision,value) {
        	_precisionSize = precision;
            var iPrecision=parseInt(precision);
            var rs = value;
            if(rs.length > iPrecision) rs = rs.substring(0,iPrecision);
            return processFlags(flags,width,rs,0);
        }

        var farr = fstring.split('%');
        var retstr = farr[0];
        var fpRE = /^([-+ #]*)(\d*)\.?(\d*)([cdieEfFgGosuxX])(.*)$/;

        for(var i=1; i<farr.length; i++) {
            var fps=fpRE.exec(farr[i]);
            if(!fps) continue;
            if(arguments[i]!=null) retstr+=converters[fps[4]](fps[1],fps[2],fps[3],arguments[i]);
            retstr += fps[5];
        }
		
        return retstr;
    }
     */
    // This is a simplified version of what should be an incredibly complicated function
    override public function parse(string:String):Number {
        var number:Number = Number(string);
    	return number;
    }
  }
}
