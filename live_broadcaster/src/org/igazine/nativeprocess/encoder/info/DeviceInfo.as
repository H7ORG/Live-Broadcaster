package org.igazine.nativeprocess.encoder.info {
	
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
	
	public class DeviceInfo {
		
		private var _entries:Vector.<DeviceInfoEntry> = new Vector.<DeviceInfoEntry>();
		private var _width:int;
		private var _height:int;
		private var _fps:Number;
		
		public function DeviceInfo() {
			
		}
		
		public function addEntry( e:DeviceInfoEntry ):void {
			
			_entries.push( e );
			
		}
		
		public function get entries():Vector.<DeviceInfoEntry> {
			
			return _entries;
			
		}
		
		public function sort():void {
			
			_entries.sort( sortByResolution );
			//_entries.sort( sortByFPS );
			//_entries.sort( sortByAll );
			
		}
		
		public function getNearestEntry( width:int, height:int, fps:Number, rawVideo:Boolean = true ):DeviceInfoEntry {
			
			var results:Vector.<DeviceInfoEntry> = new Vector.<DeviceInfoEntry>();
			_width = width;
			_height = height;
			_fps = fps;
			//results = _entries.filter( filterWidth, width );
			//results = results.filter( filterHeight, height );
			//results = results.filter( filterFPS, height );
			results = results.sort( sortByResolution );
			trace( '++++++++', results );
			return results[0];
			
		}
		
		private function filterWidth( item:DeviceInfoEntry, index:int, vector:Vector.<DeviceInfoEntry> ):Boolean {
			
			return ( item.width == _width );
			
		}
		
		private function filterHeight( item:DeviceInfoEntry, index:int, vector:Vector.<DeviceInfoEntry> ):Boolean {
			
			return ( item.height == _height );
			
		}
		
		private function filterFPS( item:DeviceInfoEntry, index:int, vector:Vector.<DeviceInfoEntry> ):Boolean {
			
			return ( item.maxFps >= _fps );
			
		}
		
		private function sortByAll( a:DeviceInfoEntry, b:DeviceInfoEntry ):Number {
			
			if ( a.width < b.width ) {
				
				if ( a.maxFps < b.maxFps ) return 1;
				if ( a.maxFps == b.maxFps ) return 0;
				if ( a.maxFps > b.maxFps ) return -1;
				
			}
			
			if ( a.width == b.width ) {
				
				if ( a.maxFps < b.maxFps ) return 1;
				if ( a.maxFps == b.maxFps ) return 0;
				if ( a.maxFps > b.maxFps ) return -1;
				
			}
			
			if ( a.width > b.width ) {
				
				if ( a.maxFps < b.maxFps ) return 1;
				if ( a.maxFps == b.maxFps ) return 0;
				if ( a.maxFps > b.maxFps ) return -1;
				
			}
			
			return 0;
			
		}
		
		private function sortByResolution( a:DeviceInfoEntry, b:DeviceInfoEntry ):Number {
			
			if ( a.width < b.width ) return 1;
			if ( a.width == b.width ) return 0;
			if ( a.width > b.width ) return -1;
			
			return 0;
			
		}
		
		private function sortByFPS( a:DeviceInfoEntry, b:DeviceInfoEntry ):Number {
			
			if ( a.maxFps < b.maxFps ) return 1;
			if ( a.maxFps == b.maxFps ) return 0;
			if ( a.maxFps > b.maxFps ) return -1;
			
			return 0;
			
		}
		
		public function contains( entry:DeviceInfoEntry ):Boolean {
			
			for ( var i:int = 0; i < _entries.length; i++ ) {
				
				if ( ( _entries[i].resolution == entry.resolution ) && ( _entries[i].minFps == entry.minFps ) && ( _entries[i].maxFps == entry.maxFps ) && ( _entries[i].vCodec == entry.vCodec ) ) return true;
				
			}
			
			return false;
			
		}
		
		public function dispose():void {
			
			for ( var i:int = 0; i < _entries.length; i++ ) {
				
				_entries[i].dispose();
				_entries[i] = null;
				
			}
			
		}
		
	}

}