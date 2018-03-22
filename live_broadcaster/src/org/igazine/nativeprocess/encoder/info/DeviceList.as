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
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.system.Capabilities;
	import flash.events.Event;
	
	public class DeviceList extends EventDispatcher {
		
		private var executable:File;
		private var isMac:Boolean;
		private var args:Vector.<String>;
		private var process:NativeProcess;
		private var processInfo:NativeProcessStartupInfo;
		private var result:String;
		public var video:Array;
		public var audio:Array;
		
		public function DeviceList( exeFile:File ) {
			
			super();
			
			isMac = ( Capabilities.os.search( "Mac OS" ) >= 0 );
			executable = exeFile;
			
			process = new NativeProcess();
			process.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, processErrorData );
			process.addEventListener( NativeProcessExitEvent.EXIT, processExit );
			processInfo = new NativeProcessStartupInfo();
			processInfo.executable = executable;
			
		}
		
		public function dispose():void {
			
			process.removeEventListener( ProgressEvent.STANDARD_ERROR_DATA, processErrorData );
			process.removeEventListener( NativeProcessExitEvent.EXIT, processExit );
			process = null;
			processInfo = null;
			args = null;
			
		}
		
		public function run():void {
			
			video = new Array();
			audio = new Array();
			
			args = new Vector.<String>();
			args.push( "-hide_banner" );
			result = "";
			
			if ( isMac ) {
				
				args.push( "-list_devices" );
				args.push( "true" );
				args.push( "-f" );
				args.push( "avfoundation" );
				args.push( "-i" );
				args.push( '""' );
				
			} else {
				
				//ffmpeg -hide_banner -list_devices true -f dshow -i dummy
				args.push( "-list_devices" );
				args.push( "true" );
				args.push( "-f" );
				args.push( "dshow" );
				args.push( "-i" );
				args.push( "dummy" );
				
			}
			
			processInfo.arguments = args;
			process.start( processInfo );
			
		}
		
		private function processErrorData( e:ProgressEvent ):void {
			
			//trace( process.standardError.readUTFBytes( process.standardError.bytesAvailable ) );
			result += process.standardError.readUTFBytes( process.standardError.bytesAvailable );
			
		}
		
		private function processExit( e:NativeProcessExitEvent ):void {
			
			//trace( result );
			
			var pos:int;
			var deviceString:String;
			var newLine:String;
			newLine = "\n";
			
			var currentSection:int = -1;
			
			var a:Array = result.split( newLine );
			
			for ( var i:int = 0; i < a.length; i++ ) {
				
				if ( String( a[i] ).search( "dshow" ) >= 0 ) {
					
					var dshowVideo:String = "DirectShow video devices";
					var dshowAudio:String = "DirectShow audio devices";
					var dshowValid:RegExp = /(\[dshow)(.+)(\s{2})\"(.+)\"/g;
					
					if ( a[i].search( dshowVideo ) >= 0 ) currentSection = 0;
					if ( a[i].search( dshowAudio ) >= 0 ) currentSection = 1;
					
					pos = a[i].search( dshowValid );
					
					if ( pos >= 0 ) {
						
						deviceString = a[i].split( '"' )[1];
						//trace( deviceString );
						
						if ( currentSection == 0 ) video.push( deviceString );
						if ( currentSection == 1 ) audio.push( deviceString );
						
					}
					
				}
				
				if ( String( a[i] ).search( "AVFoundation" ) >= 0 ) {
					
					var avfVideo:String = "AVFoundation video devices";
					var avfAudio:String = "AVFoundation audio devices";
					var avfValid:RegExp = /(\[AVFoundation)(.+)(\s{1})(\[.\]\s{1})/g;
					
					if ( a[i].search( avfVideo ) >= 0 ) currentSection = 0;
					if ( a[i].search( avfAudio ) >= 0 ) currentSection = 1;
					
					pos = a[i].search( avfValid );
					
					if ( pos >= 0 ) {
						
						//trace( "split", a[i].split( avfValid ) );
						deviceString = a[i].split( avfValid )[5];
						//trace( deviceString );
						
						if ( currentSection == 0 ) {
							
							//if ( deviceString.search( "Capture screen" ) < 0 ) video.push( deviceString );
							video.push( deviceString );
							
						}
						if ( currentSection == 1 ) audio.push( deviceString );
						
					}
					
				}
				
			}
			
			// Removing Capture Device 0 from OSX video device list
			if ( isMac && ( video.length > 0 ) ) video.pop();
			
			this.dispatchEvent( new Event( Event.COMPLETE ) );
			
		}
		
		public function get xml():XML {
			
			var xxx:XML = new XML( "<devices />" );
			var i:int;
			
			for ( i = 0; i < video.length; i++ ) {
				
				xxx.appendChild( new XML( "<video type='0'>" + video[i] + "</video>" ) );
				
			}
			
			for ( i = 0; i < audio.length; i++ ) {
				
				xxx.appendChild( new XML( "<audio type='10'>" + audio[i] + "</audio>" ) );
				
			}
			
			return xxx;
			
		}
		
	}

}