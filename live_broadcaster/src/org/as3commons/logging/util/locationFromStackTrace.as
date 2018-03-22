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
	 * Parses one location from the given stacktrace and gives it in a logging compatible format.
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see org.as3commons.logging.util#here()
	 * 
	 * @param stackTrace StackTrace to parse
	 * @param lineNo Line number to use
	 * @param useLineNumbers Show the line number from the log statement
	 */
	public function locationFromStackTrace(stackTrace: String, lineNo:int=0, useLineNumbers: Boolean=true): String {
		if( stackTrace ) {
			// just in debug player
			var search: int = stackTrace.indexOf("\n");
			// Chop all lines
			while( lineNo > 0 ) {
				stackTrace = stackTrace.substr(search+1);
				search = stackTrace.indexOf("\n");
				--lineNo;
			}
			// And give me the last one
			if( search != -1 ) {
				stackTrace = stackTrace.substring(0, search);
			} 
			search = stackTrace.indexOf("(");
			var name: String = stackTrace.substring(4,search);
			if (search != stackTrace.length-2) {
				// Add the function, if given
				name += stackTrace.substring( stackTrace.lastIndexOf(":"), stackTrace.length-1 );
			}
			
			if (name.indexOf(GLOBAL_KEY) == 0 ) {
				// Global functions (function .as files)
				name = name.substr(GLOBAL_KEY.length).replace("::", "/");
			} else if (name.indexOf(LOCAL_KEY) == 0) {
				// Local defined functions
				name = name.substr(LOCAL_KEY.length).replace(".as", "").replace(":", "/");
			} else {
				// Replace the first "::" to be compatible with the rest of logging
				name = name.replace("::",".");
			}
			
			if (!useLineNumbers) {
				// Remove the line numbers if not wished
				search = name.lastIndexOf(":");
				if( search == -1 ) {
					name = name.substr(0,search);
				}
			}
			
			return name;
		} else {
			return null;
		}
	}
}
const LOCAL_KEY: String = "Function/";
const GLOBAL_KEY: String = "global/";
