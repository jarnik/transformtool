package com.senocular.display;
	
import nme.display.InteractiveObject;
import nme.display.MovieClip;
import nme.geom.Matrix;
import nme.geom.Point;

class TransformToolControl extends MovieClip {
	
	// Variables
	private var _transformTool:TransformTool;
	private var _referencePoint:Point;
	private var _relatedObject:InteractiveObject;
		
	// Properties
	public var transformTool( get_transformTool, set_transformTool ):TransformTool;
	public var relatedObject( get_relatedObject, set_relatedObject ):InteractiveObject;
	public var referencePoint( get_referencePoint, set_referencePoint ):Point;
	
	/**
	 * Reference to TransformTool instance using the control
	 * This property is defined after using TransformTool.addControl
	 * prior to being added to the TransformTool display list
	 * (it can be accessed after the TransformTool.CONTROL_INIT event)
	 */
	public function get_transformTool():TransformTool {
		return _transformTool;
	}
	public function set_transformTool(t:TransformTool):TransformTool {
		_transformTool = t;
		return transformTool;
	}
	
	/**
	 * The object "related" to this control and can be referenced
	 * if the control needs association with another object.  This is
	 * used with the default move control to relate itself with the
	 * tool target (cursors also check for this)
	 */
	public function get_relatedObject():InteractiveObject {
		return _relatedObject;
	}
	public function set_relatedObject(i:InteractiveObject):InteractiveObject {
		_relatedObject = i ? i : this;
		return relatedObject;
	}
	
	/**
	 * A point of reference that can be used to handle transformations
	 * A TransformTool instance will use this property for offsetting the
	 * location of the mouse to match the desired start location of the transform
	 */
	public function get_referencePoint():Point {
		return _referencePoint;
	}
	public function set_referencePoint(p:Point):Point {
		_referencePoint = p;
		return referencePoint;
	}
	
	/**
	 * Constructor
	 */
	public function new() {
		super();
		_relatedObject = this;
	}
	
	/**
	 * Optionally used with transformTool.maintainHandleForm to 
	 * counter transformations applied to a control by its parents
	 */
	public function counterTransform():Void {
		transform.matrix = new Matrix();
		var concatMatrix:Matrix = transform.concatenatedMatrix;
		concatMatrix.invert();
		transform.matrix = concatMatrix;
	}
}