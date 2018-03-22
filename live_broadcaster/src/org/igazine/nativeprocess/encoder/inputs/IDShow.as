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
package org.igazine.nativeprocess.encoder.inputs {
	
	public class IDShow extends FInput {
		
		private var videoDevice:String;
		private var audioDevice:String;
		
		public var width:int;
		public var height:int;
		public var frameRate:Number;
		public var vCodec:String;
		public var pixelFormat:String;
		
		public function IDShow( videoDeviceName:String, audioDeviceName:String ) {
			
			super();
			
			//if ( videoDeviceName ) videoDevice = videoDeviceName.substring( 0, 31 );
			//if ( audioDeviceName ) audioDevice = audioDeviceName.substring( 0, 31 );
			
			if ( videoDeviceName ) videoDevice = videoDeviceName;
			if ( audioDeviceName ) audioDevice = audioDeviceName;
			
		}
		
		override public function get parameters():Vector.<String> {
			
			var p:Vector.<String> = new Vector.<String>();
			p.push( "-f", "dshow" );
			
			if ( vCodec ) p.push( "-vcodec", vCodec );
			if ( pixelFormat ) p.push( "-pix_fmt", pixelFormat );
			if ( width ) p.push( "-s", String( width ) + "x" + String( height ) );
			if ( frameRate ) p.push( "-framerate", String( frameRate ) );
			
			var s:String = "";
			if ( videoDevice && audioDevice ) {
				
				s = "video=" + videoDevice + ":audio=" + audioDevice;
				
			}
			if ( videoDevice && !audioDevice ) {
				
				s = "video=" + videoDevice;
				
			}
			if ( audioDevice && !videoDevice ) {
				
				s = "audio=" + audioDevice;
				
			}
			if ( videoDevice || audioDevice ) p.push( "-i", s );
			
			return p;
			
		}
		
	}

}