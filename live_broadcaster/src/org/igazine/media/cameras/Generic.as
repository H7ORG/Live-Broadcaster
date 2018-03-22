package org.igazine.media.cameras {
	
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
	import org.igazine.events.IPCameraEvent;
	
	public class Generic implements IIPCamera {
		
		private var _dispatcher:EventDispatcher = new EventDispatcher();
		private var _type:String = CameraType.GENERIC;
		private var _username:String;
		private var _password:String;
		private var _address:String;
		private var _port:int;
		private var _name:String;
		private var _streamAddress:String;
		private var _imageFlip:Boolean;
		private var _imageMirror:Boolean;
		
		public function Generic() {
			
		}
		
		/* INTERFACE org.igazine.media.cameras.IIPCamera */
		
		public function getSnapshot():void {
			
		}
		
		public function getIPInfo():void {
			
		}
		
		public function getDevInfo():void {
			_name = "Generic IP Camera";
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.DEV_INFO );
			this.dispatchEvent( evt );
		}
		
		public function getDevState():void {}
		
		public function getStatus():void {}
		
		public function getImageFlip():void {}
		
		public function setImageFlip( flipped:Boolean ):void {}
		
		public function getImageMirror():void {}
		
		public function setImageMirror( mirrored:Boolean ):void {}
		
		public function getInfraRedConfig():void {}
		
		public function setInfraRedConfig( mode:int ):void { }
		
		public function openInfraRed():void { }
		
		public function closeInfraRed():void {}
		
		public function get type():String {
			return _type;
		}
		
		public function get username():String {
			return _username;
		}
		
		public function set username(value:String):void {
			_username = value;
		}
		
		public function get password():String {
			return _password;
		}
		
		public function set password(value:String):void {
			_password = value;
		}
		
		public function get address():String {
			return _address;
		}
		
		public function set address(value:String):void {
			_address = value;
		}
		
		public function get streamAddress():String {
			return _streamAddress;
		}
		
		public function set streamAddress( s:String ):void {
			_streamAddress = s;
		}
		
		public function get port():int {
			return _port;
		}
		
		public function set port(value:int):void {
			_port = value;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get imageFlip():Boolean {
			return _imageFlip;
		}
		
		public function get imageMirror():Boolean {
			return _imageMirror;
		}
		
		public function get autoInfraRed():Boolean {
			return false;
		}
		
		public function get infraRed():Boolean {
			return false;
		}
		
		public function get supportsAutoInfraRed():Boolean {
			return false;
		}
		
		public function get supportsInfraRed():Boolean {
			return false;
		}
		
		public function get supportsImageFlip():Boolean {
			return false;
		}
		
		public function get supportsImageMirror():Boolean {
			return false;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener( type, listener, useCapture );
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return _dispatcher.dispatchEvent( event );
		}
		
		public function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener( type );
		}
		
		public function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger( type );
		}
		
	}

}