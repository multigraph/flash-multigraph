package multigraph
{
	public class Export
	{
		import com.adobe.images.PNGEncoder;
		import mx.core.UIComponent;
		import flash.display.DisplayObject;
		import flash.net.FileReference;
		import flash.display.BitmapData;
		import flash.utils.ByteArray;
		
		public function Export()
		{
		}
        CONFIG::player10 {
          public static function savePNG(obj:UIComponent):void {
			var w:int = obj.screen.width;
			var h:int = obj.screen.height;
            
			var fr:FileReference = new FileReference();
			var bitmapdata:BitmapData = new BitmapData(w, h, false, 0xFFFFFF);
			bitmapdata.draw(obj);
			var bytes:ByteArray = PNGEncoder.encode(bitmapdata);
			fr.save(bytes, "image-" + w  + "x" + h + ".png");
          }
        }
	}
}
