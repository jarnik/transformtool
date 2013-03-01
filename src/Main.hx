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
import nme.events.MouseEvent;
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
		
		trace("START!");
		
		var tool:TransformTool = new TransformTool();
		Lib.current.addChild( tool );
		tool.target = s;
		tool.registration = new Point( s.x + s.width / 2, s.y + s.height / 2 );
		
		/*
		var c:TransformToolScaleControl = new TransformToolScaleControl(TransformTool.SCALE_BOTTOM, null, "boundsBottom");
		Lib.current.addChild( c );
		c.x = 50;
		c.y = 50;
		c.transformTool = tool;
		c.draw();
		*/
		
		var icon:Sprite = new Sprite();
		icon.graphics.clear();
		icon.graphics.lineStyle(2, 0xFF0000);
		icon.graphics.beginFill( 0x00ff00);
		var size = tool.controlSize;
		var size2:Float = size/2;
		icon.graphics.drawRect(-size2, -size2, size, size);
		icon.graphics.endFill();
		//Lib.current.addChild( icon );
		trace("icon "+icon.x+" "+icon.y);
		icon.x = 50;
		icon.y = 50;
		
		
		
		/*
		trace( "tool " + tool.x+" "+tool.y );
		trace( "toolSprites " + tool.toolSprites + " " + tool.toolSprites.x + " " + tool.toolSprites.y );
		trace( "scaleControls "+tool.scaleControls+" "+tool.scaleControls.x+" "+tool.scaleControls.y );
		trace( "scale TOP LEFT " + tool.scaleTopLeftControl +" " + tool.scaleTopLeftControl.x +" " + tool.scaleTopLeftControl.y );
		
		
		//icon.width = 100;
		//icon.height = 100;
		
		tool.x += 100;
		tool.y += 100;
			*/
		//tool.scaleTopLeftControl.addChild( icon );
		//icon.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		trace( s+" has listener "+s.hasEventListener( MouseEvent.MOUSE_MOVE ));
		tool.skewBottomControl.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		trace( "skewBottomControl " + tool.skewBottomControl.alpha +" " + tool.skewBottomControl.width +" "
			+tool.skewBottomControl.height+" "+tool.skewBottomControl.visible );
		//tool.toolSprites.addChild( icon );
    }
	
	private static function onMouseMove( e:MouseEvent ):Void 
	{
		trace("mouse move "+e.stageX);
	}

} 