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
	
	import jp.nium.core.debug.Logger;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>Progression4Target</code> can send log statements to the 
	 * logging mechanism used in the <code>Progression</code> framework.
	 * 
	 * <p>Built on version '4.0.22'.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://progression.jp/ja/download/
	 * @see org.as3commons.logging.setup#Progression4Integration()
	 */
	public class Progression4Target implements IFormattingLogTarget {
		
		/** Default format to be used for formatting statements. */
		private static const DEFAULT_FORMAT: String = "{shortName} {message}";
		
		/** Formater used to format log messages */
		private var _formatter: LogMessageFormatter;
		
		/**
		 * Creates a new <code>Progression4Target</code>
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function Progression4Target(format:String=null) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String):void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String):void {
			message = _formatter.format(name, shortName, level, timeStamp, message,
										parameters, person, context, shortContext);
			switch( level ) {
				case DEBUG:
				case INFO:
					Logger.info(message);
					break;
				case WARN:
					Logger.warn(message);
					break;
				case ERROR:
				case FATAL:
					Logger.error(message);
					break;
			}
		}
	}
}
