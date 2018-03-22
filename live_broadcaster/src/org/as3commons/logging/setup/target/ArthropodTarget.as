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
	
	import com.carlcalderon.arthropod.Debug;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.setup.LogSetupLevel;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * Sends log statements to the <code>Athropod</code> Logging client.
	 * 
	 * @author Martin Heidegger
	 * @version 1.0
	 * @since 2.5
	 * @see http://arthropod.stopp.se
	 */
	public final class ArthropodTarget implements IFormattingLogTarget {
		
		/** Default format used to log statements */
		public static const DEFAULT_FORMAT:String = "{shortName}{atPerson} {message}";
		
		/** Default colors used to color the output statements. */
		public static const DEFAULT_COLORS: Object = {};
		{
			DEFAULT_COLORS[DEBUG] = Debug.LIGHT_BLUE;
			DEFAULT_COLORS[INFO] = Debug.BLUE;
			DEFAULT_COLORS[WARN] = Debug.YELLOW;
			DEFAULT_COLORS[ERROR] = Debug.PINK;
			DEFAULT_COLORS[FATAL] = Debug.RED;
		}
		
		/** Formatter used to format strings. */
		private var _formatter:LogMessageFormatter;
		
		/** Levels that use the "warn" method */
		private var _warnLevels:LogSetupLevel;
		
		/** Colors taken to render statements */
		private var _colors:Object;
		
		/**
		 * Creates a new <code>Arthopod</code> log target.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 * @param colors Colors used to display the different log statements
		 *        (default=DEFAULT_COLORS)
		 * @param warnLevels Levels that use the warn method instead of the log method
		 *        (default=WARN_ONLY);
		 */
		public function ArthropodTarget( format:String=null, colors:Object=null,
										 warnLevels:LogSetupLevel=null  ) {
			this.format = format;
			this.warnLevels = warnLevels;
			this.colors = colors;
		}
		
		/**
		 * Athropod supports <code>log</code> and <code>warn</code> statements.
		 * With this property you can define which levels should use the warn
		 * statement and which should use the log statements.
		 */
		public function set warnLevels( warnLevels:LogSetupLevel ):void {
			_warnLevels = warnLevels||LogSetupLevel.WARN_ONLY;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ):void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
		
		/**
		 * @inheritDoc
		 */
		public function set colors( colors:Object ):void {
			_colors = colors||DEFAULT_COLORS;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int, timeStamp:Number,
							message:String, parameters:*, person:String, context:String,
							shortContext:String): void {
			var color: uint = _colors[ level ];
			if( message != "{}" ) {
				message = _formatter.format(name, shortName, level, timeStamp,
											message, parameters, person,context,
											shortContext);
				if( (_warnLevels.valueOf() & level) == level ) {
					Debug.warning( message );
				} else {
					Debug.log( message, color );
				}
			} else if( parameters is String || parameters is Number || parameters is Boolean ) {
				if( (_warnLevels.valueOf() & level) == level ) {
					Debug.warning( parameters );
				} else {
					Debug.log( parameters, color );
				}
			} else if( parameters is Array ) {
				Debug.array( parameters );
			} else {
				Debug.object( parameters );
			}
		}
	}
}
