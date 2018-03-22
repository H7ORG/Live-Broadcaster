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
	
	import com.pblabs.engine.debug.ILogAppender;
	import com.pblabs.engine.debug.LogEntry;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getNamedLogger;
	
	/**
	 * <code>PushButtonIntegration</code> can be used as <code>ILogAppender</code>
	 * for the Push Button Engine that sends all log requests to as3commons.
	 * 
	 * <listing>
	 *   import com.pblabs.engine.debug.Logger;
	 *   
	 *   com.pblabs.engine.PBE.IS_SHIPPING_BUILD = true;
	 *   
	 *   Logger.startup();
	 *   Logger.registerListener( new PushButtonIntegration() );
	 * </listing>
	 * 
	 * <p><b>Note:</b> Unlike Mate, SpiceLib, Progression or Flex there
	 * is no way for us to implement a PushButtonTarget that would allow logging
	 * from as3commons to Push Button Engine.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://pushbuttonengine.com
	 */
	public final class PushButtonIntegration implements ILogAppender {
		
		// Stores loggers related to the targets
		private static const _cache: Object /* ILogger */ = {};
		
		/**
		 * Sends the log statements to as3commons logging. (implementation of
		 * ILogAppender hook)
		 * 
		 * @param level Level of the log entry
		 * @param loggerName Name of the logger
		 * @param message Message that was supposed to be logged
		 */
		public function addLogMessage(level:String, loggerName:String, message:String):void {
			var logger: ILogger = _cache[ loggerName ] || ( _cache[ loggerName ] = getNamedLogger( loggerName.replace("::", "."), "pushbutton" ) );
			switch( level ) {
				case LogEntry.DEBUG:
					logger.debug(message);
					break;
				case LogEntry.INFO:
					logger.info(message);
					break;
				case LogEntry.WARNING:
					logger.warn(message);
					break;
				case LogEntry.ERROR:
					logger.error(message);
					break;
				default:
					logger.debug(message);
					break;
			}
		}
	}
}
