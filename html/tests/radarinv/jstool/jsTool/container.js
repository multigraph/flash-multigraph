/// Copyright (c) 2007 Jasm Sison

Tool._containableItemFactory = 
{
	/** containers either array or many elements **/
	makeItemContainable: function ( element_or_dragGroup , container_array )
	{
		// make the item draggable
		var group = null;
		if (element_or_dragGroup instanceof _ToolManDragGroup)
			{group = element_or_dragGroup;}
		else
			{group = ToolMan.drag().createSimpleGroup ( element_or_dragGroup );}

		/// !!! only dom elements allowed !!!
		if ( container_array instanceof Array)			
			group._itemContainers = container_array;
		else
			group._itemContainers = [container_array];

		group.register( 'dragstart', this._dragstart);
		group.register( 'dragmove',  this._drag);
		group.register( 'dragend',   this._dragend);

		return group;
	},

	_dragstart : function(dragEvent)
	{
		/// access libraries
		var intersect = Tool.intersect();
		var events = ToolMan.events();
		var drag2cs = Tool.drag2container();

		// access array of elements
		var containers = dragEvent.group._itemContainers;
	
		/// Setup variable in Tool
		/// get ready for message passing
		drag2cs._container = null;
		drag2cs._proxy_bool = false;

		/// setup container message passing system
		intersect.activate_containers(containers, Tool.drag2container()._container);

		/// setup proxy object, only clone root
		var item_element = dragEvent.group.element;
		drag2cs._proxy_element = item_element.cloneNode(false);
		
		/// there is a chance that this might copy the exact same id
		/// and interfere with the original, if getById is used later on
		//drag2cs._proxy_element.id += "-proxy";
	},

	_drag : function(dragEvent)
	{
		/// access libraries
		var intersect = Tool.intersect();
		var coords = ToolMan.coordinates();
		var drag2cs = Tool.drag2container();
		
		var item_element = dragEvent.group.element;
		var xmouse = dragEvent.transformedMouseOffset;
		var containers = dragEvent.group._itemContainers;
		var active_container = null;

		drag2cs._proxy_bool = false; 
		var proxy_element = null;
		/// I need this because group._proxy_bool can't be trusted
		/// to give only a true positive
		
		/// if there is a proxy
		/// remove proxy from it's current position
		/// else make a new proxy
		if (drag2cs._proxy_element)
		{
			var proxy_parent = drag2cs._proxy_element.parentNode;
			if (proxy_parent)
				proxy_element =
					proxy_parent.removeChild(drag2cs._proxy_element);
		}
		
		/// find the container I'm hovering on top of
		active_container = intersect.intersectTest (drag2cs._container, xmouse, containers);
		
		if (!active_container)
			return;
		
		/// active container message refresh
		drag2cs._container = active_container;

		/// special fx
		//drag2cs._orig_container_bgcolor = active_container.style.backgroundColor;
		//active_container.style.backgroundColor = "#fff";
		//window.setTimeout
		//	(function () {active_container.backgroundColor = container_bgcolor;}, 500);
		
		/// FIX just use a different element nodeName for the handler <b ... <span etc...
		/// not <div...
		var children = active_container.getElementsByTagName(item_element.nodeName);

		/// the container is empty
		if (!children.length)
		{
			/// insert a proxy anyway
			drag2cs._proxy_element = active_container.appendChild (drag2cs._proxy_element);
			drag2cs._proxy_bool = true;
			coords.create(0, 0).reposition (drag2cs._proxy_element); /// ?!

			return;
		}
		
		/// At which element does the mouse point at?
		var virtual_index = intersect.findVirtualIndex(xmouse, item_element, active_container);

		if (virtual_index >= children.length)
			drag2cs._proxy_element =
				active_container.appendChild(drag2cs._proxy_element);
		else
			drag2cs._proxy_element = 
				active_container.insertBefore(drag2cs._proxy_element, children[virtual_index]);

		/// add styling crap here for proxy
		drag2cs._proxy_element.style.backgroundColor = "#ff0";

		drag2cs._proxy_bool = true;
		coords.create(0, 0).reposition(drag2cs._proxy_element);

		return;
	},

	_dragend : function (dragEvent)
	{
		/// access libraries
		var events = ToolMan.events();
		var intersect = Tool.intersect();
		var drag2cs = Tool.drag2container();
		var coords = ToolMan.coordinates();

		/// declare variables	
		var containers = dragEvent.group._itemContainers;
		var item_element = dragEvent.group.element;
		var xmouse = dragEvent.transformedMouseOffset;
		var proxy_element = drag2cs._proxy_element;
		var active_container = null;

		/// shutdown message passing system
		intersect.deactivate_containers (containers);

		/**
		 * Evidently mouseup does not bubble through to the container,
		 * so we have to do some inexpensive intersection tests
		 *
		 * The message passing mechanism is an optimization
		 * Necessary for eliminating intersection tests with all
		 * containers, but the message passed must be verified first
		 */
		/// intersection test
		active_container = intersect.intersectTest (drag2cs._container, xmouse, containers);
	

		/// if no container destroy proxy, put item back and exit
		if (!active_container)
		{
			/// detach proxy, remove proxy
			if (drag2cs._proxy_element)
			{
				proxy_element = drag2cs._proxy_element;
				if (proxy_element.parent)
					proxy_element.parent.removeChild (proxy_element);
				drag2cs._proxy_element = null;			
			}	
			coords.create(0, 0).reposition(item_element);
			return;
		}		

		/// if proxy exists and proxy has been docked
		try
		{
			if (proxy_element && drag2cs._proxy_bool)
				drag2cs._proxy_element =
					 active_container.replaceChild(item_element, proxy_element);
		} catch (error)
		{
			/*
			alert (error.message);
			alert(
				"if you have encountered this error: " +
				"then you have probably dragged an item over " +
				"a number of overlapping containers" +
				"there is currently no fix for this."
			);
			*/
			var _proxy = drag2cs._proxy_element;
			var _proxy_parent = _proxy.parentNode;
			drag2cs._proxy_element = _proxy_parent.removeChild(_proxy);
			drag2cs._proxy_element = null;
			coords.create(0, 0).reposition(item_element);
		}
		drag2cs._proxy_element = null;
		coords.create(0, 0).reposition(item_element);
	}	

	/**
	 * When the 'dragstart' event of the item is activated
	 * the containers are notified by registering the functions
	 * needed to coordinate when a a container experiences 
	 * a mouseover or mouseup on a container
	 *
	 * When the dragmove event happens, the containers scan
	 * if they are active
	 *
	 * When the dragend event happens, the item is placed if
	 * there is an active container, and after that in any case
	 * the containers are relieved of the functions activated
	 * at dragstart
	 */
	/**
	 * WARNING!
	 * Javascript language feature: 'this' is a bitch
	 *	If you create an object, and refer to 'this' from the object
	 *	like this: obj.fn1 ... obj.fnn, 'this' pertains to obj.
	 *	But when you assign obj.fni to handle an event of some objx, (objx =/= obj)
	 *	then 'this' will no longer point to obj, but to objx.
	 * TIP!
	 * Also, closures always take the last state of the variable it is initialized in
	 */
	
};
