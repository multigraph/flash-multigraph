/// Copyright (c) 2007 Jasm Sison

Tool._intersectionDrawer =
{
	_corners : function (item)
	{
		var coords = ToolMan.coordinates();
		var size = coords._size(item);		
		var topLeftOffset = coords.topLeftOffset(item);
		var bottomRightOffset = coords.bottomRightOffset(item);
		var topRightOffset = topLeftOffset.plus(coords.create(size.x,0));
		var bottomLeftOffset = topLeftOffset.plus(coords.create(0,size.y));

		// clockwise, starting from topleft corner
		return [topLeftOffset, topRightOffset, bottomRightOffset, bottomLeftOffset];
	},
	
	_intersectDomain : function (container)
	{
		var coords = ToolMan.coordinates();
		var size = coords._size(container);
		var topLeftOffset = coords.topLeftOffset(container);
		var topLeftOffsetX = topLeftOffset.x;
		var topLeftOffsetY = topLeftOffset.y;
		var d = new Array();
		d[0] = topLeftOffsetX;
		d[1] = topLeftOffsetY;
		d[2] = topLeftOffsetX + size.x;
		d[3] = topLeftOffsetY + size.y;
		return d;

		/// illegal syntax: expressions in an array declaration
		/*
		/// e.g.		
		return
		{
			topLeftOffsetX,
			topLeftOffsetY,
			topLeftOffsetX + size.x,
			topLeftOffsetY + size.y
		};
		*/
	},

	/// mouse to div intersection
	pointIntersect : function (p, container)
	{
		var d = this._intersectDomain(container);

		var topLeftOffsetX = d[0];
		var topLeftOffsetY = d[1];
		var topLeftOffsetXPlusWidth = d[2];
		var topLeftOffsetYPlusHeight = d[3];		
		
/*
		Tool . test() .
		print3 (p.x + ' ' + topLeftOffsetX + ' ' + topLeftOffsetXPlusWidth + ' '
			+ p.y +  ' ' + topLeftOffsetY + ' ' + topLeftOffsetYPlusHeight);
*/

		if (topLeftOffsetX <= p.x && p.x <= topLeftOffsetXPlusWidth)
			if (topLeftOffsetY <= p.y && p.y <= topLeftOffsetYPlusHeight)
				return true;
		return false;		
	},

	/**
	 * Two assumptions:
	 *	- item must be strictly smaller than container -> a corner of the item must intersect the space of the container
	 *	- the shapes must be rectangular
	 */
	/// corner to element intersection
	intersect : function (item, container)
	{
		var d = this._intersectDomain(container);

		var topLeftOffsetX = d[0];
		var topLeftOffsetY = d[1];
		var topLeftOffsetXPlusWidth = d[2];
		var topLeftOffsetYPlusHeight = d[3];
		
		var corners = this._corners (item);

		for
		(
			var i = 0, len=corners.length;
			i<len;
			++i
		)
		{
			var p = corners[i];
			if (topLeftOffsetX <= p.x && p.x <= topLeftOffsetXPlusWidth)
				if (topLeftOffsetY <= p.y && p.y <= topLeftOffsetYPlusHeight)
		/**
		 * at least one corner is inside, if there are multiple intersections
		 * pick the first container where there is an intersection
		 */
					return true;
		}
		return false;
	},

	intersectContainers : function (item_element, containers_array)
	{
		var active_container = null;
		for (var c=0, len=containers_array.length; c<len; ++c)
		{
			var container = containers_array[c];
			if (this.intersect(item_element, container))
			{
				active_container = container;
				break;
			}
		}
		return active_container;
	},
	
	pointIntersectContainers : function (p_coord, containers_array)
	{
		var active_container = null;
		for (var c=0, len=containers_array.length; c<len; ++c)
		{
			var container = containers_array[c];
			if (this.pointIntersect(p_coord, container))
			{
				active_container = container;
				break;
			}
		}
		return active_container;
	},

	activate_containers : function(containers, target_obj)
	{
		var events = ToolMan.events();

		function closureMakerMessagePassing (ac, to)
		{
			var _active_container = ac;
			var _target_object = to;
			return function ()
			{
				_target_object = _active_container; // DONE
			};
		};

		var events_str = 'mouseup mouseover mouseout mouseenter';
		var events_arr = new Array();
		events_arr = events_str.split(' ');
		var container = null;
		for (var c=0, len1=containers.length; c<len1; ++c)
		{	
			container = containers[c];
			container._sendMessageIntersect = closureMakerMessagePassing (container, target_obj);
			for (var v=0, len2 = events_arr.length; v<len2; ++v)
				events.register
				(
					container,
					events_arr[v],
					container._sendMessageIntersect
				);
		}		
	},

	deactivate_containers : function (containers)
	{
		var events = ToolMan.events();
		var container = null;
		var events_str = 'mouseup mouseover mouseout mouseenter';
		var events_arr = new Array();
		events_arr = events_str.split(' ');
		for (var c=0, len1=containers.length; c<len1; ++c)
		{
			container = containers[c];
			for (var v=0, len2 = events_arr.length; v<len2; ++v)
			{
				events.unregister
				(
					container,
					events_arr[v],
					container._sendMessageIntersect
				);
			}
			// erase the handler
			container._sendMessageIntersect = null;
		}
	},

	intersectTest : function (container, mouse_coord, containers)
	{
		if (container)
			if ( this.pointIntersect(mouse_coord, container) )
				return container;
		return this.pointIntersectContainers(mouse_coord, containers);
	},

	/// drawback: you have to assume that all siblings have the same dimensions
	/// otherwise it will not work as expected
	findVirtualIndex : function  (p_coord, ref_item, container)
	{
		var coords = ToolMan.coordinates();

		var c_topLeftOffset = coords.topLeftOffset(container);
		var c_size = coords._size(container);
		var i_size = coords._size(ref_item);

		var virt_cols = Math.floor (c_size.x / i_size.x);
		var virt_rows = Math.floor (c_size.y / i_size.y);

		var mouse_pos = p_coord . minus (c_topLeftOffset);

		var rel_pos_x = mouse_pos.x / c_size.x;
		var rel_pos_y = mouse_pos.y / c_size.y;

		var col = Math.floor (virt_cols * rel_pos_x);
		var row = Math.floor (virt_rows * rel_pos_y);
		
		var insert_index = 0;
		for (var r=0; r<row; ++r)
		{
			insert_index = r * virt_cols;
		}
		insert_index += col;
		return insert_index;
	}
};
