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
	
	public class Status implements IResource {
		
		public static const PRIVACY_STATUS_PRIVATE:String = "private";
		public static const PRIVACY_STATUS_PUBLIC:String = "public";
		public static const PRIVACY_STATUS_UNLISTED:String = "unlisted";
		public static const RECORDING_STATUS_NOT_RECORDING:String = "notRecording";
		public static const RECORDING_STATUS_RECORDING:String = "recording";
		public static const RECORDING_STATUS_RECORDED:String = "recorded";
		public static const STREAM_STATUS_ACTIVE:String = "active";
		public static const STREAM_STATUS_CREATED:String = "created";
		public static const STREAM_STATUS_ERROR:String = "error";
		public static const STREAM_STATUS_INACTIVE:String = "inactive";
		public static const STREAM_STATUS_READY:String = "ready";
		public static const BROADCAST_LIFECYCLE_STATUS_READY:String = "ready";
		public static const BROADCAST_LIFECYCLE_STATUS_ABANDONED:String = "abandoned";
		public static const BROADCAST_LIFECYCLE_STATUS_CREATED:String = "created";
		public static const BROADCAST_LIFECYCLE_STATUS_COMPLETE:String = "complete";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE:String = "live";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE_STARTING:String = "liveStarting";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE_RECLAIMED:String = "reclaimed";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE_REVOKED:String = "revoked";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE_TEST_STARTING:String = "testStarting";
		public static const BROADCAST_LIFECYCLE_STATUS_LIVE_TESTING:String = "testing";
		
		private var _object:Object = new Object();
		private var _healthStatus:HealthStatus;
		
		public function Status() {
			
		}
		
		public static function create( value:Object ):Status {
			
			var s:Status = new Status();
			s._object = value;
			s._healthStatus = HealthStatus.create( value.healthStatus );
			return s;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.healthStatus ) {
				
				if ( _healthStatus ) _healthStatus.update( value.healthStatus ) else _healthStatus = HealthStatus.create( value.healthStatus );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _healthStatus ) _healthStatus.dispose();
			_healthStatus = null;
			
		}
		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			
			( _healthStatus ) ? _object["healthStatus"] = _healthStatus.object : _object["healthStatus"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get streamStatus():String {
			
			return _object["streamStatus"];
			
		}
		
		public function get healthStatus():HealthStatus {
			
			return _healthStatus;
			
		}
		
		public function get privacyStatus():String {
			
			return _object["privacyStatus"];
			
		}
		
		public function set privacyStatus( value:String ):void {
			
			_object["privacyStatus"] = value;
		}
		
		public function get recordingStatus():String {
			
			return _object["recordingStatus"];
			
		}
		
		public function set recordingStatus( value:String ):void {
			
			_object["recordingStatus"] = value;
		}
		
		public function get lifeCycleStatus():String {
			
			return _object["lifeCycleStatus"];
			
		}
		
	}

}