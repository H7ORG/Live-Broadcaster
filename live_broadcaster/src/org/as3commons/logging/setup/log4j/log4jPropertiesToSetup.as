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
package org.as3commons.logging.setup.log4j {
	
	import org.as3commons.logging.setup.HierarchicalSetup;
	
	/**
	 * Reads a log4j properties string and creates a hierarchical setup.
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 * @param properties Properties key, value string
	 * @return Setup configured following the passed in properties
	 * @see http://en.wikipedia.org/wiki/.properties
	 */
	public function log4jPropertiesToSetup(properties:String):HierarchicalSetup {
		const log4j: Log4JStyleSetup = new Log4JStyleSetup();
		
		// For all lines
		const lines: Array = properties.split("\n");
		const l: int = lines.length;
		for( var lineNo: int= 0; lineNo < l; ++lineNo ) {
			var line: String = lines[lineNo];
			line = line.replace(/^\s*/, ''); // trim left
			var char: String = line.charAt(0);
			// comments should be ignored
			if( char != "!" && char != "#" ) {
				var lineData: Object = /^\s*(?P<key>([^\s\\:=]|(\\\s)|(\\n)|(\\r)|(\\t)|(\\\u[a-fA-F0-9]{4,4})|(\\[^\s]))*)\s*[=:]?\s*(?P<value>.*)$/m.exec(line);
				// The regexp should not fail, just in case
				if( lineData ) {
					var key: String = unescape(lineData["key"]);
					var value: String = unescape(lineData["value"]);
					// Add additional lines
					while( value.charAt(value.length-1) == "\\" && lineNo < (lines.length-1) ) {
						++lineNo;
						value = value.substr(0,value.length-1) + "\n" + unescape(lines[lineNo]);
					}
					var path: Array = key.split(".");
					var root: String = path.shift();
					// The root has to be "log4j"
					if( root == "log4j" ) {
						var target: Object = log4j;
						while( path.length > 1 ) {
							target = target[path.shift()];
						}
						if( path.length == 1 ) {
							target[path[0]] = value;
						}
					}
				}
			}
		}
		return log4j.compile();
	}
}

/**
 * Unescapes values from the strings
 */
function unescape(str:String):String {
	return str.replace(/\\\u([a-fA-F0-9]{4,4})/g, unicodeReplace)
			// use a regular expression to unescape 
			.replace(/\\([\\tnrb])/g, encodingReplace);
}

const tags: Object =  {
	"t": "\t",
	"n": "\n",
	"r": "\r",
	"\\": "\\",
	"b": "\b"
};

function encodingReplace(...args:Array):String {
	return tags[args[1]];
}
function unicodeReplace(...args:Array):String {
	return String.fromCharCode(parseInt(args[1],16));
}
