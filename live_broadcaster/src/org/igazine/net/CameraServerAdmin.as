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
	
	import flash.utils.ByteArray;
	import com.adobe.crypto.MD5;
	
	public class CameraServerAdmin extends CameraServer {
		
		public function CameraServerAdmin() {
			
			super();
			
		}
		
		private function setData( category:String, name:String, data:ByteArray, compressData:Boolean = false ):void {
			
			var ba:ByteArray = new ByteArray();
			data.position = 0;
			data.readBytes( ba );
			if ( compressData ) ba.deflate();
			nc.call( "setData", null, category, name, ba );
			ba.clear();
			ba = null;
			
		}
		
		private function clearData( category:String, name:String ):void {
			
			nc.call( "clearData", null, category, name );
			
		}
		
		private function setServerProperty( property:String, value:* ):void {
			
			if ( nc ) nc.call( "setServerProperty", null, property, value );
			
		}
		
		public function setCameras( data:ByteArray ):void {
			
			setData( "cameras", "0", data, compress );
			
		}
		
		public function addCamera( id:String, data:ByteArray ):void {
			
			setData( "cameras", id, data, compress );
			
		}
		
		public function deleteCamera( id:String ):void {
			
			clearData( "cameras", id );
			
		}
		
		public function setSnapshot( id:String, snapshotData:ByteArray ):void {
			
			setData( "snapshots", id, snapshotData, false );
			
		}
		
		public function setProperties( params:Object ):void {
			
			nc.call( "setServerProperties", null, params );
			
		}
		
		public function closeClientByID( id:String ):void {
			
			nc.call( "closeClient", null, id );
			
		}
		
		public function closeClientByUID( uid:String ):void {
			
			var clientId:String;
			
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				if ( clients[i].connectionProperties.uid == uid ) {
					
					clientId = clients[i].id;
					break;
					
				}
				
			}
			
			nc.call( "closeClient", null, clientId );
			
		}
		
		public function get allowAnonymousConnections():Boolean { return _allowAnonymousConnections }
		public function set allowAnonymousConnections( value:Boolean ):void { _allowAnonymousConnections = value; setServerProperty( "allowAnonymousClientConnections", value ); }
		public function get allowConnections():Boolean { return _allowConnections }
		public function set allowConnections( value:Boolean ):void { _allowConnections = value; setServerProperty( "allowClientConnections", value ); }
		public function get secret():String { return _secret }
		public function set secret( value:String ):void { _secret = value; setServerProperty( "secret", MD5.hash( value ) ); }
		public function get owner():String { return _owner }
		public function set owner( value:String ):void { _owner = value; setServerProperty( "owner",  MD5.hash( value ) ); }
		public function get token():String { return _token }
		public function set token( value:String ):void { _token = value; setServerProperty( "token",  MD5.hash( value ) ); }
		public function set brandName( value:String ):void { _brandName = value; setServerProperty( "brandName",  value ); }
		public function set brandId( value:String ):void { _brandId = value; setServerProperty( "brandId",  value ); }
		public function set serverId( value:String ):void { _serverId = value; setServerProperty( "serverId",  value ); }
		public function set user( value:String ):void { _user = value; setServerProperty( "user",  value ); }
		
	}

}