package org.igazine.apis.googledrive.resources {
	
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
	
	import com.adobe.serialization.json.JSON;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import org.igazine.apis.googledrive.GoogleDrive;
	
	public class FileResource {
		
		public static const BOUNDARY:String = "foo_bar_baz";
		public static const BOUNDARY_FULL:String = "--foo_bar_baz";
		
		private var _content:String;
		private var _contentType:String;
		private var _id:String;
		private var _name:String;
		private var _spaces:Array;
		private var _parents:Array;
		
		public function FileResource() {
			
			
			
		}
		
		//
		// Factory
		//
		
		public static function create( data:String ):FileResource {
			
			var f:FileResource = new FileResource();
			return f;
			
		}
		
		//
		// Public functions
		//
		
		public function addSpace( space:String ):void {
			
			if ( !_spaces ) _spaces = [];
			_spaces.push( space );
			
		}
		
		public function addParent( parent:String ):void {
			
			if ( !_parents ) _parents = [];
			_parents.push( parent );
			
		}
		
		public function generateId( space:String = "appDataFolder" ):void {
			
		}
		
		//
		// Getters and Setters
		//
		
		public function get metadata():String {
			
			var s:String;
			var o:Object = {};
			if ( _name ) o.name = _name;
			if ( _id ) o.id = _id;
			if ( _spaces ) o.spaces = _spaces;
			if ( _parents ) o.parents = _parents;
			s = com.adobe.serialization.json.JSON.encode( o );
			return s;
			
		}
		
		public function get content():String {
			
			return _content;
			
		}
		
		public function set content( s:String ):void {
			
			_content = s;
			
		}
		
		public function get contentType():String {
			
			return _contentType;
			
		}
		
		public function set contentType( s:String ):void {
			
			_contentType = s;
			
		}
		
		public function get id():String {
			
			return _id;
			
		}
		
		public function set id( s:String ):void {
			
			_id = s;
			
		}
		
		public function get name():String {
			
			return _name;
			
		}
		
		public function set name( s:String ):void {
			
			_name = s;
			
		}
		
	}

}