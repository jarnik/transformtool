package com.senocular.display;
	
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Shape;
import nme.display.Sprite;
import nme.display.Stage;
import nme.events.Event;
import nme.events.EventPhase;
import nme.events.MouseEvent;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Transform;

// TODO: Documentation
// TODO: Handle 0-size transformations

/**
 * Creates a transform tool that allows uaers to modify display objects on the screen
 * 
 * @usage
 * <pre>
 * var tool:TransformTool = new TransformTool();
 * addChild(tool);
 * tool.target = targetDisplayObject;
 * </pre>
 * 
 * @version 0.9.10
 * @author  Trevor McCauley
 * @author  http://www.senocular.com
 */
class TransformTool extends Sprite {
	
	// Variables
	private var toolInvertedMatrix:Matrix;
	private var innerRegistration:Point;
	private var registrationLog:DisplayHash<Point>;
	
	private var targetBounds:Rectangle;
	
	private var mouseLoc:Point;
	private var mouseOffset:Point;
	private var innerMouseLoc:Point;
	private var interactionStart:Point;
	private var innerInteractionStart:Point;
	private var interactionStartAngle:Float = 0;
	private var interactionStartMatrix:Matrix;
	
	private var toolSprites:Sprite;
	private var lines:Sprite;
	private var moveControls:Sprite;
	private var registrationControls:Sprite;
	private var rotateControls:Sprite;
	private var scaleControls:Sprite;
	private var skewControls:Sprite;
	private var cursors:Sprite;
	private var customControls:Sprite;
	private var customCursors:Sprite;
	
	// With getter/setters
	private var _target:DisplayObject;
	private var _toolMatrix:Matrix;
	private var _globalMatrix:Matrix;
	
	private var _registration:Point;
	
	private var _livePreview:Bool = true;
	private var _raiseNewTargets:Bool = true;
	private var _moveNewTargets:Bool = false;
	private var _moveEnabled:Bool = true;
	private var _registrationEnabled:Bool = true;
	private var _rotationEnabled:Bool = true;
	private var _scaleEnabled:Bool = true; 
	private var _skewEnabled:Bool = true;
	private var _outlineEnabled:Bool = true;
	private var _customControlsEnabled:Bool = true;
	private var _customCursorsEnabled:Bool = true;
	private var _cursorsEnabled:Bool = true; 
	private var _rememberRegistration:Bool = true;
	
	private var _constrainScale:Bool = false;
	private var _constrainRotationAngle:Float;
	private var _constrainRotation:Bool = false;
	
	private var _moveUnderObjects:Bool = true;
	private var _maintainControlForm:Bool = true;
	private var _controlSize:Float = 8;
		
	private var _maxScaleX:Float;
	private var _maxScaleY:Float;
	
	private var _boundsTopLeft:Point;
	private var _boundsTop:Point;
	private var _boundsTopRight:Point;
	private var _boundsRight:Point;
	private var _boundsBottomRight:Point;
	private var _boundsBottom:Point;
	private var _boundsBottomLeft:Point;
	private var _boundsLeft:Point;
	private var _boundsCenter:Point;
	
	private var _currentControl:TransformToolControl;
	
	private var _moveControl:TransformToolControl;
	private var _registrationControl:TransformToolControl;
	private var _outlineControl:TransformToolControl;
	private var _scaleTopLeftControl:TransformToolControl;
	private var _scaleTopControl:TransformToolControl;
	private var _scaleTopRightControl:TransformToolControl;
	private var _scaleRightControl:TransformToolControl;
	private var _scaleBottomRightControl:TransformToolControl;
	private var _scaleBottomControl:TransformToolControl;
	private var _scaleBottomLeftControl:TransformToolControl;
	private var _scaleLeftControl:TransformToolControl;
	private var _rotationTopLeftControl:TransformToolControl;
	private var _rotationTopRightControl:TransformToolControl;
	private var _rotationBottomRightControl:TransformToolControl;
	private var _rotationBottomLeftControl:TransformToolControl;
	private var _skewTopControl:TransformToolControl;
	private var _skewRightControl:TransformToolControl;
	private var _skewBottomControl:TransformToolControl;
	private var _skewLeftControl:TransformToolControl;
		
	private var _moveCursor:TransformToolCursor;
	private var _registrationCursor:TransformToolCursor;
	private var _rotationCursor:TransformToolCursor;
	private var _scaleCursor:TransformToolCursor;
	private var _skewCursor:TransformToolCursor;
	
	// Event constants
	public static inline var NEW_TARGET:String = "newTarget";
	public static inline var TRANSFORM_TARGET:String = "transformTarget";
	public static inline var TRANSFORM_TOOL:String = "transformTool";
	public static inline var CONTROL_INIT:String = "controlInit";
	public static inline var CONTROL_TRANSFORM_TOOL:String = "controlTransformTool";
	public static inline var CONTROL_DOWN:String = "controlDown";
	public static inline var CONTROL_MOVE:String = "controlMove";
	public static inline var CONTROL_UP:String = "controlUp";
	public static inline var CONTROL_PREFERENCE:String = "controlPreference";
	
	// Skin constants
	public static inline var REGISTRATION:String = "registration";
	public static inline var SCALE_TOP_LEFT:String = "scaleTopLeft";
	public static inline var SCALE_TOP:String = "scaleTop";
	public static inline var SCALE_TOP_RIGHT:String = "scaleTopRight";
	public static inline var SCALE_RIGHT:String = "scaleRight";
	public static inline var SCALE_BOTTOM_RIGHT:String = "scaleBottomRight";
	public static inline var SCALE_BOTTOM:String = "scaleBottom";
	public static inline var SCALE_BOTTOM_LEFT:String = "scaleBottomLeft";
	public static inline var SCALE_LEFT:String = "scaleLeft";
	public static inline var ROTATION_TOP_LEFT:String = "rotationTopLeft";
	public static inline var ROTATION_TOP_RIGHT:String = "rotationTopRight";
	public static inline var ROTATION_BOTTOM_RIGHT:String = "rotationBottomRight";
	public static inline var ROTATION_BOTTOM_LEFT:String = "rotationBottomLeft";
	public static inline var SKEW_TOP:String = "skewTop";
	public static inline var SKEW_RIGHT:String = "skewRight";
	public static inline var SKEW_BOTTOM:String = "skewBottom";
	public static inline var SKEW_LEFT:String = "skewLeft";
	public static inline var CURSOR_REGISTRATION:String = "cursorRegistration";
	public static inline var CURSOR_MOVE:String = "cursorMove";
	public static inline var CURSOR_SCALE:String = "cursorScale";
	public static inline var CURSOR_ROTATION:String = "cursorRotate";
	public static inline var CURSOR_SKEW:String = "cursorSkew";
	
	// Properties
	public var target(getTarget, setTarget):DisplayObject;
	public var raiseNewTargets( getRaiseNewTargets, setRaiseNewTargets ):Bool;
	public var moveNewTargets( getMoveNewTargets, setMoveNewTargets ):Bool;
	public var livePreview( getLivePreview, setLivePreview ):Bool;
	public var controlSize( get_controlSize, set_controlSize ):Float;
	public var maintainControlForm( get_maintainControlForm, set_maintainControlForm ):Bool;
	public var moveUnderObjects( get_moveUnderObjects, set_moveUnderObjects ):Bool;
	public var toolMatrix( get_toolMatrix, set_toolMatrix ):Matrix;
	public var globalMatrix( get_globalMatrix, set_globalMatrix ):Matrix;
	public var registration( get_registration, set_registration ):Point;
	public var currentControl( get_currentControl, null ):TransformToolControl;
	public var moveEnabled( get_moveEnabled, set_moveEnabled ):Bool;
	public var registrationEnabled( get_registrationEnabled, set_registrationEnabled ):Bool;
	public var rotationEnabled( get_rotationEnabled, set_rotationEnabled ):Bool;
	public var scaleEnabled( get_scaleEnabled, set_scaleEnabled ):Bool;
	public var skewEnabled( get_skewEnabled, set_skewEnabled ):Bool;
	public var outlineEnabled( get_outlineEnabled, set_outlineEnabled ):Bool;
	public var cursorsEnabled( get_cursorsEnabled, set_cursorsEnabled ):Bool;
	public var customControlsEnabled( get_customControlsEnabled, set_customControlsEnabled ):Bool;
	public var customCursorsEnabled( get_customCursorsEnabled, set_customCursorsEnabled ):Bool;
	public var rememberRegistration( get_rememberRegistration, set_rememberRegistration ):Bool;
	public var constrainScale( get_constrainScale, set_constrainScale ):Bool;
	public var constrainRotation( get_constrainRotation, set_constrainRotation ):Bool;
	public var constrainRotationAngle( get_constrainRotationAngle, set_constrainRotationAngle ):Float;
	public var maxScaleX( get_maxScaleX, set_maxScaleX ):Float;
	public var maxScaleY( get_maxScaleY, set_maxScaleY ):Float;
	
