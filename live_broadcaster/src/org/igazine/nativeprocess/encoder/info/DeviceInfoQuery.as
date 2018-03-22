package org.igazine.nativeprocess.encoder.info {
	
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
	import flash.events.IEventDispatcher;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import flash.filesystem.File;
	
	public class DeviceInfoQuery extends EventDispatcher {
		
		private var process:NativeProcess;
		private var processInfo:NativeProcessStartupInfo;
		private var args:Vector.<String> = new Vector.<String>;
		private var executable:File;
		private var result:String;
		private var deviceInfo:DeviceInfo;
		
		public var deviceInfoList:Vector.<DeviceInfo> = new Vector.<DeviceInfo>();
		
		public function DeviceInfoQuery( executable:File ) {
			
			super( );
			
			process = new NativeProcess();
			process.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, processErrorData );
			process.addEventListener( NativeProcessExitEvent.EXIT, processExit );
			processInfo = new NativeProcessStartupInfo();
			executable = executable;
			processInfo.executable = executable;
			
		}
		
		public function queryVideoDevice( deviceName:String ):void {
			
			result = "";
			args = new Vector.<String>;
			args.push( "-hide_banner" );
			
			if ( FFMPEG.isMac ) {
				
				args.push( "-f", "avfoundation" );
				args.push( "-s", "1x1" );
				args.push( "-i", deviceName + ':none' );
				
			} else {
				
				args.push( "-list_options" );
				args.push( "true" );
				args.push( "-f" );
				args.push( "dshow" );
				args.push( "-i" );
				args.push( "video=" + deviceName );
				
			}
			
			processInfo.arguments = args;
			process.start( processInfo );
			
		}
		
		private function processErrorData( e:ProgressEvent ):void {
			
			//trace( process.standardError.readUTFBytes( process.standardError.bytesAvailable ) );
			result += process.standardError.readUTFBytes( process.standardError.bytesAvailable );
			
			//var di:DeviceInfo = DeviceInfoFactory.create( s );
			//trace( '-------------------------', di.entries.length );
			//di.getNearestEntry( 1280, 720, 25 );
			
		}
		
		private function processExit( e:NativeProcessExitEvent ):void {
			
			//result = "[avfoundation @ 0x7ff19b800e00] Selected video size (1x1) is not supported by the device\n[avfoundation @ 0x7ff19b800e00] Supported modes:\n[avfoundation @ 0x7ff19b800e00]   160x120@[60.000240 60.000240]fps\n[avfoundation @ 0x7ff19b800e00]   160x120@[30.000030 30.000030]fps\n[avfoundation @ 0x7ff19b800e00]   160x120@[25.000000 25.000000]fps";
			result = result.replace(/\r\n/g, "\n");
			
			/*
			//Tracer.echo( "--------", result.split( /(\[avfoundation)(.+)(\s{3})/gm ) );
			var rx:RegExp = /(\[avfoundation)(.+)(\s{3})/gm;
			//rx = /\[avfoundation/g;
			
			//result = result.replace( /\s/g, "|" );
			result = result.replace( rx, "" );
			
			Tracer.echo( result );
			//Tracer.echo( "--------", result.split( rx ) );
			*/
			
			deviceInfo = DeviceInfoFactory.create( result );
			//trace( '-------------------------', deviceInfo.entries.length );
			this.dispatchEvent( new Event( Event.COMPLETE ) );
			
		}
		
		public function get xml():XML {
			
			var x:XML = new XML( "<root />" );
			
			for ( var i:int = 0; i < deviceInfo.entries.length; i++ ) {
				
				/*
				if ( deviceInfo.entries[i].vCodec == "rawvideo" ) {
					x.appendChild( deviceInfo.entries[i].xml );
				} else if ( String( deviceInfo.entries[i].vCodec ).toLowerCase() == "h264" ) {
					x.appendChild( deviceInfo.entries[i].xml );
				}
				*/
				
				x.appendChild( deviceInfo.entries[i].xml );
				
			}
			
			return x;
			
		}
		
		public function dispose():void {
			
			if ( process ) {
				
				if ( process.running ) process.exit( true );
				process.removeEventListener( ProgressEvent.STANDARD_ERROR_DATA, processErrorData );
				process.removeEventListener( NativeProcessExitEvent.EXIT, processExit );
				process = null;
				
			}
			
			processInfo = null;
			args = null;
			executable = null;
			result = null;
			deviceInfo.dispose();
			deviceInfo = null;
			
		}
		
	}

}