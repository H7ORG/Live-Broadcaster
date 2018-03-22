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
	
	public class LiveStream  implements IResource {
		
		private var _object:Object = new Object();
		private var _snippet:Snippet;
		private var _cdn:CDN;
		private var _status:Status;
		
		public function LiveStream() {
			
		}
		
		public static function create( value:Object ):LiveStream {
			
			var ls:LiveStream = new LiveStream();
			ls._object = value;
			if ( value.snippet ) ls._snippet = Snippet.create( value.snippet );
			if ( value.cdn ) ls._cdn = CDN.create( value.cdn );
			if ( value.status ) ls._status = Status.create( value.status );
			return ls;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.snippet ) {
				
				if ( _snippet ) _snippet.update( value.snippet ) else _snippet = Snippet.create( value.snippet );
				
			}
			
			if ( value && value.cdn ) {
				
				if ( _cdn ) _cdn.update( value.cdn ) else _cdn = CDN.create( value.cdn );
				
			}
			
			if ( value && value.status ) {
				
				if ( _status ) _status.update( value.status ) else _status = Status.create( value.status );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _snippet ) _snippet.dispose();
			if ( _cdn ) _cdn.dispose();
			if ( _status ) _status.dispose();
			_snippet = null;
			_cdn = null;
			_status = null;
			
		}
		
		public function get json():String {
			
			( _snippet ) ? _object["snippet"] = _snippet.object : _object["snippet"] = null;
			( _cdn ) ? _object["cdn"] = _cdn.object : _object["cdn"] = null;
			( _status ) ? _object["status"] = _status.object : _object["status"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function set json( value:String ):void {
			
			_object = com.adobe.serialization.json.JSON.decode( value );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get etag():String {
			
			return _object["etag"];
			
		}
		
		public function get id():String {
			
			return _object["id"];
			
		}
		
		public function set id( value:String ):void {
			
			_object["id"] = value;
			
		}
		
		public function get snippet():Snippet {
			
			return _snippet;
			
		}
		
		public function set snippet( value:Snippet ):void {
			
			_snippet = value;
			
		}
		
		public function get cdn():CDN {
			
			return _cdn;
			
		}
		
		public function set cdn( value:CDN ):void {
			
			_cdn = value;
			
		}
		
		public function get status():Status {
			
			return _status;
			
		}
		
		//
		// Helper functions to access sub-level properties
		//
		
		public function get title():String {
			
			return _snippet.title;
			
		}
		
	}

}