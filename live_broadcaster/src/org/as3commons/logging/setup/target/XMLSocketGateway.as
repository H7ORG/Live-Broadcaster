/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.setup.target {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.XMLSocket;
	
	/**
	 * <code>XMLSocketGateway</code> is a abstract class to support sending
	 * messages using a xml socket.
	 * 
	 * <p>It sends out messages in intervals. The connection will be started upon
	 * the first log request. In case the connection was not established due to
	 * an IOError or after its closed it will try to reconnect to the server.</p>
	 * 
	 * <p>The implementation has to use <code>doLog</code> to send log messages.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 */
	public class XMLSocketGateway {
		
		private const _timer: Timer = new Timer(0);
		private const _buffer: Array = [];
		
		private var _host: String;
		private var _port: uint;
		private var _socket: XMLSocket;
		private var _ready: Boolean = false;
		private var _broken: Boolean = false;
		private var _maxBufferSize: int;
		private var _prefix: String;
		
		/**
		 * Constructs a new <code>XMLSocketGateway</code>
		 * 
		 * @param host Host on which the client is running (default: localhost)
		 * @param port Port on which the client is running (default: 4444)
		 * @param sendInterval Interval on which message should be sent out
		 * @param maxBufferSize Maximal amount of messages sent in one request
		 * @param prefix Prefix to be added when sending the messages
		 */
		public function XMLSocketGateway(host:String, port:uint, sendInterval:int=200, maxBufferSize:int=int.MAX_VALUE, prefix:String="") {
			_host = host;
			_port = port;
			_prefix = prefix || "";
			_maxBufferSize = maxBufferSize;
			_timer.delay = sendInterval;
			_timer.addEventListener( TimerEvent.TIMER, sendBuffer, false, 0, true );
		}
		/**
		 * Logs a Statement to the XMLSocket.
		 * 
		 * @param message 
		 */
		protected function doLog(message: String): void {
			if( message ) {
				_buffer.push( message );
				if( !_timer.running ) {
					_timer.start();
				}
			}
		}
		
		private function sendBuffer(e:Event=null): void {
			if( !_ready ) {
				if( !_broken ) {
					if( !_socket ) {
						_socket = new XMLSocket();
						_socket.addEventListener( Event.CLOSE, onConnectionClosed );
						_socket.addEventListener( Event.CONNECT, onConnectionToSOSestablished );
						_socket.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
						_socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
						try {
							_socket.connect( _host, _port );
						} catch ( e: SecurityError ) {
							markAsBroken( "Connection to SOS was not allowed due to Security Error @"+_host+":"+_port+"]: " + e.message );
						}
					}
				}
			} else {
				var msg: String = _prefix;
				var bufferWritten: int = 0;
				while(_buffer.length > 0 ) {
					msg += _buffer.shift();
					++bufferWritten;
					if( bufferWritten >= _maxBufferSize ) {
						_socket.send(msg);
						msg = _prefix;
						bufferWritten = 0;
					}
				}
				if( bufferWritten > 0 ) {
					_socket.send(msg); 
				}
				_timer.stop();
			}
		}
		
		private function onConnectionToSOSestablished( event:Event ): void {
			_ready = true;
			sendBuffer();
		}
		
		private function onConnectionClosed(event: Event): void {
			close();
		}
		
		private function onIOError(event: IOErrorEvent): void {
			close();
		}
		
		private function close(): void {
			try {
				_socket.close();
			} catch( e: Error ) {}
			_socket = null;
			_ready = false;
			if( _buffer.length > 0 ) {
				sendBuffer();
			}
		}
		
		private function onSecurityError(event: SecurityErrorEvent): void {
			markAsBroken( "A security error prevented the connection to SOS @" + _host + ":" + _port );
		}
		
		private function markAsBroken( string: String): void {
			// Give the least of help for the developer
			trace( string );
			_broken = true;
			_ready = false;
			_socket.removeEventListener( Event.CLOSE, onConnectionClosed );
			_socket.removeEventListener( Event.CONNECT, onConnectionToSOSestablished );
			_socket.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			_socket.close();
			_socket = null;
		}
	}
}
