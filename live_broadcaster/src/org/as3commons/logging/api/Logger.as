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
	
	import org.as3commons.logging.api.ILogTarget;
	import flash.utils.getTimer;
	
	/**
	 * Proxy for an <code>ILogger</code> implementation. This class is used
	 * by the <code>LoggerFactory</code> in the setup process.
	 *
	 * <p>A <code>Logger</code> instance is created for each logger requested from
	 * the factory. The <code>Logger</code> instances do get augmented by
	 * <code>ILogSetup</code> in the setup process.</p>
	 *
	 * @author Martin Heidegger
	 * @author Christophe Herreman
	 * @version 2.0
	 * @version 2
	 * @see org.as3commons.logging.api.ILogSetup
	 */
	public final class Logger implements ILogger {
		
		/** The logger for debug level, if not added (<code>== null</code>) debug is not enabled. */
		public var debugTarget:ILogTarget;
		
		/** The logger for debug level, if not added (<code>== null</code>) info is not enabled. */
		public var infoTarget:ILogTarget;
		
		/** The logger for warn level, if not added (<code>== null</code>) warn is not enabled. */
		public var warnTarget:ILogTarget;
		
		/** The logger for error level, if not added (<code>== null</code>) error is not enabled. */
		public var errorTarget:ILogTarget;
		
		/** The logger for fatal level, if not added (<code>== null</code>) fatal is not enabled. */
		public var fatalTarget:ILogTarget;
		
		/** Full name of the logger. */
		private var _name:String;
		
		/** Short name of the logger. (Generated from the passed-in name) */
		private var _shortName:String;
		
		/** Optional Personalization option for log statements */
		private var _person:String;
		
		/** Optional Contextual name for the log statements */
		private var _context:String;
		
		/** Short name of the context. (Generated from the passed-in context) */
		private var _shortContext:String;
		
		/**
		 * Creates a new <code>Logger</code> Proxy.
		 *
		 * @param name Name of the logger
		 * @param person Name of the person that requested this logger
		 * @param context Name of the context in which this logger resides
		 */
		public function Logger(name:String, person:String=null, context:String=null) {
			_name = name;
			_shortName = _name.substr( _name.lastIndexOf(".")+1);
			_person = person;
			_context = context;
			if( _context != null ) {
				_shortContext = _context.substr( _context.lastIndexOf(".")+1);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function debug(message:*, parameter:*=null):void {
			if(debugTarget) {
				var msg: String;
				if(parameter != null || (message is String)) {
					msg = String(message);
				} else {
					msg = "{}";
					parameter = message;
				}
				debugTarget.log(_name, _shortName, 0x0020 /*DEBUG*/,
							getTimer(), msg, parameter, _person, _context, _shortContext);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function info(message:*, parameter:*=null):void {
			if(infoTarget) {
				var msg: String;
				if(parameter != null || (message is String)) {
					msg = String(message);
				} else {
					msg = "{}";
					parameter = message;
				}
				infoTarget.log(_name, _shortName, 0x0010 /*INFO*/,
							getTimer(), msg, parameter, _person, _context, _shortContext);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function warn(message:*, parameter:*=null):void {
			if(warnTarget) {
				var msg: String;
				if(parameter != null || (message is String)) {
					msg = String(message);
				} else {
					msg = "{}";
					parameter = message;
				}
				warnTarget.log(_name, _shortName, 0x0008 /*WARN*/,
						getTimer(), msg, parameter, _person, _context, _shortContext);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function error(message:*, parameter:*=null):void {
			if(errorTarget) {
				var msg: String;
				if(parameter != null || (message is String)) {
					msg = String(message);
				} else {
					msg = "{}";
					parameter = message;
				}
				errorTarget.log(_name, _shortName, 0x0004 /*ERROR*/,
							getTimer(), msg, parameter, _person, _context, _shortContext);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function fatal(message:*, parameter:*=null):void {
			if(fatalTarget) {
				var msg: String;
				if(parameter != null || (message is String)) {
					msg = String(message);
				} else {
					msg = "{}";
					parameter = message;
				}
				fatalTarget.log(_name, _shortName, 0x0002 /*FATAL*/,
							getTimer(), msg, parameter, _person, _context, _shortContext);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get debugEnabled():Boolean {
			return debugTarget != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get infoEnabled():Boolean {
			return infoTarget != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get warnEnabled():Boolean {
			return warnTarget != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get errorEnabled():Boolean {
			return errorTarget != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get fatalEnabled():Boolean {
			return fatalTarget != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return _name;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get shortName():String {
			return _shortName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get person():String {
			return _person;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get context(): String {
			return _context;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get shortContext(): String {
			return _shortContext;
		}
		
		/**
		 * Sets all loggers to the passed-in logTarget.
		 *
		 * @param logTarget target to be used for all levels
		 */
		public function set allTargets(logTarget: ILogTarget): void {
			debugTarget = infoTarget = warnTarget = errorTarget = fatalTarget = logTarget;
		}
		
		/**
		 * String representation of the Logger.
		 */
		public function toString(): String {
			return "[Logger name='" + _name + (_person!=null ? "@" + _person: "")
					+ (_context!=null ? " in " + _context : "") + "']";
		}
	}
}
