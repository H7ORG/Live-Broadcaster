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
	
	import logmeister.LogMeister;
	import logmeister.NSLogMeister;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * Sends statement to the <code>LogMeister</code> logging framework.
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new SimpleTargetSetup( new LogMeisterTarget );
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.2
	 * @see http://github.com/base42/LogMeister
	 * @see org.as3commons.logging.integration.LogMeisterIntegration
	 */
	public final class LogMeisterTarget extends AbstractClassicTarget implements IFormattingLogTarget {
		
		/** Default format used to stringify the log statements. */
		public static const DEFAULT_FORMAT:String = "{time} {logLevel} - {shortName}{atPerson} - {message}\n";
		
		/** Formatter that formats the log statements. */
		private var _formatter : LogMessageFormatter;
		
		/**
		 * Creates a new LogMeisterTarget.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 */
		public function LogMeisterTarget(format:String=null) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function doLog(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:Array,
							person:String, context:String, shortContext:String):void {
			var args: Array;
			message = _formatter.format(name, shortName, level, timeStamp, message,
										parameters, person, context, shortContext);
			if( parameters && parameters.length > 0 ) {
				args = parameters.concat();
				args.unshift(message);
			}
			if( args ) {
				if ( level === DEBUG ) {
					LogMeister.NSLogMeister::debug.apply(null, args);
				} else if ( level === INFO ) {
					LogMeister.NSLogMeister::info.apply(null, args);
				} else if ( level === WARN ) {
					LogMeister.NSLogMeister::warn.apply(null, args);
				} else if ( level === ERROR ) {
					LogMeister.NSLogMeister::error.apply(null, args);
				} else {
					LogMeister.NSLogMeister::fatal.apply(null, args);
				}
			} else {
				if ( level === DEBUG ) {
					LogMeister.NSLogMeister::debug(message);
				} else if ( level === INFO ) {
					LogMeister.NSLogMeister::info(message);
				} else if ( level === WARN ) {
					LogMeister.NSLogMeister::warn(message);
				} else if ( level === ERROR ) {
					LogMeister.NSLogMeister::error(message);
				} else {
					LogMeister.NSLogMeister::fatal(message);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String):void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
	}
}
