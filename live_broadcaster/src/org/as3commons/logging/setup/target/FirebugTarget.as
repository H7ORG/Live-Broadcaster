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
package org.as3commons.logging.setup.target {
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.util.objectify;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	/**
	 * <code>FirebugTarget</code> sends the output to the Firebug console. Also
	 * works with Google Chrome and others.
	 * 
	 * <p>The <code>FirebugTarget</code> will send a warning to the logging system in case
	 * logging to a console is not available.</p>
	 * 
	 * @see http://getfirebug.com/
	 * @author Martin Heidegger
	 * @version 1.5
	 * @since 2.5
	 */
	public final class FirebugTarget implements IFormattingLogTarget {
		
		/** Default format used if non is passed in */
		public static const DEFAULT_FORMAT: String = "{time} {shortName}{atPerson} {message}";
		
		/** Logger used to notify if Firebug doesn't work */
		private static const LOGGER: ILogger = getLogger(FirebugTarget);
		
		/** True if the external interface was inited */
		private static var _inited: Boolean = false;
		
		/** Regular expression used to transform the value */
		private static const _fieldRegexp: RegExp = /{(([\w_]+\.?)*)}/ig;
		
		/** True if the console is available */
		private static var _available:Boolean = true;
		
		/**
		 * Inits the External Interface
		 */
		private static function init(): void {
			_inited = true;
			if( _available = ExternalInterface.available ) {
				try {
					if( !ExternalInterface.call('function(){ return console ? true : false; }') ) {
						LOGGER.warn("No native console found in this browser.");
						_available = false;
					}
				} catch( e:Error ) {
					LOGGER.warn("Could not setup FirebugTarget, exception while setup {0}", [e]);
					_available = false;
				}
			} else {
				LOGGER.warn("Could not setup FirebugTarget, because ExternalInterface wasn't available");
			}
		}
		
		/** Formatter used to format the message */
		private var _formatter: LogMessageFormatter;
		
		/** Depth of the introspection for objects */
		private var _depth: uint = 5;
		
		private var _params:Array;
		private var _value:*;
		private var _valuePair:Object;
		private var _typePair:Object;
		private var _types: Dictionary;
		private var _cnt:int;
		
		/**
		 * Creates new <code>FirebugTarget</code>
		 * 
		 * @param format Format to be used 
		 */
		public function FirebugTarget( format:String=null ) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			_formatter = new LogMessageFormatter( format||DEFAULT_FORMAT );
		}
		
		/**
		 * Maximum depth of introspection for objects to be rendered (default=5)
		 */
		public function set depth( depth:uint ): void {
			_depth = depth;
		}
		
		public function get depth():uint {
			return _depth;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String):void {
			if( !_inited ) {
				init();
			}
			if( _available ) {
				// Select the matching method
				var method: String;
				if( level == DEBUG ) method = "console.debug";
				else if( level == WARN ) method = "console.warn";
				else if( level == INFO ) method = "console.info";
				else method = "console.error";
				
				// Modify the input to pass it properly to firefox
				//   
				//   as3commons pattern:  "some text {0} other text {abc} and {0}", {0:a, abc:b}
				//   firebug pattern: "some text %o other text %o and %o", a, b, a
				//
				_params = [method, null];
				_value = parameters;
				_cnt = 1;
				
				// This might fill the _params array!
				message = message.replace(_fieldRegexp, replaceMessageEntries);
				
				_params[1] = _formatter.format( name, shortName, level, timeStamp, 
					message, null, person, context, shortContext).split("\\").join("\\\\");
				
				try {
					// Send it out!
					ExternalInterface.call.apply( ExternalInterface, _params );
				} catch( e: Error ) {}
				
				_params = null;
				_value = null;
				_valuePair = null;
				_typePair = null;
			}
		}
		
		/**
		 * Replaces the messages in the string and fills the new Array with the necessary
		 * new parameters.
		 */
		private function replaceMessageEntries(encapsulated: String,  field: String,
											   no: int, len: int, intext: String):String {
			var d: String;
			var type: String = (_typePair ||= {})[field];
			var value: *;
			if( !type ) {
				type = "?";
				value = _value;
				if( field != "" ) {
					
					var start: int = 0;
					var end: int;
					while( value != null ) {
						end = field.indexOf(".", start);
						if( end == -1 ) {
							try {
								value = value[d];
							} catch( e: * ) {
								value = e;
							}
						} else {
							d = field.substring(start, end);
							start = end+1;
							try {
								value = value[d];
							} catch( e: * ) {
								value = e;
								break;
							}
						}
					}
				}
				if( value is uint ) {
					type = "%i";
				} else if( value is Number ) {
					type = "%f";
				} else if( value is String ) {
					type = "%s";
					value = String( value ).split("\\").join("\\\\");
				} else if( value is Object ) {
					type = "%o";
					try {
						value = objectify( value, _types || (_types = new Dictionary()), _depth );
					} catch( e: Error ) {
						value = objectify( e );
					}
				}
				_typePair[field] = type;
				(_valuePair ||= {})[field] = value;
			} else {
				value = _valuePair[field];
			}
			if( type != "?" ) {
				_params[ ++_cnt ] = value;
			}
			return type;
		}
	}
}