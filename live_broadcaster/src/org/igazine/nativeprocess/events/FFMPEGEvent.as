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

package org.igazine.nativeprocess.events {
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class FFMPEGEvent extends Event {
		
		public static const INIT:String = "ffmpegInit";
		public static const START:String = "ffmpegStart";
		public static const INPUT_FRAME:String = "ffmpegInputFrame";
		public static const ERROR_OUTPUT:String = "ffmpegErrorOutput";
		public static const EXIT:String = "ffmpegExit";
		public static const CONNECTION_ERROR:String = "ffmpegConnectionError";
		public static const VIDEO_STREAM_FOUND:String = "ffmpegVideoStreamFound";
		public static const STDOUT_STOP:String = "ffmpegStdoutStop";
		public static const STDOUT_START:String = "ffmpegStdoutStart";
		public static const BITMAP_CREATED:String = "ffmpegBitmapCreated";
		public static const RETRY:String = "ffmpegRetry";
		public static const DATA_AVAILABLE:String = "ffmpegDataAvailable";
		public static const INITIAL_STREAM_DATA_AVAILABLE:String = "ffmpegInitialStreamDataAvailable";
		
		private var internalData:String;
		
		public var exitCode:Number;
		public var bmp:BitmapData;
		
		public function FFMPEGEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			
			super( type, bubbles, cancelable );
			
		}
		
		public function get data():String {
			
			return internalData;
			
		}
		
		public function set data( s:String ):void {
			
			internalData = s;
			
		}
		
	}

}