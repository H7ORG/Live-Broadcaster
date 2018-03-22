package org.igazine.net {

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
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class CameraServerEvent extends Event {
		
		public static const CONNECTED:String = "cameraServerConnceted";
		public static const REJECTED:String = "cameraServerRejected";
		public static const FAILED:String = "cameraServerFailed";
		public static const CLOSED:String = "cameraServerClosed";
		public static const SERVER_COMMAND:String = "cameraServerCommand";
		public static const NET_STATUS:String = "cameraServerNetStatus";
		
		// Commands
		public static const ADD_CAMERA:String = "cameraServerCommandAddCamera";
		public static const ADD_SNAPSHOT:String = "cameraServerCommandAddSnapshot";
		public static const ADD_CLIENT:String = "cameraServerCommandAddClient";
		public static const GET_CAMERA:String = "cameraServerCommandGetCamera";
		public static const GET_CAMERAS:String = "cameraServerCommandGetCameras";
		public static const GET_SNAPSHOT:String = "cameraServerCommandGetSnapshot";
		public static const DELETE_CAMERA:String = "cameraServerCommandDeleteCamera";
		public static const DELETE_CLIENT:String = "cameraServerCommandDeleteClient";
		public static const SET_PROPERTY:String = "cameraServerSetProperty";
		
		public var data:ByteArray;
		public var id:String;
		public var command:String;
		public var size:int;
		public var property:String;
		public var value:*;
		public var category:String;
		public var uid:String;
		public var code:String;
		public var description:String;
		
		public function CameraServerEvent( type:String ) {
			
			data = new ByteArray();
			super( type );
			
		}
		
		public function dispose():void {
			
			data.clear();
			data = null;
			id = null;
			command = null;
			
		}
		
	}

}