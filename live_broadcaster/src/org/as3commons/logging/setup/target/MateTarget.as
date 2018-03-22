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
	
	import com.asfusion.mate.core.MateManager;
	import com.asfusion.mate.utils.debug.IMateLogger;
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * Logger that allows tracing to the current configuration in Mate.
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://mate.asfusion.com
	 * @see org.as3commons.logging.integration.MateIntegration
	 */
	public final class MateTarget implements IFormattingLogTarget {
		
		/** Default formatting used if none(null) given */
		public static const DEFAULT_FORMAT:String = "{message}";
		
		/** Formats the log messages */
		private var _formatter: LogMessageFormatter;
		
		/** Formats the log messages */
		private var _logger: IMateLogger;
		
		public function MateTarget(format:String=null) {
			_logger = MateManager.instance.getLogger(true);
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
							 timeStamp:Number, message:String, parameters:*,
							 person:String, context:String, shortContext:String): void {
			message = _formatter.format(name, shortName, level, timeStamp, message,
										parameters, person, context, shortContext);
			switch( level ) {
				case INFO:
					_logger.info(message);
					break;
				case DEBUG:
					_logger.debug(message);
					break;
				case ERROR:
					_logger.error(message);
					break;
				case WARN:
					_logger.warn(message);
					break;
				case FATAL:
					_logger.fatal(message);
					break;
			}
		}
	}
}
