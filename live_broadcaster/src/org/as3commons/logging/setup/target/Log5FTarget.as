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
package org.as3commons.logging.setup.target {
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.util.LogMessageFormatter;
	import org.log5f.ILogger;
	import org.log5f.LoggerManager;
	
	/**
	 * Sends all messages to the Log5f framework.
	 * 
	 * <p>As Log5F does not implement the same logic as as3commons we send a 
	 * formatted string to Log5F.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see http://log5f.org
	 * @see org.as3commons.logging.integration.Log5FIntegration
	 */
	public final class Log5FTarget implements ILogTarget {
		
		/** Default format to be used for formatting statements. */
		public static const DEFAULT_FORMAT: String = "{time} {logLevel} - {shortName}{atPerson} - {message}";
		
		/** Formatter to render the log statements */
		private var _formatter:LogMessageFormatter;
		
		/**
		 * Stores all loggers - performance
		 */
		private const _loggers: Object = {};
		
		
		/**
		 * Creates a new <code>Log5FTarget</code> instance.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function Log5FTarget(format:String=null) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String):void {
			_formatter = new LogMessageFormatter( format || DEFAULT_FORMAT );
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							 timeStamp:Number, message:String, parameters:*,
							 person:String, context:String, shortContext:String): void {
			if( person != "log5f") {
				var logger: ILogger = _loggers[name]||=LoggerManager.getLogger(name);
				message = _formatter.format(name, shortName, level, timeStamp,
											message, parameters, person, context,
											shortContext);
				if( level == INFO ) {
					logger.info( message );
				} else if( level == DEBUG ) {
					logger.debug( message );
				} else if( level == ERROR ) {
					logger.error( message );
				} else if( level == WARN ) {
					logger.warn( message );
				} else if( level == FATAL ) {
					logger.fatal( message );
				}
			}
		}
	}
}
