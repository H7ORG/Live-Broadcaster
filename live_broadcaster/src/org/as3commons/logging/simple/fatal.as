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
	 * Logs a message to notify about an error that broke the application and
	 * couldn't be fixed automatically to the <code>DIRECT_LOGGER</code>.
	 * 
	 * <p>The Fatal level is designated to be used in case an error occurred
	 * that couldn't be stopped. A fatal error usually results in a inconsistent
	 * or inperceivable application state.</p>
	 * 
	 * <p>A message can contain place holders that are filled with the additional
	 * parameters. The <code>ILogTarget</code> implementation may treat the 
	 * options as they want.</p>
	 * 
	 * <p>Example for a message with parameters:</p>
	 * <listing>
	 *   fatal("A: {0} is B: {1}", "Hello", "World");
	 *   // A: Hello is B: World
	 * </listing>
	 * 
	 * @param message Message that should be logged.
	 * @param parameters List of parameters.
	 */
	public function fatal( message: *, parameters:Array=null ): void {
		var logger: ILogger;
		if( IS_DEBUGGER && USE_STACKTRACE ) {
			logger = LOGGER_FACTORY.getNamedLogger( here(1, USE_LINE_NUMBERS), "direct" );
		} else {
			logger = DIRECT_LOGGER;
		}
		logger.fatal( message, parameters );
	}
}
