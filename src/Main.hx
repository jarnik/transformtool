package;

import com.senocular.display.TransformTool;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.DisplayObjectContainer;
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
	
    private static var inited:Bool;
	private static var stateLayer:Sprite; 

    private static function initLog():Void {
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;        
		
		stateLayer = new Sprite();
		Lib.current.addChild( stateLayer ); 
		
        Lib.current.stage.addEventListener( Event.ENTER_FRAME, update );
    }

	private static function update( e:Event ) {
        if ( !inited ) {
            init();
        }
    }

	// Entry point
	public static function main() {
        inited = false;
        initLog();
	}

    private static function init():Void {
        inited = true;
        test();
    }

    private static function test():Void {
		var b:Bitmap = new Bitmap( Assets.getBitmapData("assets/rewind.png") );
		
		
		
		var tool:TransformTool = new TransformTool();
		stateLayer.addChild( tool );
		
		var s:Sprite = new Sprite();
		stateLayer.addChild( s );
		s.addChild( b );
		tool.target = s;
		
    }

} 