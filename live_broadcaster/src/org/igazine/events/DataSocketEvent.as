package org.igazine.events {
	
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
	import org.igazine.net.DataSocket;
	import org.igazine.net.DataSocketChunk;
	
	public class DataSocketEvent extends Event {
		
		public static const CHUNK_READY:String = "chunkReady";
		public static const CHUNK_ERROR:String = "chunkError";
		public static const UNAUTHORIZED:String = "unauthorized";
		public static const CONNECTION_ERROR:String = "connectionError";
		public static const CONNECTED:String = "connected";
		public static const CLOSED:String = "closed";
		public static const CLIENT_CONNECTED:String = "clientConnected";
		public static const CLIENT_COMMAND:String = "clientCommand";
		public static const CLIENT_DISCONNECTED:String = "clientDisconnected";
		public static const DATA:String = "clientDataAvailable";
		
		public var chunk:DataSocketChunk;
		public var clientInfo:Object;
		public var socket:DataSocket;
		public var data:ByteArray;
		public var uid:String;
		
		public function DataSocketEvent( type:String ) {
			
			super( type );
			
		}
		
	}

}