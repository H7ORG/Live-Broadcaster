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

package org.igazine.nativeprocess.encoder.outputs {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import org.igazine.nativeprocess.encoder.codecs.AudioCodec;
	import org.igazine.nativeprocess.encoder.codecs.VCodec;
	import org.igazine.nativeprocess.encoder.destinations.DPipe;
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import org.igazine.nativeprocess.encoder.parameters.IParameterSet;
	import flash.events.ProgressEvent;
	import org.igazine.nativeprocess.events.FFMPEGEvent;
	import flash.net.NetStreamAppendBytesAction;
	
	public class FOutput extends EventDispatcher implements IParameterSet {
		
		public static const PRESET_ULTRAFAST:String = "ultrafast";
		public static const PRESET_SUPERFAST:String = "superfast";
		public static const PRESET_VERYFAST:String = "veryfast";
		public static const PRESET_FASTER:String = "faster";
		public static const PRESET_FAST:String = "fast";
		public static const PRESET_MEDIUM:String = "medium";
		public static const PRESET_SLOW:String = "slow";
		public static const PRESET_SLOWER:String = "slower";
		public static const PRESET_VERYSLOW:String = "veryslow";
		
		public static const FORMAT_FLV:String = "flv";
		public static const FORMAT_F4V:String = "f4v";
		public static const FORMAT_LIVE_FLV:String = "live_flv";
		public static const FORMAT_TEE:String = "tee";
		public static const FORMAT_HLS:String = "hls";
		public static const FORMAT_SEGMENT:String = "segment";
		
		public static var minimumRequiredHeaderFrames:int = 1;
		public static var flvHeaderSize:int = 317;
		
		public var videoCodec:VCodec;
		public var audioCodec:AudioCodec;
		public var preset:String;
		public var frameRate:int;
		public var gop:int;
		public var keyFrames:int;
		public var format:String;
		public var destinations:Array = new Array();
		public var pipeFormat:String = FOutput.FORMAT_FLV;
		public var inputVideoSource:int;
		public var inputVideoStream:int;
		public var inputAudioSource:int;
		public var inputAudioStream:int;
		public var snapshot:Boolean;
		public var snapshotPath:String;
		public var copyTimeBase:Boolean;
		public var copyTimeStamp:Boolean;
		public var startAtZero:Boolean;
		public var width:int;
		public var height:int;
		public var zeroLatency:Boolean;
		public var scaleX:int;
		public var scaleY:int;
		
		protected var isPiped:Boolean;
		protected var encoderInstance:FFMPEG;
		protected var pipe:DPipe;
		protected var ns:NetStream;
		protected var nc:NetConnection;
		protected var st:SoundTransform;
		protected var metaData:Object;
		protected var netStreamReceivePipeData:Boolean;
		protected var numBytesSent:int = 0;
		protected var minNumBytesSent:int = 128000;
		protected var dataStreamBytesInternal:ByteArray;
		protected var initialBytesInternal:ByteArray;
		protected var flvHeaderBytesInternal:ByteArray;
		
		public function FOutput( ) {
			
			videoCodec = new VCodec();
			nc = new NetConnection();
			nc.connect( null );
			st = new SoundTransform( 0 );
			ns = new NetStream( nc );
			ns.bufferTime = 1;
			ns.client = this;
			ns.soundTransform = st;
			//ns.addEventListener( NetStatusEvent.NET_STATUS, nsStatus );
			ns.play( null );
			
		}
		
		private function nsStatus( e:NetStatusEvent ):void {
			
			//trace( '-------------------------------------------------------------', ns, e.info.code, ns.audioReliable, ns.bufferLength, ns.bufferTime, ns.bytesTotal );
			trace( ns, e.info.code );
			
		}
		
		/* INTERFACE org.igazine.nativeprocess.encoder.parameters.IParameterSet */
		
		public function get parameters():Vector.<String> {
			
			var p:Vector.<String> = new Vector.<String>();
			
			p = p.concat( videoCodec.parameters );
			
			if ( width && height ) {
				
				//p.push( "-vf", "scale=" + String( width ) + ":" + String( height ) );
				//p.push( "-s", String( width ) + "x" + String( height ) );
				
				if ( height != 0 ) p.push( "-vf", "scale=" + String( width ) + ":" + String( height ) );
				
			}
			
			if ( ( scaleX != 0 ) && ( scaleY != 0 ) ) {
				
				p.push( "-vf", "scale=" + String( scaleX ) + ":" + String( scaleY ) );
				
			}
			
			if ( audioCodec ) p = p.concat( audioCodec.parameters );
			if ( preset ) p.push( "-preset", preset );
			if ( frameRate ) p.push( "-r", String( frameRate ) );
			if ( gop ) p.push( "-g", String( gop ) );
			if ( keyFrames ) p.push( "-force_key_frames", String( keyFrames ) );
			if ( copyTimeBase ) p.push( "-copytb", "1" );
			if ( startAtZero ) p.push( "-start_at_zero" );
			if ( copyTimeStamp ) p.push( "-copyts" );
			if ( metaData ) {
				
				for ( var data:String in metaData ) p.push( "-metadata", data + "=" + metaData[data] );
				
			}
			
			if ( zeroLatency ) p.push( "-tune", "zerolatency" );
			
			p.push( "-map", String( inputVideoSource ) + ":" + String( inputVideoStream ) );
			if ( audioCodec && ( inputAudioSource != -1 ) ) p.push( "-map", String( inputAudioSource ) + ":" + String( inputAudioStream ) );
			
			p.push( "-f", format );
			
			if ( isPiped ) p.push( "pipe:1" );
			
			if ( snapshot ) {
				
				p.push( "-f", "image2", "-r",  "1/60", "-updatefirst", "1", snapshotPath );
				
			}
			
			return p;
			
		}
		
		protected function addListeners():void {
			
			if ( encoderInstance ) {
				
				if ( isPiped ) encoderInstance.addEventListener( FFMPEGEvent.DATA_AVAILABLE, encoderOutputData );
				encoderInstance.addEventListener( FFMPEGEvent.STDOUT_START, stdoutStart );
				encoderInstance.addEventListener( FFMPEGEvent.STDOUT_STOP, stdoutStop );
				
			}
			
		}
		
		protected function removeListeners():void {
			
			if ( encoderInstance ) {
				
				encoderInstance.removeEventListener( FFMPEGEvent.DATA_AVAILABLE, encoderOutputData );
				encoderInstance.removeEventListener( FFMPEGEvent.STDOUT_START, stdoutStart );
				encoderInstance.removeEventListener( FFMPEGEvent.STDOUT_STOP, stdoutStop );
				
			}
			
		}
		
		public function set dataBytes( value:ByteArray ):void {
			
			dataStreamBytesInternal = value;
			
		}
		
		public function set initialBytes( value:ByteArray ):void {
			
			initialBytesInternal = value;
			
		}
		
		public function set flvHeaderBytes( value:ByteArray ):void {
			
			flvHeaderBytesInternal = value;
			
		}
		
		protected function encoderOutputData( e:Event ):void {
			
			dataStreamBytesInternal.clear();
			encoderInstance.readDataBytes( dataStreamBytesInternal );
			//trace( '\tFOutput.dataStreamBytesInternal.length', dataStreamBytesInternal.length );
			
			if ( ns ) {
				
				if ( ns.decodedFrames < minimumRequiredHeaderFrames ) {
					
					ns.appendBytes( dataStreamBytesInternal );
					initialBytesInternal.writeBytes( dataStreamBytesInternal );
					
				} else {
				
					initialBytesInternal.position = 0;
					initialBytesInternal.readBytes( flvHeaderBytesInternal, 0, flvHeaderSize );
					trace( "FOutput.flvHeaderBytesInternal", flvHeaderBytesInternal.length, flvHeaderSize );
					this.dispatchEvent( new Event( FFMPEGEvent.INITIAL_STREAM_DATA_AVAILABLE ) );
					ns.close();
					ns.dispose();
					ns = null;
					
				}
				
			}
			
			this.dispatchEvent( new Event( Event.VIDEO_FRAME ) );
			
		}
		
		protected function stdoutStart( e:FFMPEGEvent ):void {
			
			ns.appendBytesAction( NetStreamAppendBytesAction.RESET_SEEK );
			
		}
		
		protected function stdoutStop( e:FFMPEGEvent ):void {
			
			ns.appendBytesAction( NetStreamAppendBytesAction.END_SEQUENCE );
			
		}
		
		public function get encoder():FFMPEG {
			
			return encoderInstance;
			
		}
		
		public function set encoder( value:FFMPEG ):void {
			
			removeListeners();
			encoderInstance = value;
			addListeners();
			
		}
		
		public function get piped():Boolean {
			
			return isPiped;
			
		}
		
		public function set piped( value:Boolean ):void {
			
			isPiped = value;
			
			if ( isPiped ) {
				
				if ( dataStreamBytesInternal ) {
					
					dataStreamBytesInternal.clear();
					dataStreamBytesInternal = null;
					
				}
				
				dataStreamBytesInternal = new ByteArray();
				
			} else {
				
				if ( dataStreamBytesInternal ) {
					
					dataStreamBytesInternal.clear();
					dataStreamBytesInternal = null;
					
				}
				
			}
			
		}
		
		public function onMetaData( o:* = null ):void {
			
			//for ( var i:String in o ) trace( 'onMetaData', i, o[i] );
			
		}
	
		public function dispose():void {
			
			removeListeners();
			
			if ( ns ) ns.dispose();
			ns = null;
			
			if ( nc ) nc.close();
			nc = null;
			
			st = null;
			
			if ( dataStreamBytesInternal ) {
					
				dataStreamBytesInternal.clear();
				dataStreamBytesInternal = null;
				
			}
			
		}
		
		public function addMetaData( name:String, value:String ):void {
			
			if ( !metaData ) metaData = new Object();
			metaData[ name ] = value;
			
		}
		
	}

}
