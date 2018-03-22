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
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.log5f.Level;
	import org.log5f.core.Appender;
	import org.log5f.core.IAppender;
	import org.log5f.events.LogEvent;
	
	
	/**
	 * Appender to the Log5F framework that redirects statements to the Log5F framework
	 * to the as3commons logging setup.
	 * 
	 * <listing>
	 *   import org.as3commons.logging.integration.Log5FIntegration;
	 *   import org.log5f.LoggerManager;
	 *   import org.log5f.core.config.tags.LoggerTag;
	 *   import org.log5f.core.config.tags.ConfigurationTag;
	 *   
	 *   var tag: LoggerTag = new LoggerTag();
	 *   tag.appenders = [new Log5FIntegration()];
	 *   tag.level = "ALL";
	 *   
	 *   var setup: ConfigurationTag = new ConfigurationTag();
	 *   setup.objects = [tag];
	 *   
	 *   LoggerManager.configure(setup);
	 * </listing>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 2.6
	 * @see http://log5f.org
	 * @see org.as3commons.logging.setup.target.Log5FTarget
	 */
	public final class Log5FIntegration extends Appender implements IAppender {
		
		private static const DEBUG: int = Level.DEBUG.toInt();
		private static const ALL: int = Level.ALL.toInt();
		private static const OFF: int = Level.OFF.toInt();
		private static const INFO: int = Level.INFO.toInt();
		private static const WARN: int = Level.WARN.toInt();
		private static const ERROR: int = Level.ERROR.toInt();
		
		/**
		 * Creates a new Log5FIntegration.
		 * Automatically defines the layout as "SimpleLayout". 
		 */
		public function Log5FIntegration() {
			layout = INTERNAL;
		}
		
		/**
		 * Logger storage to tweak some performance ... even though its not necessary
		 * (Log5F wasting a lot of it...)
		 */
		private const _loggers: Object = {};
		
		/**
		 * Sends the events to the as3commons logging framework.
		 * 
		 * @param event Event used by Log5F
		 */
		override protected function append(event:LogEvent):void {
			var name: String = event.category.name;
			var message: String;
			var args: Array;
			var logger: ILogger = _loggers[name] || (_loggers[name] = getLogger(name, "log5f"));
			if( layout != INTERNAL ) {
				message = layout.format(event);
				if( message.length > 0 && message.charAt(message.length-1) == "\n" ) {
					message = message.substr(0,message.length-1);
				}
			} else if( event.message is Array ) {
				args = event.message as Array;
				if( args.length == 1 && args[0] is String ) {
					message = args[0];
					args = null;
				} else {
					message = "";
					for(var i: int = 0, l: int = args.length; i<l; ++i ) {
						message += ((i!=0) ? ",{" : "{") + i + "}";
					}
				}
			} else if( event.message is String ) {
				message = event.message as String; 
			} else {
				message = "{0}";
				args = [event.message];
			}
			var level: int = event.level.toInt();
			switch (level) {
				case ALL:
				case DEBUG:
					logger.debug(message,args);
					break;
				case INFO:
					logger.info(message,args);
					break;
				case WARN:
					logger.warn(message,args);
					break;
				case ERROR:
					logger.error(message,args);
				case OFF:
					break;
				default:
					logger.fatal(message,args);
					break;
			}
		}
	}
}
import org.log5f.core.ILayout;
import org.log5f.events.LogEvent;

const INTERNAL: InternalLayout = new InternalLayout();

class InternalLayout implements ILayout {
	public function get isStackNeeded(): Boolean {
		return false;
	}

	public function format(event : LogEvent) : String {
		return "";
	}
}