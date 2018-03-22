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
	
	import com.hexagonstar.util.debug.Debug;

	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>AlconTarget</code> sends log statements to the Alcon-Air application. 
	 * 
	 * <p>This will need the alcon.swc which you can aquire with the help in 
	 * the alcon logger!</p>
	 * 
	 * <p>Note: This version is built for 3.1.4.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.1
	 * @see http://www.hexagonstar.com/project/alcon/#download
	 */
	public final class AlconTarget implements ILogTarget {
		
		/** Default format to be used for formatting statements. */
		public static const DEFAULT_FORMAT: String = "{time} {logLevel} - {shortName}{atPerson} - {message}";
		
		/** Formatter to render the log statements */
		private var _formatter:LogMessageFormatter;
		
		private static const _levelMap: Object = {};
		{
			_levelMap[ DEBUG ] = Debug.LEVEL_DEBUG;
			_levelMap[ FATAL ] = Debug.LEVEL_FATAL;
			_levelMap[ INFO ] = Debug.LEVEL_INFO;
			_levelMap[ WARN ] = Debug.LEVEL_WARN;
			_levelMap[ ERROR ] = Debug.LEVEL_ERROR;
		}
		
		/**
		 * Creates a new <code>AlconTarget</code> instance.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function AlconTarget(format:String=null) {
			Debug.enabled = true;
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
							person:String, context:String, shortContext:String):void {
			if( message == "{}" ) {
				if( message is Number || message is Boolean || message is Function ) {
					Debug.trace( message, _levelMap[level]);
				} else {
					Debug.traceObj( message );
				}
			} else {
				Debug.trace(
					_formatter.format(name, shortName, level, timeStamp, message,
										parameters, person, context, shortContext),
					_levelMap[level]
				);
			}
		}
	}
}
