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
	
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.api.ILogTarget;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	
	/**
	 * Sends log statements to the Open source media frameworks logging system.
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new SimpleTargetSetup( new OSMFTarget );
	 * </listing>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 2.5.2
	 * @see http://sourceforge.net/apps/mediawiki/osmf.adobe/index.php?title=Logging
	 * @see http://osmf.org/dev/osmf/specpdfs/LoggingFrameworkSpecification.pdf
	 * @see org.as3commons.logging.integration.OSMFIntegration
	 */
	public class OSMFTarget extends AbstractClassicTarget {
		
		/** Loggers of the OSMF used to log output */
		private static const _loggers: Object = {};
		
		/**
		 * @inheritDoc
		 */
		override protected function doLog(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:Array,
							person:String, context:String, shortContext:String): void {
			var logName: String = name;
			if( person ) {
				logName += "@"+person;
			}
			if( parameters ) {
				parameters.unshift(message);
			} else {
				parameters = [message];
			}
			var logger: Logger = _loggers[logName] ||= Log.getLogger(logName);
			switch( level ) {
				case DEBUG:
					logger.debug.apply(null, parameters);
					break;
				case INFO:
					logger.info.apply(null, parameters);
					break;
				case WARN:
					logger.warn.apply(null, parameters);
					break;
				case ERROR:
					logger.error.apply(null, parameters);
					break;
				case FATAL:
					logger.fatal.apply(null, parameters);
					break;
			}
		}
	}
}
