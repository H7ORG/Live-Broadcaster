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
	
	/**
	 * A <code>ILogger</code> defines the public access for any kind of logging
	 * request.
	 * 
	 * <p><code>ILogger</code> offers the common methods to log your traces like
	 * <code>debug</code>, <code>info</code>, <code>warning</code>, <code>error</code>,
	 * <code>fatal</code>. Each of these methods gets treated separately by the
	 * logging framework.</p>
	 * 
	 * <p>The message statements allow the use of parameters. Using the parameter
	 * is actually more efficient than using <code>String<code> concatination.</p>
	 * 
	 * <listing>
	 *   logger.info( "{x}x{y}", this ); // good
	 *   logger.info( this.x+"x"+this.y ); // bad
	 * </listing>
	 * 
	 * <p>Parameters are indicated by two curly braces <code>{}</code>. If it contains
	 * no property then the parameter will be used.</p>
	 * 
	 * <listing>
	 *   logger.info( "{}", this ); // this.toString();
	 * </listing>
	 * 
	 * <p>It is possible to adress deep properties too:</p>
	 * <listing>
	 *   logger.info( "{a.b}", {a:{b:"Hello World"}} ); // "Hello World"
	 * </listing>
	 * 
	 * <p><b>Performance Note:</b> If you have a log statement that does intense
	 * processing or intense stringification it will be executed no matter if a log
	 * target is actually in place.</p>
	 * 
	 * <listing>
	 *   // This will call the complexStringifcation no matter if it will do actually
	 *   // something.
	 *   logger.info( complexStringification() );
	 *   
	 *   if( logger.infoEnabled ) {
	 *      // will just call the stringification in case the info is enabled
	 *      logger.info( complexStringification() );
	 *   }
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 3
	 * @see LoggerFactory
	 * @see org.as3commons.logging.api#getLogger()
	 * @see org.as3commons.logging.api#getNamedLogger()
	 */
	public interface ILogger {
		
		/**
		 * The name of this <code>ILogger</code>.
		 */
		function get name():String;
		
		/**
		 * The short form of the name.
		 * 
		 * <p>The name of a <code>ILogger</code> is usually [package].[class]. The
		 * short name contains only the name of [class], in other words: the content
		 * after the last ".".</p>
		 * 
		 * @example If the name is <code>com.some.MyClass</code> then the short
		 *          name is <code>MyClass</code>.
		 * @see #name 
		 */
		function get shortName():String

		/**
		 * Returns the person that this logger created.
		 * 
		 * <p>For person based log statements loggers contain a optional information
		 * that can be used to filter for persons that created the logggers</p>
		 * 
		 * <p>Can be <code>null</code></p>
		 */
		function get person():String;
		
		/**
		 * The context in which the this logger was called.
		 * 
		 * <p>To be used for inheritance based design. If you want to differenciate
		 * between where it is written and where it is called.</p>
		 * 
		 * <p>Can be <code>null</code></p>
		 */
		function get context(): String;
		
		/**
		 * Returns the short form of the context.
		 * 
		 * <p>The context of a <code>ILogger</code> is usually [package].[class]. The
		 * short name contains only the name of [class], in other words: the content
		 * after the last ".".</p>
		 * 
		 * @example If the context is <code>com.some.MyClass</code> then the short
		 *          name is <code>MyClass</code>.
		 * 
		 * @return short form of the context.
		 * @see #context 
		 */
		function get shortContext(): String;
		
		/**
		 * Logs a message for debug purposes.
		 * 
		 * <p>Debug messages should be messages that ease the debugging of an
		 * application.</p>
		 * 
		 * <p>A message can contain multiple placeholder that are filled with
		 * the parameter.</p> 
		 * <listing>
		 *   logger.debug("Hello {}", "Hello"); // Hello World
		 *   logger.debug("{} {}", "A"); // A A
		 * </listing>
		 * 
		 * <p>The parameter can also reference to the properties of the parameter.</p> 
		 * <listing>
		 *   logger.debug("{0} {1}", ["Hello", "World"]); // Hello World
		 *   logger.debug("{a} {b}", {a:"Hello", b:"World"}); // Hello Hello
		 * </listing>
		 * 
		 * <p>Deep inspection also works as reference definition.</p> 
		 * <listing>
		 *   logger.debug("{a.b} {a.c}", {a:{b:"Hello", c:"World"}}); // Hello World
		 * </listing>
		 * 
		 * <p>Without a parameter passed in the message will be used as parameter.</p>
		 * <listing>
		 *   logger.debug({hello:"world"});
		 *   logger.debug("{}", {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * <p>If both the message and the parameter is available then the String
		 * representation of the message is used. This is important for some intelligent
		 * .toString operations (that create log statements)</p>
		 * <listing>
		 *   logger.debug({}, {hello:"world"});
		 *   logger.debug({}.toString(), {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * @param message Message that should be logged.
		 * @param parameter Parameter to be used for inspection.
		 */
		function debug(message:*, parameter:*=null):void;
		
		/**
		 * Logs a message for notification purposes.
		 * 
		 * <p>Notification messages should be messages that highlight interesting
		 * informations about what happens in the the application.</p>
		 * 
		 * <p>A message can contain multiple placeholder that are filled with
		 * the parameter.</p> 
		 * <listing>
		 *   logger.info("Hello {}", "Hello"); // Hello World
		 *   logger.info("{} {}", "A"); // A A
		 * </listing>
		 * 
		 * <p>The parameter can also reference to the properties of the parameter.</p> 
		 * <listing>
		 *   logger.info("{0} {1}", ["Hello", "World"]); // Hello World
		 *   logger.info("{a} {b}", {a:"Hello", b:"World"}); // Hello Hello
		 * </listing>
		 * 
		 * <p>Deep inspection also works as reference definition.</p> 
		 * <listing>
		 *   logger.info("{a.b} {a.c}", {a:{b:"Hello", c:"World"}}); // Hello World
		 * </listing>
		 * 
		 * <p>Without a parameter passed in the message will be used as parameter.</p>
		 * <listing>
		 *   logger.info({hello:"world"});
		 *   logger.info("{}", {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * <p>If both the message and the parameter is available then the String
		 * representation of the message is used. This is important for some intelligent
		 * .toString operations (that create log statements)</p>
		 * <listing>
		 *   logger.info({}, {hello:"world"});
		 *   logger.info({}.toString(), {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * @param message Message that should be logged.
		 * @param parameter Parameter to be used for inspection.
		 */
		function info(message:*, parameter:*=null):void;
		
		/**
		 * Logs a message for warning about a undesirable application state.
		 * 
		 * <p>A message can contain multiple placeholder that are filled with
		 * the parameter.</p> 
		 * <listing>
		 *   logger.warn("Hello {}", "Hello"); // Hello World
		 *   logger.warn("{} {}", "A"); // A A
		 * </listing>
		 * 
		 * <p>The parameter can also reference to the properties of the parameter.</p> 
		 * <listing>
		 *   logger.warn("{0} {1}", ["Hello", "World"]); // Hello World
		 *   logger.warn("{a} {b}", {a:"Hello", b:"World"}); // Hello Hello
		 * </listing>
		 * 
		 * <p>Deep inspection also works as reference definition.</p> 
		 * <listing>
		 *   logger.warn("{a.b} {a.c}", {a:{b:"Hello", c:"World"}}); // Hello World
		 * </listing>
		 * 
		 * <p>Without a parameter passed in the message will be used as parameter.</p>
		 * <listing>
		 *   logger.warn({hello:"world"});
		 *   logger.warn("{}", {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * <p>If both the message and the parameter is available then the String
		 * representation of the message is used. This is important for some intelligent
		 * .toString operations (that create log statements)</p>
		 * <listing>
		 *   logger.warn({}, {hello:"world"});
		 *   logger.warn({}.toString(), {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * @param message Message that should be logged.
		 * @param parameter Parameter to be used for inspection.
		 */
		function warn(message:*, parameter:*=null):void;
		
		/**
		 * Logs a message to notify about an error that was dodged by the application.
		 * 
		 * <p>The Error level is designated to be used in case an error occurred
		 * and the error could be dodged. It should contain hints about why
		 * that error occurs and if there is a common case where this error occurs.</p>
		 * 
		 * <p>A message can contain multiple placeholder that are filled with
		 * the parameter.</p> 
		 * <listing>
		 *   logger.error("Hello {}", "Hello"); // Hello World
		 *   logger.error("{} {}", "A"); // A A
		 * </listing>
		 * 
		 * <p>The parameter can also reference to the properties of the parameter.</p> 
		 * <listing>
		 *   logger.error("{0} {1}", ["Hello", "World"]); // Hello World
		 *   logger.error("{a} {b}", {a:"Hello", b:"World"}); // Hello Hello
		 * </listing>
		 * 
		 * <p>Deep inspection also works as reference definition.</p> 
		 * <listing>
		 *   logger.error("{a.b} {a.c}", {a:{b:"Hello", c:"World"}}); // Hello World
		 * </listing>
		 * 
		 * <p>Without a parameter passed in the message will be used as parameter.</p>
		 * <listing>
		 *   logger.error({hello:"world"});
		 *   logger.error("{}", {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * <p>If both the message and the parameter is available then the String
		 * representation of the message is used. This is important for some intelligent
		 * .toString operations (that create log statements)</p>
		 * <listing>
		 *   logger.error({}, {hello:"world"});
		 *   logger.error({}.toString(), {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * @param message Message that should be logged.
		 * @param parameter Parameter to be used for inspection.
		 */
		function error(message:*, parameter:*=null):void;
		
		/**
		 * Logs a message to notify about an error that broke the application and
		 * couldn't be fixed automatically.
		 * 
		 * <p>A message can contain multiple placeholder that are filled with
		 * the parameter.</p> 
		 * <listing>
		 *   logger.fatal("Hello {}", "Hello"); // Hello World
		 *   logger.fatal("{} {}", "A"); // A A
		 * </listing>
		 * 
		 * <p>The parameter can also reference to the properties of the parameter.</p> 
		 * <listing>
		 *   logger.fatal("{0} {1}", ["Hello", "World"]); // Hello World
		 *   logger.fatal("{a} {b}", {a:"Hello", b:"World"}); // Hello Hello
		 * </listing>
		 * 
		 * <p>Deep inspection also works as reference definition.</p> 
		 * <listing>
		 *   logger.fatal("{a.b} {a.c}", {a:{b:"Hello", c:"World"}}); // Hello World
		 * </listing>
		 * 
		 * <p>Without a parameter passed in the message will be used as parameter.</p>
		 * <listing>
		 *   logger.fatal({hello:"world"});
		 *   logger.fatal("{}", {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * <p>If both the message and the parameter is available then the String
		 * representation of the message is used. This is important for some intelligent
		 * .toString operations (that create log statements)</p>
		 * <listing>
		 *   logger.fatal({}, {hello:"world"});
		 *   logger.fatal({}.toString(), {hello:"world"}); // Both calls are equal!
		 * </listing>
		 * 
		 * @param message Message that should be logged.
		 * @param parameter Parameter to be used for inspection.
		 */
		function fatal(message:*, parameter:*=null):void;
		
		/**
		 * <code>true</code> if <code>debug</code> actually does something.
		 * @see #debug()
		 */
		function get debugEnabled():Boolean;
		
		/**
		 * <code>true</code> if <code>info</code> actually does something.
		 * @see #info()
		 */
		function get infoEnabled():Boolean;
		
		/**
		 * <code>true</code> if <code>warn</code> actually does something.
		 * @see #warn()
		 */
		function get warnEnabled():Boolean;
		
		/**
		 * <code>true</code> if <code>error</code> actually does something.
		 * @see #error()
		 */
		function get errorEnabled():Boolean;
		
		/**
		 * <code>true</code> if <code>fatal</code> works.
		 * @see #fatal()
		 */
		function get fatalEnabled():Boolean;
	}
}