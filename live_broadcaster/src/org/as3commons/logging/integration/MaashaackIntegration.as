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
package org.as3commons.logging.integration {
	
	import system.logging.LoggerLevel;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.api.ILogger;
	import system.logging.LoggerEntry;
	import system.logging.LoggerTarget;
	
	/**
	 * <code>MaashaackIntegration</code> offers a way to send log messages deployed
	 * via Maashacks system to the as3commons system.
	 * 
	 * <listing>
	 * import system.logging.Log;
	 * import org.as3commons.logging.integration.MaashaackIntegration;
	 * 
	 * Log.addTarget( new MaashaackIntegration() );
	 * 
	 * Log.getLogger( "myclass" ).info( "hi" );// Sends "hi" to as3commons logging
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 * @see http://code.google.com/p/maashaack/
	 * @see org.as3commons.logging.setup.target.MaashaackTarget
	 */
	public final class MaashaackIntegration extends LoggerTarget {
		
		private const _loggers: Object = {};
		
		public function MaashaackIntegration() {}
		
		/**
		 * @inheritDoc
		 */
		override public function logEntry( entry: LoggerEntry ):void {
			var logger: ILogger = _loggers[entry.channel] ||= LOGGER_FACTORY.getNamedLogger(entry.channel,"Maashaack");
			var level: LoggerLevel = entry.level;
			if( level == LoggerLevel.INFO ) {
				logger.info(entry.message);
			} else if( level == LoggerLevel.WARN || level == LoggerLevel.WTF ) {
				logger.warn(entry.message);
			} else if( level == LoggerLevel.ERROR ) {
				logger.error(entry.message);
			} else if( level == LoggerLevel.FATAL ) {
				logger.fatal(entry.message);
			} else if( level == LoggerLevel.NONE ) {
			} else {
				logger.debug(entry.message);
			}
		}
	}
}
