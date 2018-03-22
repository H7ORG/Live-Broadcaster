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

package org.igazine.apis.youtube {
	
	import com.adobe.serialization.json.JSON;
	
	public class Snippet implements IResource {
		
		private var _object:Object = new Object();
		private var _textMessageDetails:TextMessageDetails;
		
		public function Snippet() {
			
		}
		
		public static function create( value:Object ):Snippet {
			
			var s:Snippet = new Snippet();
			s._object = value;
			
			if ( value.type && ( value.type == "textMessageEvent" ) ) {
				
				s._textMessageDetails = TextMessageDetails.create( value.textMessageDetails );
				
			}
			
			return s;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
				
		}
		
		public function dispose():void {
			
			_object = null;
			
		}
		
		public function get json():String {
			
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function set json( value:String ):void {
			
			_object = com.adobe.serialization.json.JSON.decode( value );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get title():String {
			
			return _object["title"];
			
		}
		
		public function set title( value:String ):void {
			
			_object["title"] = value;
			
		}
		
		public function get description():String {
			
			return _object["description"];
			
		}
		
		public function set description( value:String ):void {
			
			_object["description"] = value;
			
		}
		
		public function get publishedAt():String {
			
			return _object["publishedAt"];
			
		}
		
		public function get channelId():String {
			
			return _object["channelId"];
			
		}
		
		public function get isDefaultStream():Boolean {
			
			return _object["isDefaultStream"];
			
		}
		
		public function get isDefaultBroadcast():Boolean {
			
			return _object["isDefaultBroadcast"];
			
		}
		
		public function get scheduledStartTime():String {
			
			return _object["scheduledStartTime"];
			
		}
		
		public function set scheduledStartTime( value:String ):void {
			
			_object["scheduledStartTime"] = value;
			
		}
		
		public function get scheduledEndTime():String {
			
			return _object["scheduledEndTime"];
			
		}
		
		public function set scheduledEndTime( value:String ):void {
			
			_object["scheduledEndTime"] = value;
			
		}
		
		public function get liveChatId():String {
			
			return _object["liveChatId"];
			
		}
		
		public function get type():String {
			
			return _object["type"];
			
		}
		
		public function get authorChannelId():String {
			
			return _object["authorChannelId"];
			
		}
		
		public function get hasDisplayContent():Boolean {
			
			return _object["hasDisplayContent"];
			
		}
		
		public function get displayMessage():String {
			
			return _object["displayMessage"];
			
		}
		
		public function get textMessageDetails():TextMessageDetails {
			
			return _textMessageDetails;
			
		}
		
	}

}