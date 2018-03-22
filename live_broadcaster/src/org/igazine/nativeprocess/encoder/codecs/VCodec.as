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

package org.igazine.nativeprocess.encoder.codecs {
	
	import org.igazine.nativeprocess.encoder.parameters.IParameterSet;
	
	public class VCodec implements IParameterSet {
		
		public static const CODEC_COPY:String = "copy";
		public static const CODEC_H264:String = "libx264";
		public static const CODEC_VP6:String = "vp6f";
		public static const CODEC_MJPEG:String = "mjpeg";
		public static const CODEC_RAWVIDEO:String = "rawvideo";
		public static const CODEC_FLV:String = "flv1";
		public static const PROFILE_BASELINE:String = "baseline";
		public static const PROFILE_MAIN:String = "main";
		public static const PIXEL_FORMAT_YUV420P:String = "yuv420p";
		public static const PIXEL_FORMAT_YUYV422:String = "yuyv422";
		
		public var name:String;
		public var profile:String;
		public var pixelFormat:String;
		public var bandwidth:int;
		public var bufferSize:int;
		public var width:int;
		public var height:int;
		public var globalHeader:Boolean;
		public var maxRate:int;
		public var crf:int = -1;
		
		public function VCodec() {
			
			this.name = CODEC_COPY;
			
		}
		
		/* INTERFACE org.igazine.nativeprocess.encoder.parameters.IParameterSet */
		
		public function get parameters():Vector.<String> {
			
			var p:Vector.<String> = new Vector.<String>();
			
			p.push( "-c:v", this.name );
			if ( height && width ) -p.push( "-s", String( width ) + "x" + String( height ) );
			if ( globalHeader ) p.push( "-flags", "+global_header" );
			if ( profile ) p.push( "-profile:v", this.profile );
			if ( pixelFormat ) p.push( "-pix_fmt", this.pixelFormat );
			if ( crf != -1 ) p.push( "-crf", String ( crf ) );
			if ( bandwidth ) p.push( "-b:v", String ( bandwidth ) + "k" );
			if ( maxRate ) p.push( "-maxrate", String ( maxRate ) + "k" );
			if ( bufferSize ) p.push( "-bufsize", String ( bufferSize ) + "k" );
			
			return p;
			
		}
		
	}

}