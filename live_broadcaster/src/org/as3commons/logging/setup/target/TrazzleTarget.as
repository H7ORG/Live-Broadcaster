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
	
	import flash.display.BitmapData;
	import com.nesium.logging.TrazzleLogger;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	import flash.display.Stage;
	
	/**
	 * <code>TrazzleTarget</code> sends log statements to the mac-only
	 * <code>Trazzle</code> logger.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 2.5.2
	 * @see http://www.nesium.com/products/trazzle
	 */
	public final class TrazzleTarget implements IFormattingLogTarget {
		
		/** Default format to be used for formatting statements. */
		private static const DEFAULT_FORMAT: String = "{message}";
		
		/** Formater used to format log messages */
		private const _formatters: Object = {};
		
		/** Logger used to push the statements */
		private var _instance: TrazzleLogger;
		
		/** Line of the stack trace element. */
		private var _stackIndex: uint;
		
		/**
		 * Creates a new <code>TrazzleTarget</code>
		 * 
		 * <p>This method will initialize the TrazzleLogger if both title and
		 * stage are given.</p>
		 * 
		 * @param stackIndex Line used from the stacktrace. (can be different
		 *        in different setups).
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 * @param stage Stage used to initialize the logger
		 * @param title Title of this application.
		 */
		public function TrazzleTarget(stackIndex:uint, format:String=null,
										stage:Stage=null, title:String=null) {
			if( stage && title ) {
				zz_init(stage, title);
			}
			this.format = format;
			_stackIndex = stackIndex;
			_instance = TrazzleLogger.instance();
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			if( !format ) {
				format = DEFAULT_FORMAT;
			}
			_formatters[ DEBUG ] = new LogMessageFormatter( "d "+format );
			_formatters[ INFO ] =  new LogMessageFormatter( "i "+format );
			_formatters[ WARN ] =  new LogMessageFormatter( "n "+format );
			_formatters[ ERROR ] = new LogMessageFormatter( "e "+format );
			_formatters[ FATAL ] = new LogMessageFormatter( "f "+format );
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String): void {
			if(message == "{}" && parameters is BitmapData) {
				_instance.logBitmapData(parameters);
			} else {
				_instance.log( LogMessageFormatter( _formatters[level] || _formatters[ FATAL ] )
					.format(name, shortName, level, timeStamp, message,
							parameters, person, context, shortContext),
					_stackIndex
				);
			}
		}
	}
}