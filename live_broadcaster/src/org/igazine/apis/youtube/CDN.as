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
	
	public class CDN implements IResource {
		
		public static const FORMAT_2160P_60FPS:String = "2160p_hfr";
		public static const FORMAT_2160P:String = "2160p";
		public static const FORMAT_1440P_60FPS:String = "1440p_hfr";
		public static const FORMAT_1440P:String = "1440p";
		public static const FORMAT_1080P_60FPS:String = "1080p_hfr";
		public static const FORMAT_1080P:String = "1080p";
		public static const FORMAT_720P_60FPS:String = "720p_hfr";
		public static const FORMAT_720P:String = "720p";
		public static const FORMAT_480P:String = "480p";
		public static const FORMAT_360P:String = "360p";
		public static const FORMAT_240P:String = "240p";
		public static const RESOLUTION_2160P:String = "2160p";
		public static const RESOLUTION_1440P:String = "1440p";
		public static const RESOLUTION_1080P:String = "1080p";
		public static const RESOLUTION_240P:String = "240p";
		public static const RESOLUTION_360P:String = "360p";
		public static const RESOLUTION_480P:String = "480p";
		public static const RESOLUTION_720P:String = "720p";
		public static const FRAMERATE_30FPS:String = "30fps";
		public static const FRAMERATE_60FPS:String = "60fps";
		public static const INGESTION_TYPE_RTMP:String = "rtmp";
		
		private var _object:Object = new Object();
		private var _ingestionType:String = INGESTION_TYPE_RTMP;
		private var _frameRate:String = FRAMERATE_30FPS;
		private var _resolution:String = RESOLUTION_720P;
		private var _ingestionInfo:IngestionInfo;
		
		public function CDN() {
			
			_object[ "ingestionType" ] = _ingestionType;
			_object[ "frameRate" ] = _frameRate;
			_object[ "resolution" ] = _resolution;
			
		}
		
		public static function create( value:Object ):CDN {
			
			var c:CDN = new CDN();
			c._object = value;
			if ( value.ingestionType != null ) c._ingestionType = value.ingestionType;
			if ( value.frameRate ) c._frameRate = value.frameRate;
			if ( value.resolution ) c._resolution = value.resolution;
			if ( value.ingestionInfo ) c._ingestionInfo = IngestionInfo.create( value.ingestionInfo );
			return c;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
			if ( value && value.ingestionInfo ) {
				
				if ( _ingestionInfo ) _ingestionInfo.update( value.ingestionInfo ) else _ingestionInfo = IngestionInfo.create( value.ingestionInfo );
				
			}
			
		}
		
		public function dispose():void {
			
			_object = null;
			if ( _ingestionInfo ) _ingestionInfo.dispose();
			_ingestionInfo = null;
			
		}
		

		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			
			( _ingestionInfo ) ? _object["ingestionInfo"] = _ingestionInfo.object : _object["ingestionInfo"] = null;
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function set json( value:String ):void {
			
			_object = com.adobe.serialization.json.JSON.decode( value );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		//
		// This property has been deprecated as of April 18, 2016. Instead, please use the cdn.frameRate and cdn.resolution properties to specify the frame rate and resolution separately.
		//
		
		public function get ingestionType():String {
			
			return _ingestionType;
			
		}
		
		public function set ingestionType( value:String ):void {
			
			_ingestionType = value;
			_object[ "ingestionType" ] = _ingestionType;
			
		}
		
		public function get ingestionInfo():IngestionInfo {
			
			return _ingestionInfo;
			
		}
		
		public function get frameRate():String {
			
			return _frameRate;
			
		}
		
		public function set frameRate( value:String ):void {
			
			_frameRate = value;
			_object[ "frameRate" ] = _frameRate;
			
		}
		
		public function get resolution():String {
			
			return _resolution;
			
		}
		
		public function set resolution( value:String ):void {
			
			_resolution = value;
			_object[ "resolution" ] = _resolution;
			
		}
		
	}

}