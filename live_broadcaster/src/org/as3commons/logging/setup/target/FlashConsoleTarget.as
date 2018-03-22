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

	import com.junkbyte.console.Cc;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.setup.target.IFormattingLogTarget;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>FlashConsoleTarget</code> sends log statements to the FlashConsole
	 * user interface by Lu-Aye Oo.
	 * 
	 * <p>Built on Version 2.5</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://code.google.com/p/flash-console/
	 */
	public final class FlashConsoleTarget implements IFormattingLogTarget {
		
		/** Formatter that renders the log statements via MonsterDebugger.log(). */
		private static const DEFAULT_FORMAT: String = "{time} {shortName}{atPerson} {message}";
		
		/** Formatter that formats the log statements. */
		private var _formatter: LogMessageFormatter;
		
		public function FlashConsoleTarget( format:String=null ) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			_formatter = new LogMessageFormatter( format || DEFAULT_FORMAT );
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							 timeStamp:Number, message:String, parameter:*,
							 person:String, context:String, shortContext:String): void {
			message = _formatter.format(name, shortName, level, timeStamp, message,
										parameter, person, context, shortContext);
			switch( level ) {
				case DEBUG:
					Cc.debug( message );
					break;
				case INFO:
					Cc.info( message );
					break;
				case WARN:
					Cc.info( message );
					break;
				case ERROR:
					Cc.error( message );
					break;
				case FATAL:
					Cc.fatal( message );
					break;
			}
		}
	}
}

