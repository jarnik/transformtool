package com.senocular.display;

import nme.display.DisplayObject;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Matrix;
import nme.geom.Point;

import com.senocular.display.TransformTool;
import com.senocular.display.TransformToolControl;

class TransformToolCursor extends TransformToolControl {
	
	private var _mouseOffset:Point;
	private var contact:Bool = false;
	private var active:Bool = false;
	private var references:DisplayHash<Bool>;
		
	public var mouseOffset( get_mouseOffset, set_mouseOffset ):Point;
	
	public function get_mouseOffset():Point {
		return _mouseOffset.clone();
	}
	public function set_mouseOffset(p:Point):Void {
		_mouseOffset = p;
	}
	
	public function new() {
		super();
		_mouseOffset = new Point(20, 20);
		references = new DisplayHash<Bool>();
		addEventListener(TransformTool.CONTROL_INIT, init);
	}
		
	/**
	 * Adds a reference to the list of references that the cursor
	 * uses to determine when to be displayed.  Typically this would
	 * be a TransformToolControl instance used in the transform tool
	 * @see removeReference
	 */
	public function addReference(reference:DisplayObject):Void {
		if (reference != null && !references.contains(reference)) {
			references.set( reference, true );
			addReferenceListeners(reference);
		}
	}
	
	/**
	 * Removes a reference to the list of references that the cursor
	 * uses to determine when to be displayed.
	 * @see addReference
	 */
	public function removeReference(reference:DisplayObject):DisplayObject {
		if (reference && references.contains( reference ) ) {
			removeReferenceListeners(reference);
			references.remove( reference );
			return reference;
		}
		return null;
	}
	
	/**
	 * Called when the cursor should determine 
	 * whether it should be visible or not
	 */
	public function updateVisible(event:Event = null):Void {
		if (active) {
			if (!visible) {
				visible = true;
			}
		}else if (visible != contact) {
			visible = contact;
		}
		position(event);
	}
	
	/**
	 * Called when the cursor should position itself
	 */
	public function position(event:Event = null):Void {
		if (parent != null ) {
			x = parent.mouseX + mouseOffset.x;
			y = parent.mouseY + mouseOffset.y;
		}
	}
	
	private function init(event:Event):Void {
		_transformTool.addEventListener(TransformTool.TRANSFORM_TOOL, position, false, 0, true);
		_transformTool.addEventListener(TransformTool.NEW_TARGET, referenceUnset, false, 0, true);
		_transformTool.addEventListener(TransformTool.CONTROL_TRANSFORM_TOOL, position, false, 0, true);
		_transformTool.addEventListener(TransformTool.CONTROL_DOWN, controlMouseDown, false, 0, true);
		_transformTool.addEventListener(TransformTool.CONTROL_MOVE, controlMove, false, 0, true);
		_transformTool.addEventListener(TransformTool.CONTROL_UP, controlMouseUp, false, 0, true);
		updateVisible(event);
		position(event);
	}
	
	private function addReferenceListeners(reference:DisplayObject):Void {
		reference.addEventListener(MouseEvent.MOUSE_MOVE, referenceMove, false, 0, true);
		reference.addEventListener(MouseEvent.MOUSE_DOWN, referenceSet, false, 0, true);
		reference.addEventListener(MouseEvent.ROLL_OVER, referenceSet, false, 0, true);
		reference.addEventListener(MouseEvent.ROLL_OUT, referenceUnset, false, 0, true);
	}
	
	private function removeReferenceListeners(reference:DisplayObject):Void {
		reference.removeEventListener(MouseEvent.MOUSE_MOVE, referenceMove, false);
		reference.removeEventListener(MouseEvent.MOUSE_DOWN, referenceSet, false);
		reference.removeEventListener(MouseEvent.ROLL_OVER, referenceSet, false);
		reference.removeEventListener(MouseEvent.ROLL_OUT, referenceUnset, false);
	}
	
	private function referenceMove(event:MouseEvent):Void {
		position(event);
		event.updateAfterEvent();
	}
	
	private function referenceSet(event:Event):Void {
		contact = true;
		if (_transformTool.currentControl == null) {
			updateVisible(event);
		}
	}
	
	private function referenceUnset(event:Event):Void {
		contact = false;
		if (_transformTool.currentControl == null) {
			updateVisible(event);
		}
	}

	// the following control methods rely on TransformToolControl.relatedObject
	// to tell if a reference is being interacted with and therefore active
	
	private function controlMouseDown(event:Event):Void {
		if (references.contains( _transformTool.currentControl.relatedObject ) ) {
			active = true;
			//~ contact = true;
		}
		updateVisible(event);
	}
	
	private function controlMove(event:Event):Void {
		if (references.contains( _transformTool.currentControl.relatedObject ) ) {
			position(event);
		}
	}
	
	private function controlMouseUp(event:Event):Void {
		if (references.contains( _transformTool.currentControl.relatedObject ) ) {
			active = false;
		}
		updateVisible(event);
	}
}
