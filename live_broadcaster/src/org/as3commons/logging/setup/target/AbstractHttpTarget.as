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
	
	import flash.events.ErrorEvent;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class AbstractHttpTarget {
		
		private static const logger: ILogger = getLogger(AbstractHttpTarget);
		
		protected const _checkInterval: Timer = new Timer(1000);
		protected const _freeLoaderPool: Array = [];
		
		private var _freeRequestPool:Array = [];
		private var _infoRegistry:Dictionary = new Dictionary();
		private var _broken:Boolean;
		
		public function AbstractHttpTarget() {
			_checkInterval.addEventListener(TimerEvent.TIMER, submit);
		}

		/**
		 * Tries to send the log to the server
		 *
		 * @param event Event, just for coding comfort.
		 * @param maxRequests Maximum amount of request to be pushed in one try (0 = use the general default)
		 * @param maxStatements Maximum amount of statements used in one request (0 = use the general default)
		 * @return true if some requests where sent to the server, false if not
		 */
		protected function submit(event:Event = null):void {
			var loader: URLLoader = _freeLoaderPool.shift() || createLoader();
			var info: URLRequestInfo = _freeRequestPool.shift() || new URLRequestInfo();
			info.request = createRequest();
			info.tries = 1;
			_infoRegistry[loader] = info;
			loader.load(info.request);
		}
		
		private function createLoader():URLLoader {
			var loader: URLLoader = new URLLoader();
			loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHttpStatus, false, 0, true );
			loader.addEventListener( Event.COMPLETE, onComplete, false, 0, true );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onError, false, 0, true );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,onError, false, 0, true );
			return loader;
		}
		
		private function onHttpStatus(event:HTTPStatusEvent):void {
			if(event.status >= 300) {
				handleError("Http-status-error "+event.status, event.target as URLLoader);
			}
		}
		
		public function log(name:String, shortName:String, level:int,
									 timeStamp:Number, message:String, parameters:*,
									 person:String, context:String, shortContext:String):void {
			if(_broken || (name != logger.name || person != logger.person)) {
				doLog(name, shortName, level, timeStamp, message, parameters, person,
						context, shortContext);
			}
		}
		
		protected function doLog(name:String, shortName:String, level:int,
									 timeStamp:Number, message:String, parameters:*,
									 person:String, context:String, shortContext:String):void  {
			throw new Error("abstract");
		}
		
		private function handleError(message:String, loader:URLLoader):void {
			var info: URLRequestInfo = _infoRegistry[loader];
			if( info.tries == 3 ) {
				logger.fatal("Logging didn't work even after 3rd time trying.");
				handleFatal();
			} else {
				if(logger.infoEnabled) {
					logger.info("Attempt #{0} to send out a logging request: {1}", [info.tries, message]);
				}
				loader.load(info.request);
				info.tries++;
			}
		}
		
		protected function handleFatal():void {
			throw new Error("abstract");
		}
		
		protected function onComplete(event:Event):void {
			_freeLoaderPool.push(event.target as URLLoader);
		}

		protected function onError(event:ErrorEvent):void {
			handleError(event.text, event.target as URLLoader);
		}

		protected function createRequest():URLRequest {
			throw new Error("abstract");
		}

		protected function trySubmit():void {
			if(_checkInterval.delay == 0) {
				submit();
			} else if(!_checkInterval.running) {
				_checkInterval.start();
			}
		}
	}
}
