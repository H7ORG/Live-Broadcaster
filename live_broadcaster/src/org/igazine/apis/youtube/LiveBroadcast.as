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
	
	public class LiveBroadcast implements IResource {	
		
		public static const BROADCAST_STATUS_COMPLETE:String = "complete";
		public static const BROADCAST_STATUS_LIVE:String = "live";
		public static const BROADCAST_STATUS_TESTING:String = "testing";
		
		private var _object:Object = new Object();
		private var _snippet:Snippet;
		private var _status:Status;
		private var _contentDetails:ContentDetails;
		
		public function LiveBroadcast() {}
		
		public static function create( value:Object ):LiveBroadcast {
			
			var lb:LiveBroadcast = new LiveBroadcast();
			lb._object = value;
			if ( value.snippet ) lb._snippet = Snippet.create( value.snippet );
			if ( value.status ) lb._status = Status.create( value.status );
			if ( value.contentDetails ) lb._contentDetails = ContentDetails.create( value.contentDetails );
			return lb;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.snippet ) {
				
				if ( _snippet ) _snippet.update( value.snippet ) else _snippet = Snippet.create( value.snippet );
				
			}
			
			if ( value && value.contentDetails ) {
				
				if ( _contentDetails ) _contentDetails.update( value.contentDetails ) else _contentDetails = ContentDetails.create( value.contentDetails );
				
			}
			
			if ( value && value.status ) {
				
				if ( _status ) _status.update( value.status ) else _status = Status.create( value.status );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _snippet ) _snippet.dispose();
			if ( _contentDetails ) _contentDetails.dispose();
			if ( _status ) _status.dispose();
			_snippet = null;
			_contentDetails = null;
			_status = null;
			
		}
		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			
			( _snippet ) ? _object["snippet"] = _snippet.object : _object["snippet"] = null;
			( _status ) ? _object["status"] = _status.object : _object["status"] = null;
			( _contentDetails ) ? _object["contentDetails"] = _contentDetails.object : _object["contentDetails"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get snippet():Snippet {
			
			return _snippet;
			
		}
		
		public function set snippet( value:Snippet ):void {
			
			_snippet = value;
			
		}
		
		public function get contentDetails():ContentDetails {
			
			return _contentDetails;
			
		}
		
		public function set contentDetails( value:ContentDetails ):void {
			
			_contentDetails = value;
			
		}
		
		public function get status():Status {
			
			return _status;
			
		}
		
		public function set status( value:Status ):void {
			
			_status = value;
			
		}
		
		public function get id():String {
			
			return _object["id"];
			
		}
		
		public function get etag():String {
			
			return _object["etag"];
			
		}
		
	}

}