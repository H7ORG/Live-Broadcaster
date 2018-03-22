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
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	
	public class StreamingSocketServer extends EventDispatcher {
		
		private var _socket:DatagramSocket;
		private var _mtu:int;
		private var _headerBytes:ByteArray = new ByteArray();
		private var _clients:Vector.<StreamingSocketClient> = new Vector.<StreamingSocketClient>();
		private var _chunks:Vector.<ByteArray> = new Vector.<ByteArray>();
		private var _chunkId:uint = 0;
		
		public function StreamingSocketServer( ) {
			
			super( );
			_socket = new DatagramSocket();
			
		}
		
		public function open():void {
			
			
			
		}
		
		//
		// Getters and Setters
		// 
		
		public function get mtu():int { return _mtu }
		public function set mtu( value:int ):void { _mtu = value }
		
		public function set headerBytes( bytes:ByteArray ):void {
			
			bytes.readBytes( _headerBytes );
			
		}
		
		//
		// UDP Client functions
		//
		
		public function addClient( client:StreamingSocketClient ):void {
			
			_clients.push( client );
			trace( "StreamingSocketServer.addClient", client.address, client.port, client.uid );
			_socket.send( _headerBytes, 0, 0, client.address, client.port );
			//_socket.send( createChunk( _headerBytes ), 0, 0, client.address, client.port );
			trace( "StreamingSocketServer.headerBytes", _headerBytes.length );
			
		}
		
		public function removeClientByUID( uid:String ):void {
			
			trace( "StreamingSocketServer.removeClientByUID", uid );
			
			for ( var i:int = 0; i < _clients.length; i++ ) {
				
				if ( _clients[i].uid == uid ) {
					
					_clients.removeAt( i );
					break;
					
				}
				
			}
			
		}
		
		//
		// Data functions
		//
		
		public function writeBytes( bytes:ByteArray ):void {
			
			trace( "StreamingSocketServer.writeBytes", bytes.length );
			
			if ( _clients.length > 0 ) {
				
				updateChunks( bytes );
				sendChunks();
				
			}
			
		}
		
		private function createChunk( bytes:ByteArray, position:uint = 0, length:uint = 0 ):ByteArray {
			
			var ba:ByteArray = new ByteArray();
			ba.writeInt( _chunkId );
			ba.writeBytes( bytes, position, length );
			_chunkId++;
			return ba;
			
		}
		
		private function updateChunks( bytes:ByteArray ):void {
			
			var numChunks:int = bytes.length / mtu;
			var finalNumBytes:int = bytes.length % mtu;
			var i:int = 0;
			var ba:ByteArray;
			
			for ( i = 0; i < numChunks; i++ ) {
				
				bytes.position = 0;
				
				ba = new ByteArray();
				ba.writeBytes( bytes, i * mtu, mtu );
				
				//ba = createChunk( bytes, i * mtu, mtu );
				_chunks.push( ba );
				
			}
			
			if ( finalNumBytes > 0 ) {
				
				
				ba = new ByteArray();
				ba.writeBytes( bytes, i * mtu, finalNumBytes );
				
				//ba = createChunk( bytes, i * mtu, finalNumBytes );
				_chunks.push( ba );
				
			}
			
		}
		
		private function sendChunks():void {
			
			if ( _chunks.length == 0 ) return;
			
			while( _chunks.length > 0 ) {
			
				for ( var i:int = 0; i < _clients.length; i++ ) {
					
					trace( "StreamingSocketServer.sendChunks", _chunks[0].length, _clients[i].address, _clients[i].port );
					_socket.send( _chunks[0], 0, 0, _clients[i].address, _clients[i].port );
					
				}
				
				var ba:ByteArray = _chunks.removeAt( 0 ) as ByteArray;
				//ba.clear();
				ba = null;
				
			}
			
		}
		
	}

}