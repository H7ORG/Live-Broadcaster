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
	
	import org.as3commons.logging.api.getNamedLogger;
	import org.spicefactory.lib.logging.LogFactory;
	import org.spicefactory.lib.logging.Logger;
	
	/**
	 * <code>SpiceLibIntegration</code> sends log statements from SpiceLib
	 * to the as3commons.
	 * 
	 * <listing>
	 *   import org.spicefactory.lib.logging.LogContext;
	 *   LogContext.factory = new SpiceLibIntegration();
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://www.spicefactory.org/parsley
	 * @see org.as3commons.logging.setup.target.SpiceLibTarget
	 */
	public final class SpiceLibIntegration implements LogFactory {
		
		// Cache of LoggerWrapper, so we dont need to create them more
		// often than necessary.
		private var _cache: Object /* String -> LoggerWrapper */ = {};
		
		/**
		 * Constructs the integration.
		 */
		public function SpiceLibIntegration() {}
		
		/**
		 * Creates a logger for the Swiz system.
		 * 
		 * @param name Name of the logger to wrap.
		 */
		public function getLogger( name: Object ): Logger {
			var nameStr: String;
			/*FDT_IGNORE*/
			nameStr = name.toString();
			/*FDT_IGNORE*/
			return _cache[ nameStr ] || ( _cache[ nameStr ] = new LoggerWrapper( getNamedLogger( nameStr ) ) );
		}
	}
}

import org.as3commons.logging.api.ILogger;
import org.spicefactory.lib.logging.Logger;

final class LoggerWrapper implements Logger {
	
	private var _logger: ILogger;
	
	public function LoggerWrapper( logger: ILogger ) {
		_logger = logger;
	}
	
	public function debug( message:String, ...args:* ):void {	
		_logger.debug( message, args.length > 0 ? args : null );
	}

	public function error( message:String, ...args:* ):void {	
		_logger.error( message, args.length > 0 ? args : null );
	}

	public function fatal( message:String, ...args:* ):void {	
		_logger.fatal( message, args.length > 0 ? args : null );
	}

	public function info( message:String, ...args:*):void {
		_logger.info( message, args.length > 0 ? args : null );
	}

	public function trace( message:String, ...args:* ):void {	
		_logger.info( message, args.length > 0 ? args : null );
	}

	public function warn( message:String, ...args:* ):void {	
		_logger.warn( message, args.length > 0 ? args : null );
	}

	public function isDebugEnabled():Boolean {
		return _logger.debugEnabled;
	}

	public function isErrorEnabled():Boolean {
		return _logger.errorEnabled;
	}

	public function isFatalEnabled():Boolean {
		return _logger.fatalEnabled;
	}

	public function isInfoEnabled():Boolean {
		return _logger.infoEnabled;
	}

	public function isTraceEnabled():Boolean {
		return _logger.infoEnabled;
	}

	public function isWarnEnabled():Boolean {
		return _logger.warnEnabled;
	}

	public function get name():String {
		return _logger.name;
	}

}