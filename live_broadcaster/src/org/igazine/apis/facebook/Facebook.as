package org.igazine.apis.facebook {

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
	
	public class Facebook extends EventDispatcher {
		
		private static const API_ADDRESS:String = "https://graph.facebook.com/v2.12/";
		private static const FB_ME:String = "me/";
		private static const FB_PERMISSIONS:String = "permissions/";
		private static const FB_ACCOUNTS:String = "accounts/";
		private static const FB_LIVE_VIDEOS:String = "live_videos/";
		private static const FB_COMMENTS:String = "comments/";
		private static const FB_LIKES:String = "likes/";
		private static const FB_PICTURE:String = "picture/";
		private static const FB_DEBUG_TOKEN:String = "debug_token/";
		
		internal static const API:String = API_ADDRESS;
		internal static const ME:String = API_ADDRESS + FB_ME;
		internal static const PERMISSIONS:String = API_ADDRESS + FB_ME + FB_PERMISSIONS;
		internal static const ACCOUNTS:String = API_ADDRESS + FB_ME + FB_ACCOUNTS;
		internal static const LIVE_VIDEOS:String = FB_LIVE_VIDEOS;
		internal static const DEBUG_TOKEN:String = API_ADDRESS + FB_DEBUG_TOKEN;
		
		public function Facebook( target:flash.events.IEventDispatcher = null ) {
			
			super(target);
			
		}
		
		public static function getVideoCommentsURI( id:String ):String {
			
			return API_ADDRESS + id + "/" + FB_COMMENTS;
			
		}
		
		public static function getVideoLikesURI( id:String ):String {
			
			return API_ADDRESS + id + "/" + FB_LIKES;
			
		}
		
		public static function getPictureURI( id:String ):String {
			
			return API_ADDRESS + id + "/" + FB_PICTURE;
			
		}
		
		public static function getVideoURI( id:String ):String {
			
			return API_ADDRESS + id + "/";
			
		}
		
	}

}