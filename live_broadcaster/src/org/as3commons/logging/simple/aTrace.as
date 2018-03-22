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
package org.as3commons.logging.simple {
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.util.IS_DEBUGGER;
	import org.as3commons.logging.util.here;
	
	/**
	 * Subsitute for the native trace function.
	 * 
	 * <p>In many applications the classic <code>trace</code> is used to trace
	 * statements. To refactor this code one can use this function in a search&amp;replace
	 * for the trace statements and have immediatly a as3commons logger.</p>
	 * 
	 * @param args
	 */
	public function aTrace( ...args:Array ): void {
		var logger: ILogger;
		if( IS_DEBUGGER && USE_STACKTRACE ) {
			logger = LOGGER_FACTORY.getNamedLogger( here(1, USE_LINE_NUMBERS), "direct" );
		} else {
			logger = DIRECT_LOGGER;
		}
		if( logger.infoEnabled ) {
			// Using the message formatter, other systems like the Firebug
			// debugger can show the arguments as objects. 
			var message: String = MESSAGES[args.length];
			if( !message ) {
				message = "";
				for(var i: int = 0, l: int = args.length; i<l; ++i ) {
					message += ((i!=0) ? " {" : "{") + i + "}";
				}
				MESSAGES[args.length] = message;
			}
			logger.info( message, args );
		}
	}
}

const MESSAGES: Object = {};
