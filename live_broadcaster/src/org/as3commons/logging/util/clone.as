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
	
	import flash.utils.Dictionary;
	
	/**
	 * Copies/Clones any generic object.
	 * 
	 * <p>If the object has a <code>clone</code> or <code>copy</code> method it
	 * will be used to copy the object, else it will attempt to copy it using a
	 * bytearray.</p>
	 * 
	 * <p>Primitive objects, namely <code>String</code>, <code>Number</code>,
	 * <code>Boolean</code>, <code>Function</code>, <code>Namespace</code>, 
	 * <code>QName</code> instances can not be copied anywhere are simply 
	 * returned.</p>
	 * 
	 * @param object Object to be cloned
	 * @param storage Storage of all the instances created
	 *        (not necessary to be passed)
	 * @param useByteArray <code>True</code> It will try copy using a bytearray
	 *        (and preserving the type) or just copy the objects to primitive objects.
	 * @param introspectDepth depth to which the objects should be introspected
	 *        in case it cant be copied using a bytearray, copy or clone.
	 * @return Clone of the object
	 * @author Martin Heidegger
	 * @since 2.5
	 */
	public function clone( object:*, introspectDepth:uint=4.294967295E9	,
						   storage:Dictionary=null, useByteArray:Boolean=true):* {
		// Core types can not be modified anyways so dont even try to copy them
		if( object is QName || object is String || object is Boolean
			|| object is Namespace || object is Number || object == null
			|| object is Function ) {
			return object;
		}
		var theClone: * = null;
		if( storage ) {
			// Pick it from the storage if available
			theClone = storage[ object ];
		}
		if( !theClone ) {
			if( object.hasOwnProperty("clone") && object["clone"] is Function ) {
				try {
					// First we try "clone" method, since some classes are not
					// really copyable and this allows a flexible implementation
					// any Interface might interfere with existing interfaces. 
					theClone = object["clone"]();
				} catch( e: Error ) {}
			}
			if( !theClone && object.hasOwnProperty("copy") && object["copy"] is Function ) {
				try {
					// Some frameworks think the "copy" naming is more fun.
					theClone = object["copy"]();
				} catch( e1: Error ) {}
			}
			if( !theClone ) {
				var nextDepth: uint;
				if( object is Array ) {
					// Arrays are in any way faster copied by iteration
					var resultArr: Array = [];
					if( introspectDepth > 0 ) {
						nextDepth = introspectDepth-1;
						var arr: Array = object;
						var l: int = arr.length;
						for( var i: int = 0; i<l; ++i ) {
							resultArr[i] = clone(arr[i], nextDepth,
								storage || (storage = new Dictionary()),
								useByteArray);
						}
					}
					theClone = resultArr;
				} else if( useByteArray ) {
					try {
						// Try to copy it to a bytearray, its a very safe,
						// iteration-free way but does take some time.
						BYTE_ARRAY.position = 0;
						BYTE_ARRAY.writeObject(object);
						BYTE_ARRAY.position = 0;
						theClone = BYTE_ARRAY.readObject();
					} catch( e2: Error ) {}
				}
			}
			if( !theClone ) {
				// In case it didn't work out fetch the properties by hand and
				// copy them into generic objects.
				var resultObj: Object = {};
				var props: Array = allProperties( object );
				if( introspectDepth > 0 ) {
					nextDepth = introspectDepth-1;
					for( var prop: String in object ) {
						resultObj[prop] = clone(
							object[prop], nextDepth,
							storage || (storage = new Dictionary()),
							useByteArray);
					}
				}
				theClone = resultObj;
			}
			if( storage ) {
				// Store the clone so we dont need to evaluate this instance
				// again. (protects from endless recursions too!)
				// If the storage is not available: No recursion has occurend and
				// therefore its not necessary
				storage[object] = theClone;
			}
		}
		return theClone;
	}
}
import flash.utils.ByteArray;
// Used to copy that thing.
const BYTE_ARRAY: ByteArray = new ByteArray();