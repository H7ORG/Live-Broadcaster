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
	
	import flash.display.LoaderInfo;
	import flash.events.EventDispatcher;
	
	/**
	 * Util that redirects the uncaught global errors to the log as fatal messages. 
	 * 
	 * @param loader LoaderInfo, preferrably of the root DisplayObject
	 * @author Martin Heidegger
	 * @since 2.5
	 */
	public function captureUncaughtErrors( loaderInfo:LoaderInfo ): void {
		if( loaderInfo.hasOwnProperty("uncaughtErrorEvents") ) {
			var events: EventDispatcher = loaderInfo["uncaughtErrorEvents"];
			events.addEventListener( "uncaughtError", doLog, false, 0, true );
		}
	}
}
import flash.events.Event;
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;


const logger: ILogger = getLogger( "org.as3commons.logging.util/captureUncaughtErrors" );

/**
 * Logs the statements
 * 
 * @param e Error that was thrown
 */
function doLog( e: Event ): void {
	e.preventDefault();
	logger.fatal( e["error"] );
}