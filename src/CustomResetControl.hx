package {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import com.senocular.display.TransformTool;
	import com.senocular.display.TransformToolControl;
	import com.senocular.display.TransformToolCursor;
	
	public class CustomResetControl extends TransformToolControl {
		
		public function CustomResetControl() {
			addEventListener(TransformTool.CONTROL_INIT, init, false, 0, true);
		}
		
		private function init(event:Event):void {
			
			// add event listeners 
			transformTool.addEventListener(TransformTool.NEW_TARGET, update, false, 0, true);
			transformTool.addEventListener(TransformTool.TRANSFORM_TOOL, update, false, 0, true);
			transformTool.addEventListener(TransformTool.CONTROL_TRANSFORM_TOOL, update, false, 0, true);
			addEventListener(MouseEvent.CLICK, resetClick);
			
			// initial positioning
			update();
		}
		
		private function update(event:Event = null):void {
			if (transformTool.target) {
				// find to bottom right of selection
				var maxX:Number = Math.max(transformTool.boundsTopLeft.x, transformTool.boundsTopRight.x);
				maxX = Math.max(maxX, transformTool.boundsBottomRight.x);
				maxX = Math.max(maxX, transformTool.boundsBottomLeft.x);
				
				var maxY:Number = Math.max(transformTool.boundsTopLeft.y, transformTool.boundsTopRight.y);
				maxY = Math.max(maxY, transformTool.boundsBottomRight.y);
				maxY = Math.max(maxY, transformTool.boundsBottomLeft.y);
				
				// set location to found values
				x = maxX;
				y = maxY;
			}
		}
		
		private function resetClick(event:MouseEvent):void {
			
			// reset the matrix but keep the current location by 
			// noting the change in the registration point
			var origReg:Point = transformTool.registration;
			
			// global matrix as a default matrix (identity)
			transformTool.globalMatrix = new Matrix();
			
			// find change in positioning based on registration
			// Note: registration location is based within
			// the coordinate space of the tool (not global)
			var regDiff = origReg.subtract(transformTool.registration);
			
			// update the tool matrix with the change in position
			// offsetting movement from the new matrix to have
			// the old and new registration points match
			var toolMatrix:Matrix = transformTool.toolMatrix;
			toolMatrix.tx += regDiff.x;
			toolMatrix.ty += regDiff.y;
			transformTool.toolMatrix = toolMatrix;
			
			// apply the new matrix to the target
			transformTool.apply();
		}
	}
}