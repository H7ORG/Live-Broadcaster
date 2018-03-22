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
	 * Extracts the current method name/linenumber from the calling position if
	 * possible.
	 * 
	 * <p>In the release player it is not possible to retreive the current location.</p>
	 * 
	 * <p>Note: It is just with the debug player possible to get the current target,
	 * see: Bug FP-644 in the adobe bug base.</p> 
	 * 
	 * <p>Warning: Performance intense task, use with care!</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @version 2.0
	 * @see https://bugs.adobe.com/jira/browse/FP-644
	 * @see org.as3commons.logging.util#locationFromStackTrace()
	 * 
	 * @param linesChopped Amount of lines in the stacktrace that should be cut.
	 * @param useLineNumbers If true the line numbers will not be cropped
	 * @return The current location (if evaluatable)
	 */
	public function here(linesChopped:int=0,useLineNumbers:Boolean=true): String {
		if( IS_DEBUGGER ) {
			// just in debug player
			return locationFromStackTrace(
				(new Error).getStackTrace(), linesChopped+2, useLineNumbers
			) || "";
		} else {
			return "";
		}
	}
}