	public var boundsTopLeft( get_boundsTopLeft, null ):Point;
	public var boundsTop( get_boundsTop, null ):Point;
	public var boundsTopRight( get_boundsTopRight, null ):Point;
	public var boundsRight( get_boundsRight, null ):Point;
	public var boundsBottomRight( get_boundsBottomRight, null ):Point;
	public var boundsBottom( get_boundsBottom, null ):Point;
	public var boundsBottomLeft( get_boundsBottomLeft, null ):Point;
	public var boundsLeft( get_boundsLeft, null ):Point;
	public var boundsCenter( get_boundsCenter, null ):Point;
	public var mouse( get_mouse, null ):Point;
	
	public var moveControl( get_moveControl, null ):TransformToolControl;
	public var registrationControl( get_registrationControl, null ):TransformToolControl;
	public var outlineControl( get_outlineControl, null ):TransformToolControl;
	public var scaleTopLeftControl( get_scaleTopLeftControl, null ):TransformToolControl;
	public var scaleTopControl( get_scaleTopControl, null ):TransformToolControl;
	public var scaleTopRightControl( get_scaleTopRightControl, null ):TransformToolControl;
	public var scaleRightControl( get_scaleRightControl, null ):TransformToolControl;
	public var scaleBottomRightControl( get_scaleBottomRightControl, null ):TransformToolControl;
	public var scaleBottomControl( get_scaleBottomControl, null ):TransformToolControl;
	public var scaleBottomLeftControl( get_scaleBottomLeftControl, null ):TransformToolControl;
	public var scaleLeftControl( get_scaleLeftControl, null ):TransformToolControl;
	public var rotationTopLeftControl( get_rotationTopLeftControl, null ):TransformToolControl;
	public var rotationTopRightControl( get_rotationTopRightControl, null ):TransformToolControl;
	public var rotationBottomRightControl( get_rotationBottomRightControl, null ):TransformToolControl;
	public var rotationBottomLeftControl( get_rotationBottomLeftControl, null ):TransformToolControl;
	public var skewTopControl( get_skewTopControl, null ):TransformToolControl;
	public var skewRightControl( get_skewRightControl, null ):TransformToolControl;
	public var skewBottomControl( get_skewBottomControl, null ):TransformToolControl;
	public var skewLeftControl( get_skewLeftControl, null ):TransformToolControl;
	
	public var moveCursor( get_moveCursor, null ):TransformToolCursor;
	public var registrationCursor( get_registrationCursor, null ):TransformToolCursor;
	public var rotationCursor( get_rotationCursor, null ):TransformToolCursor;
	public var scaleCursor( get_scaleCursor, null ):TransformToolCursor;
	public var skewCursor( get_skewCursor, null ):TransformToolCursor;
	
