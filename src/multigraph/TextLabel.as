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
  import flash.geom.Matrix;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;

  public class TextLabel extends TextField
  {
    /*    
     * A TextLabel is a non-editable TextField that can be positioned,
     * aligned, and rotated in a convenient manner.
     *
     * !!!
     * IMPORTANT NOTE: In order for this class to work correctly
     * in Multigraph, you need to be sure to pass the following
     * option to the mxmlc compiler (in the "Flex Compiler" options
     * in Flash Builder):
     *          -managers flash.fonts.AFEFontManager
     * Failing to do this will cause all your TextLabels to be invisible
     * but will generate no errors or warnings!!
     * !!!
     *
     * Note: this object is designed to be inserted into a parent object
     * whose vertical coordinate direction has been reversed, so that
     * y increases in the upward screen direction.
     *
     * The location of the TextLabel object is specified in terms of
     * an "anchor" point which is a location within the text field.
     * The achor point is specified in a coordinate systems that
     * ranges from -1 to 1 in both the horizontal and vertical across
     * the length and width of the text itself.  (-1,-1) corresponds
     * to the lower left corner of the text, and (1,1) corresponds to
     * the upper right corner.  The text will be positioned so that
     * its anchor point (anchorX,anchorY) is located at the given
     * location (positionX,positionY) relative to its parent, and
     * rotated the given number of degrees counterclockwize from
     * horizontal.
     * 
     * The text of the TextField, and a TextFormat object determining
     * its format, must be specified in the constructor.  This
     * information is used in determining the pixel coordinates of the
     * achor point.  (If the text or the format is later changed, the
     * anchor point will no longer be correct.)
     */
    public function TextLabel(text:String,
                              textFormat:TextFormat,
                              positionX:Number,
                              positionY:Number,
                              anchorX:Number,
                              anchorY:Number,
                              degreesRotation:Number) {
      super();
      this.text = text;
      this.setTextFormat(textFormat);
      this.autoSize = TextFieldAutoSize.LEFT;
      this.embedFonts = true;
      this.selectable = false;
      
      // set (px,py) to the pixel coords of the anchor point
      var px:Number = (anchorX+1)*this.textWidth/2.0;
      var py:Number = (1+anchorY)*this.textHeight/2.0;

      var radians:Number = Math.PI * degreesRotation / 180;
		
      var c:Number = Math.cos(-radians);
      var s:Number = Math.sin(-radians);

	  var Tx:Number = positionX - ( c*px + s*py  );
	  var Ty:Number = positionY - ( -s*px + c*py  );

      // R is a reflection matrix --- it reflects the TextField in a
      // horizontal line along its base; this is what is needed to
      // counterbalance the fact that the parent coordinate system has
      // y reversed.
	  var R:Matrix = new Matrix(1,  0,
	  							0, -1,
	  							0, textHeight);

      // M is the general positioning matrix.  Note that the
      // translational component of this matrix is the position vector
      // minus the "rotated" anchor point:
	  var M:Matrix = new Matrix(c, -s,
                                s, c,
                                Tx,
                                Ty
                                );

      // This seems to replace R with M*R --- i.e.  "concat()" seems
      // to do left matrix multiplication:
	  R.concat(M);

      // Finally, set the TextField's transform to what is now M*R:
      this.transform.matrix = R;

      /*
       * This is quite bewildering.  The above code seems to do the
       * right thing, which is to set the object's transformation to
       * the result of first reflecting in the TextField baseline,
       * then positioning as desired.  If we work out the formula for
       * M*R and just set this.transform.matrix to that result
       * directly, though, we get
       * 
       *     this.transform.matrix = new Matrix(c,  s,
       *                                        s,  -c,
       *                                        Tx - s * textHeight,
       *                                        Ty + c * textHeight);
       * 
       * Right?  Did I make a mistake with this?  I can't find one,
       * but replacing the above code with this combined formula
       * produces the wrong result.  So for now, I'm leaving it in
       * terms of the product M*R.  But what on earth is going on?
       */ 

    }
		
  }
}
