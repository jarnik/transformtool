package;

import com.senocular.display.TransformTool;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.DisplayObjectContainer;
import nme.geom.Point;
import nme.text.TextField;
import nme.text.Font;
import nme.text.TextFormat;
import nme.Lib;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.KeyboardEvent;

class Main extends Sprite 
{
	
	public static function main() {
		var bgr:Sprite = new Sprite();
		Lib.current.addChild( bgr );
		bgr.graphics.beginFill( 0xf0f0f0 );
		bgr.graphics.drawRect( 0, 0, 600, 400 );
		bgr.graphics.endFill();
		
		var s:Sprite = new Sprite();
		Lib.current.addChild( s );
		
		var b:Bitmap = new Bitmap( Assets.getBitmapData("assets/haxe_logo.png") );
		s.addChild( b );
		s.x = (600 - s.width) / 2;
		s.y = (400 - s.height) / 2;
		
		var tool:TransformTool = new TransformTool();
		Lib.current.addChild( tool );
		tool.target = s;
		tool.registration = new Point( s.x + s.width/2, s.y + s.height/2 );
    }

} 