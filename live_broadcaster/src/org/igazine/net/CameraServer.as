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
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.adobe.crypto.MD5;
	import flash.utils.setTimeout;
	
	public class CameraServer extends EventDispatcher {
		
		public static const TYPE_SERVER:String = "CameleonServer";
		public static const TYPE_CLIENT:String = "CameleonClient";
		public static const RTMP_PROTOCOL:String = "rtmp://";
		public static const RTMFP_PROTOCOL:String = "rtmfp://";
		
		public static const CATEGORY_CAMERAS:String = "cameras";
		
		public static const PROPERTY_OUTPUT:String = "output_";
		public static const PROPERTY_CONTROL:String = "control";
		public static const PROPERTY_CONTROL_START:String = "start";
		public static const PROPERTY_CONTROL_STOP:String = "stop";
		
		protected var nc:NetConnection;
		
		protected var _address:String;
		protected var _alternateAddress:String;
		protected var _port:int;
		protected var _username:String = "";
		protected var _user:String = "";
		protected var _serverName:String = "";
		protected var _clientSecret:String = "";
		protected var _clientType:String = TYPE_CLIENT;
		protected var _allowConnections:Boolean;
		protected var _allowAnonymousConnections:Boolean;
		protected var _secret:String;
		protected var _owner:String;
		protected var _token:String;
		protected var _uid:String;
		protected var _info:String;
		protected var _deviceOS:String;
		protected var _deviceModel:String;
		protected var _brandName:String;
		protected var _brandId:String;
		protected var _serverId:String;
		protected var _remoteAddress:String;
		protected var _connectPhase:int;
		protected var _userObject:Object;
		protected var _timer:Timer;
		protected var _entries:Vector.<CameraServerEntry>;
		protected var _timeOut:Number = 5000;
		
		public var compress:Boolean = true;
		public var clients:Vector.<Object>;
		
		public function CameraServer() {
			
			_entries = new Vector.<CameraServerEntry>();
			
			clients = new Vector.<Object>();
			
			_timer = new Timer( _timeOut, 1 );
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, timerComplete );
			
			super();
			
		}
		
		private function createListeners():void {
			
			if ( nc ) {
				
				nc.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
				
			}
			
		}
		
		private function deleteListeners():void {
			
			if ( nc ) {
				
				nc.removeEventListener( NetStatusEvent.NET_STATUS, netStatus );
				
			}
			
		}
		
		private function clearEntries():void {
			
			_entries = new Vector.<CameraServerEntry>();
			
		}
		
		private function netStatus( e:NetStatusEvent ):void {
			
			trace( "netStatus", e.info.code );
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.NET_STATUS );
			evt.code = e.info.code;
			evt.description = e.info.description;
			this.dispatchEvent( evt );
			
			switch( e.info.code ) {
				
				case "NetConnection.Connect.Success":
					trace( "netStatus message:", e.info.message );
					for ( var i:String in e.info ) trace( "netStatus.info", i, e.info[i] );
					connectionAccepted( e.info.serverinfo);
					break;
					
				case "NetConnection.Connect.Rejected":
					trace( "netStatus description:", e.info.description );
					connectionRejected();
					break;
					
				case "NetConnection.Connect.Failed":
					trace( "netStatus description:", e.info.description );
					connectionFailed( );
					break;
					
				case "NetConnection.Connect.Closed":
					trace( "netStatus closed" );
					connectionClosed();
					break;
				
				case "NetConnection.Connect.InvalidApp":
					trace( "netStatus InvalidApp" );
					connectionRejected();
					break;
				
			}
			
		}
		
		private function connectionAccepted( serverObject:Object ):void {
			
			_timer.stop();
			
			if ( serverObject ) {
				
				_brandId = String( serverObject.brandId );
				_brandName = String( serverObject.brandName );
				_deviceOS = String( serverObject.deviceOS );
				_serverId = String( serverObject.serverId );
				
			}
			
			setTimeout( dispatchConnectedEvent, 100 );
			
		}
		
		private function dispatchConnectedEvent():void {
			
			this.dispatchEvent( new CameraServerEvent( CameraServerEvent.CONNECTED ) );
			
		}
		
		private function connectionRejected():void {
			
			clearEntries();
			deleteListeners();
			this.dispatchEvent( new CameraServerEvent( CameraServerEvent.REJECTED ) );
			
		}
		
		private function connectionFailed( ):void {
			
			_connectPhase++;
			
			if ( _connectPhase >= _entries.length ) {
				
				clearEntries();
				this.dispatchEvent( new CameraServerEvent( CameraServerEvent.FAILED ) );
				return;
				
			}
			
			deleteListeners();
			nc = null;
			createConnection( _connectPhase );
			
		}
		
		private function connectionClosed():void {
			
			clearEntries();
			deleteListeners();
			this.dispatchEvent( new CameraServerEvent( CameraServerEvent.CLOSED ) );
			
		}
		
		private function timerComplete( e:TimerEvent ):void {
			
			connectionFailed();
			
		}
		
		private function createConnection( entryIndex:int ):void {
			
			deleteListeners();
			if ( nc ) nc.close();
			nc = new NetConnection();
			nc.client = this;
			createListeners();
			
			_timer.delay = _entries[ _connectPhase ].timeout;
			_timer.start();
			
			trace( "Connecting:", _entries[ _connectPhase ].info );
			nc.connect( _entries[ _connectPhase ].address, _userObject );
			
		}
		
		public function connect():void {
			
			_connectPhase = 0;
			
			deleteListeners();
			
			_userObject = new Object();
			_userObject.software = _clientType;
			//_userObject.username = _username;
			_userObject.username = MD5.hash( _username );
			_userObject.secret = MD5.hash( _clientSecret );
			_userObject.uid = _uid;
			_userObject.info = _info;
			_userObject.deviceModel = _deviceModel;
			_userObject.deviceOS = _deviceOS;
			_userObject.brandId = _brandId;
			_userObject.brandName = _brandName;
			_userObject.serverId = _serverId;
			_userObject.user = _user;
			for ( var i:String in _userObject ) trace( '_userObject:', i, _userObject[i] );
			
			createConnection( _connectPhase );
			
		}
		
		//
		// Callbacks
		//
		
		public function close():void {
			
			deleteListeners();
			nc.close();
			this.dispatchEvent( new CameraServerEvent( CameraServerEvent.CLOSED ) );
			
		}
		
		public function closeConnection( e:* = null ):void {
			
			nc.close();
			
		}
		
		public function getDataResponse( params:Object ):void {
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			
			if ( params != null ) {
				
				switch( params.category ) {
					
					case "cameras":
						evt.id = params.name;
						if ( evt.id == "0" ) 
							evt.command = CameraServerEvent.GET_CAMERAS;
						else
							evt.command = CameraServerEvent.GET_CAMERA;
						break;
					
					case "snapshots":
						evt.id = params.name;
						evt.command = CameraServerEvent.GET_SNAPSHOT;
						break;
					
				}
				
				if ( params.data != null ) {
					
					var ba:ByteArray = params.data as ByteArray;
					evt.size = ba.length;
					try { ba.inflate() } catch ( e:Error ) {}
					evt.data = ba;
					
				}
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		public function setDataResponse( params:Object ):void {
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			
			if ( params != null ) {
				
				switch( params.category ) {
					
					case "cameras":
						evt.id = params.name;
						evt.command = CameraServerEvent.ADD_CAMERA
						break;
					
					case "snapshots":
						evt.id = params.name;
						evt.command = CameraServerEvent.ADD_SNAPSHOT;
						break;
					
				}
				
				if ( params.data != null ) {
					
					var ba:ByteArray = params.data as ByteArray;
					evt.size = ba.length;
					try { ba.inflate() } catch ( e:Error ) {}
					evt.data = ba;
					
				}
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		public function clearDataResponse( params:Object ):void {
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			
			if ( params != null ) {
				
				switch( params.category ) {
					
					case "cameras":
						evt.id = params.name;
						evt.uid = params.name;
						evt.command = CameraServerEvent.DELETE_CAMERA;
						break;
					
				}
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		public function setPropertyResponse( params:Object ):void {
			
			for ( var i:String in params ) trace( "setPropertyResponse", i, params[i] );
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			evt.command = CameraServerEvent.SET_PROPERTY;
			
			if ( params != null ) {
				
				evt.property = params.name;
				evt.value = params.value;
				evt.category = params.category;
				evt.uid = params.uid;
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		public function clientAdded( clientObject:* ):void {
			
			var i:String;
			
			for ( i in clientObject ) trace( "clientAdded", i, clientObject[i] );
			for ( i in clientObject.properties ) trace( "clientAdded.properties", i, clientObject.properties[i] );
			for ( i in clientObject.parameters ) trace( "clientAdded.parameters", i, clientObject.parameters[i] );
			for ( i in clientObject.connectionProperties ) trace( "clientAdded.connectionProperties", i, clientObject.connectionProperties[i] );
			
			clients.push( clientObject );
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			evt.id = clientObject.id;
			evt.command = CameraServerEvent.ADD_CLIENT;
			this.dispatchEvent( evt );
			
			trace( 'clients.length', clients.length );
			
		}
		
		public function clientDeleted( clientId:String ):void {
			
			trace( "CameraServer.clientDeleted", clientId );
			
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				if ( clients[i].id == clientId ) {
					
					clients.removeAt( i );
					break;
					
				}
				
			}
			
			var evt:CameraServerEvent = new CameraServerEvent( CameraServerEvent.SERVER_COMMAND );
			evt.command = CameraServerEvent.DELETE_CLIENT;
			evt.id = clientId;
			this.dispatchEvent( evt );
			
			trace( 'clients.length', clients.length );
			
		}
		
		//
		// Server functions
		//
		
		private function getData( category:String, name:String ):void {
			
			nc.call( "getData", null, category, name );
			
		}
		
		private function setProperty( category:String, uid:String, name:String, value:* ):void {
			
			nc.call( "setProperty", null, category, uid, name, value );
			
		}
		
		public function getCameras():void {
			
			getData( "cameras", "0" );
			
		}
		
		public function getCamera( id:String ):void {
			
			getData( "cameras", id );
			
		}
		
		public function getSnapshot( id:String ):void {
			
			getData( "snapshots", id );
			
		}
		
		public function setCameraProperty( uid:String, name:String, value:* ):void {
			
			setProperty( CATEGORY_CAMERAS, uid, name, value );
			
		}
		
		
		//
		// Entry management
		// 
		
		public function addEntry( entry:CameraServerEntry ):void {
			
			_entries.push( entry );
			
		}
		
		public function addEntryAt( index:int, entry:CameraServerEntry ):void {
			
			_entries.insertAt( index, entry );
			
		}
		
		//
		// Getters and Setters
		//
		
		public function get username():String { return _username }
		public function set username( value:String ):void { _username = value }
		public function get clientType():String { return _clientType }
		public function set clientType( value:String ):void { _clientType = value }
		public function get uid():String { return _uid }
		public function set uid( value:String ):void { _uid = value }
		public function get info():String { return _info }
		public function set info( value:String ):void { _info = value }
		public function get remoteAddress():String { return _remoteAddress }
		public function set remoteAddress( value:String ):void { _remoteAddress = value }
		public function get deviceOS():String { return _deviceOS }
		public function set deviceOS( value:String ):void { _deviceOS = value }
		public function get deviceModel():String { return _deviceModel }
		public function set deviceModel( value:String ):void { _deviceModel = value }
		public function get clientSecret():String { return _clientSecret }
		public function set clientSecret( value:String ):void { _clientSecret = value }
		
		public function get brandName():String { return _brandName }
		public function get brandId():String { return _brandId }
		public function get serverId():String { return _serverId }
		public function get user():String { return _user }
		public function get serverName():String { return _serverName }
		public function set serverName( value:String ):void { _serverName = value }
		
		public function get connection():NetConnection { return nc; }
		public function get connected():Boolean { return nc && nc.connected; }
		
	}

}