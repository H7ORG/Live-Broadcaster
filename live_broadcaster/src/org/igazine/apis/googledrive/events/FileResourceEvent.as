package org.igazine.apis.googledrive.events {
	
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
	import org.igazine.apis.googledrive.resources.FileResource;
	
	public class FileResourceEvent extends Event {
		
		public static const ERROR:String = "fileResourceError";
		public static const ID_GENERATED:String = "fileResourceIdGenerated";
		public static const FILE_FOUND:String = "fileResourceFound";
		public static const COMPLETE:String = "fileResourceActionComplete";
		public static const DELETED:String = "fileResourceDeleted";
		public static const UPLOADED:String = "fileResourceUploaded";
		public static const DOWNLOADED:String = "fileResourceDownloaded";
		
		public var file:FileResource;
		public var files:Array;
		public var content:String;
		
		public function FileResourceEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) {
			
			super( type, bubbles, cancelable );
			
		}
		
	}

}