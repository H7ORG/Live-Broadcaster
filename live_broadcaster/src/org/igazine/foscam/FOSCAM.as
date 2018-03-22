package org.igazine.foscam {
	
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
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import org.igazine.events.IPCameraEvent;
	import org.igazine.media.cameras.CameraLoader;
	import org.igazine.media.cameras.IIPCamera;
	import org.igazine.media.cameras.CameraType;
	
	public class FOSCAM implements IIPCamera {
		
		public static const MODEL_FI9805W:String = "FI9805W";
		
		private const COMMAND_ROOT:String = "/cgi-bin/CGIProxy.fcgi";
		
		private var _dispatcher:EventDispatcher = new EventDispatcher();
		
		protected var snapshotLoader:Loader;
		protected var statusLoader:URLLoader;
		protected var devInfoLoader:URLLoader;
		protected var ipInfoLoader:URLLoader;
		
		protected var cameraType:String;
		protected var cameraUsername:String;
		protected var cameraPassword:String;
		protected var cameraAddress:String;
		protected var cameraPort:int;
		protected var cameraName:String;
		protected var cameraImageFlip:Boolean;
		protected var cameraImageMirror:Boolean;
		protected var cameraInfraRedMode:int;
		protected var cameraInfraRedState:int;
		
		public function FOSCAM() {			
		}
		
		//
		// Private functions
		//
		
		private function snapshotLoaded( e:Event ):void {
			
			//trace( 'snapshotLoaded', e.target.data as Bitmap );
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.SNAPSHOT );
			evt.snapshot = e.target.content as Bitmap;
			this.dispatchEvent( evt );

		}
		
		private function snapshotError( e:IOErrorEvent ):void {
			
			this.dispatchEvent( new IPCameraEvent( IPCameraEvent.SNAPSHOT_ERROR ) );
			
		}
		
		private function ipInfoLoaderComplete( e:Event ):void {
			
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.IP_INFO );
			this.dispatchEvent( evt );
			
		}
		
		private function ipInfoLoaderError( e:IOErrorEvent ):void {
			
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.IP_INFO_ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function devInfoLoaderComplete( e:Event ):void {
			
			var result:XML = new XML( e.target.data );
			trace( result );
			cameraName = String( result.devName );
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.DEV_INFO );
			this.dispatchEvent( evt );
			
		}
		
		private function devInfoLoaderError( e:IOErrorEvent ):void {
			
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.DEV_INFO_ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function statusLoaderComplete( e:Event ):void {
			
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.STATUS );
			this.dispatchEvent( evt );
			
		}
		
		private function statusLoaderError( e:IOErrorEvent ):void {
			
			var evt:IPCameraEvent = new IPCameraEvent( IPCameraEvent.STATUS_ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function ldrComplete( e:Event ):void {
			
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			processResult( e.target as CameraLoader );
			var evt:Event = new Event( Event.COMPLETE );
			this.dispatchEvent( evt );
			
		}
		
		private function ldrError( e:IOErrorEvent ):void {
			
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var evt:Event = new Event( Event.CANCEL );
			this.dispatchEvent( evt );
			
		}
		
		private function processResult( ldr:CameraLoader ):void {
			
			var xml:XML = XML( ldr.data );
			trace( xml );
			
			if ( int( xml.result ) == 0 ) {
				
				for ( var i:int = 0; i < xml.children().length(); i++ ) {
					
					trace( i, xml.children()[i], xml.children()[i].name() );
					
					if ( xml.children()[i].name() == "isMirror" ) cameraImageMirror = Boolean( int( xml.children()[i] ) );
					if ( xml.children()[i].name() == "isFlip" ) cameraImageFlip = Boolean( int( xml.children()[i] ) );
					if ( xml.children()[i].name() == "mode" ) {
						
						if ( ldr.action == CameraLoader.GET_INFRA_RED_CONFIG ) cameraInfraRedMode = int( xml.children()[i] );
						
					}
					if ( xml.children()[i].name() == "infraLedState" ) cameraInfraRedState = int( xml.children()[i] );
					
				}
				
				if ( ldr.action == CameraLoader.SET_INFRA_RED_CONFIG ) {
					getInfraRedConfig();
					getDevState();
				}
				
				if ( ldr.action == CameraLoader.OPEN_INFRA_RED ) {
					getDevState();
				}
				
				if ( ldr.action == CameraLoader.CLOSE_INFRA_RED ) {
					getDevState();
				}
				
			}
			
		}
		
		//
		// Public functions
		//
		
		public function getSnapshot():void {
			
			if ( !snapshotLoader ) {
				
				snapshotLoader = new Loader();
				snapshotLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, snapshotLoaded );
				snapshotLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, snapshotError );
				
			}
			
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "snapPicture2&usr=" + username + "&pwd=" + password;
			snapshotLoader.load( req );
			
		}
		
		public function getIPInfo():void {
			
			if ( !ipInfoLoader ) {
				
				ipInfoLoader = new URLLoader();
				ipInfoLoader.addEventListener( Event.COMPLETE, ipInfoLoaderComplete );
				ipInfoLoader.addEventListener( IOErrorEvent.IO_ERROR, ipInfoLoaderError );
				
			}
			
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getIPInfo&usr=" + username + "&pwd=" + password;
			ipInfoLoader.load( req );
			
		}
		
		public function getDevInfo():void {
			
			if ( !devInfoLoader ) {
				
				devInfoLoader = new URLLoader();
				devInfoLoader.addEventListener( Event.COMPLETE, devInfoLoaderComplete );
				devInfoLoader.addEventListener( IOErrorEvent.IO_ERROR, devInfoLoaderError );
				
			}
			
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getDevInfo&usr=" + username + "&pwd=" + password;
			devInfoLoader.load( req );
			
		}
		
		public function getStatus():void {
			
			if ( !statusLoader ) {
				
				statusLoader = new URLLoader();
				statusLoader.addEventListener( Event.COMPLETE, statusLoaderComplete );
				statusLoader.addEventListener( IOErrorEvent.IO_ERROR, statusLoaderError );
				
			}
			
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getDevInfo&usr=" + username + "&pwd=" + password;
			statusLoader.load( req );
			
		}
		
		public function getImageFlip():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.IMAGE_FLIP;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getMirrorAndFlipSetting&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function setImageFlip( flipped:Boolean ):void {
			
			this.dispatchEvent( new Event( Event.CONNECT ) );
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.IMAGE_FLIP;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "flipVideo&isFlip=" + String( int( flipped ) ) + "&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function getImageMirror():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.IMAGE_MIRROR;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getMirrorAndFlipSetting&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function setImageMirror( mirrored:Boolean ):void {
			
			this.dispatchEvent( new Event( Event.CONNECT ) );
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.IMAGE_MIRROR;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "mirrorVideo&isMirror=" + String( int( mirrored ) ) + "&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function getInfraRedConfig():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.GET_INFRA_RED_CONFIG;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getInfraLedConfig&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function setInfraRedConfig( mode:int ):void {
			
			this.dispatchEvent( new Event( Event.CONNECT ) );
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.SET_INFRA_RED_CONFIG;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "setInfraLedConfig&mode=" + String( mode ) + "&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function openInfraRed():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.OPEN_INFRA_RED;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "openInfraLed&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function closeInfraRed():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.CLOSE_INFRA_RED;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "closeInfraLed&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		public function getDevState():void {
			
			var ldr:CameraLoader = new CameraLoader();
			ldr.action = CameraLoader.DEV_STATE;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			var req:URLRequest = new URLRequest();
			req.url = commandAddress + "getDevState&usr=" + username + "&pwd=" + password;
			ldr.load( req );
			
		}
		
		//
		// Getters and setters
		//
		
		private function get commandAddress():String {
			
			return "http://" + cameraAddress + ":" + String( cameraPort ) + COMMAND_ROOT + "?cmd=";
			
		}
		
		public function get type():String {
			
			return CameraType.CAMERA_FOSCAM;
			
		}
		
		public function get username():String {
			
			return cameraUsername;
			
		}
		
		public function set username( s:String ):void {
			
			cameraUsername = s;
			
		}

		public function get password():String {
			
			return cameraPassword;
			
		}
		
		public function set password( s:String ):void {
			
			cameraPassword = s;
			
		}

		public function get address():String {
			
			return cameraAddress;
			
		}
		
		public function set address( s:String ):void {
			
			cameraAddress = s;
			
		}
		
		public function get streamAddress():String {
			
			return "rtsp://" + username + ":" + password + "@" + cameraAddress + ":" + cameraPort + "/videoMain";
			
		}
		
		public function set streamAddress( s:String ):void {	}
		
		public function get port():int {
			
			return cameraPort;
			
		}
		
		public function set port( i:int ):void {
			
			cameraPort = i;
			
		}
		
		public function get name():String {
			
			return cameraName;
			
		}
		
		public function get imageFlip():Boolean {
			
			return cameraImageFlip;
			
		}
		
		public function get imageMirror():Boolean {
			
			return cameraImageMirror;
			
		}
		
		public function get autoInfraRed():Boolean {
			
			return Boolean( cameraInfraRedMode == 0 );
			
		}
		
		public function get infraRed():Boolean {
			
			return Boolean( cameraInfraRedState );
			
		}
		
		public function get supportsAutoInfraRed():Boolean {
			
			return true;
			
		}
		
		public function get supportsInfraRed():Boolean {
			
			return true;
			
		}
		
		public function get supportsImageFlip():Boolean {
			
			return true;
			
		}
		
		public function get supportsImageMirror():Boolean {
			
			return true;
			
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