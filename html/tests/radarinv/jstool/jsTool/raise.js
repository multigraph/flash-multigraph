/// Copyright (c) 2007 Jasm Sison

Tool._raiseFactory =
{
	/// only draggable elements are raisable
	/// so use the _ToolManDragGroup object
	/// of the element
	makeRaisable : function (group)
	{
		/**
		 * There are 4 abstracted events in the library:
		 * @ draginit (this is before the drag i.e. when a mousedown is detected)
		 * @ dragstart (right after draginit, it hooks dragmove and dragend i.e. mouseover and mouseup)
		 * @ dragmove (when there is a element.mousedown and document.mouseover is detected)
		 * @ dragend (when a mouseup is detected)
		 */
		group.register('draginit', this._raise);
		group.register('dragend', this._dragend);
		ToolMan.events().register(group.element, "mousedown", this._raise);
	},

	_raise : function (dragEvent)
	{
		var element = dragEvent.group ? dragEvent.group.element : this;

		var parent = element.parentNode;
		
		/// advantage: the search is limited only to the child elements under the parent
		/// drawback: this might contain many false positives.
		var siblings = parent.childNodes;
		for (var i=0, len=siblings.length; i<len; ++i)
			if (element.nodeName == siblings[i].nodeName)
			//if (siblings.style)
				siblings[i].style.zIndex = 0;
		/*
		/// advantage: locates only elements of the same type
		/// drawback: this selects all subnodes recursively (many false positives)
		var siblings = parent.getElementsByTagName (element.nodeName);
		for (var i=0, len=siblings.length; i<len; ++i)
			siblings[i].style.zIndex = 0;
		*/
		element.style.zIndex++;
	},

	_dragstart : function (dragEvent)
	{
		/// hook extra parameter to ToolManGroup object to check for double registered _raise
		ToolMan.events().unregister(dragEvent.group.element, "mousedown", Tool.raise()._raise);
	},

	_dragend : function (dragEvent)
	{
		ToolMan.events().register(dragEvent.group.element, "mousedown", Tool.raise()._raise);
	}
};
