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
	
	import com.furusystems.logging.slf4as.constants.Levels;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.util.toLogName;
	import org.as3commons.logging.api.ILogger;
	import flash.utils.Dictionary;
	import com.furusystems.logging.slf4as.bindings.ILogBinding;
	
	/**
	 * <code>SLF4ASIntegration</code> redirects statements from the slf4as framework
	 * to the as3commons logging targets;
	 * 
	 * <p>Example:</p>
	 * <listing>
	 *   import com.furusystems.logging.slf4as.Logging;
	 *   import org.as3commons.logging.integration.SLF4ASIntegration;
	 *   
	 *   Logging.logBinding = new SLF4ASIntegration();
	 * </listing>
	 * 
	 * <p>Note: This version is built for r25.</p>
	 * 
	 * <p>Note: There is no swc in the wild for SLF4AS, it does however get
	 * shipped with the DConsole</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.1
	 * @see http://code.google.com/p/slf4as/
	 * @see org.as3commons.logging.setup.target.DConsoleTarget
	 */
	public final class SLF4ASIntegration implements ILogBinding {
		
		private var _loggers : Dictionary = new Dictionary();
		
		/**
		 * Constructs a new <code>SLF4ASIntegration</code>
		 */
		public function SLF4ASIntegration() {}
		
		/**
		 * Prints a log statement
		 * 
		 * @param owner Owner name to be displayed.
		 * @param level Level, stringified of the log statement
		 * @param str String to be rendered
		 */
		public function print( owner: Object, level: String, str: String ): void {
			var logger: ILogger = _loggers[owner];
			if( !logger ) {
				var name: * = owner;
				var nameStr: String;
				if(owner is String ) {
					nameStr = name;
				} else if(owner) {
					nameStr = toLogName(owner);
				}
				logger = LOGGER_FACTORY.getNamedLogger(nameStr, "slf4as");
				_loggers[owner] = logger;
			}
			var levelNo: int = Levels[level];
			switch( levelNo ) {
				case Levels.ERROR:
					logger.error( str );
					break;
				case Levels.FATAL:
					logger.fatal( str );
					break;
				case Levels.DEBUG:
					logger.debug( str );
					break;
				case Levels.WARN:
					logger.warn( str );
					break;
				default:
					logger.info( str );
			}
		}
	}
}
