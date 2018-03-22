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

package org.igazine.nativeprocess.encoder.destinations {
	
	public class DSpycamIO extends DRTMP {
		
		import org.igazine.nativeprocess.encoder.outputs.FOutput;
		
		private static const SPYCAM_MEDIA_SERVER_URL:String = "rtmp://52.3.193.254:1935/SpycamOrigin/";
		
		public var userId:String;
		public var token:String;
		public var cameraName:String;
		public var cameraDesc:String;
		public var cameraId:String;
		
		public function DSpycamIO() {
			
			super( SPYCAM_MEDIA_SERVER_URL );
			this.format = FOutput.FORMAT_FLV;
			//this.options = { flags:"+global_header" };
			
		}
		
		override public function get target():String {
			
			//"rtmp://52.3.193.254:1935/SpycamOrigin/?encoder live=1 conn=S:1234 conn=S:5678 conn=S:Nameeee conn=S:Desssssc%20qeqweqweqe swfUrl=Cameleon"
			//return SPYCAM_MEDIA_SERVER_URL + cameraId + "_source" + "?t=" + token + " live=1 conn=S:" + cameraId + " swfUrl=Cameleon";
			//return SPYCAM_MEDIA_SERVER_URL + cameraId + "" + "?t=" + token + " live=1 conn=S:" + cameraId + " swfUrl=Cameleon";
			return SPYCAM_MEDIA_SERVER_URL + cameraId + "?Cameleon";
			
		}
		
		override public function set target(value:String):void {
			
			super.target = value;
			
		}
		
	}

}