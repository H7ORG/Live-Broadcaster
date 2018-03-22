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
	import mx.logging.LogEventLevel;
	/*FDT_IGNORE*/
	
	import flash.utils.Dictionary;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.ILoggingTarget;
	import mx.logging.LogEvent;
	import org.as3commons.logging.api.getNamedLogger;
	
	
	/**
	 * The <code>FlexLogger</code> implements Flex's <code>ILoggingTarget</code>
	 * and allows this way to route the events sent to Flex's system straight to
	 * the as3commons system.
	 * 
	 * <p>If you want to switch from the Flex's logging system to the as3commons
	 * logging system you can either change all references to from Flex to as3commons
	 * or use this <code>FlexLogger</code> in the <code>mx.commons</code> setup.</p>
	 * 
	 * <listing>
	 *    mx.logging.Log.addTarget( new org.as3commons.logging.FlexLogger() );
	 *    
	 *    mx.logging.Log.getLogger( "MyClass" ).debug( "Hello World" );
	 *    // is now routed to
	 *    org.as3commons.logging.getLogger( "MyClass" ).debug( "Hello World" );
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2
	 */
	public final class FlexLogger extends AbstractTarget implements ILoggingTarget {
		
		/** Caches the as3commons loggers. */
		private var _loggerMap:Dictionary /* mx.logging.ILogger -> org.as3commons.logging.ILogger */ = new Dictionary();
		
		/**
		 * Constructs the <code>FlexLogger</code> instance. 
		 * 
		 * @param level Level to which the targets should be applied.
		 */
		public function FlexLogger(level:int=2) {
			super();
			this.level = level;
		}
		
		/**
		 * Stores a logger from the mx.commons system.
		 * 
		 * @param logger <code>ILogger</code> to be stored.
		 */
		override public function addLogger(logger:ILogger):void {
			super.addLogger(logger);
			// Stores the equivalent logger of as3commons in the map
			if( logger ) {
				_loggerMap[ logger ] = getNamedLogger(logger.category,"flex");
			}
		}
		
		/**
		 * Routes the log events to the as3commons equivalent.
		 * 
		 * @param event Event triggered by the flex event system.
		 */
		override public function logEvent(event:LogEvent):void {
			/*FDT_IGNORE*/
			// Retrieves the logger from as3commons from the cache. 
			var logger: org.as3commons.logging.api.ILogger = _loggerMap[ event.target ];
			if( event.level < LogEventLevel.FATAL ) {
				if( event.level < LogEventLevel.WARN ) {
					if( event.level < LogEventLevel.INFO ) {
						logger.debug( event.message );
					} else {
						logger.info( event.message );
					}
				} else {
					if( event.level < LogEventLevel.ERROR ) {
						logger.warn( event.message );
					} else {
						logger.error( event.message );
					}
				}
			} else {
				logger.fatal( event.message );
			}
			/*FDT_IGNORE*/
		}
	}
}
