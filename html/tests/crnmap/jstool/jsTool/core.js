/// Copyright (c) 2007 Jasm Sison

/**
 *
 * This is an extension to the original Toolman javascript library
 * This 'extension' shall be referred to as "Tool"
 * Tool follows the general design of "Toolman"
 * 	which uses factory objects to create wrapped _drag&drop_ objects
 *
 */

var Tool =
{
	/// before drag2container or dragswap get called
	/// make sure this is present
	intersect : function ()
	{
		var f = Tool._intersectionDrawer;
                if (!f) throw "Tool intersection module isn't loaded";
                return f;
	},

	/// gets the parent, gets its siblings
	/// then puts all other z-index value of all siblings to 0
	/// then increments own z-index value 
	raise: function()
	{
		var f = Tool._raiseFactory;
		if (!f) throw "Tool raise module isn't loaded";
		return f;
	},

	/// drag item to container(s)
	drag2container: function ()
	{
		var f = Tool._containableItemFactory;
		if (!f) throw "Tool drag2container module isn't loaded";
		return f;
	},
	
	dragswap: function ()
	{
		var f = Tool._dragswapFactory;
		if (!f) throw "Tool dragswap module isn't loaded";
		return f;	
	},	

	/// creates input elements to show ouput value
	/// purely for debugging and testing
	test: function ()
	{
		var f = Tool._testing;
		if (!f) throw "Tool test module isn't loaded";
		return f;
	}
};

