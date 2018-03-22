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
	
	/*FDT_IGNORE*/
	import org.as3commons.logging.api.LOGGER_FACTORY;
	/*FDT_IGNORE*/
	
	import org.as3commons.logging.util.toLogName;
	import org.seasar.akabana.yui.core.logging.ILogger;
	import org.seasar.akabana.yui.core.logging.ILoggerFactory;
	
	import flash.utils.Dictionary;
	
	/**
	 * <code>YUILoggerFactory</code> provides a integration into the YUI framework.
	 * 
	 * <p>To integrate this class properly it needs to be registered via registerClass
	 * before calling <code>initialize();</code>
	 * </p>
	 * 
	 * <listing>
	 * registerClassAlias( "org.seasar.akabana.yui.logging.LoggerFactory", YUILoggerFactory );
	 * Logging.initialize();
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.1
	 * @see http://yui-docs.akabana.info/
	 */
	public final class YUILoggerFactory implements ILoggerFactory {
		
		private var _loggers: Dictionary = new Dictionary(true);
		
		/**
		 * Constructs a new <code>YUILoggerFactory</code>
		 */
		public function YUILoggerFactory() {}
		
		/**
		 * Returns a matching ILogger for the passed in object that sends
		 * all statements to as3commons.
		 * 
		 * @param target Target to be taken as information for the object to log.
		 */
		public function getLogger(target:Object): ILogger {
			var logger: ILogger = _loggers[target];
			if( !logger ) {
				var name: * = target;
				if(name && !(name is String)) {
					name = toLogName(name);
				}
				/*FDT_IGNORE*/
				logger = new YUILogger( LOGGER_FACTORY.getNamedLogger(name, "yui") );
				/*FDT_IGNORE*/
				_loggers[target] = logger;
			}
			return logger;
		}
	}
}

/*FDT_IGNORE*/
import org.as3commons.logging.api.ILogger;

final class YUILogger implements org.seasar.akabana.yui.core.logging.ILogger {
	
	private var _target: ILogger;
	
	public function YUILogger( target: ILogger ) {
		_target = target;
	}
	
	public function debug( message: String, ...args:* ): void {
		_target.debug( message, args.length == 0 ? null : args );
	}
	
	public function error( message: String, ...args:* ): void {
		_target.error( message, args.length == 0 ? null : args );
	}
	
	public function fatal( message: String, ...args:* ): void {
		_target.fatal( message, args.length == 0 ? null : args );
	}
	
	public function info( message: String, ...args:* ): void {
		_target.info( message, args.length == 0 ? null : args );
	}
	
	public function warn( message: String, ...args:* ): void {
		_target.warn( message, args.length == 0 ? null : args );
	}
}
/*FDT_IGNORE*/