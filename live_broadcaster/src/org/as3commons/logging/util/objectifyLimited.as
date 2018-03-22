/**
 * Created by IntelliJ IDEA.
 * User: mini
 * Date: 12/01/08
 * Time: 7:20
 * To change this template use File | Settings | File Templates.
 */
package org.as3commons.logging.util {
	
	public function objectifyLimited(value:*, paths:Object, maxDepth: int):* {
		var result: * = doObjectifyLimited(value, paths, maxDepth);
		map = null;
		return result;
	}
}
import flash.utils.Dictionary;
import org.as3commons.logging.util.objectify;

var map: Dictionary; 
function doObjectifyLimited(value:*, paths:Object, maxDepth:int ): * {
	if( paths ) {
		var str: String;
		try {
			str = value as String;
		} catch (e:Error) {
			str = e.toString();
		}
		var result: Object;
		var noPath: Boolean = true;
		for( var pathName: String in paths ) {
			noPath = false;
			var child: * = null;
			try {
				child = value[pathName];
			} catch(e:Error) {
				child = e;
			}
			(result||={})[pathName] = doObjectifyLimited( child, paths[pathName], maxDepth );
		}
		str = Object.prototype.toString.apply(value);
		if( noPath ) {
			result = value;
		}
		if( value is Number || value is String || value is Boolean || value is Array)
		if( str != Object.prototype.toString.apply(value) ) {
			result["toString"] = str;
		} else 
		return result;
	} else {
		return objectify(value, map ||= new Dictionary, maxDepth);
	}
}
