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
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.DateChooser;
	import mx.controls.TextInput;
	import mx.core.ScrollPolicy;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.FocusManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.validators.DateValidator;
	
	public class AxisControls
	{
		private var _focusManager:FocusManager;
		
		private static var __controlList:Array;
		
		private var _xPos:Number;
		private var _xEndPos:Number;
		private var _yPos:Number;
		private var _yEndPos:Number;
		private var _width:Number;
		private var _height:Number;
		private var _box:mx.containers.Box;
		private var _dateBox:VBox;
		private var _hbox:HBox;
		private var _vbox:VBox;
		private var _lDateChooser:DateChooser;
		private var _rDateChooser:DateChooser;
		private var _dateFormatter:DateFormatter;
		
		// Global inputs for numerical controls
		private var _textInputMin:TextInput;
		private var _textInputMax:TextInput;
		
		private var _boxOne:mx.containers.Box;
		private var _boxTwo:mx.containers.Box;
		
		private var _orientation:Boolean;
		
		private var buttonCSS:CSSStyleDeclaration;
		private var hboxCSS:CSSStyleDeclaration;
		
		private var _sprite:MultigraphUIComponent;
		private var _newSprite:MultigraphUIComponent;
		private var _axis:Axis;
		
		static private var _controlList:Array = new Array();
		
		private var _controlButton:Button;
		public function get controlButton():Button { return _controlButton; }
		public function set controlButton(button:Button):void { _controlButton = button; }
		
		// icon asset
    	[Embed(source="assets/left_searcherSmall.png")]
    	[Bindable]
    	private var leftSearchIcon:Class;
    	
    	[Embed(source="assets/right_searcherSmall.png")]
    	[Bindable]
    	private var rightSearchIcon:Class;
		
		[Embed(source="assets/left_arrowSmall.png")]
		[Bindable]
		private var leftArrowIcon:Class;
		
		[Embed(source="assets/right_arrowSmall.png")]
		[Bindable]
		private var rightArrowIcon:Class;
		
		[Embed(source="assets/up_searcherSmall.png")]
		[Bindable]
		private var upSearchIcon:Class;
		
		[Embed(source="assets/down_searcherSmall.png")]
		[Bindable]
		private var downSearchIcon:Class;
		
		[Embed(source="assets/up_arrowSmall.png")]
		[Bindable]
		private var upArrowIcon:Class;
		
		[Embed(source="assets/down_arrowSmall.png")]
		[Bindable]
		private var downArrowIcon:Class;
		
		[Embed(source="assets/plus.PNG")]
	    [Bindable]
	    private var plusIcon:Class;
	    
	    [Embed(source="assets/minus.PNG")]
	    [Bindable]
	    private var minusIcon:Class;
		
		[Embed(source="assets/calendar.png")]
	    [Bindable]
	    private var calendarIcon:Class;
		
		private var _visible:Boolean = false;
		public function get visible():Boolean { return _visible; }
		
		private var _paddingBorder:Number;
		
		public function AxisControls(sprite:MultigraphUIComponent, axis:Axis, config:Config)
		{	
			buttonCSS = StyleManager.getStyleDeclaration("Button");
			buttonCSS.setStyle("cornerRadius", 2);
			
			_sprite = sprite;
			_newSprite = new MultigraphUIComponent();
			_axis = axis;
			_orientation = (_axis.orientation == 1) ? true : false; 
			
			_paddingBorder = Number(config.value('window', '@margin')) + Number(config.value('window', '@border')) + Number(config.value('window', '@padding'));
			
			// Calculate the x, y, width, and height of the control area
			// This will inevitably change after more configuration options are added to mugl
			_width = (_orientation) ? _axis.length: 45;
			_height = (_orientation) ? 30 : _axis.length;
			_xPos = (_orientation) ? 
					Number(config.value('plotarea', '@marginleft')) + _paddingBorder + _axis.parallelOffset :
					Number(config.value('plotarea', '@marginleft'))
				  	+ _paddingBorder + _axis.perpOffset - (_width / 2);
			_xEndPos = _xPos + _width;
			_yPos = (_orientation) ? 
					Number(config.value('plotarea', '@marginbottom')) 
				  	+ _paddingBorder + _axis.perpOffset - (_height / 2) :
				  	Number(config.value('plotarea', '@marginbottom')) + _paddingBorder + _axis.parallelOffset;
			_yEndPos = _yPos + _height;
			
			_sprite.addChild(_newSprite);
			
			drawControlButton();
		}

		public function drawControls():void {
			_visible = true;
			
			// draw the semi-transparent rounded rectangle (represents the control area)
			var g:Graphics = _newSprite.graphics;
      		g.beginFill(0xDDDDDD, 0.9);
      		g.drawRoundRect(_xPos, _yPos, _width, _height, 10, 10);
      		g.endFill();
      		
      		if(_axis.type == 2) {
      			// Style the hbox container
	      		_dateBox = new VBox();
	      		_dateBox.transform.matrix = new Matrix(1, 0, 0, -1, 0, _height);
	      		_dateBox.setStyle("verticalAlign", "bottom");
				_dateBox.setStyle("horizontalAlign", "center");
				_dateBox.height = _height + 150;
	      		_dateBox.width = _width;		      		
				_dateBox.x = _xPos;
	      		_dateBox.y = _yPos + _height + 150;
	      		_dateBox.horizontalScrollPolicy = ScrollPolicy.OFF;
	      		_dateBox.verticalScrollPolicy = ScrollPolicy.OFF;
	      		
	      		var lDateBox:HBox = new HBox();
	      		lDateBox.setStyle("borderStyle", "solid");
	      		lDateBox.width = _width / 2;
	      		lDateBox.setStyle("verticalAlign", "bottom");
				lDateBox.setStyle("horizontalAlign", "left");
	      		
	      		var rDateBox:HBox = new HBox();
	      		rDateBox.setStyle("borderStyle", "solid");
	      		rDateBox.width = _width / 2;
	      		rDateBox.setStyle("verticalAlign", "bottom");
				rDateBox.setStyle("horizontalAlign", "right");
	      		
	      		_lDateChooser = new DateChooser();
  				_lDateChooser.setStyle("horizontalGap", "0");
  				_lDateChooser.setStyle("verticalGap", "0");
  				_lDateChooser.setStyle("fontSize", "10");
  				
  				_rDateChooser = new DateChooser();
  				_rDateChooser.setStyle("horizontalGap", "0");
  				_rDateChooser.setStyle("verticalGap", "0");
  				_rDateChooser.setStyle("fontSize", "10");
  				
  				_dateBox.addChild(_lDateChooser);
	      		_dateBox.addChild(_rDateChooser);
	      		_dateBox.removeChild(_lDateChooser);
	      		_dateBox.removeChild(_rDateChooser);
	      						
  				_dateFormatter = new DateFormatter();
  				_dateFormatter.formatString = "MM/DD/YYYY 00:00";
  				
  				_textInputMin = new TextInput();
  				_textInputMax = new TextInput();
      		} else {
      			_textInputMin = new TextInput();
      			_textInputMax = new TextInput();
      		}
      		
  			// Style the hbox container
      		_box = new mx.containers.Box();
      		_box.direction = (_orientation) ? "horizontal" : "vertical";
      		if (_axis.type != 2) {
      			_box.transform.matrix = new Matrix(1, 0, 0, -1, 0, _height);	
      		}
      		_box.setStyle("verticalAlign", "middle");
			_box.setStyle("horizontalAlign", "center");		      		
			_box.x = _xPos;
      		_box.y = _yPos + _height;
      		_box.height = _height;
      		_box.width = _width;
      		
      		// boxOne will be left or top depending on axis orientation
      		_boxOne = new mx.containers.Box();
      		_boxOne.direction = (_orientation) ? "horizontal" : "vertical";
      		
      		// boxTwo will be right or bottom depending on axis orientation
      		_boxTwo = new mx.containers.Box();
      		_boxTwo.direction = (_orientation) ? "horizontal" : "vertical";
      		
      		_boxOne.setStyle((_orientation) ? "horizontalAlign" : "verticalAlign", (_orientation) ? "left" : "top");
      		_boxTwo.setStyle((_orientation) ? "horizontalAlign" : "verticalAlign", (_orientation) ? "right" : "bottom");
      		if (_orientation) {
      			_boxOne.width = _width / 2 - 10;
      			_boxTwo.width = _width / 2 - 10;
      		} else {
      			_boxOne.height = _height / 2 - 10;
      			_boxTwo.height = _height / 2 - 10;
      		}	      		
      		
      		// panButtonOne is the left or top panning button depending on axis orientation
      		var panButtonOne:Button = new Button();
      		panButtonOne.toolTip = (_orientation) ? "Pan Left" : "Pan Up";
      		panButtonOne.setStyle("icon", (_orientation) ? leftArrowIcon : upArrowIcon);
      		panButtonOne.addEventListener(MouseEvent.CLICK,
	      		function(event:MouseEvent):void {
	      			// Remove the DateChoosers if either are visible
	      			if (_axis.type == 2) {
      					if (_dateBox.contains(_rDateChooser)) _dateBox.removeChild(_rDateChooser);
      					if (_dateBox.contains(_lDateChooser)) _dateBox.removeChild(_lDateChooser);
      				}
	      			
	      			var min:Number = _axis.dataMin;
    	  			var max:Number = _axis.dataMax;
      				var range:Number = max - min;
      				_axis.setDataRange(
      					(_orientation) ? min - range : max,
      					(_orientation) ? min : max + range);
      			});
      		
      		// zoomButtonOne is the left or top zooming button depending on axis orientation
      		var zoomButtonOne:Button = new Button();
      		zoomButtonOne.toolTip = (_orientation) ? "Zoom Left to Value" : "Zoom Up to Value";
      		zoomButtonOne.setStyle("icon", (_orientation) ? leftSearchIcon : upSearchIcon);
      		zoomButtonOne.addEventListener(MouseEvent.CLICK,
      			function(event:MouseEvent):void {
      				_textInputMin.width = zoomButtonOne.width;
      				_textInputMin.text = (_orientation) ? _axis.dataMin.toString() : _axis.dataMax.toString();
      				
      				
      				var buttonIndex:int = _boxOne.getChildIndex(zoomButtonOne);
      				_boxOne.removeChild(zoomButtonOne);

      				_boxOne.addChildAt(_textInputMin, buttonIndex);
      				_textInputMin.focusManager.setFocus(_textInputMin);
      				
      				_textInputMin.addEventListener(KeyboardEvent.KEY_DOWN, 
      					function(event:KeyboardEvent):void {
      						if (event.charCode == 13) {
      							var input:Number = Number(_textInputMin.text);
      							var change:Number = (_orientation) ? _axis.dataMax : _axis.dataMin;
      							_axis.setDataRange(
      								(_orientation) ? input : change,
      								(_orientation) ? change : input);	      							
      							_boxOne.removeChild(_textInputMin);
      							_boxOne.addChildAt(zoomButtonOne, buttonIndex);
      						}
      					});
      			});
      		
      		// If the axis is of type datetime create the date zooming control to be appended later
      		if (_axis.type == 2) {
      			var zoomDateOne:Button = new Button();
      			zoomDateOne.toolTip = (_orientation) ? "Zoom Left to Date" : "Zoom Up To Date";
      			zoomDateOne.setStyle("icon", calendarIcon);
      			zoomDateOne.addEventListener(MouseEvent.CLICK,
      				function(event:MouseEvent):void {
      					_dateBox.setStyle("horizontalAlign", "left");
      					if (_dateBox.contains(_rDateChooser)) _dateBox.removeChild(_rDateChooser);
	      				_dateBox.addChildAt(_lDateChooser, 0);
	      							
	      				_textInputMin = new TextInput();
	      				_textInputMin.width = zoomDateOne.width * 2;
	      				_textInputMin.setStyle("fontSize", "8");
	      				
	      				// Create a local date object and get the timezone offset to be used later
	      				var localDate:Date = new Date();
	      				var localOffset:Number = localDate.getTimezoneOffset();
	      				
	      				// Create a new date as the axis' min value
	      				var date:Date = new Date();				
						date.setTime(_axis.dataMin);
						
						// Construct the date and time string that will appear in the input box
	      				var dateString:String = 
	      					(date.getUTCMonth() <= 9) ? "0" + (date.getUTCMonth() + 1) + '' : (date.getUTCMonth() + 1) + '';
	      					dateString += "/";
	      					dateString += (date.getUTCDate() < 10) ? "0" + date.getUTCDate() + '' : date.getUTCDate() + '';
	      					dateString += "/" + date.getFullYear();
	      				var timeString:String = 
	      					(date.getUTCHours() < 10) ? "0" + date.getUTCHours() + '' : date.getUTCHours() + '';
	      				timeString += ":";
	      				timeString += (date.getUTCMinutes() < 10) ? "0" + date.getUTCMinutes() + '' : date.getUTCMinutes() + '';

	      				_textInputMin.text = dateString + " " + timeString;
	      				
	      				// Set the current date to the selected date on the date chooser
	      				date.setTime(Date.parse(_textInputMin.text));
	      				_lDateChooser.selectedDate = date;
	      				var maxDate:Date = new Date();
	      				maxDate.setTime(_axis.dataMax);
	      				_lDateChooser.selectableRange = {rangeEnd: maxDate};
	      			
	      				// Keep track of where the calendar button used to be and add the input field in its place
	      				var buttonIndex:int = _boxOne.getChildIndex(zoomDateOne);
	      				_boxOne.removeChild(zoomDateOne);
	      				_boxOne.addChildAt(_textInputMin, buttonIndex);
	      				_textInputMin.focusManager.setFocus(_textInputMin);
	      				
	      				// The date validator is responsible for making sure the date is in the format MM/DD/YYYY
	      				var dateValidator:DateValidator = new DateValidator();
						dateValidator.inputFormat = "MM/DD/YYYY";
						dateValidator.property = "text";
						dateValidator.source = _textInputMin;
						dateValidator.triggerEvent = "";
        				
        				// Update the input field, format the date, and validate it
        				_lDateChooser.addEventListener(CalendarLayoutChangeEvent.CHANGE,
        					function (event:CalendarLayoutChangeEvent):void {
        						_textInputMin.text = _dateFormatter.format(_lDateChooser.selectedDate);
        						var date:Array = _dateFormatter.format(_lDateChooser.selectedDate).split(" ");
        						dateValidator.validate(date[0]);
        					});
        					
        				// Continually validate the date as the user types	
        				_textInputMin.addEventListener(Event.CHANGE,
        					function (event:Event):void {
        						var date:Array = _textInputMin.text.split(" ");
        						dateValidator.validate(date[0]);
        					});
	      				
	      				// This is older code and could be removed... If the user presses the enter key update the axis
	      				_textInputMin.addEventListener(KeyboardEvent.KEY_DOWN, 
	      					function(event:KeyboardEvent):void {
	      						if (event.charCode == 13) {
	      							var input:Number = Date.parse(_textInputMin.text);
	      							var change:Number = _axis.dataMax;
	      							_axis.setDataRange(input - (localOffset / 60 * 3600000), change);
	      							
	      							_boxOne.removeChild(_textInputMin);
	      							_dateBox.removeChild(_lDateChooser);
	      							_boxOne.addChildAt(zoomDateOne, buttonIndex);
	      						}
	      					});
	      					
	      				// Switch between the DateChoosers if the user clicks in the input field
	      				_textInputMin.addEventListener(MouseEvent.CLICK,
	      					function(event:MouseEvent):void {
	      						_dateBox.setStyle("horizontalAlign", "left");
	      						
      							if (_dateBox.contains(_rDateChooser)) _dateBox.removeChild(_rDateChooser);
      							if (_dateBox.contains(_lDateChooser)) _dateBox.removeChild(_lDateChooser);
      							
	      						_dateBox.addChildAt(_lDateChooser, 0);		
	      					});
	      			});
      		}
			
			// panButtonTwo is the right or bottom panning button depending on axis orientation
      		var panButtonTwo:Button = new Button();
      		panButtonTwo.toolTip = (_orientation) ? "Pan Right" : "Pan Down";
      		panButtonTwo.setStyle("icon", (_orientation) ? rightArrowIcon : downArrowIcon);
      		panButtonTwo.addEventListener(MouseEvent.CLICK,
      			function(event:MouseEvent):void {
      				// Remove the DateChoosers if either are visible
      				if (_axis.type == 2) {
      					if (_dateBox.contains(_rDateChooser)) _dateBox.removeChild(_rDateChooser);
      					if (_dateBox.contains(_lDateChooser)) _dateBox.removeChild(_lDateChooser);
      				}
      				
      				var min:Number = _axis.dataMin;
      				var max:Number = _axis.dataMax;
      				var range:Number = max - min;
      				_axis.setDataRange(
      					(_orientation) ? max : min - range,
      					(_orientation) ? max + range : min);
      			});
      			     		    
      		// zoomButtonTwo is the right or bottom zooming button depending on axis orientation	     		 
      		var zoomButtonTwo:Button = new Button();
      		zoomButtonTwo.toolTip = (_orientation) ? "Zoom Right to Value" : "Zoom Down to Value";
      		zoomButtonTwo.setStyle("icon", (_orientation) ? rightSearchIcon : downSearchIcon);
      		zoomButtonTwo.addEventListener(MouseEvent.CLICK,
      			function(event:MouseEvent):void {
      				_textInputMax.width = zoomButtonTwo.width;
      				_textInputMax.text = (_orientation) ? _axis.dataMax.toString() : _axis.dataMin.toString();
      				
      				var buttonIndex:int = _boxTwo.getChildIndex(zoomButtonTwo);
      				_boxTwo.removeChild(zoomButtonTwo);

      				_boxTwo.addChildAt(_textInputMax, buttonIndex);
      				_textInputMax.focusManager.setFocus(_textInputMax);
      				
      				_textInputMax.addEventListener(KeyboardEvent.KEY_DOWN, 
      					function(event:KeyboardEvent):void {
      						if (event.charCode == 13) {
      							var input:Number = Number(_textInputMax.text);
      							var change:Number = (_orientation) ? _axis.dataMin : _axis.dataMax;
      							_axis.setDataRange(
      								(_orientation) ? change : input,
      								(_orientation) ? input : change);	      				      						
      							_boxTwo.removeChild(_textInputMax);
      							_boxTwo.addChildAt(zoomButtonTwo, buttonIndex);
      						}
      					});
      			});
      			
      		// If the axis is of type datetime create the date zooming control to be appended later
       		if (_axis.type == 2) {
      			var zoomDateTwo:Button = new Button();
      			zoomDateTwo.toolTip = (_orientation) ? "Zoom Left to Date" : "Zoom Up To Date";
      			zoomDateTwo.setStyle("icon", calendarIcon);
      			zoomDateTwo.addEventListener(MouseEvent.CLICK,
      				function(event:MouseEvent):void {
      					_dateBox.setStyle("horizontalAlign", "right");
      					if (_dateBox.contains(_lDateChooser)) _dateBox.removeChild(_lDateChooser);
	      				_dateBox.addChildAt(_rDateChooser, 0);		
	      				_textInputMax = new TextInput();
	      				_textInputMax.width = zoomDateTwo.width * 2;
	      				_textInputMax.setStyle("fontSize", "8");
	      				
	      				var localDate:Date = new Date();
	      				var localOffset:Number = localDate.getTimezoneOffset();
	      				
	      				var date:Date = new Date();
	      				date.setTime(_axis.dataMax);
	      				
	      				var dateString:String = 
	      					(date.getUTCMonth() <= 9) ? "0" + (date.getUTCMonth() + 1) + '' : (date.getUTCMonth() + 1) + '';
	      					dateString += "/";
	      					dateString += (date.getUTCDate() < 10) ? "0" + date.getUTCDate() + '' : date.getUTCDate() + '';
	      					dateString += "/" + date.getFullYear();
	      				var timeString:String = 
	      					(date.getUTCHours() < 10) ? "0" + date.getUTCHours() + '' : date.getUTCHours() + '';
	      				timeString += ":";
	      				timeString += (date.getUTCMinutes() < 10) ? "0" + date.getUTCMinutes() + '' : date.getUTCMinutes() + '';
	      					
	      				_textInputMax.text = dateString + " " + timeString;
	      				
	      				// Set the current date to the selected date on the date chooser
	      				date.setTime(Date.parse(_textInputMax.text));
	      				_rDateChooser.selectedDate = date;
	      				var minDate:Date = new Date();
	      				minDate.setTime(_axis.dataMin + 24 * 3600000);
	      				_rDateChooser.selectableRange = {rangeStart: minDate};
	      					      				
	      				var buttonIndex:int = _boxTwo.getChildIndex(zoomDateTwo);
	      				_boxTwo.removeChild(zoomDateTwo);
	      				_boxTwo.addChildAt(_textInputMax, buttonIndex);
	      				_textInputMax.focusManager.setFocus(_textInputMax);
	      				
	      				var dateValidator:DateValidator = new DateValidator();
						dateValidator.inputFormat = "MM/DD/YYYY";
						dateValidator.property = "text";
						dateValidator.source = _textInputMax;
						dateValidator.triggerEvent = "";
	      				
	      				_rDateChooser.addEventListener(CalendarLayoutChangeEvent.CHANGE,
        					function (event:CalendarLayoutChangeEvent):void {
        						_textInputMax.text = _dateFormatter.format(_rDateChooser.selectedDate);
        						var date:Array = _dateFormatter.format(_rDateChooser.selectedDate).split(" ");
        						if (minDate.getDate() == _rDateChooser.selectedDate.date) _textInputMax.text = date[0] + " 01:00";
        						dateValidator.validate(date[0]);
        					});
        					
        				_textInputMax.addEventListener(Event.CHANGE,
        					function (event:Event):void {
        						var date:Array = _textInputMax.text.split(" ");
        						dateValidator.validate(date[0]);
        					});
	      				
	      				_textInputMax.addEventListener(KeyboardEvent.KEY_DOWN, 
	      					function(event:KeyboardEvent):void {
	      						if (event.charCode == 13) {
	      							var input:Number = Date.parse(_textInputMax.text);
	      							var change:Number = _axis.dataMin;
	      							_axis.setDataRange(change, input - localOffset / 60 * 3600000);
	      							_boxTwo.removeChild(_textInputMax);
	      							_dateBox.removeChild(_rDateChooser);
	      							_boxTwo.addChildAt(zoomDateTwo, buttonIndex);
	      						}
	      					});
	      					
	      				_textInputMax.addEventListener(MouseEvent.CLICK,
	      					function(event:MouseEvent):void {
	      						_dateBox.setStyle("horizontalAlign", "right");
	      						
	      						if (_dateBox.contains(_rDateChooser)) _dateBox.removeChild(_rDateChooser);
      							if (_dateBox.contains(_lDateChooser)) _dateBox.removeChild(_lDateChooser);
      							
	      						_dateBox.addChildAt(_rDateChooser, 0);	
	      					});
	      			});
      		}
			
      		_box.addChild(_boxOne);
      		_box.addChild(_boxTwo);
      		_boxOne.addChild((_axis.type == 2) ? zoomDateOne : zoomButtonOne);
      		_boxOne.addChild(panButtonOne);
      		_boxTwo.addChild(panButtonTwo);
      		_boxTwo.addChild((_axis.type == 2) ? zoomDateTwo : zoomButtonTwo);
      		if (_axis.type == 2) _dateBox.addChild(_box);
      		_newSprite.addChild((_axis.type == 2) ? _dateBox : _box);
		}
		
		public function removeControls():void {
			_visible = false;
			_newSprite.removeChild((_axis.type == 2) ? _dateBox : _box);
			_newSprite.graphics.clear();
		}
		
		public function destroyAllControls():void {
			for (var i:uint = 0; i < _controlList.length; i++) {
      			// p represents a pointer to the set of controls being removed
      			var p:AxisControls = _controlList[i];
      			if (p.visible) {
      				p.removeControls();
      				p._controlButton.setStyle("icon", plusIcon);
	      			p._controlButton.toolTip = "Open Control Menu";
      			}
      		}
		}
		
		public function drawControlButton():void {
			// Push this instance of the axis controls onto the control list
			_controlList.push(this);
			
			
			_controlButton = new Button();
			_controlButton.transform.matrix = new Matrix(1, 0, 0, -1, 0, 6);
      		_controlButton.x = (_axis.orientation == 1) ? _xEndPos : _xPos + (_width / 2) - 3;
      		_controlButton.y = (_axis.orientation == 1) ? _yPos + (_height / 2) + 3 : _yEndPos + 7;
      		_controlButton.width = 6;
      		_controlButton.height = 6;
      		_controlButton.setStyle("icon", plusIcon);
      		_controlButton.toggle = true;
      		_controlButton.toolTip = "Open Control Menu";
      		_controlButton.addEventListener(MouseEvent.CLICK,      			 
      			function(event:MouseEvent):void {
      				var forceSend:Function = function():void {
      					if (_axis.type == 2) {
	      					var localDate:Date = new Date();
	      					var localHourOffset:Number = localDate.getTimezoneOffset() / 60 * 3600000;
	      					if (_boxOne.contains(_textInputMin) && _boxTwo.contains(_textInputMax)) {
	      						var min:Number = Date.parse(_textInputMin.text) - localHourOffset;
	      						var max:Number = Date.parse(_textInputMax.text) - localHourOffset;
	      						if (min < max) {
	      							_axis.setDataRange(min, max);		
	      						}
	      					} else if (_boxOne.contains(_textInputMin)) {
	      						var input:Number = Date.parse(_textInputMin.text) - localHourOffset;
	      						var change:Number = _axis.dataMax;
	      						if (input < change) {
	      							_axis.setDataRange(input, change);
	      						}
	      					} else if (_boxTwo.contains(_textInputMax)) {
	      						var input:Number = Date.parse(_textInputMax.text) - localHourOffset;
	      						var change:Number = _axis.dataMin;
	      						if (input > change) {
	      							_axis.setDataRange(change, input);
	      						}
      						}
      					} else {
      						if (_boxOne.contains(_textInputMin) && _boxTwo.contains(_textInputMax)) {
      							var min:Number = Number(_textInputMin.text);
      							var max:Number = Number(_textInputMax.text);
      							if (min < max) {
      								_axis.setDataRange(
      									(_orientation) ? min : max,
      									(_orientation) ? max : min);
      							}
      						} else if (_boxOne.contains(_textInputMin)) {
      							var input:Number = Number(_textInputMin.text);
      							var change:Number = (_orientation) ? _axis.dataMax : _axis.dataMin;
      							if (input < change) {
      								_axis.setDataRange(
      									(_orientation) ? input : change,
      									(_orientation) ? change : input);
      							}
      						} else if (_boxTwo.contains(_textInputMax)) {
      							var input:Number = Number(_textInputMax.text);
      							var change:Number = (_orientation) ? _axis.dataMin : _axis.dataMax;
      							if (change > input) {
      								_axis.setDataRange(
      									(_orientation) ? change : input,
      									(_orientation) ? input : change);
      							}
      						}
      					}
      				};
      				
      				if(!_axis.axisControl.visible) {
      					// Iterate through the list of possible controls determining which are visible
      					// If the controls are of date/time force send the dates to the axis and
      					// then proceed to remove the controls and toggle the activation button.
      					for (var i:uint = 0; i < _controlList.length; i++) {
      						// p represents a pointer to the set of controls being removed
      						var p:AxisControls = _controlList[i];
      						if (p.visible) {
      							if (p._axis.type == 2) {
	      							var localDate:Date = new Date();
	      							var localHourOffset:Number = localDate.getTimezoneOffset() / 60 * 3600000;
	      							if (p._boxOne.contains(p._textInputMin) && p._boxTwo.contains(p._textInputMax)) {
	      								var min:Number = Date.parse(p._textInputMin.text) - localHourOffset;
	      								var max:Number = Date.parse(p._textInputMax.text) - localHourOffset;
	      								if (min < max) {
		      								p._axis.setDataRange(min, max);
		      							}	
	      							} else if (p._boxOne.contains(p._textInputMin)) {
	      								var input:Number = Date.parse(p._textInputMin.text) - localHourOffset;
	      								var change:Number = p._axis.dataMax;
	      								if (input < change) {
	      									p._axis.setDataRange(input, change);
	      								}
	      							} else if (p._boxTwo.contains(p._textInputMax)) {
	      								var input:Number = Date.parse(p._textInputMax.text) - localHourOffset;
	      								var change:Number = p._axis.dataMin;
	      								if (input > change) {
	      									p._axis.setDataRange(change, input);	
	      								}
      								}
      							} else {
      								if (p._boxOne.contains(p._textInputMin) && p._boxTwo.contains(p._textInputMax)) {
      									var min:Number = Number(p._textInputMin.text);
      									var max:Number = Number(p._textInputMax.text);
      									if (min < max) {
      									p._axis.setDataRange(
      										(p._orientation) ? min : max,
      										(p._orientation) ? max : min);
      									}
      								} else if (p._boxOne.contains(p._textInputMin)) {
      									var input:Number = Number(p._textInputMin.text);
      									var change:Number = (p._orientation) ? p._axis.dataMax : p._axis.dataMin;
      									if (input < change) {
      										p._axis.setDataRange(
      											(p._orientation) ? input : change,
      											(p._orientation) ? change : input);
      									}
      								} else if (p._boxTwo.contains(p._textInputMax)) {
      									var input:Number = Number(p._textInputMax.text);
      									var change:Number = (p._orientation) ? p._axis.dataMin : p._axis.dataMax;
      									if (change > input) {
      										p._axis.setDataRange(
      											(p._orientation) ? change : input,
      											(p._orientation) ? input : change);
      									}
      								}
      							}
      							
      							p.removeControls();
      							p._controlButton.setStyle("icon", plusIcon);
	      						p._controlButton.toolTip = "Open Control Menu";
      						}
      					}
      					
      					// Draw the new controls and toggle the activation button
      					_axis.axisControl.drawControls();
      					_controlButton.setStyle("icon", minusIcon);
      					_controlButton.toolTip = "Close Control Menu";
      				} else {
						forceSend();
      					_axis.axisControl.removeControls();
      					
	      				_controlButton.setStyle("icon", plusIcon);
	      				_controlButton.toolTip = "Open Control Menu";
      				}
      			});
        	_newSprite.addChild(_controlButton);
		}
	}
}
