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

package org.igazine.apis.youtube {
	
	import com.adobe.serialization.json.JSON;
	
	public class IngestionInfo implements IResource {
		
		private var _object:Object = new Object();
		
		public function IngestionInfo() {
			
		}
		
		public static function create( value:Object ):IngestionInfo {
			
			var i:IngestionInfo = new IngestionInfo();
			i._object = value;
			return i;
			
		}
		
		public function update( value:Object ):void {
			
			for ( var i:String in value ) _object[i] = value[i];
			
		}
		
		public function dispose():void {
			
			_object = null;
			
		}
		
		/* INTERFACE org.igazine.apis.youtube.IResource */
		
		public function get json():String {
			
			return com.adobe.serialization.json.JSON.encode( _object );
			
		}
		
		public function get object():Object {
			
			return _object;
			
		}
		
		public function get streamName():String {
			
			return _object["streamName"];
			
		}
		
		public function get ingestionAddress():String {
			
			return _object["ingestionAddress"];
			
		}
		
		public function get backupIngestionAddress():String {
			
			return _object["backupIngestionAddress"];
			
		}
		
	}

}