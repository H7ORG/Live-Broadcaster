package live.cameleon.settings {

/**
 * 
 * Live Broadcaster
 * Live Streaming Software for Mac / Windows
 * Copyright (c) 2014 - 2017 Yatko (LLC) and Kalman Venczel
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
 * Author: Tamas Sopronyi, 2017
 * 
 */
 	
	public class URLs {
		
		// Links
		public static const LINK_WEBSITE:String = "https://app.h7.org/cameleon/";
		public static const LINK_FACEBOOK:String = "https://community.h7.org/category/33/cameleon-air-apps/";
		public static const LINK_FACEBOOK_BEST_PRACTICES:String = "https://www.facebook.com/facebookmedia/best-practices/live";
		public static const LINK_FACEBOOK_COMMUNITY_STANDARDS:String = "http://newsroom.fb.com/news/h/community-standards-and-facebook-live/";
		public static const LINK_FACEBOOK_APP_SETTINGS:String = "https://www.facebook.com/settings?tab=applications";
		public static const LINK_YOUTUBE_LIVE_STREAMING_HELP:String = "https://support.google.com/youtube/answer/2474026?hl=en";
		public static const LINK_YOUTUBE_LIVE_DASHBOARD:String = "https://www.youtube.com/live_dashboard";
		
		public static const LICENSE_PURCHASE:String = "https://cameleon.live";
		
		// Server app
		public static const SERVER_APP_NAME:String = "LiveBroadcaster";
		public static const SERVER_STREAM_NAME:String = "LiveBroadcasterStream";
		public static const SERVER_ADDRESS:String = "localhost";
		public static const SERVER_PROTOCOL:String = "rtmp://";
		
		public function URLs() {}
		
		/*
		public static function get SERVER_FULL_ADDRESS():String {
			
			return SERVER_PROTOCOL + SERVER_ADDRESS + ":" + settings.UserSettings.rtmpPort + "/" + SERVER_APP_NAME + "/"
			
		}
		*/
		
	}

}