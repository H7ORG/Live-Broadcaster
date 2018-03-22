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
	
	import org.asaplibrary.util.debug.Log;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>ASAPTarget</code> can be used to send statements from your code
	 * that uses as3commons-logging to your Asap library setup.
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://asaplibrary.org
	 * @see org.as3commons.logging.integration#ASAPIntegration
	 */
	public final class ASAPTarget implements IFormattingLogTarget {
		
		/** Default format used to stringify the log statements. */
		public static const DEFAULT_FORMAT:String = "{message}";
		
		/** Formatter to render the log statements */
		private var _formatter: LogMessageFormatter;
		
		/**
		 * Creates a new <code>ASAPTarget</code> instance.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function ASAPTarget(format:String=null) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String): void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							 timeStamp:Number, message: String, parameters:*,
							 person:String, context:String, shortContext:String): void {
			message = _formatter.format(name, shortName, level, timeStamp,
										message, parameters, person, context,
										shortContext);
			switch( level ) {
				case INFO:
					Log.info(message, name);
					break;
				case DEBUG:
					Log.debug(message, name);
					break;
				case ERROR:
					Log.error(message, name);
					break;
				case WARN:
					Log.warn(message, name);
					break;
				case FATAL:
					Log.fatal(message, name);
					break;
			}
		}
	}
}
