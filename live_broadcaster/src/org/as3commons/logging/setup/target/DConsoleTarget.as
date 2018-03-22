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
	
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import org.as3commons.logging.util.LogMessageFormatter;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	
	/**
	 * <code>DConsoleTarget</code> sends log messages directly to the Doomsday
	 * console.
	 * 
	 * <p>Don't forget to add the console to the stage before using this target.</p>
	 * <listing>
	 *   addChild( DConsole.view );
	 *   DConsole.show();
	 *   
	 *   LOGGER_FACTORY.setup = new SimpleTargetSetup( new DConsoleTarget() );
	 * </listing>
	 * 
	 * <p>Note: The doomsday console uses integrates the slf4as logging system.</p>
	 * <p>Note: This version is built for v2 r203.</p>
	 * 
	 * @author Martin Heidegger
	 * @see http://code.google.com/p/doomsdayconsole
	 * @see org.as3commons.logging.integration.SLF4ASIntegration
	 * @since 2.5.1
	 */
	public final class DConsoleTarget implements IFormattingLogTarget {
		
		/** Default format used to stringify the log statements. */
		public static const DEFAULT_FORMAT: String = "{atPerson} {message}\n";
		
		/** Formatter that formats the log statements. */
		private var _formatter:LogMessageFormatter;
		
		private static const LEVELS: Object = {};
		{
			LEVELS[ DEBUG ] = ConsoleMessageTypes.DEBUG;
			LEVELS[ ERROR ] = ConsoleMessageTypes.ERROR;
			LEVELS[ WARN ] = ConsoleMessageTypes.WARNING;
			LEVELS[ INFO ] = ConsoleMessageTypes.INFO;
			LEVELS[ FATAL ] = ConsoleMessageTypes.FATAL;
		}
		
		/**
		 * Creates a new <code>DConsoleTarget</code> instance.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function DConsoleTarget(format:String=null) {
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
			DConsole.print(
				_formatter.format(name, shortName, level, timeStamp, message,
									parameters, person, context, shortContext),
				LEVELS[ level ],
				name 
			);
		}
	}
}
