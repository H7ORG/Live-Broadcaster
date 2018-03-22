package org.igazine.managers {
	
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
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import org.igazine.nativeprocess.events.FFMPEGEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class FFMPEGManager {
		
		
		private static var processes:Vector.<FFMPEG> = new Vector.<FFMPEG>;
		
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		public static var bwIn:Number = 0;
		public static var bwOut:Number = 0;
		
		public function FFMPEGManager() { }
		
		public static function addProcess( p:FFMPEG ):void {
			
			processes.push( p );
			p.addEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegErrorOutput );
			checkProcesses();
			dispatcher.dispatchEvent( new Event( Event.CHANGE ) );
			
		}
		
		private static function ffmpegErrorOutput( e:FFMPEGEvent ):void {
			
			//trace( "[", e.target.uid, "]", ":", e.data );
			var evt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.ERROR_OUTPUT );
			evt.data = "[" + e.target.uid + "] : " + e.data;
			dispatcher.dispatchEvent( evt );
			
		}
		
		private static function checkProcesses():void {
			
		}
		
		private static function startLog():void {
		}
		
		private static function stopLog():void {
		}
		
		public static function getProcess( uid:String ):FFMPEG {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].uid == uid ) return processes[i];
				
			}
			
			return null;
			
		}
		
		public static function getProcessByUID( uid:String ):FFMPEG {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].uid == uid ) return processes[i];
				
			}
			
			return null;
			
		}
		
		public static function getProcessByCameraID( cameraID:String ):FFMPEG {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].cameraId == cameraID ) return processes[i];
				
			}
			
			return null;
			
		}
		
		public static function removeProcess( p:FFMPEG ):void {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].uid == p.uid ) {
					
					processes[i].removeEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegErrorOutput );
					processes.splice( i, 1 );
					dispatcher.dispatchEvent( new Event( Event.CHANGE ) );
					break;
					
				}
				
			}
			
			checkProcesses();
			
		}
		
		public static function hasProcess( p:FFMPEG ):Boolean {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].uid == p.uid ) return true;
					
			}
			
			return false;
			
		}
		
		public static function get length():int {
			
			return processes.length;
			
		}
		
		public static function stopAll():void {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				processes[i].removeEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegErrorOutput );
				processes[i].stop();
				
			}
			
		}
		
		public static function stopAllByCameraID( cameraID:String ):void {
			
			for ( var i:int = 0; i < processes.length; i++ ) {
				
				if ( processes[i].cameraId == cameraID ) {
				
					processes[i].removeEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegErrorOutput );
					processes[i].stop();
					
				}
				
			}
			
		}
		
	}

}