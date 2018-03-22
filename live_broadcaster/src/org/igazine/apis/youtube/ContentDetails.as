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
	
	public class ContentDetails implements IResource {
		
		private var _object:Object = new Object();
		private var _monitorStream:MonitorStream;
		
		public function ContentDetails() {
			
		}
		
		public static function create( value:Object ):ContentDetails {
			
			var cd:ContentDetails = new ContentDetails();
			cd._object = value;
			cd._monitorStream = MonitorStream.create( value.monitorStream );
			return cd;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.monitorStream ) {
				
				if ( _monitorStream ) _monitorStream.update( value.monitorStream ) else _monitorStream = MonitorStream.create( value.monitorStream );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _monitorStream ) _monitorStream.dispose();
			_monitorStream = null;
			
		}
		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			
			( _monitorStream ) ? _object["monitorStream"] = _monitorStream.object : _object["monitorStream"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get monitorStream():MonitorStream {
			
			return _monitorStream;
			
		}
		
		public function set monitorStream( value:MonitorStream ):void {
			
			_object["monitorStream"] = value;
			_monitorStream = value;
			
		}
		
		public function get enableEmbed():Boolean {
			
			return _object["enableEmbed"];
			
		}
		
		public function set enableEmbed( value:Boolean ):void {
			
			_object["enableEmbed"] = value;
			
		}
		
		public function get enableDvr():Boolean {
			
			return _object["enableDvr"];
			
		}
		
		public function set enableDvr( value:Boolean ):void {
			
			_object["enableDvr"] = value;
			
		}
		
		public function get enableContentEncryption():Boolean {
			
			return _object["enableContentEncryption"];
			
		}
		
		public function set enableContentEncryption( value:Boolean ):void {
			
			_object["enableContentEncryption"] = value;
			
		}
		
		public function get recordFromStart():Boolean {
			
			return _object["recordFromStart"];
			
		}
		
		public function set recordFromStart( value:Boolean ):void {
			
			_object["recordFromStart"] = value;
			
		}
		
		public function get startWithSlate():Boolean {
			
			return _object["recordFromStart"];
			
		}
		
		public function set startWithSlate( value:Boolean ):void {
			
			_object["recordFromStart"] = value;
			
		}
		
		public function get boundStreamId():String {
			
			return _object["boundStreamId"];
			
		}
		
		public function get closedCaptionsIngestionUrl():String {
			
			return _object["closedCaptionsIngestionUrl"];
			
		}
		
		public function get isReusable():Boolean {
			
			return _object["isReusable"];
			
		}
		
		public function set isReusable( value:Boolean ):void {
			
			_object["isReusable"] = value;
			
		}
		
	}

}