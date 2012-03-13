package multigraph {
    /**
    * This function can be used by the renderer whenever setting any of the color options. In most cases
    * experienced users will probably want to supply a hex set for a specific color. The follow function 
    * takes several popular color names and returns the hex uint code for that color.
    * */
    public function parsecolor(color:String):uint {
		switch(color) {
			case "black":   return 0x000000;
    		case "red":     return 0xFF0000;
    		case "green":   return 0x00FF00;
    		case "blue":    return 0x0000FF;
    		case "cyan":    return 0x00FFFF;
    		case "yellow":  return 0xFFFF00;
    		case "magenta": return 0xFF00FF;
    		case "skyblue": return 0x87CEEB;
    		case "khaki":   return 0xF0E68C;
    		case "orange":  return 0xFFA500;
    		case "salmon":  return 0xFA8072;
    		case "olive":   return 0x9ACD32;
    		case "sienna":  return 0xA0522D;
    		case "pink":    return 0xFFB5C5;
    		case "violet":  return 0xEE82EE;
		}
		if (!color.match(/^0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$/)) {
			throw new ParseError('invalid color: ' + color);
		}
		return parseInt(color) as uint;
	}
}
