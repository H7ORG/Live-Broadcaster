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
	
	/**
	 * Util to instantiate classes.
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 * @param type Class to be instantiated
	 * @param args Constructor arguments used
	 * @return New instance of the class
	 */
	public function instantiate( type: Class, args: Array = null ): * {
		var result: *;
		if( args && args.length > 0 ) {
			var l: int = CACHE[ type ] || -1;
			if( l < 0 ) {
				// Store one variable more to do it properly
				try {
					CACHE[ type ] = ( l = describeType( type ).factory
											.constructor.parameter.length() );
				} catch( e: Error ) {
					if( LOGGER.warnEnabled ) {
						LOGGER.warn("Could not describe {0} to analyse arguments", [type]);
					}
					CACHE[ type ] = 0;
				}
			}
			if( l > args.length ) {
				l = args.length; 
			}
			if (l == 0) {
				result = new type();
			} else if (l == 1) {
				result = new type(args[0]);
			} else if (l == 2) {
				result = new type(args[0], args[1]);
			} else if (l == 3) {
				result = new type(args[0], args[1], args[2]);
			} else if (l == 4) {
				result = new type(args[0], args[1], args[2], args[3]);
			} else if (l == 5) {
				result = new type(args[0], args[1], args[2], args[3], args[4]);
			} else if (l == 6) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5]);
			} else if (l == 7) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6]);
			} else if (l == 8) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7]);
			} else if (l == 9) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8]);
			} else if (l == 10) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8], args[9]);
			} else if (l == 11) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8], args[9], args[10]);
			} else if (l == 12) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
			} else if (l == 13) {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8], args[9], args[10], args[11],
					args[12]);
			} else {
				result = new type(args[0], args[1], args[2], args[3], args[4],
					args[5], args[6], args[7], args[8], args[9], args[10], args[11],
					args[12], args[13]);
			}
		} else {
			result = new type();
		}
		return result;
	}
}

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import flash.utils.Dictionary;

const LOGGER: ILogger = getLogger("org.as3commons.logging.util#instantiate()");
const CACHE: Dictionary = new Dictionary();