	/**
	 * The display object the transform tool affects
	 */
	public function getTarget():DisplayObject {
		return _target;
	}
	public function setTarget(d:DisplayObject):DisplayObject {
		
		// null target, set target as null
		if ( d == null ) {
			if (_target != null) {
				_target = null;
				updateControlsVisible();
				dispatchEvent(new Event(NEW_TARGET));
			}
			return _target;
		}else{
			
			// invalid target, do nothing
			if (d == _target || d == this || contains(d)
			|| (Std.is( d, DisplayObjectContainer ) && cast( d, DisplayObjectContainer).contains(this))) {
				return _target;
			}
			
			// valid target, set and update
			_target = d;
			updateMatrix();
			setNewRegistation();
			updateControlsVisible();
			
			// raise to top of display list if applies
			if (_raiseNewTargets) {
				raiseTarget();
			}
		}
		
		// if not moving new targets, apply transforms
		if (!_moveNewTargets) {
			apply();
		}
		
		// send event; updates control points
		dispatchEvent(new Event(NEW_TARGET));
			
		// initiate move interaction if applies after controls updated
		if (_moveNewTargets && _moveEnabled && _moveControl != null) {
			_currentControl = _moveControl;
			_currentControl.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		return _target;
	}
	
	/**
	 * When true, new targets are placed at the top of their display list
	 * @see target
	 */
	public function getRaiseNewTargets():Bool {
		return _raiseNewTargets;
	}
	public function setRaiseNewTargets(b:Bool):Bool {
		_raiseNewTargets = b;
		return raiseNewTargets;
	}
	
	/**
	 * When true, new targets are immediately given a move interaction and can be dragged
	 * @see target
	 * @see moveEnabled
	 */
	public function getMoveNewTargets():Bool {
		return _moveNewTargets;
	}
	public function setMoveNewTargets(b:Bool):Bool {
		_moveNewTargets = b;
		return moveNewTargets;
	}
	
	/**
	 * When true, the target instance scales with the tool as it is transformed.
	 * When false, transforms in the tool are only reflected when transforms are completed.
	 */
	public function getLivePreview():Bool {
		return _livePreview;
	}
	public function setLivePreview(b:Bool):Bool {
		_livePreview = b;
		return livePreview;
	}
	
	/**
	 * Controls the default Control sizes of controls used by the tool
	 */
	public function get_controlSize():Float {
		return _controlSize;
	}
	public function set_controlSize(n:Float):Float {
		if (_controlSize != n) {
			_controlSize = n;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return controlSize;
	}
	
	/**
	 * When true, counters transformations applied to controls by their parent containers
	 */
	public function get_maintainControlForm():Bool {
		return _maintainControlForm;
	}
	public function set_maintainControlForm(b:Bool):Bool {
		if (_maintainControlForm != b) {
			_maintainControlForm = b;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return maintainControlForm;
	}
	
	/**
	 * When true (default), the transform tool uses an invisible control using the shape of the current
	 * target to allow movement. This means any objects above the target but below the
	 * tool cannot be clicked on since this hidden control will be clicked on first
	 * (allowing you to move objects below others without selecting the objects on top).
	 * When false, the target itself is used for movement and any objects above the target
	 * become clickable preventing tool movement if the target itself is not clicked directly.
	 */
	public function get_moveUnderObjects():Bool {
		return _moveUnderObjects;
	}
	public function set_moveUnderObjects(b:Bool):Bool {
		if (_moveUnderObjects != b) {
			_moveUnderObjects = b;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return moveUnderObjects;
	}
	
	/**
	 * The transform matrix of the tool
	 * as it exists in its on coordinate space
	 * @see globalMatrix
	 */
	public function get_toolMatrix():Matrix {
		return _toolMatrix.clone();
	}
	public function set_toolMatrix(m:Matrix):Matrix {
		updateMatrix(m, false);
		updateRegistration();
		dispatchEvent(new Event(TRANSFORM_TOOL));
		return toolMatrix;
	}
	
	/**
	 * The transform matrix of the tool
	 * as it appears in global space
	 * @see toolMatrix
	 */
	public function get_globalMatrix():Matrix {
		var _globalMatrix:Matrix = _toolMatrix.clone();
		_globalMatrix.concat(transform.concatenatedMatrix);
		return _globalMatrix;
	}
	public function set_globalMatrix(m:Matrix):Matrix {
		updateMatrix(m);
		updateRegistration();
		dispatchEvent(new Event(TRANSFORM_TOOL));
		return globalMatrix;
	}
	
	/**
	 * The location of the registration point in the tool. Note: registration
	 * points are tool-specific.  If you change the registration point of a
	 * target, the new registration will only be reflected in the tool used
	 * to change that point.
	 * @see registrationEnabled
	 * @see rememberRegistration
	 */
	public function get_registration():Point {
		return _registration.clone();
	}
	public function set_registration(p:Point):Point {
		_registration = p.clone();
		innerRegistration = toolInvertedMatrix.transformPoint(_registration);
		
		if (_rememberRegistration) {
			// log new registration point for the next
			// time this target is selected
			//registrationLog[_target] = innerRegistration;
			registrationLog.set( _target, innerRegistration );
		}
		dispatchEvent(new Event(TRANSFORM_TOOL));
		return registration;
	}
	
	/**
	 * The current control being used in the tool if being manipulated.
	 * This value is null if the user is not transforming the tool.
	 */
	public function get_currentControl():TransformToolControl {
		return _currentControl;
	}
	
	/**
	 * Allows or disallows users to move the tool
	 */
	public function get_moveEnabled():Bool {
		return _moveEnabled;
	}
	public function set_moveEnabled(b:Bool):Bool {
		if (_moveEnabled != b) {
			_moveEnabled = b;
			updateControlsEnabled();
		}
		return moveEnabled;
	}
	
	/**
	 * Allows or disallows users to see and move the registration point
	 * @see registration
	 * @see rememberRegistration
	 */
	public function get_registrationEnabled():Bool {
		return _registrationEnabled;
	}
	public function set_registrationEnabled(b:Bool):Bool {
		if (_registrationEnabled != b) {
			_registrationEnabled = b;
			updateControlsEnabled();
		}
		return registrationEnabled;
	}
	
	/**
	 * Allows or disallows users to see and adjust rotation controls
	 */
	public function get_rotationEnabled():Bool {
		return _rotationEnabled;
	}
	public function set_rotationEnabled(b:Bool):Bool {
		if (_rotationEnabled != b) {
			_rotationEnabled = b;
			updateControlsEnabled();
		}
		return rotationEnabled;
	}
	
	/**
	 * Allows or disallows users to see and adjust scale controls
	 */
	public function get_scaleEnabled():Bool {
		return _scaleEnabled;
	}
	public function set_scaleEnabled(b:Bool):Bool {
		if (_scaleEnabled != b) {
			_scaleEnabled = b;
			updateControlsEnabled();
		}
		return scaleEnabled;
	}
	
	/**
	 * Allows or disallows users to see and adjust skew controls
	 */
	public function get_skewEnabled():Bool {
		return _skewEnabled;
	}
	public function set_skewEnabled(b:Bool):Bool {
		if (_skewEnabled != b) {
			_skewEnabled = b;
			updateControlsEnabled();
		}
		return skewEnabled;
	}
	
	/**
	 * Allows or disallows users to see tool boundry outlines
	 */
	public function get_outlineEnabled():Bool {
		return _outlineEnabled;
	}
	public function set_outlineEnabled(b:Bool):Bool {
		if (_outlineEnabled != b) {
			_outlineEnabled = b;
			updateControlsEnabled();
		}
		return outlineEnabled;
	}
	
	/**
	 * Allows or disallows users to see native cursors
	 * @see addCursor
	 * @see removeCursor
	 * @see customCursorsEnabled
	 */
	public function get_cursorsEnabled():Bool {
		return _cursorsEnabled;
	}
	public function set_cursorsEnabled(b:Bool):Bool {
		if (_cursorsEnabled != b) {
			_cursorsEnabled = b;
			updateControlsEnabled();
		}
		return cursorsEnabled;
	}
	
	/**
	 * Allows or disallows users to see and use custom controls
	 * @see addControl
	 * @see removeControl
	 * @see customCursorsEnabled
	 */
	public function get_customControlsEnabled():Bool {
		return _customControlsEnabled;
	}
	public function set_customControlsEnabled(b:Bool):Bool {
		if (_customControlsEnabled != b) {
			_customControlsEnabled = b;
			updateControlsEnabled();
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return customControlsEnabled;
	}
	
	/**
	 * Allows or disallows users to see custom cursors
	 * @see addCursor
	 * @see removeCursor
	 * @see cursorsEnabled
	 * @see customControlsEnabled
	 */
	public function get_customCursorsEnabled():Bool {
		return _customCursorsEnabled;
	}
	public function set_customCursorsEnabled(b:Bool):Bool {
		if (_customCursorsEnabled != b) {
			_customCursorsEnabled = b;
			updateControlsEnabled();
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return customCursorsEnabled;
	}
	
	/**
	 * Allows or disallows users to see custom cursors
	 * @see registration
	 */
	public function get_rememberRegistration():Bool {
		return _rememberRegistration;
	}
	public function set_rememberRegistration(b:Bool):Bool {
		_rememberRegistration = b;
		if (!_rememberRegistration) {
			//registrationLog = new Dictionary(true);
			registrationLog = new DisplayHash<Point>();
		}
		return rememberRegistration;
	}
	
	/**
	 * Allows constraining of scale transformations that scale along both X and Y.
	 * @see constrainRotation
	 */
	public function get_constrainScale():Bool {
		return _constrainScale;
	}
	public function set_constrainScale(b:Bool):Bool {
		if (_constrainScale != b) {
			_constrainScale = b;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return constrainScale;
	}
	
	/**
	 * Allows constraining of rotation transformations by an angle
	 * @see constrainRotationAngle
	 * @see constrainScale
	 */
	public function get_constrainRotation():Bool {
		return _constrainRotation;
	}
	public function set_constrainRotation(b:Bool):Bool {
		if (_constrainRotation != b) {
			_constrainRotation = b;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return constrainRotation;
	}
	
	/**
	 * The angle at which rotation is constrainged when constrainRotation is true
	 * @see constrainRotation
	 */
	public function get_constrainRotationAngle():Float {
		return _constrainRotationAngle * 180/Math.PI;
	}
	public function set_constrainRotationAngle(n:Float):Float {
		var angleInRadians:Float = n * Math.PI/180;
		if (_constrainRotationAngle != angleInRadians) {
			_constrainRotationAngle = angleInRadians;
			dispatchEvent(new Event(CONTROL_PREFERENCE));
		}
		return constrainRotationAngle;
	}
	
	/**
	 * The maximum scaleX allowed to be applied to a target
	 */
	public function get_maxScaleX():Float {
		return _maxScaleX;
	}
	public function set_maxScaleX(n:Float):Float {
		_maxScaleX = n;
		return maxScaleX;
	}
	
	/**
	 * The maximum scaleY allowed to be applied to a target
	 */
	public function get_maxScaleY():Float {
		return _maxScaleY;
	}
	public function set_maxScaleY(n:Float):Float {
		_maxScaleY = n;
		return maxScaleY;
	}
	
	public function get_boundsTopLeft():Point { return _boundsTopLeft.clone(); }
	public function get_boundsTop():Point { return _boundsTop.clone(); }
	public function get_boundsTopRight():Point { return _boundsTopRight.clone(); }
	public function get_boundsRight():Point { return _boundsRight.clone(); }
	public function get_boundsBottomRight():Point { return _boundsBottomRight.clone(); }
	public function get_boundsBottom():Point { return _boundsBottom.clone(); }
	public function get_boundsBottomLeft():Point { return _boundsBottomLeft.clone(); }
	public function get_boundsLeft():Point { return _boundsLeft.clone(); }
	public function get_boundsCenter():Point { return _boundsCenter.clone(); }
	public function get_mouse():Point { return new Point(mouseX, mouseY); }
	
	public function get_moveControl():TransformToolControl { return _moveControl; }
	public function get_registrationControl():TransformToolControl { return _registrationControl; }
	public function get_outlineControl():TransformToolControl { return _outlineControl; }
	public function get_scaleTopLeftControl():TransformToolControl { return _scaleTopLeftControl; }
	public function get_scaleTopControl():TransformToolControl { return _scaleTopControl; }
	public function get_scaleTopRightControl():TransformToolControl { return _scaleTopRightControl; }
	public function get_scaleRightControl():TransformToolControl { return _scaleRightControl; }
	public function get_scaleBottomRightControl():TransformToolControl { return _scaleBottomRightControl; }
	public function get_scaleBottomControl():TransformToolControl { return _scaleBottomControl; }
	public function get_scaleBottomLeftControl():TransformToolControl { return _scaleBottomLeftControl; }
	public function get_scaleLeftControl():TransformToolControl { return _scaleLeftControl; }
	public function get_rotationTopLeftControl():TransformToolControl { return _rotationTopLeftControl; }
	public function get_rotationTopRightControl():TransformToolControl { return _rotationTopRightControl; }
	public function get_rotationBottomRightControl():TransformToolControl { return _rotationBottomRightControl; }
	public function get_rotationBottomLeftControl():TransformToolControl { return _rotationBottomLeftControl; }
	public function get_skewTopControl():TransformToolControl { return _skewTopControl; }
	public function get_skewRightControl():TransformToolControl { return _skewRightControl; }
	public function get_skewBottomControl():TransformToolControl { return _skewBottomControl; }
	public function get_skewLeftControl():TransformToolControl { return _skewLeftControl; }
	
	public function get_moveCursor():TransformToolCursor { return _moveCursor; }
	public function get_registrationCursor():TransformToolCursor { return _registrationCursor; }
	public function get_rotationCursor():TransformToolCursor { return _rotationCursor; }
	public function get_scaleCursor():TransformToolCursor { return _scaleCursor; }
	public function get_skewCursor():TransformToolCursor { return _skewCursor; }
	
	/**
	 * TransformTool constructor.
	 * Creates new instances of the transform tool
	 */
	public function new() {
		super();
		
		toolInvertedMatrix = new Matrix();
		innerRegistration = new Point();
		registrationLog = new DisplayHash<Point>();
		
		targetBounds = new Rectangle();
		
		mouseLoc = new Point();
		mouseOffset = new Point();
		innerMouseLoc = new Point();
		interactionStart = new Point();
		innerInteractionStart = new Point();
		interactionStartMatrix = new Matrix();
		
		toolSprites = new Sprite();
		lines = new Sprite();
		moveControls = new Sprite();
		registrationControls = new Sprite();
		rotateControls = new Sprite();
		scaleControls = new Sprite();
		skewControls = new Sprite();
		cursors = new Sprite();
		customControls = new Sprite();
		customCursors = new Sprite();
		
		_toolMatrix = new Matrix();
		_globalMatrix = new Matrix();
		
		_registration = new Point();
		_constrainRotationAngle = Math.PI/4; // default at 45 degrees
		
		_maxScaleX = Math.POSITIVE_INFINITY;
		_maxScaleY = Math.POSITIVE_INFINITY;
		
		_boundsTopLeft = new Point();
		_boundsTop = new Point();
		_boundsTopRight = new Point();
		_boundsRight = new Point();
		_boundsBottomRight = new Point();
		_boundsBottom = new Point();
		_boundsBottomLeft = new Point();
		_boundsLeft = new Point();
		_boundsCenter = new Point();
		
		createControls();
	}
	
	/**
	 * Provides a string representation of the transform instance
	 */
	override public function toString():String {
		return "[Transform Tool: target=" + _target + "]" ;
	}
	
	// Setup
	private function createControls():Void {
		
		// defining controls
		_moveControl = new TransformToolMoveShape("move", moveInteraction);
		_registrationControl = new TransformToolRegistrationControl(REGISTRATION, registrationInteraction, "registration");
		_rotationTopLeftControl = new TransformToolRotateControl(ROTATION_TOP_LEFT, rotationInteraction, "boundsTopLeft");
		_rotationTopRightControl = new TransformToolRotateControl(ROTATION_TOP_RIGHT, rotationInteraction, "boundsTopRight");
		_rotationBottomRightControl = new TransformToolRotateControl(ROTATION_BOTTOM_RIGHT, rotationInteraction, "boundsBottomRight");
		_rotationBottomLeftControl = new TransformToolRotateControl(ROTATION_BOTTOM_LEFT, rotationInteraction, "boundsBottomLeft");
		_scaleTopLeftControl = new TransformToolScaleControl(SCALE_TOP_LEFT, scaleBothInteraction, "boundsTopLeft");
		_scaleTopControl = new TransformToolScaleControl(SCALE_TOP, scaleYInteraction, "boundsTop");
		_scaleTopRightControl = new TransformToolScaleControl(SCALE_TOP_RIGHT, scaleBothInteraction, "boundsTopRight");
		_scaleRightControl = new TransformToolScaleControl(SCALE_RIGHT, scaleXInteraction, "boundsRight");
		_scaleBottomRightControl = new TransformToolScaleControl(SCALE_BOTTOM_RIGHT, scaleBothInteraction, "boundsBottomRight");
		_scaleBottomControl = new TransformToolScaleControl(SCALE_BOTTOM, scaleYInteraction, "boundsBottom");
		_scaleBottomLeftControl = new TransformToolScaleControl(SCALE_BOTTOM_LEFT, scaleBothInteraction, "boundsBottomLeft");
		_scaleLeftControl = new TransformToolScaleControl(SCALE_LEFT, scaleXInteraction, "boundsLeft");
		_skewTopControl = new TransformToolSkewBar(SKEW_TOP, skewXInteraction, "boundsTopRight", "boundsTopLeft", "boundsTopRight");
		_skewRightControl = new TransformToolSkewBar(SKEW_RIGHT, skewYInteraction, "boundsBottomRight", "boundsTopRight", "boundsBottomRight");
		_skewBottomControl = new TransformToolSkewBar(SKEW_BOTTOM, skewXInteraction, "boundsBottomLeft", "boundsBottomRight", "boundsBottomLeft");
		_skewLeftControl = new TransformToolSkewBar(SKEW_LEFT, skewYInteraction, "boundsTopLeft", "boundsBottomLeft", "boundsTopLeft");
		
		// defining cursors
		_moveCursor = new TransformToolMoveCursor();
		_moveCursor.addReference(_moveControl);
		
		_registrationCursor = new TransformToolRegistrationCursor();
		_registrationCursor.addReference(_registrationControl);
		
		_rotationCursor = new TransformToolRotateCursor();
		_rotationCursor.addReference(_rotationTopLeftControl);
		_rotationCursor.addReference(_rotationTopRightControl);
		_rotationCursor.addReference(_rotationBottomRightControl);
		_rotationCursor.addReference(_rotationBottomLeftControl);
		
		_scaleCursor = new TransformToolScaleCursor();
		_scaleCursor.addReference(_scaleTopLeftControl);
		_scaleCursor.addReference(_scaleTopControl);
		_scaleCursor.addReference(_scaleTopRightControl);
		_scaleCursor.addReference(_scaleRightControl);
		_scaleCursor.addReference(_scaleBottomRightControl);
		_scaleCursor.addReference(_scaleBottomControl);
		_scaleCursor.addReference(_scaleBottomLeftControl);
		_scaleCursor.addReference(_scaleLeftControl);
		
		_skewCursor = new TransformToolSkewCursor();
		_skewCursor.addReference(_skewTopControl);
		_skewCursor.addReference(_skewRightControl);
		_skewCursor.addReference(_skewBottomControl);
		_skewCursor.addReference(_skewLeftControl);
		
		// adding controls
		addToolControl(moveControls, _moveControl);
		addToolControl(registrationControls, _registrationControl);
		addToolControl(rotateControls, _rotationTopLeftControl);
		addToolControl(rotateControls, _rotationTopRightControl);
		addToolControl(rotateControls, _rotationBottomRightControl);
		addToolControl(rotateControls, _rotationBottomLeftControl);
		addToolControl(scaleControls, _scaleTopControl);
		addToolControl(scaleControls, _scaleRightControl);
		addToolControl(scaleControls, _scaleBottomControl);
		addToolControl(scaleControls, _scaleLeftControl);
		addToolControl(scaleControls, _scaleTopLeftControl);
		addToolControl(scaleControls, _scaleTopRightControl);
		addToolControl(scaleControls, _scaleBottomRightControl);
		addToolControl(scaleControls, _scaleBottomLeftControl);
		addToolControl(skewControls, _skewTopControl);
		addToolControl(skewControls, _skewRightControl);
		addToolControl(skewControls, _skewBottomControl);
		addToolControl(skewControls, _skewLeftControl);
		addToolControl(lines, new TransformToolOutline("outline"), false);
		
		// adding cursors
		addToolControl(cursors, _moveCursor, false);
		addToolControl(cursors, _registrationCursor, false);
		addToolControl(cursors, _rotationCursor, false);
		addToolControl(cursors, _scaleCursor, false);
		addToolControl(cursors, _skewCursor, false);
		
		
		updateControlsEnabled();
	}
	
	private function addToolControl(container:Sprite, control:TransformToolControl, interactive:Bool = true):Void {
		control.transformTool = this;
		if (interactive) {
			control.addEventListener(MouseEvent.MOUSE_DOWN, startInteractionHandler);	
		}
		container.addChild(control);
		control.dispatchEvent(new Event(CONTROL_INIT));
	}
	
	/**
	 * Allows you to add a custom control to the tool
	 * @see removeControl
	 * @see addCursor
	 * @see removeCursor
	 */
	public function addControl(control:TransformToolControl):Void {
		addToolControl(customControls, control);
	}
	
	/**
	 * Allows you to remove a custom control to the tool
	 * @see addControl
	 * @see addCursor
	 * @see removeCursor
	 */
	public function removeControl(control:TransformToolControl):TransformToolControl {
		if (customControls.contains(control)) {
			customControls.removeChild(control);
			return control;
		}
		return null;
	}
	
	/**
	 * Allows you to add a custom cursor to the tool
	 * @see removeCursor
	 * @see addControl
	 * @see removeControl
	 */
	public function addCursor(cursor:TransformToolCursor):Void {
		addToolControl(customCursors, cursor);
	}
	
	/**
	 * Allows you to remove a custom cursor to the tool
	 * @see addCursor
	 * @see addControl
	 * @see removeControl
	 */
	public function removeCursor(cursor:TransformToolCursor):TransformToolCursor {
		if (customCursors.contains(cursor)) {
			customCursors.removeChild(cursor);
			return cursor;
		}
		return null;
	}
	
	/**
	 * Allows you to change the appearance of default controls
	 * @see addControl
	 * @see removeControl
	 */
	public function setSkin(controlName:String, skin:DisplayObject):Void {
		var control:TransformToolInternalControl = getControlByName(controlName);
		if (control != null) {
			control.skin = skin;
		}
	}
	
	/**
	 * Allows you to get the skin of an existing control.
	 * If one was not set, null is returned
	 * @see addControl
	 * @see removeControl
	 */
	public function getSkin(controlName:String):DisplayObject {
		var control:TransformToolInternalControl = getControlByName(controlName);
		return control.skin;
	}
	
	private function getControlByName(controlName:String):TransformToolInternalControl {
		var control:TransformToolInternalControl = null;
		var containers:Array<Sprite> = [ skewControls, registrationControls, cursors, rotateControls, scaleControls ];
		var i:Int = containers.length;
		while ((i--) != 0 && control == null) {
			control = cast( containers[i].getChildByName(controlName), TransformToolInternalControl );
		} 
		return control;
	}
	
	// Interaction Handlers
	private function startInteractionHandler(event:MouseEvent):Void {
		_currentControl = cast( event.currentTarget, TransformToolControl );
		if (_currentControl != null) {
			setupInteraction();
		}
	}
	
	private function setupInteraction():Void {
		updateMatrix();
		apply();
		dispatchEvent(new Event(CONTROL_DOWN));
		
		// mouse offset to allow interaction from desired point
		mouseOffset = (_currentControl != null && _currentControl.referencePoint != null) ? _currentControl.referencePoint.subtract(new Point(mouseX, mouseY)) : new Point(0, 0);
		updateMouse();
		
		// set variables for interaction reference
		interactionStart = mouseLoc.clone();
		innerInteractionStart = innerMouseLoc.clone();
		interactionStartMatrix = _toolMatrix.clone();
		interactionStartAngle = distortAngle();
		
		if (stage != null) {
			// setup stage events to manage control interaction
			stage.addEventListener(MouseEvent.MOUSE_MOVE, interactionHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, endInteractionHandler, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, endInteractionHandler, true);
		}
	}
	
	private function interactionHandler(event:MouseEvent):Void {
		// define mouse position for interaction
		updateMouse();
		
		// use original toolMatrix for reference of interaction
		_toolMatrix = interactionStartMatrix.clone();
		
		// dispatch events that let controls do their thing
		dispatchEvent(new Event(CONTROL_MOVE));
		dispatchEvent(new Event(CONTROL_TRANSFORM_TOOL));
		
		if (_livePreview) {
			// update target if applicable
			apply();
		}
		
		// smooth sailing
		event.updateAfterEvent();
	}
	
	private function endInteractionHandler(event:MouseEvent):Void {
		if (event.eventPhase == EventPhase.BUBBLING_PHASE || !Std.is(event.currentTarget, Stage)) {
			// ignore unrelated events received by stage
			return;
		}
		
		if (!_livePreview) {
			// update target if applicable
			apply();
		}
		
		// get stage reference from event in case
		// stage is no longer accessible from this instance
		var stageRef:Stage = cast( event.currentTarget, Stage );
		stageRef.removeEventListener(MouseEvent.MOUSE_MOVE, interactionHandler);
		stageRef.removeEventListener(MouseEvent.MOUSE_UP, endInteractionHandler, false);
		stageRef.removeEventListener(MouseEvent.MOUSE_UP, endInteractionHandler, true);
		dispatchEvent(new Event(CONTROL_UP));
		_currentControl = null;
	}
	
	// Interaction Transformations
	/**
	 * Control Interaction.  Moves the tool
	 */
	public function moveInteraction():Void {
		var moveLoc:Point = mouseLoc.subtract(interactionStart);
		_toolMatrix.tx += moveLoc.x;
		_toolMatrix.ty += moveLoc.y;
		updateRegistration();
		completeInteraction();
	}
	
	/**
	 * Control Interaction.  Moves the registration point
	 */
	public function registrationInteraction():Void {
		// move registration point
		_registration.x = mouseLoc.x;
		_registration.y = mouseLoc.y;
		innerRegistration = toolInvertedMatrix.transformPoint(_registration);
		
		if (_rememberRegistration) {
			// log new registration point for the next
			// time this target is selected
			//registrationLog[_target] = innerRegistration;
			registrationLog.set( _target, innerRegistration );
		}
		completeInteraction();
	}
	
	/**
	 * Control Interaction.  Rotates the tool
	 */
	public function rotationInteraction():Void {
		// rotate in global transform
		var globalMatrix:Matrix = transform.concatenatedMatrix;
		var globalInvertedMatrix:Matrix = globalMatrix.clone();
		globalInvertedMatrix.invert();
		_toolMatrix.concat(globalMatrix);
		
		// get change in rotation
		var angle:Float = distortAngle() - interactionStartAngle;
		
		if (_constrainRotation) {
			// constrain rotation based on constrainRotationAngle
			if (angle > Math.PI) {
				angle -= Math.PI*2;
			}else if (angle < -Math.PI) {
				angle += Math.PI*2;
			}
			angle = Math.round(angle/_constrainRotationAngle)*_constrainRotationAngle;
		}
		
		// apply rotation to toolMatrix
		_toolMatrix.rotate(angle);
		
		_toolMatrix.concat(globalInvertedMatrix);
		completeInteraction(true);
	}
	
	/**
	 * Control Interaction.  Scales the tool along the X axis
	 */
	public function scaleXInteraction():Void {
		
		// get distortion offset vertical movement
		var distortH:Point = distortOffset(new Point(innerMouseLoc.x, innerInteractionStart.y), innerInteractionStart.x - innerRegistration.x);
		
		// update the matrix for vertical scale
		_toolMatrix.a += distortH.x;
		_toolMatrix.b += distortH.y;
		completeInteraction(true);
	}
	
	/**
	 * Control Interaction.  Scales the tool along the Y axis
	 */
	public function scaleYInteraction():Void {
		// get distortion offset vertical movement
		var distortV:Point = distortOffset(new Point(innerInteractionStart.x, innerMouseLoc.y), innerInteractionStart.y - innerRegistration.y);
		
		// update the matrix for vertical scale
		_toolMatrix.c += distortV.x;
		_toolMatrix.d += distortV.y;
		completeInteraction(true);
	}
	
	/**
	 * Control Interaction.  Scales the tool along both the X and Y axes
	 */
	public function scaleBothInteraction():Void {
		// mouse reference, may change from innerMouseLoc if constraining
		var innerMouseRef:Point = innerMouseLoc.clone();
		
		if (_constrainScale) {
			
			// how much the mouse has moved from starting the interaction
			var moved:Point = innerMouseLoc.subtract(innerInteractionStart);
			
			// the relationship of the start location to the registration point
			var regOffset:Point = innerInteractionStart.subtract(innerRegistration);
			
			// find the ratios between movement and the registration offset
			var ratioH = regOffset.x != 0 ? moved.x/regOffset.x : 0;
			var ratioV = regOffset.y != 0 ? moved.y/regOffset.y : 0;
			
			// have the larger of the movement distances brought down
			// based on the lowest ratio to fit the registration offset
			if (ratioH > ratioV) {
				innerMouseRef.x = innerInteractionStart.x + regOffset.x * ratioV;
			}else{
				innerMouseRef.y = innerInteractionStart.y + regOffset.y * ratioH;
			}
		}
		
		// get distortion offsets for both vertical and horizontal movements
		var distortH:Point = distortOffset(new Point(innerMouseRef.x, innerInteractionStart.y), innerInteractionStart.x - innerRegistration.x);
		var distortV:Point = distortOffset(new Point(innerInteractionStart.x, innerMouseRef.y), innerInteractionStart.y - innerRegistration.y);
		
		// update the matrix for both scales
		_toolMatrix.a += distortH.x;
		_toolMatrix.b += distortH.y;
		_toolMatrix.c += distortV.x;
		_toolMatrix.d += distortV.y;
		completeInteraction(true);
	}
	
	/**
	 * Control Interaction.  Skews the tool along the X axis
	 */
	public function skewXInteraction():Void {
		var distortH:Point = distortOffset(new Point(innerMouseLoc.x, innerInteractionStart.y), innerInteractionStart.y - innerRegistration.y);
		_toolMatrix.c += distortH.x;
		_toolMatrix.d += distortH.y;
		completeInteraction(true);
	}
	
	/**
	 * Control Interaction.  Skews the tool along the Y axis
	 */
	public function skewYInteraction():Void {
		var distortV:Point = distortOffset(new Point(innerInteractionStart.x, innerMouseLoc.y), innerInteractionStart.x - innerRegistration.x);
		_toolMatrix.a += distortV.x;
		_toolMatrix.b += distortV.y;
		completeInteraction(true);
	}
	
	private function distortOffset(offset:Point, regDiff:Float):Point {
		// get changes in matrix combinations based on targetBounds
		var ratioH:Float = regDiff != 0 ? targetBounds.width/regDiff : 0;
		var ratioV:Float = regDiff != 0 ? targetBounds.height/regDiff : 0;
		offset = interactionStartMatrix.transformPoint(offset).subtract(interactionStart);
		offset.x *= targetBounds.width != 0 ? ratioH/targetBounds.width : 0;
		offset.y *= targetBounds.height != 0 ? ratioV/targetBounds.height : 0;
		return offset;
	}
	
	private function completeInteraction(offsetReg:Bool = false):Void {
		enforceLimits();
		if (offsetReg) {
			// offset of registration to have transformations based around
			// custom registration point
			var offset:Point = _registration.subtract(_toolMatrix.transformPoint(innerRegistration));
			_toolMatrix.tx += offset.x;
			_toolMatrix.ty += offset.y;
		}
		updateBounds();
	}
	
	// Information
	private function distortAngle():Float {
		// use global mouse and registration
		var globalMatrix:Matrix = transform.concatenatedMatrix;
		var gMouseLoc:Point = globalMatrix.transformPoint(mouseLoc);
		var gRegistration:Point = globalMatrix.transformPoint(_registration);
		
		// distance and angle of mouse from registration
		var offset:Point = gMouseLoc.subtract(gRegistration);
		return Math.atan2(offset.y, offset.x);
	}
	
	// Updates
	private function updateMouse():Void {
		mouseLoc = new Point(mouseX, mouseY).add(mouseOffset);
		innerMouseLoc = toolInvertedMatrix.transformPoint(mouseLoc);
	}
	
	private function updateMatrix(useMatrix:Matrix = null, counterTransform:Bool = true):Void {
		if (_target != null) {
			_toolMatrix = useMatrix != null ? useMatrix.clone() : _target.transform.concatenatedMatrix.clone();
			if (counterTransform) {
				// counter transform of the parents of the tool
				var current:Matrix = transform.concatenatedMatrix;
				current.invert();
				_toolMatrix.concat(current);
			}
			enforceLimits();
			toolInvertedMatrix = _toolMatrix.clone();
			toolInvertedMatrix.invert();
			updateBounds();
		}
	}
	
	private function updateBounds():Void {
		if (_target != null) {
			// update tool bounds based on target bounds
			targetBounds = _target.getBounds(_target);
			_boundsTopLeft = _toolMatrix.transformPoint(new Point(targetBounds.left, targetBounds.top));
			_boundsTopRight = _toolMatrix.transformPoint(new Point(targetBounds.right, targetBounds.top));
			_boundsBottomRight = _toolMatrix.transformPoint(new Point(targetBounds.right, targetBounds.bottom));
			_boundsBottomLeft = _toolMatrix.transformPoint(new Point(targetBounds.left, targetBounds.bottom));
			_boundsTop = Point.interpolate(_boundsTopLeft, _boundsTopRight, .5);
			_boundsRight = Point.interpolate(_boundsTopRight, _boundsBottomRight, .5);
			_boundsBottom = Point.interpolate(_boundsBottomRight, _boundsBottomLeft, .5);
			_boundsLeft = Point.interpolate(_boundsBottomLeft, _boundsTopLeft, .5);
			_boundsCenter = Point.interpolate(_boundsTopLeft, _boundsBottomRight, .5);
		}
	}
	
	private function updateControlsVisible():Void {
		// show toolSprites only if there is a valid target
		var isChild:Bool = contains(toolSprites);
		if (_target != null) {
			if (!isChild) {
				addChild(toolSprites);
			}				
		}else if (isChild) {
			removeChild(toolSprites);
		}
	}
	
	private function updateControlsEnabled():Void {
		// highest arrangement
		updateControlContainer(customCursors, _customCursorsEnabled);
		updateControlContainer(cursors, _cursorsEnabled);
		updateControlContainer(customControls, _customControlsEnabled);
		updateControlContainer(registrationControls, _registrationEnabled);
		updateControlContainer(scaleControls, _scaleEnabled);
		updateControlContainer(skewControls, _skewEnabled);
		updateControlContainer(moveControls, _moveEnabled);
		updateControlContainer(rotateControls, _rotationEnabled);
		updateControlContainer(lines, _outlineEnabled);
		// lowest arrangement
	}
	
	private function updateControlContainer(container:Sprite, enabled:Bool):Void {
		var isChild:Bool = toolSprites.contains(container);
		if (enabled) {
			// add child or sent to bottom if enabled
			if (isChild) {
				toolSprites.setChildIndex(container, 0);
			}else{
				toolSprites.addChildAt(container, 0);
			}
		}else if (isChild) {
			// removed if disabled
			toolSprites.removeChild(container);
		}
	}
	
	private function updateRegistration():Void {
		_registration = _toolMatrix.transformPoint(innerRegistration);
	}
	
	private function enforceLimits():Void {
		
		var currScale:Float;
		var angle:Float;
		var enforced:Bool = false;
		
		// use global matrix
		var _globalMatrix:Matrix = _toolMatrix.clone();
		_globalMatrix.concat(transform.concatenatedMatrix);
		
		// check current scale in X
		currScale = Math.sqrt(_globalMatrix.a * _globalMatrix.a + _globalMatrix.b * _globalMatrix.b);
		if (currScale > _maxScaleX) {
			// set scaleX to no greater than _maxScaleX
			angle = Math.atan2(_globalMatrix.b, _globalMatrix.a);
			_globalMatrix.a = Math.cos(angle) * _maxScaleX;
			_globalMatrix.b = Math.sin(angle) * _maxScaleX;
			enforced = true;
		}
		
		// check current scale in Y
		currScale = Math.sqrt(_globalMatrix.c * _globalMatrix.c + _globalMatrix.d * _globalMatrix.d);
		if (currScale > _maxScaleY) {
			// set scaleY to no greater than _maxScaleY
			angle= Math.atan2(_globalMatrix.c, _globalMatrix.d);
			_globalMatrix.d = Math.cos(angle) * _maxScaleY;
			_globalMatrix.c = Math.sin(angle) * _maxScaleY;
			enforced = true;
		}
		
		
		// if scale was enforced, apply to _toolMatrix
		if (enforced) {
			_toolMatrix = _globalMatrix;
			var current:Matrix = transform.concatenatedMatrix;
			current.invert();
			_toolMatrix.concat(current);
		}
	}
	
	// Render
	private function setNewRegistation():Void {
		if (_rememberRegistration && registrationLog.contains( _target ) ) {
			
			// retrieved saved reg point in log
			var savedReg:Point = registrationLog.get( _target );
			innerRegistration = registrationLog.get( _target );
		}else{
			
			// use internal own point
			innerRegistration = new Point(0, 0);
		}
		updateRegistration();
	}
	
	private function raiseTarget():Void {
		// set target to last object in display list
		var index:Int = _target.parent.numChildren - 1;
		_target.parent.setChildIndex(_target, index);
		
		// if this tool is in the same display list
		// raise it to the top above target
		if (_target.parent == parent) {
			parent.setChildIndex(this, index);
		}
	}
	
	/**
	 * Draws the transform tool over its target instance
	 */
	public function draw():Void {
		// update the matrix and draw controls
		updateMatrix();
		dispatchEvent(new Event(TRANSFORM_TOOL));
	}
	
	/**
	 * Applies the current tool transformation to its target instance
	 */
	public function apply():Void {
		if (_target != null) {
			
			// get matrix to apply to target
			var applyMatrix:Matrix = _toolMatrix.clone();
			applyMatrix.concat(transform.concatenatedMatrix);
			
			// if target has a parent, counter parent transformations
			if (_target.parent != null) {
				var invertMatrix:Matrix = target.parent.transform.concatenatedMatrix;
				invertMatrix.invert();
				applyMatrix.concat(invertMatrix);
			}
			
			// set target's matrix
			_target.transform.matrix = applyMatrix;
			
			dispatchEvent(new Event(TRANSFORM_TARGET));
		}
	}
	
	public function getPointByReferenceName( ref:String ):Point {
		switch ( ref ) {
			case "registration": return registration;
			case "boundsTopLeft": return boundsTopLeft;
			case "boundsTop": return boundsTop;
			case "boundsTopRight": return boundsTopRight;
			case "boundsRight": return boundsRight;
			case "boundsBottomRight": return boundsBottomRight;
			case "boundsBottom": return boundsBottom;
			case "boundsBottomLeft": return boundsBottomLeft;
			case "boundsLeft": return boundsLeft;
			case "boundsCenter": return boundsCenter;
		}
		return null;
	}
}

import nme.display.DisplayObject;
import nme.display.InteractiveObject;
import nme.display.Shape;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Matrix;
import nme.geom.Point;

import com.senocular.display.TransformTool;
import com.senocular.display.TransformToolControl;
import com.senocular.display.TransformToolCursor;

// Controls
class TransformToolInternalControl extends TransformToolControl {
	
	public var interactionMethod:Dynamic;
	public var referenceName:String;
	public var _skin:DisplayObject;
	
	public var skin( get_skin, set_skin ):DisplayObject;
	
	public function set_skin(skin:DisplayObject):DisplayObject {
		if (_skin != null && contains(_skin)) {
			removeChild(_skin);
		}
		_skin = skin;
		if (_skin != null) {
			addChild(_skin);
		}
		draw();
		return skin;
	}
	
	public function get_skin():DisplayObject {
		return _skin;
	}
	
	override public function get_referencePoint():Point {
		return _transformTool.getPointByReferenceName( referenceName );
	}
		
	/*
	 * Constructor
	 */	
	public function new(name:String, interactionMethod:Dynamic = null, referenceName:String = null) {
		super();
		this.name = name;
		this.interactionMethod = interactionMethod;
		this.referenceName = referenceName;
		addEventListener(TransformTool.CONTROL_INIT, init);
	}
	
	private function init(event:Event):Void {
		_transformTool.addEventListener(TransformTool.NEW_TARGET, draw);
		_transformTool.addEventListener(TransformTool.TRANSFORM_TOOL, draw);
		_transformTool.addEventListener(TransformTool.CONTROL_TRANSFORM_TOOL, position);
		_transformTool.addEventListener(TransformTool.CONTROL_PREFERENCE, draw);
		_transformTool.addEventListener(TransformTool.CONTROL_MOVE, controlMove);
		draw();
	}
	
	public function draw(event:Event = null):Void {
		if (_transformTool.maintainControlForm) {
			counterTransform();
		}
		position();
	}
	
	public function position(event:Event = null):Void {
		var reference:Point = referencePoint;
		if (reference != null) {
			x = reference.x;
			y = reference.y;
		}
	}
	
	private function controlMove(event:Event):Void {
		if (interactionMethod != null && _transformTool.currentControl == this) {
			interactionMethod();
		}
	}
}


class TransformToolMoveShape extends TransformToolInternalControl {
	
	private var lastTarget:DisplayObject;
	
	public function new(name:String, interactionMethod:Dynamic) {
		super(name, interactionMethod);
	}
		
	override public function draw(event:Event = null):Void {
		
		var currTarget:DisplayObject;
		var moveUnderObjects:Bool = _transformTool.moveUnderObjects;
		
		// use hitArea if moving under objects
		// then movement would have the same depth as the tool
		if (moveUnderObjects) {
			#if ( cpp || neko )
			#else
			hitArea = cast( _transformTool.target, Sprite );
			#end
			currTarget = null;
			relatedObject = this;
			
		}else{
			
			// when not moving under objects
			// use the tool target to handle movement allowing
			// objects above it to be selectable
			#if ( cpp || neko )
			#else
			hitArea = null;
			#end
			currTarget = _transformTool.target;
			relatedObject = cast( _transformTool.target, InteractiveObject );
		}
		
		if (lastTarget != currTarget) {
			// set up/remove listeners for target being clicked
			if (lastTarget != null) {
				lastTarget.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false);
			}
			if (currTarget != null) {
				currTarget.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			}
			
			// register/unregister cursor with the object
			var cursor:TransformToolCursor = _transformTool.moveCursor;
			cursor.removeReference(lastTarget);
			cursor.addReference(currTarget);
			
			lastTarget = currTarget;
		}
	}
	
	private function mouseDown(event:MouseEvent):Void {
		dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
	}
}


class TransformToolRegistrationControl extends TransformToolInternalControl {
		
	public function new(name:String, interactionMethod:Dynamic, referenceName:String) {
		super(name, interactionMethod, referenceName);
	}

	override public function draw(event:Event = null):Void {
		graphics.clear();
		if (_skin == null) {
			graphics.lineStyle(1, 0);
			graphics.beginFill(0xFFFFFF);
			graphics.drawCircle(0, 0, _transformTool.controlSize/2);
			graphics.endFill();
		}
		super.draw();
	}
}


class TransformToolScaleControl extends TransformToolInternalControl {
	
	public function new(name:String, interactionMethod:Dynamic, referenceName:String) {
		super(name, interactionMethod, referenceName);
	}

	override public function draw(event:Event = null):Void {
		graphics.clear();
		if (_skin == null) {
			graphics.lineStyle(2, 0xFFFFFF);
			graphics.beginFill(0);
			var size = _transformTool.controlSize;
			var size2:Float = size/2;
			graphics.drawRect(-size2, -size2, size, size);
			graphics.endFill();
		}
		super.draw();
	}
}


class TransformToolRotateControl extends TransformToolInternalControl {
	
	private var locationName:String;
	
	public function new(name:String, interactionMethod:Dynamic, locationName:String) {
		super(name, interactionMethod);
		this.locationName = locationName;
	}

	override public function draw(event:Event = null):Void {
		graphics.clear();
		if (_skin == null) {
			graphics.beginFill(0xFF, 0);
			graphics.drawCircle(0, 0, _transformTool.controlSize*2);
			graphics.endFill();
		}
		super.draw();
	}
	
	override public function position(event:Event = null):Void {
		if ( _transformTool.getPointByReferenceName( locationName ) != null ) {
			var location:Point = _transformTool.getPointByReferenceName( locationName );
			x = location.x;
			y = location.y;
		}
	}
}


class TransformToolSkewBar extends TransformToolInternalControl {
	
	private var locationStart:String;
	private var locationEnd:String;
	
	public function new(name:String, interactionMethod:Dynamic, referenceName:String, locationStart:String, locationEnd:String) {
		super(name, interactionMethod, referenceName);
		this.locationStart = locationStart;
		this.locationEnd = locationEnd;
	}
	
	override public function draw(event:Event = null):Void {
		graphics.clear();
		
		if (_skin != null) {
			super.draw(event);
			return;
		}
		
		// derive point locations for bar
		var locStart:Point = _transformTool.getPointByReferenceName( locationStart );
		var locEnd:Point = _transformTool.getPointByReferenceName( locationEnd );
		
		// counter transform
		var toolTrans:Matrix;
		var toolTransInverted:Matrix = null;
		var maintainControlForm:Bool = _transformTool.maintainControlForm;
		if (maintainControlForm) {
			toolTrans = transform.concatenatedMatrix;
			toolTransInverted = toolTrans.clone();
			toolTransInverted.invert();
			
			locStart = toolTrans.transformPoint(locStart);
			locEnd = toolTrans.transformPoint(locEnd);
		}
		
		var size:Float = _transformTool.controlSize/2;
		var diff:Point = locEnd.subtract(locStart);
		var angle:Float = Math.atan2(diff.y, diff.x) - Math.PI/2;	
		var offset:Point = Point.polar(size, angle);
		
		var corner1:Point = locStart.add(offset);
		var corner2:Point = locEnd.add(offset);
		var corner3:Point = locEnd.subtract(offset);
		var corner4:Point = locStart.subtract(offset);
		if (maintainControlForm) {
			corner1 = toolTransInverted.transformPoint(corner1);
			corner2 = toolTransInverted.transformPoint(corner2);
			corner3 = toolTransInverted.transformPoint(corner3);
			corner4 = toolTransInverted.transformPoint(corner4);
		}
		
		// draw bar
		graphics.beginFill(0xFF0000, 0);
		graphics.moveTo(corner1.x, corner1.y);
		graphics.lineTo(corner2.x, corner2.y);
		graphics.lineTo(corner3.x, corner3.y);
		graphics.lineTo(corner4.x, corner4.y);
		graphics.lineTo(corner1.x, corner1.y);
		graphics.endFill();
	}

	override public function position(event:Event = null):Void {
		if (_skin != null) {
			var locStart:Point = _transformTool.getPointByReferenceName( locationStart );
			var locEnd:Point = _transformTool.getPointByReferenceName( locationEnd );
			var location:Point = Point.interpolate(locStart, locEnd, .5);
			x = location.x;
			y = location.y;
		}else{
			x = 0;
			y = 0;
			draw(event);
		}
	}
}


class TransformToolOutline extends TransformToolInternalControl {
	
	public function new(name:String) {
		super(name);
	}

	override public function draw(event:Event = null):Void {
		var topLeft:Point = _transformTool.boundsTopLeft;
		var topRight:Point = _transformTool.boundsTopRight;
		var bottomRight:Point = _transformTool.boundsBottomRight;
		var bottomLeft:Point = _transformTool.boundsBottomLeft;
		
		graphics.clear();
		graphics.lineStyle(0, 0);
		graphics.moveTo(topLeft.x, topLeft.y);
		graphics.lineTo(topRight.x, topRight.y);
		graphics.lineTo(bottomRight.x, bottomRight.y);
		graphics.lineTo(bottomLeft.x, bottomLeft.y);
		graphics.lineTo(topLeft.x, topLeft.y);
	}
	
	override public function position(event:Event = null):Void {
		draw(event);
	}
}


// Cursors
class TransformToolInternalCursor extends TransformToolCursor {
	
	public var offset:Point;
	public var icon:Shape;
	
	public function new() {
		super();
		offset = new Point();
		icon = new Shape();
		
		addChild(icon);
		offset = _mouseOffset;
		//addEventListener(TransformTool.CONTROL_INIT, init);
	}
		
	override private function init(event:Event):Void {
		super.init( event );
		_transformTool.addEventListener(TransformTool.NEW_TARGET, maintainTransform);
		_transformTool.addEventListener(TransformTool.CONTROL_PREFERENCE, maintainTransform);
		draw();
	}
	
	private function maintainTransform(event:Event):Void {
		offset = _mouseOffset;
		if (_transformTool.maintainControlForm) {
			transform.matrix = new Matrix();
			var concatMatrix:Matrix = transform.concatenatedMatrix;
			concatMatrix.invert();
			transform.matrix = concatMatrix;
			offset = concatMatrix.deltaTransformPoint(offset);
		}
		updateVisible(event);
	}
	
	private function drawArc(originX:Float, originY:Float, radius:Float, angle1:Float, angle2:Float, useMove:Bool = true):Void {
		var diff:Float = angle2 - angle1;
		var divs:Int = 1 + Math.floor(Math.abs(diff)/(Math.PI/4));
		var span:Float = diff/(2*divs);
		var cosSpan:Float = Math.cos(span);
		var radiusc:Float = cosSpan != 0 ? radius/cosSpan : 0;
		if (useMove) {
			icon.graphics.moveTo(originX + Math.cos(angle1)*radius, originY - Math.sin(angle1)*radius);
		}else{
			icon.graphics.lineTo(originX + Math.cos(angle1)*radius, originY - Math.sin(angle1)*radius);
		}
		for ( i in 0...divs ) {
			angle2 = angle1 + span;
			angle1 = angle2 + span;
			icon.graphics.curveTo(
				originX + Math.cos(angle2)*radiusc, originY - Math.sin(angle2)*radiusc,
				originX + Math.cos(angle1)*radius, originY - Math.sin(angle1)*radius
			);
		}
	}
	
	private function getGlobalAngle(vector:Point):Float {
		var globalMatrix:Matrix = _transformTool.globalMatrix;
		vector = globalMatrix.deltaTransformPoint(vector);
		return Math.atan2(vector.y, vector.x) * (180/Math.PI);
	}
	
	override public function position(event:Event = null):Void {
		if (parent != null) {
			x = parent.mouseX + offset.x;
			y = parent.mouseY + offset.y;
		}
	}
	
	public function draw():Void {
		icon.graphics.beginFill(0);
		icon.graphics.lineStyle(1, 0xFFFFFF);
	}
}


class TransformToolRegistrationCursor extends TransformToolInternalCursor {
	
	public function new() {
		super();
	}
	
	override public function draw():Void {
		super.draw();
		icon.graphics.drawCircle(0,0,2);
		icon.graphics.drawCircle(0,0,4);
		icon.graphics.endFill();
	}
}


class TransformToolMoveCursor extends TransformToolInternalCursor {
	
	public function new() {
		super();
	}
	
	override public function draw():Void {
		super.draw();
		// up arrow
		icon.graphics.moveTo(1, 1);
		icon.graphics.lineTo(1, -2);
		icon.graphics.lineTo(-1, -2);
		icon.graphics.lineTo(2, -6);
		icon.graphics.lineTo(5, -2);
		icon.graphics.lineTo(3, -2);
		icon.graphics.lineTo(3, 1);
		// right arrow
		icon.graphics.lineTo(6, 1);
		icon.graphics.lineTo(6, -1);
		icon.graphics.lineTo(10, 2);
		icon.graphics.lineTo(6, 5);
		icon.graphics.lineTo(6, 3);
		icon.graphics.lineTo(3, 3);
		// down arrow
		icon.graphics.lineTo(3, 5);
		icon.graphics.lineTo(3, 6);
		icon.graphics.lineTo(5, 6);
		icon.graphics.lineTo(2, 10);
		icon.graphics.lineTo(-1, 6);
		icon.graphics.lineTo(1, 6);
		icon.graphics.lineTo(1, 5);
		// left arrow
		icon.graphics.lineTo(1, 3);
		icon.graphics.lineTo(-2, 3);
		icon.graphics.lineTo(-2, 5);
		icon.graphics.lineTo(-6, 2);
		icon.graphics.lineTo(-2, -1);
		icon.graphics.lineTo(-2, 1);
		icon.graphics.lineTo(1, 1);
		icon.graphics.endFill();
	}
}


class TransformToolScaleCursor extends TransformToolInternalCursor {
	
	public function new() {
		super();
	}
	
	override public function draw():Void {
		super.draw();
		// right arrow
		icon.graphics.moveTo(4.5, -0.5);
		icon.graphics.lineTo(4.5, -2.5);
		icon.graphics.lineTo(8.5, 0.5);
		icon.graphics.lineTo(4.5, 3.5);
		icon.graphics.lineTo(4.5, 1.5);
		icon.graphics.lineTo(-0.5, 1.5);
		// left arrow
		icon.graphics.lineTo(-3.5, 1.5);
		icon.graphics.lineTo(-3.5, 3.5);
		icon.graphics.lineTo(-7.5, 0.5);
		icon.graphics.lineTo(-3.5, -2.5);
		icon.graphics.lineTo(-3.5, -0.5);
		icon.graphics.lineTo(4.5, -0.5);
		icon.graphics.endFill();
	}
	
	override public function updateVisible(event:Event = null):Void {
		super.updateVisible(event);
		if (event != null && Std.is( event.target, TransformToolScaleControl ) ) {
			var reference:TransformToolScaleControl = cast( event.target, TransformToolScaleControl );
			if (reference != null) {
				switch(reference) {
					case _transformTool.scaleTopLeftControl, _transformTool.scaleBottomRightControl:
						icon.rotation = (getGlobalAngle(new Point(0,100)) + getGlobalAngle(new Point(100,0)))/2;
					case _transformTool.scaleTopRightControl, _transformTool.scaleBottomLeftControl:
						icon.rotation = (getGlobalAngle(new Point(0,-100)) + getGlobalAngle(new Point(100,0)))/2;
					case _transformTool.scaleTopControl, _transformTool.scaleBottomControl:
						icon.rotation = getGlobalAngle(new Point(0,100));
					default:
						icon.rotation = getGlobalAngle(new Point(100,0));
				}
			}
		}
	}
}


class TransformToolRotateCursor extends TransformToolInternalCursor {
	
	public function new() {
		super();
	}
	
	override public function draw():Void {
		super.draw();
		// curve
		var angle1:Float = Math.PI;
		var angle2:Float = -Math.PI/2;
		drawArc(0,0,4, angle1, angle2);
		drawArc(0,0,6, angle2, angle1, false);
		// arrow
		icon.graphics.lineTo(-8, 0);
		icon.graphics.lineTo(-5, 4);
		icon.graphics.lineTo(-2, 0);
		icon.graphics.lineTo(-4, 0);
		icon.graphics.endFill();
	}
}


class TransformToolSkewCursor extends TransformToolInternalCursor {
	
	public function new() {
		super();
	}
	
	override public function draw():Void {
		super.draw();
		// right arrow
		icon.graphics.moveTo(-6, -1);
		icon.graphics.lineTo(6, -1);
		icon.graphics.lineTo(6, -4);
		icon.graphics.lineTo(10, 1);
		icon.graphics.lineTo(-6, 1);
		icon.graphics.lineTo(-6, -1);
		icon.graphics.endFill();
		
		super.draw();
		// left arrow
		icon.graphics.moveTo(10, 5);
		icon.graphics.lineTo(-2, 5);
		icon.graphics.lineTo(-2, 8);
		icon.graphics.lineTo(-6, 3);
		icon.graphics.lineTo(10, 3);
		icon.graphics.lineTo(10, 5);
		icon.graphics.endFill();
	}
	
	override public function updateVisible(event:Event = null):Void {
		super.updateVisible(event);
		if (event != null && Std.is( event.target, TransformToolSkewBar )) {
			var reference:TransformToolSkewBar = cast( event.target, TransformToolSkewBar );
			if (reference != null ) {
				switch(reference) {
					case _transformTool.skewLeftControl, _transformTool.skewRightControl:
						icon.rotation = getGlobalAngle(new Point(0,100));
					default:
						icon.rotation = getGlobalAngle(new Point(100,0));
				}
			}
		}
	}
}
