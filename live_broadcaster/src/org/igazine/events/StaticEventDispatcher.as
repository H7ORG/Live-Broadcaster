package org.igazine.events {
 
/**
 * 
 * Live Broadcaster
 * Live Streaming Software for Mac / Windows
 * Project Copyright (c) 2014 - 2017 Yatko (LLC) and Kalman Venczel
 * File/Lib Copyright (c) 2017 Tamas Sopronyi & Yatko (LLC)
 * Licensed under GNU General Public License v3.0, with Runtime Library Exception
 * This source file is part of the cameleon.live project - https://www.cameleon.live
 * 
 * See https://app.h7.org/cameleon/ for project information and documentation
 * See https://app.h7.org/cameleon/LICENSE.txt for license information
 * See https://app.h7.org/cameleon/CONTRIBUTORS.txt for list of project authors
 *  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * 
 */
 
/**
 * 
 * ActionScript file
 * Copyright (c) 2017 Tamas Sopronyi & Yatko (LLC)
 * Author: Tamas Sopronyi, 2017
 * 
 */
 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class StaticEventDispatcher {
		
		protected static var dispatcher:EventDispatcher;
		
		public function StaticEventDispatcher() {}
		
		private static function initDispatcher():void {
			
			if ( !dispatcher ) dispatcher = new EventDispatcher();
			
		}
		
		public static function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void {
			
			initDispatcher();
			dispatcher.addEventListener( type, listener, useCapture, priority );
			
		}
		
		public static function dispatchEvent( evt:Event ):Boolean {
			
			initDispatcher();
			return dispatcher.dispatchEvent( evt );
			
		}
		
		public static function hasEventListener( type:String ):Boolean {
			
			initDispatcher();
			return dispatcher.hasEventListener( type );
			
		}
		
		public static function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void {
			
			initDispatcher();
			dispatcher.removeEventListener( type, listener, useCapture );
			
		}
		
		public static function willTrigger( type:String ):Boolean {
			
			initDispatcher();
			return dispatcher.willTrigger( type );
			
		}
		
		public static function doSomething():void {
			
			dispatchEvent( new Event( Event.COMPLETE ) );
			
		}
		
	}

}