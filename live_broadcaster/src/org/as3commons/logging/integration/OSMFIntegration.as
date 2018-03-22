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
	
	import org.osmf.logging.Logger;
	import org.osmf.logging.LoggerFactory;
	
	/**
	 * <code>OSMFIntegration</code> can be used send statements sent to the OSMF
	 * logging system to redirect them to the as3commons logging system.
	 * 
	 * <listing>
	 *    import org.as3commons.logging.integration.OSMFIntegration;
	 *    import org.osmf.logging.Log;
	 *    
	 *    Log.loggerFactory = new OSMFIntegration();
	 *    // and all the statements go to as3commons
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.2
	 * @see org.as3commons.logging.setup.target.OSMFTarget
	 * @see http://sourceforge.net/apps/mediawiki/osmf.adobe/index.php?title=Logging
	 * @see http://osmf.org/dev/osmf/specpdfs/LoggingFrameworkSpecification.pdf
	 */
	public final class OSMFIntegration extends LoggerFactory {
		
		/** Loggers stored for different logger names*/
		private const _loggers : Object = {};
		
		/**
		 * Creates a new integration
		 */
		public function OSMFIntegration(){}
		
		/**
		 * @inheritDoc
		 */
		override public function getLogger(name:String):Logger {
			return _loggers[name] || (_loggers[name] = new LoggerWrapper(name));
		}
	}
}

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getNamedLogger;
import org.osmf.logging.Logger;

final class LoggerWrapper extends Logger {
	
	private var _target: ILogger;
	
	public function LoggerWrapper(name:String) {
		_target = getNamedLogger(name, "OSMF");
		super(name);
	}
	
	override public function debug(message:String, ...args):void {
		_target.debug(message, args);
	}
	
	override public function info(message:String, ...args):void {
		_target.info(message, args);
	}
	
	override public function warn(message:String, ...args):void {
		_target.warn(message, args);
	}
	
	override public function error(message:String, ...args):void {
		_target.error(message, args);
	}
	
	override public function fatal(message:String, ...args):void {
		_target.fatal(message, args);
	}
}