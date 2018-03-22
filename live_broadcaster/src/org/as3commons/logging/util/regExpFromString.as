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
	
	/**
	 * Transforms a string that contains regular regexp syntax to a working <code>RegExp</code> instance.
	 * 
	 * <listing>
	 * var a: RegExp = regExpFromString("/test/i");
	 * a.ignoreCase; // true
	 * a.source; // "test"
	 * </listing>
	 * 
	 * @param string <code>String</code> to be transformed to Regular Expression
	 * @return <code>RegExp</code> instance if its a valid expression, else "null"
	 * @author Martin Heidegger
	 * @since 2.6
	 */
	public function regExpFromString(string:String): RegExp {
		var parts: Object = REG_EXP.exec(string);
		if( parts && parts[1] ) {
			return new RegExp(parts[1], parts[2]);
		} else {
			return null;
		}
	}
}

const REG_EXP: RegExp = /^\/(.*)\/(.*)$/;