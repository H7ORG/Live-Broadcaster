/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.util {
	
	import flash.events.ErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Introspects a object, makes it js transferable and returns it.
	 * 
	 * @param value any object
     * @param map Map used to store the representations (can be passed in to reduce performance consumption)
     * @param levels Depth used to introspect the value.
	 * @return js valid representation
	 * @since 2.5
	 */
	public function objectify(value:*, map:Dictionary=null, levels:uint=5): * {
		if( !map ) {
			map = new Dictionary();
		}
		var result: Object;
		if( value is QName || value is Namespace ) {
			result = value["toString"]();
		} else if( value is String || value is Boolean || value is Number ) {
			result = value;
		} else if( !value ) {
			result = null;
		} else {
			result = map[ value ];
			if( !result ) {
				var type:String=getQualifiedClassName(value);
				if( value is XML ) {
					result = (value as XML).toXMLString();
				} else if( value is Error ) {
					result = errorToObject( value );
				} else if( value is ErrorEvent ) {
					result = errorEventToObject( value );
				} else if( value is Array || type.indexOf("__AS3__.vec::Vector.") == 0 ) {
					result = [];
					map[ value ] = result;
					var l:int = value["length"];
					for(var i:int=0;i<l;++i) {
						result[i] = objectify(value[i],map,levels-1);
					}
				} else if( value is ByteArray ) {
					var ba:ByteArray = value;
					result = 'BASE64'+base64enc(ba, 0);
				} else {
					if( type != "Object") {
						result = {type:type};
					} else {
						result = {};
					}
					map[ value ] = result;
					var props: Array = allProperties( value );
					for each( var prop: String in props ) {
						var child: * = value[ prop ];
						if( child is Class ) {
							child = getQualifiedClassName( child );
						}
						if( child is String ) {
							child = String( child ).split("\\").join("\\\\");
						} else if( child is Object && !( child is Number || child is Boolean ) ) {
							if( levels > 0 ) {
								child = objectify( child, map, levels - 1 );
							} else {
								// Next Loop, introspection amount done
								continue;
							}
						}
						if( child ) {
							result[ prop ] = child;
						}
					}
				}
				map[ value ] = result;
			}
		}
		return result;
	}
}
import flash.events.ErrorEvent;

function errorToObject(error:Error):Object {
	var obj: Object = {
		errorNo:error.errorID,
		message:error.message,
		name:error.name
	};
	try {
		obj["stacktrace"] = error.getStackTrace();
	} catch(e:Error){}
	return obj;
}

function errorEventToObject(error:ErrorEvent):Object {
	var obj: Object = {
		errorNo:error.errorID,
		message:error.text
	};
	return obj;
}