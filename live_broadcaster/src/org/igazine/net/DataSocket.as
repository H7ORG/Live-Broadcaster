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
	
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import org.igazine.events.DataSocketEvent;
	
	public class DataSocket extends EventDispatcher {
		
		public static const DATA_ROOT:String = "!!!DATA";
		public static const DATA_LENGTH:int = 22;
		public static const DATA_TYPE_INT:String = "INT";
		public static const DATA_TYPE_NUMBER:String = "NUM";
		public static const DATA_TYPE_STRING:String = "STR";
		public static const DATA_TYPE_OBJECT:String = "OBJ";
		public static const DATA_TYPE_ARRAY:String = "ARR";
		public static const DATA_TYPE_BYTES:String = "BYT";
		public static const DATA_DIVIDER:String = "_";
		
		public static const COMMAND_INITIALIZE:String = "initialize";
		public static const COMMAND_HELP:String = "help";
		public static const COMMAND_GET_CAMERAS:String = "getCameras";
		public static const COMMAND_SEND_CAMERAS:String = "sendCameras";
		public static const COMMAND_CAMERA_UPDATED:String = "cameraUpdated";
		public static const COMMAND_CAMERA_ADDED:String = "cameraAdded";
		public static const COMMAND_CAMERA_DELETED:String = "cameraDeleted";
		public static const COMMAND_ALL_CAMERAS_DELETED:String = "allCamerasDeleted";
		public static const COMMAND_GET_STREAM:String = "getStream";
		public static const COMMAND_SEND_STREAM:String = "sendStream";
		public static const COMMAND_STOP_STREAM:String = "stopStream";
		public static const COMMAND_CONNECT_CAMERA:String = "connectCamera";
		public static const COMMAND_DISCONNECT_CAMERA:String = "disconnectCamera";
		public static const COMMAND_CLOSE_CLIENT:String = "closeClient";
		public static const COMMAND_IS_ALIVE:String = "isAlive";
		public static const COMMAND_IM_ALIVE:String = "imAlive";
		public static const COMMAND_TOGGLE_CAMERA_OUTPUT:String = "toggleCameraOutput";
		public static const COMMAND_GET_SERVER_INFO:String = "getServerInfo";
		
		// New PULL logic
		public static const COMMAND_GET_STREAM_HEADER:String = "getStreamHeader";
		public static const COMMAND_SEND_STREAM_HEADER:String = "sendStreamHeader";
		public static const COMMAND_GET_STREAM_BYTES:String = "getStreamBytes";
		public static const COMMAND_SEND_STREAM_BYTES:String = "sendStreamBytes";
		public static const COMMAND_SEND_STREAM_BYTES_NOT_READY:String = "sendStreamBytesNotReady";
		
		private var socket:Socket;
		private var controlString:String;
		private var dataBytes:ByteArray;
		private var remainingSocketBytes:Number;
		private var chunk:DataSocketChunk;
		private var position:Number;
		private var initialized:Boolean;
		private var primaryAddressFailed:Boolean;
		private var secondaryAddressFailed:Boolean;
		private var usingSecondary:Boolean;
		
		public var enableCompression:Boolean;
		public var username:String;
		public var password:String;
		public var secret:String;
		public var authorized:Boolean;
		public var name:String;
		public var address:String;
		public var secondaryAddress:String;
		public var port:int;
		public var uid:String = "0";
		public var info:String;
		public var deviceOS:String;
		public var deviceModel:String;
		public var keepAliveTimer:Timer;
		public var serverOS:String;
		public var serverBrandId:String;
		public var serverBrandName:String;
		public var forcedClose:Boolean;
		public var waitingForData:Boolean;
		public var serverInfo:Object;
		public var supportsUDP:Boolean;
		public var supportsPull:Boolean;
		public var useUDP:Boolean;
		public var mtu:int;
		public var version:String;
		public var udpVersion:int;
		public var rtmp:Boolean;
		
		// UDP
		internal var useUDPStreaming:Boolean;
		private var udpSocket:DatagramSocket;
		private var localUDPPort:int;
		internal var localUDPAddress:String;
		
		public function DataSocket( sourceSocket:* = null, preferInternalNetwork:Boolean = false, udpStreaming:Boolean = false ) {
			
			super();
			
			useUDPStreaming = udpStreaming;
			
			if ( sourceSocket ) {
				
				if ( sourceSocket is Socket ) {
				
					socket = sourceSocket;
					initialized = true;
					
				} else if ( sourceSocket is XML ) {
					
					socket = new Socket();
					
					if ( !preferInternalNetwork ) {
						
						address = String( sourceSocket.address );
						if ( sourceSocket.secondaryAddress != undefined ) secondaryAddress = String( sourceSocket.secondaryAddress );
						
					} else {
						
						if ( sourceSocket.secondaryAddress != undefined ) {
							
							address = String( sourceSocket.secondaryAddress );
							secondaryAddress = String( sourceSocket.address );
							
						} else {
							
							address = String( sourceSocket.address );
							
						}
					}
					name = String( sourceSocket.name );
					secret = String( sourceSocket.secret );
					port = int( sourceSocket.port );
					
				}
				
			} else {
				
				socket = new Socket();
				
			}
			
			socket.addEventListener( Event.CONNECT, socketConnected );
			socket.addEventListener( Event.CLOSE, socketClosed );
			socket.addEventListener( ProgressEvent.SOCKET_DATA, socketProgress );
			socket.addEventListener( IOErrorEvent.IO_ERROR, socketIOError );
			
			dataBytes = new ByteArray();
			
		}
		
		private function socketConnected( e:Event ):void {
			
			usingSecondary = false;
			primaryAddressFailed = false;
			secondaryAddressFailed = false;
			
			sendInitCommand();
			
		}
		
		private function sendInitCommand():void {
			
			writeObject( { command:COMMAND_INITIALIZE }, true );
			
		}
		
		private function socketClosed( e:Event ):void {
			
			disposeUDPSocket();
			this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CLOSED ) );
			
		}
		
		private function socketProgress( e:ProgressEvent ):void {
			
			remainingSocketBytes = socket.bytesAvailable;
			
			while ( remainingSocketBytes > 0 ) {
				
				if ( controlString == null ) {
					
					controlString = readControlString();
					chunk = new DataSocketChunk( controlString );
					if ( chunk.error ) {
						
						controlString = null;
						this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CHUNK_ERROR ) );
						return;
						
					}
					remainingSocketBytes -= DATA_LENGTH;
					position = DATA_LENGTH;
					
				}
				
				if ( chunk && ( chunk.remainingBytes > 0 ) ) {
					
					var ba:ByteArray = new ByteArray();
					
					if ( chunk.remainingBytes <= remainingSocketBytes ) {
						
						remainingSocketBytes -= chunk.remainingBytes;
						socket.readBytes( ba, 0, chunk.remainingBytes );
						chunk.addData( ba );
						
					} else {
						
						socket.readBytes( ba, 0, remainingSocketBytes );
						chunk.addData( ba );
						remainingSocketBytes = 0;
						
					}
					
					position = 0;
					
				}
					
				if ( chunk && ( chunk.remainingBytes <= 0 ) ) {
				
					if ( initialized ) {
						
						var evt:DataSocketEvent = new DataSocketEvent( DataSocketEvent.CHUNK_READY );
						evt.chunk = chunk;
						this.dispatchEvent( evt );
						controlString = null;
						
					} else {
						
						if ( chunk.data is Object ) {
							
							//for ( var s:String in chunk.data ) trace( '-----', s, chunk.data[s] );
							
							if ( chunk.data.result == true ) {
								
								initialized = true;
								serverOS = chunk.data.os;
								serverBrandId = chunk.data.brandId;
								serverBrandName = chunk.data.brandName;
								this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CONNECTED ) );
								
							} else {
								
								initialized = false;
								this.dispatchEvent( new DataSocketEvent( DataSocketEvent.UNAUTHORIZED ) );
								
							}
							
						}
						
					}
					
				}
				
			}
			
		}
		
		private function processInputBytes( ):void {
			
			
			
		}
		
		private function socketIOError( e:IOErrorEvent ):void {
			
			trace( "error" );
			
			if ( !usingSecondary ) {
				
				if ( secondaryAddress ) {
					
					connect( true );
					
				} else {
					
					this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CONNECTION_ERROR ) );
					
				}
				
			} else {
				
				this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CONNECTION_ERROR ) );
				
			}
			
		}
		
		private function flush():void {
			
			socket.flush();
			
		}
		
		private function numberToString( n:Number ):String {
			
			var s:String = String( n );
			
			if ( n < 10000000 ) s = "0" + s;
			if ( n < 1000000 ) s = "0" + s;
			if ( n < 100000 ) s = "0" + s;
			if ( n < 10000 ) s = "0" + s;
			if ( n < 1000 ) s = "0" + s;
			if ( n < 100 ) s = "0" + s;
			if ( n < 10 ) s = "0" + s;
			
			return s;
			
		}
		
		//
		// Public functions
		//
		
		public function connect( useSecondaryAddress:Boolean = false ):void {
			
			if ( useSecondaryAddress ) {
				
				usingSecondary = true;
				socket.removeEventListener( Event.CONNECT, socketConnected );
				socket.removeEventListener( Event.CLOSE, socketClosed );
				socket.removeEventListener( ProgressEvent.SOCKET_DATA, socketProgress );
				socket.removeEventListener( IOErrorEvent.IO_ERROR, socketIOError );
				socket = null;
				
				socket = new Socket();
				socket.addEventListener( Event.CONNECT, socketConnected );
				socket.addEventListener( Event.CLOSE, socketClosed );
				socket.addEventListener( ProgressEvent.SOCKET_DATA, socketProgress );
				socket.addEventListener( IOErrorEvent.IO_ERROR, socketIOError );
				
				trace( "connect secondary", secondaryAddress, port );
				socket.connect( secondaryAddress, port );
				
			} else {
				
				usingSecondary = false;
				trace( "connect primary", address, port );
				socket.connect( address, port );
				//connect( true );
				
			}
			
		}
		
		public function update( config:Object ):void {
			
			supportsPull = Boolean( config.supportsPull );
			supportsUDP = Boolean( config.supportsUDP );
			useUDP = Boolean( config.useUDP );
			mtu = int( config.mtu );
			version = String( config.version );
			udpVersion = int( config.udpVersion );
			rtmp = Boolean( config.hasRTMPServer );
			
			if ( useUDPStreaming ) createUDPSocket();
			
		}
		
		private function createUDPSocket():void {
			
			disposeUDPSocket();
			
			udpSocket = new DatagramSocket();
			udpSocket.bind( 0, socket.localAddress );
			localUDPPort = udpSocket.localPort;
			localUDPAddress = socket.localAddress;
			udpSocket.addEventListener( DatagramSocketDataEvent.DATA, udpData );
			udpSocket.receive();
			
		}
		
		public function readControlString():String {
			
			return socket.readUTFBytes( DATA_LENGTH );
			
		}
		
		public function readData( ba:ByteArray ):void {
			
			ba.writeBytes( dataBytes );
			
		}
		
		public function writeObject( o:*, compress:Boolean = false ):void {
			
			o.username = username;
			o.password = password;
			o.secret = secret;
			o.uid = uid;
			o.info = info;
			o.deviceOS = deviceOS;
			o.deviceModel = deviceModel;
			o.useUDPStreaming = useUDPStreaming;
			o.udpPort = localUDPPort;
			o.udpAddress = localUDPAddress;
			o.udpVersion = udpVersion;
			o.rtmp = rtmp;
			o.uid = uid;
			var db:ByteArray = new ByteArray();
			db.writeObject( o );
			if ( compress ) db.deflate();
			var s:String = DATA_ROOT + DATA_DIVIDER + DATA_TYPE_OBJECT + DATA_DIVIDER + numberToString( db.length ) + DATA_DIVIDER + String( int( compress ) );
			writeData( s, db );
			
		}
		
		private function writeData( pre:String, ba:ByteArray ):void {
			
			socket.writeUTFBytes( pre );
			socket.flush();
			
			socket.writeBytes( ba );
			socket.flush();
			
			ba.clear();
			ba = null;
			
		}
		
		public function close():void {
			
			initialized = false;
			controlString = null;
			
			this.dispatchEvent( new DataSocketEvent( DataSocketEvent.CLOSED ) );
			
			if ( useUDPStreaming ) disposeUDPSocket();
			
			if ( socket ) {
				
				socket.removeEventListener( Event.CONNECT, socketConnected );
				socket.removeEventListener( Event.CLOSE, socketClosed );
				socket.removeEventListener( ProgressEvent.SOCKET_DATA, socketProgress );
				socket.removeEventListener( IOErrorEvent.IO_ERROR, socketIOError );
				if ( socket.connected ) socket.close();
				
			}
			
			socket = null;
			
		}
		
		//
		// Getters and setters
		//
		
		public function get connected():Boolean {
			
			return ( socket && socket.connected );
			
		}
		
		public function get bytesAvailable():Number {
			
			return socket.bytesAvailable;
			
		}
		
		public function get xml():XML {
			
			var x:XML = new XML( "<server />" );
			x.name = this.name;
			x.address = this.address;
			x.port = this.port;
			x.secret = this.secret;
			x.uid = this.uid;
			return x;
			
		}
		
		public function get remoteAddress():String {
			
			if ( socket ) return socket.remoteAddress;
			return "";
			
		}
		
		public function get remotePort():int {
			
			if ( socket ) return socket.remotePort;
			return 0;
			
			
		}
		
		public function get udpStreamingEnabled():Boolean {
			
			return useUDPStreaming;
			
		}
		
		public function get udpPort():int {
			
			return localUDPPort;
			
		}
		
		public function set udpPort( value:int ):void {
			
			localUDPPort = value;
			
		}
		
		public function get udpAddress():String {
			
			return localUDPAddress;
			
		}
		
		private function udpData( e:DatagramSocketDataEvent ):void {
			
			//trace( "udpData", e.data.length );
			var evt:DataSocketEvent = new DataSocketEvent( DataSocketEvent.DATA );
			evt.data = e.data;
			this.dispatchEvent( evt );
			
		}
		
		private function disposeUDPSocket():void {
			
			if ( udpSocket ) {
				
				udpSocket.removeEventListener( DatagramSocketDataEvent.DATA, udpData );
				udpSocket.close();
				udpSocket = null;
				
			}
			
		}
		
		public function getUDPProperties():Object {
			
			return { address:udpSocket.localAddress, port:udpSocket.localPort, uid:uid };
			
		}
		
	}

}