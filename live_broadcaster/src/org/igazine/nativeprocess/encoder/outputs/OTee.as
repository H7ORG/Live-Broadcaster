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
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import org.igazine.nativeprocess.encoder.codecs.AudioCodec;
	import org.igazine.nativeprocess.encoder.codecs.VCodec;
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import org.igazine.nativeprocess.encoder.parameters.IParameterSet;
	import org.igazine.nativeprocess.encoder.destinations.*;
	import flash.events.ProgressEvent;
	import org.igazine.nativeprocess.events.FFMPEGEvent;
	import flash.net.NetStreamAppendBytesAction;
	
	public class OTee extends FOutput {
		
		public function OTee( ) {
			
			super();
			
		}
		
		override public function get parameters():Vector.<String> {
			
			var p:Vector.<String> = new Vector.<String>();
			
			p = p.concat( videoCodec.parameters );
			
			if ( width && height ) {
				
				//p.push( "-vf", "scale=" + String( width ) + ":" + String( height ) );
				//p.push( "-s", String( width ) + "x" + String( height ) );
				
				//if ( height != 0 ) p.push( "-s", String( width ) + "x" + String( height ) );
				if ( height != 0 ) p.push( "-vf", "scale=" + String( width ) + ":" + String( height ) );
				//if ( height != 0 ) p.push( "-filter_complex", "scale=" + String( width ) + ":" + String( height ) );
				
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
			
			//p.push( "-f", FOutput.FORMAT_TEE, "-flags", "+global_header", "-map", String( inputVideoSource ) + ":" + String( inputVideoStream ) );
			p.push( "-f", FOutput.FORMAT_TEE, "-map", String( inputVideoSource ) + ":" + String( inputVideoStream ) );
			if ( audioCodec && ( inputAudioSource != -1 ) ) p.push( "-map", String( inputAudioSource ) + ":" + String( inputAudioStream ) );
			
			if ( piped && ( pipe == null ) ) {
				
				pipe = new DPipe();
				pipe.format = pipeFormat;
				addDestination( pipe );
				
			}
			
			var s:String = "";
			var d:Destination;
			for ( var i:int = 0; i < destinations.length; i++ ) {
				
				if ( i > 0 ) s += "|";
				d = destinations[i];
				if ( d.options ) {
					
					s += "[f=" + d.format;
					
					for ( var vals:String in d.options ) s += String( ":" + vals + "=" + d.options[vals] );
					
					s += "]";
					
				} else {
					
					if ( d.format ) s += "[f=" + d.format + "]";
					
				}
				if ( d.target ) s += d.target;
				
			}
			
			p.push( s );
			
			if ( snapshot ) {
				
				p.push( "-f", "image2", "-r",  "1/60", "-updatefirst", "1", snapshotPath );
				
			}
			
			return p;
			
		}
		
		public function addDestination( d:Destination ):void {
			
			destinations.push( d );
			
		}
		
		override public function dispose():void {
			
			super.dispose();
			
		}
		
	}

}
