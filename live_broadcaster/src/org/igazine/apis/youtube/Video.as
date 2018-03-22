package org.igazine.apis.youtube {

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
	
	import com.adobe.serialization.json.JSON;
	
	public class Video implements IResource {
		
		private var _object:Object = new Object();
		private var _statistics:Statistics;
		private var _liveStreamingDetails:LiveStreamingDetails;
		
		public function Video() { }
		
		public static function create( value:Object ):Video {
			
			var v:Video = new Video();
			v._object = value;
			if ( value.statistics ) v._statistics = Statistics.create( value.statistics );
			if ( value.liveStreamingDetails ) v._liveStreamingDetails = LiveStreamingDetails.create( value.liveStreamingDetails );
			return v;
			
		}
		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			( _statistics ) ? _object["statistics"] = _statistics.object : _object["statistics"] = null;
			( _liveStreamingDetails ) ? _object["liveStreamingDetails"] = _liveStreamingDetails.object : _object["liveStreamingDetails"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
		}
		
		public function get object():Object {
			return _object;
		}
		
		public function update(value:Object):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.statistics ) {
				
				if ( _statistics ) _statistics.update( value.statistics ) else _statistics = Statistics.create( value.statistics );
				
			}
			
			if ( value && value.liveStreamingDetails ) {
				
				if ( _liveStreamingDetails ) _liveStreamingDetails.update( value.liveStreamingDetails ) else _liveStreamingDetails = LiveStreamingDetails.create( value.liveStreamingDetails );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _statistics ) _statistics.dispose();
			if ( _liveStreamingDetails ) _liveStreamingDetails.dispose();
			_statistics = null;
			_liveStreamingDetails = null;
			
		}
		
		//
		// Getters and setters
		//
		
		public function get statistics():Statistics {
			
			return _statistics;
			
		}
		
		public function get liveStreamingDetails():LiveStreamingDetails {
			
			return _liveStreamingDetails;
			
		}
		
	}

}