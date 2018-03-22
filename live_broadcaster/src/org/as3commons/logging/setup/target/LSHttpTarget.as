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
	
	import org.as3commons.logging.util.objectifyLimited;
	import org.as3commons.logging.util.extractPaths;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.util.START_TIME_UTC;
	import org.as3commons.logging.util.jsonXify;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * <code>LSHttpTarget</code> sends http requests to the <code>LS</code> server.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 3.0 
	 */
	public class LSHttpTarget extends AbstractHttpTarget implements ILogTarget {
		
		private static const logger:ILogger=getLogger(LSHttpTarget);
		private var _id:String;
		private var _initHeader:Array=[new URLRequestHeader("protocol-version", "1")];
		private var _header:Array;
		private var _url:String;
		private var _no:int=0;
		private var _waiting:Boolean=false;
		
		private var _indexMap:Object = {};
		private var _indexCnt:int = 1;
		
		// Index to be added to the request
		private var _index:String = "";
		private var _indexBuffer:Array = [];
		private var _indexBufferPos:int = -1;
		
		// Body for the next request
		private var _body:String = "";
		private var _bodyBuffer:Array = [];
		private var _bodyBufferPos:int = -1;
		
		private var _maxDepth: int;
		
		/**
		 * 
		 * 
		 * @param application Application to which the log should be registered
		 * @param applicationPart Part of the application that is running now
		 * @param url Server url where the LS server can be found
		 * @param checkInterval Interval in ms that should be used to send out requests
		 * @param maxDepth maximum depth used to introspect submitted content objects
		 */
		public function LSHttpTarget(application: String, applicationPart:String,
									 url:String, checkInterval:uint = 10000,
									 maxDepth: int = 5) {
			_url = url;
			_checkInterval.delay = checkInterval;
			_initHeader.push(new URLRequestHeader("applicationPart", applicationPart));
			_initHeader.push(new URLRequestHeader("application", application));
			_maxDepth = maxDepth;
		}

		private static const INT_MAP:Object={};

		protected static function mapInt(i:int):String {
			var num:String=i.toString(16);
			while ( num.length < 8 ) {
				num = "0" + num;
			}
			INT_MAP[i] = num;
			return num;
		}
		
		override protected function handleFatal():void {
			_id = null;
		}
		
		/**
		 * Needs first submission to 
		 */
		override protected function submit(event:Event=null):void {
			if ( !_id ) {
				// Max 1 request if no id is defined!
				if ( !_waiting ) {
					logger.info("Initial request - waiting for logging id.");
					super.submit(event);
					_waiting = true;
				}
			} else {
				// We have an ID! so lets request as much as we like!
				super.submit(event);
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function log(name:String, shortName:String, level:int,
									 timeStamp:Number, message:String, parameter:*,
									 person:String, context:String, shortContext:String):void {
			// Don't log own output
			if( name != logger.name || person != logger.person ) {
				super.log(name, shortName, level, timeStamp, message, parameter,
							person, context, shortContext);
			}
		}
		
		override protected function doLog(name:String, shortName:String, level:int,
									 timeStamp:Number, message:String, parameters:*,
									 person:String, context:String, shortContext:String):void {
			// If strings are put into an array they do not get reallocated
			// this effectively consumes less memory and is faster than
			// using a bytearray or string concatination
			
			// Evaluate the indices in the index table
			var nameIndex: int = 0;
			if( name != null ) {
				nameIndex = _indexMap[name];
				if( !nameIndex ) {
					nameIndex = _indexMap[name] = ++_indexCnt;
					_indexBuffer[++_indexBufferPos] = name.length.toString(36);
					_indexBuffer[++_indexBufferPos] = name;
				}
			}
			var personIndex: int = 0;
			if( person != null ) {
				personIndex = _indexMap[person];
				if( !personIndex ) {
					personIndex = _indexMap[person] = ++_indexCnt;
					_indexBuffer[++_indexBufferPos] = person.length.toString(36);
					_indexBuffer[++_indexBufferPos] = person;
				}
			}
			var messageIndex: int = 0;
			if( message!=null ) {
				messageIndex = _indexMap[message];
				if( !messageIndex ) {
					messageIndex = _indexMap[message] = ++_indexCnt;
					_indexBuffer[++_indexBufferPos] = message.length.toString(36);
					_indexBuffer[++_indexBufferPos] = message;
				}
			}
			var contextIndex: int = 0;
			if( context!=null ) {
				contextIndex = _indexMap[context];
				if( !contextIndex ) {
					contextIndex = _indexMap[context] = ++_indexCnt;
					_indexBuffer[++_indexBufferPos] = context.length.toString(36);
					_indexBuffer[++_indexBufferPos] = context;
				}
			}
			_bodyBuffer[++_bodyBufferPos] = level.toString(36);
			_bodyBuffer[++_bodyBufferPos] = (++_no).toString(36);
			_bodyBuffer[++_bodyBufferPos] = nameIndex.toString(36);
			_bodyBuffer[++_bodyBufferPos] = personIndex.toString(36);
			_bodyBuffer[++_bodyBufferPos] = messageIndex.toString(36);
			_bodyBuffer[++_bodyBufferPos] = (START_TIME_UTC + timeStamp).toString(36);
			if(parameters) {
				var parametersAsString:String = jsonXify(
					objectifyLimited(parameters, extractPaths(message), _maxDepth),
					int.MAX_VALUE);
				_bodyBuffer[++_bodyBufferPos] = parametersAsString.length.toString(36);
				_bodyBuffer[++_bodyBufferPos] = parametersAsString;
			} else {
				_bodyBuffer[++_bodyBufferPos] = "0;";
			}
			// Arrays can only .join up to 32768 elements, to not
			// exceed that amount its preliminarily concatinated
			// Have to remove 10 statements as they might be added
			if( _bodyBufferPos > 32758 ) { 
				_body += _bodyBuffer.join(";");
				_bodyBuffer = [];
				_bodyBufferPos = -1;
			}
			// Have to remove 3 statements as they might be added
			if( _indexBufferPos > 32764 ) {
				_index += _indexBuffer.join(";");
				_indexBuffer = [];
				_indexBufferPos = -1;
			}
			trySubmit();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onComplete(event:Event):void {
			var loader:URLLoader=event.target as URLLoader;
			var id:String=loader.data;
			if( _id != id ) {
				_id = id;
				logger.info("Using new logging-session id: {0}", [id]);
				_header = [new URLRequestHeader("lsid", id)];
			}
			super.onComplete(event);
		}

		/**
		 * Creates a <code>LS</code> compatible request.
		 * 
		 * @param maxStatements Amount of statements that should be passed
		 * @return URL Request associated to the statements.
		 */
		override protected function createRequest():URLRequest {
			var request:URLRequest=new URLRequest(_url);
			request.requestHeaders = _header ? _header : _initHeader;

			if ( _bodyBufferPos >= 0 ) {
				_body += _bodyBuffer.join(";");
				_bodyBuffer = [];
				_bodyBufferPos = -1;
			}
			if( _indexBufferPos >= 0 ) {
				_index += _indexBuffer.join(";");
				_indexBuffer = [];
				_indexBufferPos = -1;
			}
			var vars:URLVariables=new URLVariables();
			
			vars["s"] = _body;
			_body = "";
			
			vars["i"] = _index;
			_index = "";
			_indexCnt = -1;
			_indexMap = {};
			
			request.data = vars;
			request.method = URLRequestMethod.POST;

			return request;
		}
	}
}
