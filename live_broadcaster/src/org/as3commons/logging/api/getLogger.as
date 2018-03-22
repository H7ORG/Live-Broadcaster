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
package org.as3commons.logging.api {
	import org.as3commons.logging.util.toLogName;
	
	/**
	 * Returns a logger for the passed-in input that can be eighter a String
	 * or a Class.
	 * 
	 * <p>Shortest access to get a custom named <code>ILogger</code> instance to
	 * send your logging statements.</p>
	 * <p>It chooses depending on the input whether it should act like
	 * <code>getNamedLogger(name);</code> or <code>getClassLogger();</code>.</p>
	 * 
	 * @example <listing version="3.0">
	 * package {
	 *    
	 *    import org.as3commons.logging.api.getLogger;
	 *    import org.as3commons.logging.api.ILogger;
	 *    
	 *    class MyClass {
	 *        private static const log: ILogger = getLogger("This is my super name for this logger");
	 *        function MyClass() {
	 *            log.info("Hello World");
	 *        }
	 *    }
	 * } 
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @param name If String it will just pass it to <code>getNamedLogger</code>
	 *        else use it like <code>getClassLogger</code>
	 * @param person Information about the person that requested this logger.
	 * @param context Context in which this logger is called.
	 * @return <code>ILogger</code> instance to publish log statements
	 * @since 2.0
	 * @version 2
	 * @see org.as3commons.logging.api#getNamedLogger()
	 * @see org.as3commons.logging.api#getClassLogger()
	 * @see org.as3commons.logging.api#LOGGER_FACTORY
	 */
	public function getLogger(name:*=null,person:String=null,context:*=null):ILogger {
		if(name!=null && !(name is String)) {
			name = toLogName(name);
		}
		if(context!=null && !(context is String)) {
			context = toLogName(context);
		}
		return LOGGER_FACTORY.getNamedLogger(name,person,context);
	}
}
