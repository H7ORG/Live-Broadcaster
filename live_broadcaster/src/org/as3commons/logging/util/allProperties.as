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
	
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Returns a array with all public accessible properties of a object.
	 * 
	 * @param value Value of which all properties should be evaluated
	 * @author Martin Heidegger
	 * @since 2.5
	 */
	public function allProperties( value: * ): Array {
		var cls:String = getQualifiedClassName(value);
		var result: Array = storage[ cls ];
		var dyn: Boolean = isDynamic[ cls ];
		var l: int = 0;
		
		if( !result && value !== null && value !== undefined ) {
			// Evaluate the properties from the xml
			var xml: XML = describeType( value );
			result = [];
			var xmlProp: XMLList = (
										xml["factory"]["accessor"] + xml["accessor"]
									  ).( @access=="readwrite" || @access=="readonly" )
									+ xml["factory"]["variable"] + xml["variable"];
			for each( var property: XML in xmlProp ) {
				result[l++] = XML( property.@name ).toString();
			}
			
			// Sort the properties, this way they can be compared easily
			result.sort();
			
			// And store them for speed!
			storage[cls] = result;
			isDynamic[cls] = dyn = (xml.@isDynamic == "true");
		}
		// If its dynamic the properties have to be checke per instances (sucks, i know)
		if( dyn ) {
			var raw: Array = result;
			result = [];
			for( var i: String in value ) {
				result.push(i);
			}
			for each( i in raw ) {
				result.push(i);
			}
			// Sort the properties, this way they can be compared easily
			result.sort();
			return result;
		} else {
			return result;
		}
	}
}

// Store if the class was dynamic
const isDynamic: Object = {};
// Store of properties
const storage: Object = {};
