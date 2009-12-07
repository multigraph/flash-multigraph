/// Copyright (c) 2007 Jasm Sison

/**
 *
 * Assumptions:
 *	- all members of a container must have similar dimensions
 *	- all containers must have an distinct id
 */
Tool._dragswapFactory = 
{
	makeItemSwappable: function ( element , swapContainer_array )
	{
		// make the item draggable
		var group = ToolMan.drag().createSimpleGroup ( element );

		if ( !swapContainer_array instanceof Array)
			swapContainer_array = [swapContainer_array];
		var swapcs = swapContainer_array;

		group._swapContainers = [];
		group._itemContainers = [];
		for (var i in swapcs)
		{
			/// this must be a reference
			/// or there will be no agreement on the number of elements
			/// currently in the container
			group._swapContainers[swapcs[i].element.id] = swapcs[i];
			group._itemContainers.push(swapcs[i].element);
		}

		group.register( 'dragstart', this._dragstart);
		group.register( 'dragmove',  this._drag);
		group.register( 'dragend',   this._dragend);

		return group;
	},

	makeItemSwappableInline : function ( element , container_array )
	{
		var group = ToolMan.drag().createSimpleGroup ( element );

		if ( !container_array instanceof Array)
			container_array = [container_array];
		var swapcs = container_array;

		
		group._swapContainers = [];
		group._itemContainers = [];
		for (var i in swapcs)
		{
			if (swapcs[i].getAttribute('nr'))
				swapcs[i].nr = swapcs[i].getAttribute('nr');
			else
				swapcs[i].nr = 0;

			if (swapcs[i].getAttribute('max'))
				swapcs[i].max = swapcs[i].getAttribute('max');
			else
				swapcs[i].max = 1;

			group._swapContainers[swapcs[i].id] = swapcs[i];
			group._itemContainers.push(swapcs[i]);
			/*alert('max: ' + swapcs[i].getAttribute('max') + "\n" +
				'nr: ' + swapcs[i].nr + "\n" +
				'element: ' + swapcs[i]);*/
		}

		group.register( 'dragstart', this._dragstart);
		group.register( 'dragmove',  this._drag);
		group.register( 'dragend',   this._dragend);

		return group;
	},
	
	_children : function (container, nodeName)
	{
		var container_children = container.childNodes;
		var children = new Array();
		for (var i=0, len=container_children.length; i<len; ++i)
			if (nodeName == container_children[i].nodeName)
				children.push (container_children[i]);
		return children;
	},
	
	/// see Tool.intersect()._dragstart
	_dragstart : function(dragEvent)
	{
		/// access libraries
		var intersect = Tool.intersect();
		var dragswap = Tool.dragswap();

		/// get references
		var group = dragEvent.group;
		var item_element = group.element;
		var containers = group._itemContainers;
		
		/// declare variables
		dragswap._container = null;
		dragswap._proxy_bool = false;

		/// setup container message passing system
		intersect.activate_containers(containers, Tool.dragswap()._container);

		/// setup proxy if needed
		var item_element = dragEvent.group.element;
		dragswap._proxy_element = item_element.cloneNode(false);
	},

	_drag : function(dragEvent)
	{
		/// access libraries
		var intersect = Tool.intersect();
		var coords = ToolMan.coordinates();
		var intersect = Tool.intersect();
		var dragswap = Tool.dragswap();

		/// declare variables
		var group = dragEvent.group;
		var item_element = dragEvent.group.element;
		var xmouse = dragEvent.transformedMouseOffset;
		var containers = dragEvent.group._itemContainers;
		var active_container = null;

		/// I need this because ._proxy_bool can't be trusted
		/// to give only a true positive
		dragswap._proxy_bool = false; 
		var proxy_element = null;
		
		/// if there is a proxy
		/// remove proxy from it's current position
		if (dragswap._proxy_element)
		{
			var proxy_parent = dragswap._proxy_element.parentNode;
			if (proxy_parent)
				proxy_element =
					proxy_parent.removeChild(dragswap._proxy_element);
		}

		/// find the container I'm hovering on top of
		active_container = intersect.intersectTest (dragswap._container, xmouse, containers);

		if (!active_container)
			return;

		/// refresh information
		dragswap._container = active_container;

		/// get children of active container
		var children = dragswap._children(active_container, active_container.nodeName);
		
		/// see if the max has been reached
		var scs = group._swapContainers;
		var container_data = scs[active_container.id];

		/// At which element does the mouse point at?
		var virtual_index = intersect.findVirtualIndex(xmouse, item_element, active_container);

		/// if swap max has not been reached or the action is a non-transfer
		if (container_data.max > container_data.nr || item_element.parentNode === active_container)
		{
			if (virtual_index >= children.length)
				dragswap._proxy_element =
					active_container.appendChild(dragswap._proxy_element);
			else
				dragswap._proxy_element = 
					active_container.insertBefore(dragswap._proxy_element, children[virtual_index]);

			/// add styling crap here for proxy
			dragswap._proxy_element.style.backgroundColor = "#ff0";

			dragswap._proxy_bool = true;
			coords.create(0, 0).reposition(dragswap._proxy_element);

			return;
		}
		
		/// cleanup
		children = null;	
	},

	_dragend : function(dragEvent)
	{
		/// access libraries
		var events = ToolMan.events();
		var dragswap = Tool.dragswap();
		var coords = ToolMan.coordinates();
		var intersect = Tool.intersect();

		/// access array of elements
		var group = dragEvent.group;
		var containers = group._itemContainers;
		var item_element = group.element;
		var xmouse = dragEvent.transformedMouseOffset;
		var proxy_element = dragswap._proxy_element;
		var proxy_bool = dragswap._proxy_bool;
		var active_container = null;

		/// shutdown message passing system
		intersect.deactivate_containers (containers);

		/// intersection test
		active_container = intersect.intersectTest (dragswap._container, xmouse, containers);

		/// if no container destroy proxy, put item back and exit
		if (!active_container)
		{
			/// detach proxy, remove proxy
			if (proxy_element)
			{
				if (proxy_element.parent)
					proxy_element.parent.removeChild (proxy_element);
				dragswap._proxy_element = null;			
			}	
			coords.create(0, 0).reposition(item_element);
			return;
		}		


		/// TODO increment container_data.nr in _dragend
		/// if proxy exists and proxy has been docked
		//try
		//{
		if (proxy_element && proxy_bool)
		{
			/// update new container
			var swapcs = group._swapContainers;
			swapcs[active_container.id].nr++;

			/// update old container (if there is one)
			if (item_element.parentNode.id && swapcs[item_element.parentNode.id])
				swapcs[item_element.parentNode.id].nr--;
				
			/// make the swap
			dragswap._proxy_element = active_container.replaceChild(item_element, proxy_element);
		}else
		{
			/// get children of active container
			var children = dragswap._children(active_container, active_container.nodeName);
	
			/// see if the max has been reached
			var scs = group._swapContainers;
			var container_data = scs[active_container.id];
	
			/// At which element does the mouse point at?
			var virtual_index = intersect.findVirtualIndex(xmouse, item_element, active_container);
	
			/// The maximum number of elements must be reached and the drag must be a transfer
			if (container_data.max == container_data.nr && item_element.parentNode !== active_container)
			{
				var target_element = null;
				if (virtual_index >= children.length)
				{
					target_element = children[children.length-1];
				}else
				{
					target_element = children[virtual_index];
				}
				
				/// WHY OH WHY HASN'T __SWAPNODE__ BEEN IMPLEMENTENTED OUTSIDE MSIE?!
				//if (!item_element.nextSibling) return; /// breaks swap behaviour
				var item_element_next = item_element.nextSibling;
				var target_element_next = target_element.nextSibling;
				var item_element_parent = item_element.parentNode;
				
				if (item_element_next)
					target_element = item_element_parent.insertBefore(target_element, item_element_next);
				else
					target_element = item_element_parent.appendChild(target_element);
					
				if (target_element_next)
					item_element = active_container.insertBefore(item_element, target_element_next);
				else
					item_element = active_container.appendChild(item_element);
				
				/// put everything in its place
				coords.create(0, 0).reposition(item_element);
				coords.create(0, 0).reposition(target_element);
			}
		}
		dragswap._proxy_element = null;
		coords.create(0, 0).reposition(item_element);
	}
};