/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph.format
{
	public class DateFormatter extends Formatter
	{		
		public function DateFormatter(string:String)
		{
			_formatString = string;
			super(string);
		}
		
		private function formatSingleChar(char:String, date:Date):String {
			switch (char) {
		        // Date Cases
		        case "d": // Day without leading zeros
		            return date.getUTCDate() + '';
		        case "D": // Day with leading zeros
		            return (date.getUTCDate() < 10) ? "0" + date.getUTCDate() + '' : date.getUTCDate() + '';
		        case "m": // Month (numerical) without leading zeros
		            return date.getUTCMonth() + 1 + '';
		        case "M": // Month (numerical) with leading zeros
		            return (date.getUTCMonth() <= 9) ? "0" + (date.getUTCMonth() + 1) + '' : (date.getUTCMonth() + 1) + '';
		        case "Y": // Four digit year
		            return date.getUTCFullYear() + '';
		        case "y": // Two digit year
		            return (date.getUTCFullYear()+'').substr(2,2);
		        case "W": // Weekday name
		            var weekdays:Array = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
		            return weekdays[date.getUTCDay()];
		        case "w": // Weekday 3-letter abbrev
		            var weekdaysAbr:Array = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
		            return weekdaysAbr[date.getUTCDay()];
		        case "N": // Month name
		            var months:Array = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		            return months[date.getUTCMonth()];
		        case "n": // Month name -- 3 letter abbreviation
		            var monthsAbr:Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
		            return monthsAbr[date.getUTCMonth()];
		
		        // Time cases
		        case "H": // 24 hours
		        	return (date.getUTCHours() < 10) ? "0" + date.getUTCHours() + '' : date.getUTCHours() + '';
		        case "h": // 12 hours
		            if(date.getUTCHours() == 23) {
		                return "0";
		            }
		            else if(date.getUTCHours() > 11) {
		                return date.getUTCHours() + 1 - 12 + '';
		            }
		            else {
		                return date.getUTCHours() + 1 + '';
		            }
		        case "i": // Minutes
		            return (date.getUTCMinutes() < 10) ? "0" + date.getUTCMinutes() + '' : date.getUTCMinutes() + '';
		        case "s": // Seconds
		            return (date.getUTCSeconds() < 10) ? "0" + date.getUTCSeconds() + '' : date.getUTCSeconds() + '';
		        case "P": // AM or PM
		            return (date.getUTCHours() < 12) ? "AM" : "PM";
		        case "p": // am or pm
		            return (date.getUTCHours() < 12) ? "am" : "pm";
		        case "L": // newline
		            return "\n";
		        case "%":
		            return "%";
		        default:
		            return char;
			}
		}
		
		/*
			This is a general purpose function which replaces the multigraph.DateFormatter.format and
			multigraph.DateParser.format. It will usually call upon the multigraph.DateFormatter.formatSingleChar
			function in order to build a properly formatted string based upon the formatString.
		*/
		override public function format(value:Number):String {
	        var date:Date = new Date();
	        date.setTime(value);
		
	        var fString:String = new String('');
	        var index:uint;
	        if (_formatString.indexOf('%') >= 0) {
	            // If the format string has a '%' in it, assume it uses the convention that format chars
	            // are preceeded by '%':
	            index = 0;
	            while (index < _formatString.length) {
	                if (_formatString.charAt(index) == '%') {
	                    ++index;
	                    fString += formatSingleChar(_formatString.charAt(index), date);
	                } else {
	                    fString += _formatString.charAt(index);
	                }
	                ++index;
	            }
	        } else {
	            // If the format string does not have a '%', assume it does not use the '%' convention,
	            // and simply replace any format chars it contains with the corresponding value.
	            // This option is outdated and should not be used, and eventually this code
	            // should be removed.
	            for(index = 0; index < _formatString.length; ++index) {
	                fString += formatSingleChar(_formatString.charAt(index), date);
	            }
	        }
	
	        return fString;
    	}
    	
    	/*
    		This function was orginally taken from the multigraph.DateParser class. It serves
    		as a means to create a millisecond numerical value based upon a default representation of 
    		a date in multigraph. As of right now the default format that this function anticipates is:
    		YYYYMMDDHHmmss
    		@returns The millisecond numerial value of an arbitrary string representing a date
    	*/
    	override public function parse(string:String):Number {
			var YYYY:Number = 0;
            var   MM:Number = 1;
            var   DD:Number = 1;
            var   HH:Number = 0;
            var   mm:Number = 0;
            var   ss:Number = 0;
            
            switch (string.length) {
            case 14: // YYYYMMDDHHmmss
                    ss = int(string.substring(12,14));
            case 12: // YYYYMMDDHHmm
                    mm = int(string.substring(10,12));
            case 10: // YYYYMMDDHH
                    HH = int(string.substring(8,10));
            case  8: // YYYYMMDD
                    DD = int(string.substring(6,8));
            case  6: // YYYYMM
                    MM = int(string.substring(4,6)) - 1;
            case  4: // YYYY
                    YYYY = int(string.substring(0,4));
                    break;
            }
		    
            if (YYYY != 0) {
                return Date.UTC(YYYY, MM, DD, HH, mm, ss, 0);   // note that this returns ms, not a Date object!
            }

            // YYYY = 0, then we can't make sense of the string as a date at all, so just parse it as a number directly.
            // This behavior is here so that the axis-binding code will work if min="0" max="1" are given for a datetime axis!
 			return Number(string);
		}
    	
    	/*
    		This function calculates the approximate character length of the formatted value 
    	*/
    	override public function getLength():int {
	    	var length:uint = 0;
	        for(var index:int = 0; index < _formatString.length; ++index) {
	            switch(_formatString.charAt(index)) {
	                // Extra cases
	            case " ":
	                length += 1;
	                break;
	            case "/":
	                length += 1;
	                break;
	            case ":":
	                length += 1;
	                break;
	            case "-":
	            	length += 1;
	            	break;
	
	                // Date Cases
	            case "d": // Day without leading zeros
	                length += 2;
	                break;
	            case "D": // Day with leading zeros
	                length += 2;
	                break;
	            case "m": // Month (numerical) without leading zeros
	                length += 2;
	                break;
	            case "M": // Month (numerical) with leading zeros
	                length += 2;
	                break;
	            case "Y": // Four digit year
	                length += 4;
	                break;
	            case "y": // Two digit year
	                length += 2;
	                break;
	            case "W": // Weekday name
	                length += 9;
	                break;
	            case "w": // Weekday abbrev
	                length += 3;
	                break;
	            case "N": // Month name
	                length += 9;
	                break;
	            case "n": // Month name - 3 letter abbreviation
	                length += 3;
	                break;
	
	                // Time cases
	            case "H": // 24 hours
	                length += 2;
	                break;
	            case "h": // 12 hours
	                length += 2;
	                break;
	            case "i": // Minutes
	                length += 2;
	                break;
	            case "s": // Seconds
	                length += 2;
	                break;
	            case "p": // AM or PM
	                length += 2;
	                break;
	            case "p": // am or PM
	                length += 2;
	                break;
	            }
	        }
	        return length;
    	}
	}
}
