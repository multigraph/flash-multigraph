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
  import flash.display.Bitmap;
  import flash.geom.Matrix;
  import mx.core.UIComponent;
    
  public class ImageAnnotation extends NewAnnotation
  {
    private var _bitmap : Bitmap;

    public function ImageAnnotation(bitmap:Bitmap,
                          bx:Number, by:Number,
                          ax:Number, ay:Number,
                          px:Number, py:Number,
                          graph:Graph,
                          frameIsPlot:Boolean):void 
    {
      _bitmap = bitmap;

      super(bx, by,
            ax, ay,
            px, py,
            graph,
            frameIsPlot,
            0xffffff, /*color -- moot, since we set opacity for background to 0 below*/
            0, /*border*/
            0xffffff, /*borderColor -- moot since we set border=0 above*/
            0, /*opacity for background*/
            0  /*radius*/
            );
    }

    override protected function createChildren():void {
      _bitmap.x = 0;
      _bitmap.y = 0;
      _bitmap.transform.matrix = new Matrix(1, 0, 0, -1, 0, _bitmap.height);
      addChild(_bitmap);
      this.width = _bitmap.width;
      this.height = _bitmap.height;
      super.createChildren();
    }
  }
}
