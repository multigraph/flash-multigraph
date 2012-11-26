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

      public static var AXIS_TITLE_DEFAULT_POSITION_HORIZ_TOP  = new DPoint(0, 15);
      public static var AXIS_TITLE_DEFAULT_POSITION_HORIZ_BOT  = new DPoint(0, -18);
      public static var AXIS_TITLE_DEFAULT_POSITION_VERT_RIGHT = new DPoint(33, 0);
      public static var AXIS_TITLE_DEFAULT_POSITION_VERT_LEFT  = new DPoint(-25, 0);

      public static var AXIS_TITLE_DEFAULT_ANCHOR_HORIZ_TOP    = new DPoint(0, -1);
      public static var AXIS_TITLE_DEFAULT_ANCHOR_HORIZ_BOT    = new DPoint(0, 1);
      public static var AXIS_TITLE_DEFAULT_ANCHOR_VERT_RIGHT   = new DPoint(-1, 0);
      public static var AXIS_TITLE_DEFAULT_ANCHOR_VERT_LEFT    = new DPoint(1, 0);

      public static var AXIS_LABEL_DEFAULT_POSITION_HORIZ_TOP  = new DPoint(0, 5);
      public static var AXIS_LABEL_DEFAULT_POSITION_HORIZ_BOT  = new DPoint(0, -5);
      public static var AXIS_LABEL_DEFAULT_POSITION_VERT_RIGHT = new DPoint(5, 0);
      public static var AXIS_LABEL_DEFAULT_POSITION_VERT_LEFT  = new DPoint(-8, 0);

      public static var AXIS_LABEL_DEFAULT_ANCHOR_HORIZ_TOP    = new DPoint(0, -1);
      public static var AXIS_LABEL_DEFAULT_ANCHOR_HORIZ_BOT    = new DPoint(0, 1);
      public static var AXIS_LABEL_DEFAULT_ANCHOR_VERT_RIGHT   = new DPoint(-1, 0);
      public static var AXIS_LABEL_DEFAULT_ANCHOR_VERT_LEFT    = new DPoint(1, 0);


      private var _axis_title_default_position_horiz_top  = '0 15';
      private var _axis_title_default_position_horiz_bot  = '0 -18';
      private var _axis_title_default_position_vert_right = '33 0';
      private var _axis_title_default_position_vert_left  = '-25 0';

      private var _axis_title_default_anchor_horiz_top    = '0 -1';
      private var _axis_title_default_anchor_horiz_bot    = '0 1';
      private var _axis_title_default_anchor_vert_right   = '-1 0';
      private var _axis_title_default_anchor_vert_left    = '1 0';

      private var _axis_label_default_position_horiz_top  = '0 5';
      private var _axis_label_default_position_horiz_bot  = '0 -5';
      private var _axis_label_default_position_vert_right = '5 0';
      private var _axis_label_default_position_vert_left  = '-8 0';

      private var _axis_label_default_anchor_horiz_top    = '0 -1';
      private var _axis_label_default_anchor_horiz_bot    = '0 1';
      private var _axis_label_default_anchor_vert_right   = '-1 0';
      private var _axis_label_default_anchor_vert_left    = '1 0';
        
		// The default values for an axis, to be used in place of xml specified configuration if it exists
        private var _axis_defaults:Object = {
            type      : 'number',
            position  : 0,
            positionbase : function(...args):String {
              if (args[0]=='horizontalaxis') { return 'left'; }
              return 'bottom';
            },
            base      : "-1 -1",
            anchor    : -1,
            length    : 1,
            pregap    : 0,
            postgap   : 0,
            min       : 'auto',
            //minoffset : 0,
            minposition : "-1",
            max       : 'auto',
            maxposition : "1",
            //maxoffset : 0,
			color     : '0x000000',
            linewidth : 1,
            tickmin   : -3,
			tickmax   : 3,
			tickcolor : '0x000000',
			tickwidth : 1,
            highlightstyle : "axis",
            title : {
                fontname : "default",
                fontsize : 12,
                fontcolor : '0x000000',
                angle : 0,
                position_horiz_top : _axis_title_default_position_horiz_top,
                position_horiz_bot : _axis_title_default_position_horiz_bot,
                position_vert_right : _axis_title_default_position_vert_right,
                position_vert_left : _axis_title_default_position_vert_left,
                anchor_horiz_top : _axis_title_default_anchor_horiz_top,
                anchor_horiz_bot : _axis_title_default_anchor_horiz_bot,
                anchor_vert_right : _axis_title_default_anchor_vert_right,
                anchor_vert_left : _axis_title_default_anchor_vert_left
                /*
                position : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
                      if (positionbase == 'top') {
                        return _axis_title_default_position_horiz_top;
                      } else {
                        return _axis_title_default_position_horiz_bot;
                      }
                    } else {
                      if (positionbase == 'right') {
                        return _axis_title_default_position_vert_right;
                      } else {
                        return _axis_title_default_position_vert_left;
                      }
                    }
                },
                anchor : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
                      if (positionbase == 'top') {
                        return _axis_title_default_anchor_horiz_top;
                      } else {
                        return _axis_title_default_anchor_horiz_bot;
                      }
                    } else {
                      if (positionbase == 'right') {
                        return _axis_title_default_anchor_vert_right;
                      } else {
                        return _axis_title_default_anchor_vert_left;
                      }
                    }
                }
                */
            },
            labels : {
                fontname : "default",
                fontsize : 12,
                fontcolor : '0x000000',
                format   : '%1d',
                visible  : 'true',
                start    : 0,
                angle    : 0,
				densityfactor : 1.0,
                position_horiz_top  : _axis_label_default_position_horiz_top,
                position_horiz_bot  : _axis_label_default_position_horiz_bot,
                position_vert_right : _axis_label_default_position_vert_right,
                position_vert_left  : _axis_label_default_position_vert_left,
                anchor_horiz_top    : _axis_label_default_anchor_horiz_top,
                anchor_horiz_bot    : _axis_label_default_anchor_horiz_bot,
                anchor_vert_right   : _axis_label_default_anchor_vert_right,
                anchor_vert_left    : _axis_label_default_anchor_vert_left,
                /*
                position : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
	        			if (positionbase == 'top') {
                    		return _axis_label_default_position_horiz_top;
            			} else {						
                    		return _axis_label_default_position_horiz_bot;
               			}
                    } else { // vertical axis:
						if (positionbase == 'right') {
							return _axis_label_default_position_vert_right;
						} else {
		                    return _axis_label_default_position_vert_left;
	    				}
                    }

                },
                anchor : function(...args):String {
                	var positionbase:String = this.value.apply( this, this.relpath(args, '..', '..', '@positionbase') );
                    if (args[0]=='horizontalaxis') {
						if (positionbase == 'top') {
                          return _axis_label_default_anchor_horiz_top;
                        } else {
                          return _axis_label_default_anchor_horiz_bot;
                        }
                    } else {
						if (positionbase == 'right') {
							return _axis_label_default_anchor_vert_right;
						} else {
		                    return _axis_label_default_anchor_vert_left;
	    				}
                    }
                },
                */
                spacing : '10000 5000 2000 1000 500 200 100 50 20 10 5 2 1 0.1 0.01 0.001',
                label : {
            		format        : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@format') ); },
            		visible       : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@visible') ); },
                    start         : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@start') ); },
					angle         : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@angle') ); },
					densityfactor : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@densityfactor') ); },
                    position      : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@position') ); },
                    anchor        : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@anchor') ); },
                    fontname      : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@fontname') ); },
                    fontsize      : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@fontsize') ); },
                    fontcolor     : function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '@fontcolor') ); }
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
            ui : {
                eventhandler : "saui"
            },
			background : {
				img : {
					base     : "-1 -1",
					anchor   : "-1 -1",
					position : "0 0",
					frame    : "padding"
				},
                color : '0xffffff',
				opacity : "1"
			},
            img : {
              base     : "0 0",
              anchor   : "0 0",
              position : "0 0",
              frame    : "padding",
			  opacity  : "1"
            },
            window : {
                margin      : 2,
                border      : 2,
				bordercolor : '0x000000',
				borderopacity : "1",
                padding     : 5,
                x           : 0,
                y           : 0,
                width       : '100%',
                height      : '100%'
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
                    missingop: "eq",
                    variable : {
                      type   : 'number',
                      missingop: function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '..', '@missingop') ); },
                      missingvalue: function(...args) { return this.value.apply( this, this.relpath(args, '..', '..', '..', '@missingvalue') ); }
                    }
                }
            },
            horizontalaxis: _axis_defaults,
            verticalaxis: _axis_defaults,
            plot : {
                renderer : {
                    type : 'line'
                },
				datatips : {
					visible : false,
					bgcolor : '0xeeeeee',
					bgalpha : 1.0,
					pad     : 2,
					border  : 1,
					bordercolor : '0x000000',
					fontcolor : '0x000000',
					fontsize: 12,
					bold    : "false",
					variable : {
					}
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

        public function subconfig(... args)
        {
          var subconf : Config = new Config( xmlvalue.apply(this, args) );
          subconf._defaults = defaultvalue.apply(this, args);
          return subconf;
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
