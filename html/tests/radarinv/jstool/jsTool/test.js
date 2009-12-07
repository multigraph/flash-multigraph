/// Copyright (c) 2007 Jasm Sison

Tool._testing =
{
	/// make printing object ...
	_createPrintingObject : function (id)
	{
		var body = document.getElementsByTagName('BODY')[0];
		var bodyFirstChild = null;
		var container = null;
		if (!Tool.test()._printer)
		{
			Tool.test()._printer = document.createElement('DIV');
			if (body.childNodes)
				Tool.test()._printer = body.insertBefore (Tool.test()._printer, body.childNodes[0]);
			else
				Tool.test()._printer = body.appendChild (Tool.test()._printer);
		}
		container = Tool.test()._printer;
		container.style["position"] = 'fixed';

		var element = document.createElement('INPUT');
		element = container.appendChild(element);
		element.id = id;
		
		return element;
	},
	
	_print : function (id, str)
	{
		var element = document.getElementById(id);
		if (!element)
			element = this._createPrintingObject(id); 
		element.setAttribute("value",str);	
	},
	
	/// set
	set : function (v)
	{
		Tool._testing.value = v;
	},
	
	/// incr
	incr : function ()
	{
		Tool._testing.value++;
	},
	
	/// decr
	decr : function ()
	{
		Tool._testing.value--;
	},
	
	/// print value
	print : function ()
	{
		var id = 'test';
		this._print (id, Tool._testing.value);	
	},

	/// print	
	print1 : function (s)
	{
		var id = 'test1';
		this._print (id, s);
	},

	print2 : function (s)
	{
		var id = 'test2';
		this._print (id, s);
	},

	print3 : function (s)
	{
		var id = 'test3';
		this._print (id, s);
	},
	
	/// if more print units are needed
	generate_printers : function (n)
	{
		for (var i=4; i<=n; ++i)
		{
			Tool._testing["print" + i] = function (s)
			{
				var id = 'test' + i;
				this._print(id, s);
			}	
		}	
	}
};
