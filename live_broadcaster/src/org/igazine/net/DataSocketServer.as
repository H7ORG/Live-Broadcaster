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
	import flash.net.ServerSocket;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.Event;
	import org.igazine.events.DataSocketEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class DataSocketServer extends EventDispatcher {
		
		private var serverSocket:ServerSocket;
		private var allowConnections:Boolean;
		
		public var username:String;
		public var password:String;
		public var secret:String;
		public var port:int;
		public var clients:Vector.<DataSocket> = new Vector.<DataSocket>();
		public var keepAliveInterval:Number;
		public var os:String;
		public var brandId:String;
		public var brandName:String;
		public var allowAnonymousConnections:Boolean;
		public var rtmp:Boolean;
		
		public function DataSocketServer() {
			
			super();
			
		}
		
		public function open():void {
			
			if ( !serverSocket ) {
				
				serverSocket = new ServerSocket();
				serverSocket.bind( port );
				serverSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onSocketConnect );
				serverSocket.addEventListener( Event.CLOSE, onSocketServerClose );
				serverSocket.listen();
				
			} else {
				
				serverSocket.removeEventListener( ServerSocketConnectEvent.CONNECT, onSocketConnect );
				serverSocket.removeEventListener( Event.CLOSE, onSocketServerClose );
				serverSocket.close();
				serverSocket = null;
				serverSocket = new ServerSocket();
				serverSocket.bind( port );
				serverSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onSocketConnect );
				serverSocket.addEventListener( Event.CLOSE, onSocketServerClose );
				serverSocket.listen();
				
			}
			
			allowConnections = true;
			
		}
		
		private function onSocketServerClose( e:Event ):void {
			
			serverSocket.removeEventListener( ServerSocketConnectEvent.CONNECT, onSocketConnect );
			serverSocket.removeEventListener( Event.CLOSE, onSocketServerClose );
			serverSocket = null;
			
		}
		
		public function close():void {
			
			for ( var i:int = clients.length-1; i >= 0; i-- ) {
				
				var cs:DataSocket = clients.removeAt( i ) as DataSocket;
				cs.removeEventListener( DataSocketEvent.CLOSED, clientSocketClose );
				cs.removeEventListener( DataSocketEvent.CHUNK_READY, chunkReady );
				cs.removeEventListener( DataSocketEvent.UNAUTHORIZED, clientUnauthorized );
				cs.writeObject( { command:DataSocket.COMMAND_CLOSE_CLIENT }, true );
				if ( cs.connected ) cs.close();
				cs = null;
				
			}
			
			allowConnections = false;
			
		}
		
		private function onSocketConnect( e:ServerSocketConnectEvent ):void {
			
			if ( !allowConnections ) {
				
				e.socket.close();
				return;
				
			}
			
			this.dispatchEvent( e );
			
			var clientSocket:DataSocket = new DataSocket( e.socket );
			clients.push( clientSocket );
			clientSocket.addEventListener( DataSocketEvent.CLOSED, clientSocketClose );
			clientSocket.addEventListener( DataSocketEvent.CHUNK_READY, chunkReady );
			clientSocket.addEventListener( DataSocketEvent.UNAUTHORIZED, clientUnauthorized );
			
		}
		
		private function clientUnauthorized( e:DataSocketEvent ):void {
			
			e.target.close();
			this.dispatchEvent( e );
			
		}
		
		private function chunkReady( e:DataSocketEvent ):void {
			
			if ( e.chunk.data is Object ) processClientSocketCommand( e.target as DataSocket, e.chunk.data );
			
		}
		
		private function clientSocketClose( e:Event ):void {
			
			e.target.removeEventListener( DataSocketEvent.CLOSED, clientSocketClose );
			e.target.removeEventListener( DataSocketEvent.CHUNK_READY, chunkReady );
			e.target.removeEventListener( DataSocketEvent.UNAUTHORIZED, clientUnauthorized );
			
			var cs:DataSocket;
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				if ( clients[i].uid == e.target.uid ) {
					
					cs = clients.removeAt( i ) as DataSocket;
					break;
					
				}
				
			}
			
			if ( cs ) {
				
				stopKeepAliveTimer( cs );
				var disconnectEvent:DataSocketEvent = new DataSocketEvent( DataSocketEvent.CLIENT_DISCONNECTED );
				disconnectEvent.clientInfo = new Object();
				disconnectEvent.clientInfo.uid = cs.uid;
				disconnectEvent.clientInfo.info = cs.info;
				disconnectEvent.clientInfo.remoteAddress = cs.remoteAddress;
				disconnectEvent.clientInfo.remotePort = cs.remotePort;
				this.dispatchEvent( disconnectEvent );
				
			}
			
		}
		
		private function processClientSocketCommand( socket:DataSocket, o:Object ):void {
			
			//for ( var s:String in o ) trace( ";;;;;;;", s, o[s] );
			
			socket.uid = o.uid;
			socket.info = o.info;
			socket.deviceModel = o.deviceModel;
			socket.deviceOS = o.deviceOS;
			socket.useUDPStreaming = Boolean( o.useUDPStreaming );
			socket.udpPort = int( o.udpPort );
			socket.localUDPAddress = String( o.udpAddress );
			socket.uid = o.uid;
			
			if ( !authorized( o ) ) {
				
				socket.forcedClose = true;
				socket.writeObject( { result:false } );
				socket.close();
				return;
				
			}
			
			updateKeepAliveTimer( socket );
				
			if ( o.command == DataSocket.COMMAND_INITIALIZE ) {
				
				socket.writeObject( { result:true, os:os, brandId:brandId, brandName:brandName }, true );
				createKeepAliveTimer( socket );
				
			} else {
				
				updateKeepAliveTimer( socket );
				
			}
			
			var connectEvent:DataSocketEvent = new DataSocketEvent( DataSocketEvent.CLIENT_COMMAND );
			connectEvent.clientInfo = o;
			connectEvent.clientInfo.remoteAddress = socket.remoteAddress;
			connectEvent.clientInfo.remotePort = socket.remotePort;
			connectEvent.socket = socket;
			this.dispatchEvent( connectEvent );
	
		}
		
		private function authorized( o:Object ):Boolean {
			
			//return ( ( o.username == username ) && ( o.password == password ) && ( o.secret == secret ) );
			
			if ( ( o.username == username ) && ( o.password == password ) ) return true;
			if ( ( o.secret == secret ) && allowAnonymousConnections ) return true;
			return false;
			
		}
		
		public function writeObjectToAllClients( o:Object, compress:Boolean = false ):void {
			
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				clients[i].writeObject( o, compress );
				
			}
			
		}
		
		public function get numClients():int {
			
			return clients.length;
			
		}
		
		public function closeClientByUID( s:String ):void {
			
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				if ( clients[i].uid == s ) {
					
					var cs:DataSocket = clients.removeAt( i ) as DataSocket;
					
					cs.writeObject( { command:DataSocket.COMMAND_CLOSE_CLIENT }, true );
					cs.removeEventListener( DataSocketEvent.CLOSED, clientSocketClose );
					cs.removeEventListener( DataSocketEvent.CHUNK_READY, chunkReady );
					cs.removeEventListener( DataSocketEvent.UNAUTHORIZED, clientUnauthorized );
					
					var disconnectEvent:DataSocketEvent = new DataSocketEvent( DataSocketEvent.CLIENT_DISCONNECTED );
					disconnectEvent.clientInfo = new Object();
					disconnectEvent.clientInfo.uid = cs.uid;
					disconnectEvent.clientInfo.info = cs.info;
					disconnectEvent.clientInfo.remoteAddress = cs.remoteAddress;
					disconnectEvent.clientInfo.remotePort = cs.remotePort;
					this.dispatchEvent( disconnectEvent );
					
					cs.close();
					
				}
				
			}
			
		}
		
		private function createKeepAliveTimer( socket:DataSocket ):void {
			
			if ( !socket.keepAliveTimer ) {
				
				socket.keepAliveTimer = new Timer( keepAliveInterval * 1000 );
				socket.keepAliveTimer.addEventListener( TimerEvent.TIMER, keepAliveTimerEvent );
				
			}
			
			socket.keepAliveTimer.start();
			
		}
		
		private function updateKeepAliveTimer( socket:DataSocket ):void {
			
			if ( socket.keepAliveTimer ) {
				
				socket.keepAliveTimer.reset();
				socket.keepAliveTimer.start();
				
			}
			
		}
		
		private function keepAliveTimerEvent( e:TimerEvent ):void {
			
			var cli:DataSocket = getClientByTimer( e.target as Timer );
			
			if ( ( e.target as Timer ).currentCount == 1 ) {
				
				if ( cli != null ) cli.writeObject( { command:DataSocket.COMMAND_IS_ALIVE } );
				
			} else {
				
				if ( cli != null ) {
					
					stopKeepAliveTimer( cli );
					cli.close();
					
				}
				
			}
				
		}
		
		private function stopKeepAliveTimer( socket:DataSocket ):void {
			
			if ( socket && socket.keepAliveTimer ) {
				
				socket.keepAliveTimer.stop();
				socket.keepAliveTimer.removeEventListener( TimerEvent.TIMER, keepAliveTimerEvent );
				
			}
			
		}
		
		private function getClientByTimer( timer:Timer ):DataSocket {
			
			for ( var i:int = 0; i < clients.length; i++ ) {
				
				if ( clients[i].keepAliveTimer == timer ) return clients[i];
				
			}
			
			return null;
			
		}
		
	}

}