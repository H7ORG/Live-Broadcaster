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
	
	public class DataSocketChunk {
		
		private var bytes:ByteArray;
		private var alreadyUncompressed:Boolean;
		
		public var type:String;
		public var length:Number;
		public var compressed:Boolean;
		public var error:Boolean;
		
		public function DataSocketChunk( tag:String ) {
			
			//trace( "DataSocketChunk", tag, tag.split( DataSocket.DATA_DIVIDER ) );
			
			if ( String( tag.split( DataSocket.DATA_DIVIDER )[0] ) != DataSocket.DATA_ROOT ) {
				
				//throw new TypeError( "DataSocketChunk is invalid" );
				error = true;
				return;
				
			} else {
			
				type = String( tag.split( DataSocket.DATA_DIVIDER )[1] );
				length = Number( tag.split( DataSocket.DATA_DIVIDER )[2] );
				compressed = Boolean( int( tag.split( DataSocket.DATA_DIVIDER )[3] ) );
				bytes = new ByteArray();
				
			}
		}
		
		public function addData( ba:ByteArray ):void {
			
			bytes.writeBytes( ba );
			
		}
		
		public function get remainingBytes():Number {
			
			return length - bytes.length;
			
		}
		
		public function get data():* {
			
			switch ( type ) {
				
				case DataSocket.DATA_TYPE_OBJECT:
					bytes.position = 0;
					
					if ( compressed ) {
						
						if ( !alreadyUncompressed ) {
							
							bytes.inflate();
							alreadyUncompressed = true;
							
						}
						
					}
					
					return bytes.readObject();
					break;
				
				case DataSocket.DATA_TYPE_BYTES:
					return bytes;
					break;
				
			}
			
		}
		
		public function dispose():void {
			
			bytes.clear();
			bytes = null;
			
		}
		
	}

}