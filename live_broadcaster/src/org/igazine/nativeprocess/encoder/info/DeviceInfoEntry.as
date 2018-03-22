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
	
	public class DeviceInfoEntry {
		
		public var vCodec:String = "rawvideo";
		public var minFps:Number;
		public var maxFps:Number;
		public var resolution:String;
		
		public function DeviceInfoEntry() {	}
		
		public function get width():int {
			
			if ( resolution ) {
				
				return int( String( resolution.split( "x" )[0] ) );
				
			}
			
			return 0;
			
		}
		
		public function get height():int {
			
			if ( resolution ) {
				
				return int( String( resolution.split( "x" )[1] ) );
				
			}
			
			return 0;
			
		}
		
		public function get fps():Number {
			
			return maxFps;
			
		}
		
		public function get infoString():String {
			
			var s:String = "vcodec: " + vCodec + ", minFps: " + minFps + ", maxFps: " + maxFps + ", resolution: " + resolution;
			return s;
			
		}
		
		public function get xml():XML {
			
			//trace( "!!!!!!!!!!!!!!", this.infoString );
			var x:XML = new XML( "<mode />" );
			x.width = this.width;
			x.height = this.height;
			x.resolution = this.resolution;
			x.vcodec = this.vCodec;
			x.fps = this.fps;
			x.label = this.resolution + " " + String( this.fps.toFixed(0) ) + " FPS (" + String( this.vCodec ).toUpperCase() +")";
			x.youtube = 1;
			x.facebook = int( ( height <= 720 ) && ( fps < 60 ) );
			return x;
			
		}
		
		public function dispose():void {
			
			vCodec = null;
			resolution = null;
			
		}
		
	}

}