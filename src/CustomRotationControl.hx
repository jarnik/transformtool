package {
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import com.senocular.display.TransformTool;
	import com.senocular.display.TransformToolControl;
	import com.senocular.display.TransformToolCursor;
	
	public class CustomRotationControl extends TransformToolControl {
		
		private var length:Number = 20;
		private var circle:ScaleCircle;
		
		public function CustomRotationControl() {
			addEventListener(TransformTool.CONTROL_INIT, init, false, 0, true);
			circle = new ScaleCircle();
			addChild(circle);
		}
		
		private function init(event:Event):void {
			
			// add event listeners 
			transformTool.addEventListener(TransformTool.NEW_TARGET, update, false, 0, true);
			transformTool.addEventListener(TransformTool.TRANSFORM_TOOL, update, false, 0, true);
			transformTool.addEventListener(TransformTool.CONTROL_TRANSFORM_TOOL, update, false, 0, true);
			transformTool.addEventListener(TransformTool.CONTROL_DOWN, controlMouseDown, false, 0, true);
			transformTool.addEventListener(TransformTool.CONTROL_MOVE, controlMove, false, 0, true);
			
			// set this as a reference for the rotation cursor
			var cursor:TransformToolCursor = transformTool.rotationCursor;
			cursor.addReference(this);
			
			// initial positioning
			update();
		}
		
		private function update(event:Event = null):void {
			if (transformTool.target) {
				
				// move circle to point
				var top:Point = transformTool.boundsTop;
				var bottom:Point = transformTool.boundsBottom;
				var diff = top.subtract(bottom);
				var angle = Math.atan2(diff.y, diff.x);
				circle.x = top.x + length * Math.cos(angle);
				circle.y = top.y + length * Math.sin(angle);
				
				// draw connecting line
				graphics.clear();
				graphics.lineStyle(0,0);
				// draw from top of top ScaleCircle
				var offset:Number = circle.height/2;
				graphics.moveTo(top.x + offset * Math.cos(angle), top.y + offset * Math.sin(angle));
				graphics.lineTo(circle.x, circle.y);
			}
		}
		
		private function controlMouseDown(event:Event):void {
			if (transformTool.currentControl == this) {
				// if this tool is being clicked, set
				// the reference point to be the mouse location
				_referencePoint = transformTool.mouse;
			}
		}
		
		private function controlMove(event:Event):void {
			if (transformTool.currentControl == this) {
				// use default tool rotation if this tool is being used
				transformTool.rotationInteraction();
			}
		}
	}
}