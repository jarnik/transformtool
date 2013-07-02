package com.senocular.display;
import nme.display.DisplayObject;

/**
 * Hash that uses DisplayObject as a key.
 * Compensation for missing Dictionary.
 * 
 * @author Jarnik www.jarnik.com
 */
class DisplayHash<T>
{
	var keys:Array<DisplayObject>;
	var values:Array<T>;

	public function new() 
	{
		keys = [];
		values = [];
	}
	
	public function contains( d:DisplayObject ):Bool {
		for ( k in keys )
			if ( k == d )
				return true;
		return false;
	}
	
	public function set( d:DisplayObject, v:T ):Void {
		var index:Int = -1;
		for ( i in 0...keys.length ) {
			if (keys[ i ] == d ) {
				index = i;
				break;
			}
		}
		if ( index == -1 ) {
			keys.push( d );
			values.push( v );
		} else {
			values[ index ] = v;
		}
	}
	
	public function remove( d:DisplayObject ):Void {
		for ( i in 0...keys.length ) {
			if (keys[ i ] == d ) {
				keys.splice( i, 1 );
				values.splice( i, 1 );
				return;
			}
		}
	}
	
	public function get( d:DisplayObject ):T {
		for ( i in 0...keys.length ) {
			if (keys[ i ] == d ) {
				return values[ i ];
			}
		}
		return null;
	}
}