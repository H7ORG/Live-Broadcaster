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

package org.igazine.apis.events {
	
	import flash.events.Event;
	import org.igazine.apis.youtube.LiveBroadcast;
	import org.igazine.apis.youtube.LiveBroadcastListResponse;
	import org.igazine.apis.youtube.LiveChatMessageListResponse;
	import org.igazine.apis.youtube.LiveStream;
	import org.igazine.apis.youtube.LiveStreamListResponse;
	import org.igazine.apis.youtube.VideoListResponse;
	
	public class YouTubeEvent extends Event {
		
		public static const ERROR:String = "youtTubeError";
		public static const LIVE_STREAM_CREATED:String = "youtTubeLiveStreamCreated";
		public static const LIVE_BROADCAST_CREATED:String = "youtTubeLiveBroadcastCreated";
		public static const LIVE_BROADCAST_COMPLETED:String = "youtTubeLiveBroadcastCompleted";
		public static const LIVE_BROADCAST_BOUND_TO_STREAM:String = "youtTubeLiveBroadcastBoundToStream";
		public static const LIVE_BROADCAST_LIST_LOADED:String = "youtTubeLiveBroadcastListLoaded";
		public static const LIVE_BROADCAST_TRANSITIONED:String = "youtTubeLiveBroadcastTransitioned";
		public static const LIVE_BROADCAST_UPDATED:String = "youtTubeLiveBroadcastUpdated";
		public static const LIVE_STREAM_LIST_LOADED:String = "youtTubeLiveStreamListLoaded";
		public static const LIVE_STREAM_UPDATED:String = "youtTubeLiveStreamUpdated";
		public static const LIVE_STREAM_ERROR:String = "youtTubeLiveStreamError";
		public static const LIVE_CHAT_MESSAGES_LOADED:String = "youtTubeLiveChatMessagesLoaded";
		public static const VIDEO_LIST_LOADED:String = "youtTubeVideoListLoaded";
		
		public var liveStream:LiveStream;
		public var liveBroadcast:LiveBroadcast;
		public var liveBroadcastListResponse:LiveBroadcastListResponse;
		public var liveStreamListResponse:LiveStreamListResponse;
		public var liveChatMessageListResponse:LiveChatMessageListResponse;
		public var videoListResponse:VideoListResponse;
		public var error:String;
		public var errorCode:int;
		
		public function YouTubeEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) {
			
			super( type, bubbles, cancelable );
			
		}
		
	}

}