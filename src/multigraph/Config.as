/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph
{
    public class Config
    {
    	// _xml is a pointer to the XML configuration file
        private var _xml:XML;

      // This function constructs a "relative path" in the following sense:
      // 
      // relpath(PATH, component1, component2, ...)
      // 
      // PATH should be an array containing an existing 'path', and
      // the remainging arguments (component1, component2, ...) should
      // express a path that is "relative" to PATH, in the sense
      // that any of these component* arguments can be '..'.
      // 
      // This is easier to explain with a series of examples:
      // 
      // relpath(['window','width'], '..', 'height')
      // 	-> ['window','height']
      // 
      // relpath(['horizontalaxis','labels','label','format'], '..', '..', 'format')
      // 	-> ['horizontalaxis','labels','format']
      // 
      // Note: the PATH argument can be an array-like object such as the 'arguments'
      // list from another function call.
      // 
      private function relpath(...arguments) {
        var args = [];
        var i;
        for (i=0; i<arguments[0].length; ++i) { args.push(arguments[0][i]); }
        i = args.length;
        var j=1;
        while (j<arguments.length) {
          if (arguments[j] == '..') {
            --i;
          } else {
            args[i] = arguments[j];
            ++i;
          }
          ++j;
        }
        args.length = i;
        return args;
      }
        
		// The default values for an axis, to be used in place of xml specified configuration if it exists
        private var _axis_defaults:Object = {
            type      : 'number',
            position  : 0,
            positionbase : function(...args):String {
              if (args[0]=='horizontalaxis') { return 'left'; }
              return 'bottom';
            },
            pregap    : 0,
            postgap   : 0,
            min       : 'auto',
            minoffset : 0,
            max       : 'auto',
            maxoffset : 0,
            title : {
                angle : 0,
                position : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
                      if (positionbase == 'top') {
                        return '0 15';
                      } else {
                        return '0 -18';
                      }
                    } else {
                      if (positionbase == 'right') {
                        return '33 0';
                      } else {
                        return '-25 0';
                      }
                    }
                },
                anchor : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
                      if (positionbase == 'top') {
                        return '0 -1';
                      } else {
                        return '0 1';
                      }
                    } else {
                      if (positionbase == 'right') {
                        return '-1 0';
                      } else {
                        return '1 0';
                      }
                    }
                }
            },
            labels : {
                format   : '%1d',
                start    : 0,
                angle    : 0,
                position : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
	        			if (positionbase == 'top') {
                    		return '0 5';
            			} else {						
                    		return '0 -5';
               			}
                    } else { // vertical axis:
						if (positionbase == 'right') {
							return '5 0';
						} else {
		                    return '-8 0';
	    				}
                    }

                },
                anchor : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
						if (positionbase == 'top') {
                          return '0 -1';
                        } else {
                          return '0 1';
                        }
                    } else {
						if (positionbase == 'right') {
							return '-1 0';
						} else {
		                    return '1 0';
	    				}
                    }
                },
                spacing : '10000 5000 2000 1000 500 200 100 50 20 10 5 2 1 0.1 0.01 0.001',
                label : {
                    format   : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', 'format') ); },
                    start    : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', 'start') ); },
                    angle    : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', 'angle') ); },
                    position : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', 'position') ); },
                    anchor   : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', 'anchor') ); }
                }
            },
            grid : {
            	color : '0xeeeeee'
            },
            pan : {
                allowed : 'yes',
                min: null,
                max: null
            },
            zoom : {
                allowed : 'yes',
                anchor: null,
                'in': null,
                out: null
            }
        };

		// The graph specific defaults
        private var _defaults:Object = {
            window : {
                margin   : 2,
                border   : 2,
                padding  : 5
            },
            legend : {
            	frame      : "plot",
            	base       : "1 1",
            	anchor     : "1 1",
            	position   : "0 0",
            	columns    : -1,
                rows       : -1,
            	border     : 1,
                round      : "false",
                radius     : 15,
            	color      : '0xFFFFFF',
            	bordercolor: '0x000000',
            	opacity    : 1,
                padding    : 0,
            	icon       : {
            		width     : 40,
            		height    : 30,
                    border    : 1
            		//size      : "large";
            	}
            },
            title : {
            	frame      : "padding",
            	base       : "0 1",
            	anchor     : "0 1",
            	position   : "0 0",
            	border     : 0,
            	color      : '0xFFFFFF',
            	bordercolor: '0x000000',
            	opacity    : 1,
                round      : "false",
                radius     : 15,
                padding    : 0,
                fontsize : 18
            },
            plotarea : {
              border : 0,
              bordercolor : '0xeeeeee',
              marginbottom : 35,
              marginleft   : 38,
              margintop    : 10,
              marginright  : 35
            },
            data : {
                variables : {
                    variable : {
                        type   : 'number'
                    }
                }
            },
            horizontalaxis: _axis_defaults,
            verticalaxis: _axis_defaults,
            plot : {
                renderer : {
                    type : 'line'
                },
                horizontalaxis : {
                    ref : function() { return this.graph.haxis.id;  },
                    variable : {
                        ref : function() { return this.value.apply( this, 'data', 'variables', 'variable', 0, 'id' ); }
                    }
                },
                verticalaxis : {
                    ref : function() { return this.graph.vaxes[0].id;  },
                    variable : {
                        ref : function() { return this.value.apply( this, 'data', 'variables', 'variable', 1, 'id' ); }
                    }
                }
            }
        };
        
        public function Config(xml:XML)
        {
            this._xml = xml;
        }
        
        public function xmlvalue(... args) {
            var obj = _xml;
            var i:int = 0;
            while (i<args.length && obj!=null) {
                var arg = args[i];
                if (i<args.length-1) {
                    obj = obj[arg];
                } else {
                    obj = obj[arg];
                }
                ++i;
            }
            if (obj==null || obj==undefined || obj.length() == 0) { return null; }
            return obj;
        }

        public function defaultvalue(... args) {
            var obj = _defaults;
            var i:int = 0;
            while (i<args.length && obj!=null) {
              var arg = args[i];
              if (typeof arg == 'string') {
                arg = arg.replace(/^@/,'');
              }
              obj = obj[arg];
              ++i;
              while (i<args.length && (typeof args[i] == 'number')) { ++i; }
            }
            if (typeof obj == 'function') {
              return obj.apply(this, args);
            }
            return obj;
        }

        public function value(...args) {
            var value = xmlvalue.apply(this, args);
            if (value != null) { return value; }
            return defaultvalue.apply(this, args);
        }
    }
}
