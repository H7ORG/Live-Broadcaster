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
	
	import nl.acidcats.yalog.Yalog;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>YalogTarget</code> sends all statements to the Yalog logger
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new SimpleTargetSetup( new YalogTarget );
	 * </listing>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 2.5.2
	 * @see http://code.google.com/p/yalog/
	 */
	public final class YalogTarget implements IFormattingLogTarget {
		
		/** Default format to be used for formatting statements. */
		private static const DEFAULT_FORMAT: String = "{message}";
		
		/** Formater used to format log messages */
		private var _formatter: LogMessageFormatter;
		
		/**
		 * Creates a new <code>YalogTarget</code>
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function YalogTarget( format:String=null ) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			_formatter = new LogMessageFormatter( format||DEFAULT_FORMAT );
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameter:*,
							person:String, context:String, shortContext:String): void {
			message = _formatter.format(name, shortName, level, timeStamp, message,
										parameter, person, context, shortContext);
			if( person ) {
				name += "@"+person;
			}
			if( context ) {
				name += " in "+context;
			}
			switch( level ) {
				case DEBUG:
					Yalog.debug( message, name );
					break;
				case INFO:
					Yalog.info( message, name );
					break;
				case WARN:
					Yalog.warn( message, name );
					break;
				case ERROR:
					Yalog.error( message, name );
					break;
				case FATAL:
					Yalog.fatal( message, name );
					break;
			}
		}
	}
}
