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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import org.igazine.apis.events.YouTubeEvent;
	
	public class YouTube extends EventDispatcher {
		
		private static const BASE_URL:String = "https://www.googleapis.com/youtube/v3/";
		private static const SEARCH:String = "search";
		private static const LIVE_STREAMS:String = "liveStreams";
		private static const LIVE_BROADCASTS:String = "liveBroadcasts";
		private static const LIVE_CHAT_MESSAGES:String = "liveChat/messages";
		private static const VIDEOS:String = "videos";
		
		private static const KIND_LIVE_STREAM:String = "youtube#liveStream";
		private static const KIND_LIVE_BROADCAST:String = "youtube#liveBroadcast";
		private static const KIND_LIVE_BROADCAST_LIST_RESPONSE:String = "youtube#liveBroadcastListResponse";
		private static const KIND_LIVE_STREAM_LIST_RESPONSE:String = "youtube#liveStreamListResponse";
		private static const KIND_LIVE_CHAT_MESSAGE_LIST_RESPONSE:String = "youtube#liveChatMessageListResponse";
		private static const KIND_VIDEO:String = "youtube#video";
		private static const KIND_VIDEO_LIST_RESPONSE:String = "youtube#videoListResponse";
		
		public static const PART_ID:String = "id";
		public static const PART_SNIPPET:String = "snippet";
		public static const PART_STATUS:String = "status";
		public static const PART_CDN:String = "cdn";
		public static const PART_CONTENT_DETAILS:String = "contentDetails";
		public static const PART_STATISTICS:String = "statistics";
		public static const PART_LIVE_STREAMING_DETAILS:String = "liveStreamingDetails";
		
		private var rToken:String;
		private var loaders:Array = new Array();
		private var requests:Array = new Array();
		
		private var liveChatLoader:YouTubeLoader;
		private var liveChatRequest:URLRequest;
		
		private static var TOKEN:String;
		private static var HDR:URLRequestHeader;
		private static var HEADERS:Array;
		
		public static var loggerDebugFunction:Function;
		public static var loggerErrorFunction:Function;
		//public static var enableTrace:Boolean;
		
		public function YouTube( target:flash.events.IEventDispatcher = null ) {
			
			super( target );
			
		}
		
		private function ldrComplete( e:Event ):void {
			
			if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "ldrComplete {0}", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			processResult( e.target as YouTubeLoader );
			
		}
		
		private function ldrError( e:IOErrorEvent ):void {
			
			if ( loggerErrorFunction != null ) loggerErrorFunction.call( this, "ldrError {0}, {1}", e.errorID, e.text );
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "ldrError {0}", e.target.data );
			
			var errorEvt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.ERROR );
			
			var errorObject:Object = com.adobe.serialization.json.JSON.decode( e.target.data );
			
			if ( errorObject.error ) {
				/*
				if ( errorObject.error.code ) errorEvt.errorCode = int( errorObject.error.code );
				if ( errorObject.error.code && ( errorObject.error.code == 400 ) ) errorEvt.error = "YouTube error";
				if ( errorObject.error.code && ( errorObject.error.code == 401 ) ) errorEvt.error = "YouTube is unauthorized";
				if ( errorObject.error.code && ( errorObject.error.code == 403 ) ) errorEvt.error = "YouTube action forbidden";
				if ( errorObject.error.code && ( errorObject.error.code == 404 ) ) errorEvt.error = "YouTube error";
				*/
				
				errorEvt.errorCode = errorObject.error.code;
				errorEvt.error = "YouTube error: " + errorObject.error.message;
				
			}
			
			this.dispatchEvent( errorEvt );
			
		}
		
		private function ldrStatus( e:HTTPStatusEvent ):void {
			
			if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "ldrStatus {0}, {1}, {2}", e.responseHeaders, e.responseURL, e.status );
			
		}
		
		private function processResult( ldr:YouTubeLoader ):void {
			
			var jsonObject:Object = com.adobe.serialization.json.JSON.decode( ldr.data );
			
			switch( jsonObject.kind ) {
				
				case KIND_LIVE_STREAM:
					
					if ( ldr.action == YouTubeLoader.INSERT ) {
						
						processLiveStreamResult( jsonObject );
						
					}
					
					if ( ldr.action == YouTubeLoader.UPDATE ) {
						
						processLiveStreamUpdateResult( ldr );
						
					}
					
					break;
				
				case KIND_LIVE_BROADCAST:
					
					if ( ldr.action == YouTubeLoader.BIND ) {
						
						processLiveBroadcastBindResult( ldr );
						
					} else if ( ldr.action == YouTubeLoader.INSERT ) {
						
						processLiveBroadcastResult( jsonObject );
						
					} else if ( ldr.action == YouTubeLoader.TRANSITION ) {
						
						processLiveBroadcastTransitionResult( ldr );
						
					} else if ( ldr.action == YouTubeLoader.UPDATE ) {
						
						processLiveBroadcastUpdateResult( ldr );
						
					}
					
					break;
					
				case KIND_LIVE_BROADCAST_LIST_RESPONSE:
					
					processLiveBroadcastListResponseResult( ldr );
					
					break;
				
				case KIND_LIVE_STREAM_LIST_RESPONSE:
					
					processLiveStreamListResponseResult( jsonObject );
					
					break;
				
				case KIND_LIVE_CHAT_MESSAGE_LIST_RESPONSE:
					
					processLiveChatMessageListResponseResult( jsonObject );
					
					break;
				
				case KIND_VIDEO_LIST_RESPONSE:
					
					processVideoListResponseResult( jsonObject );
					
					break;
				
			}
			
		}
		
		private function processLiveStreamResult( o:Object ):void {
			
			var ls:LiveStream = LiveStream.create( o );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_STREAM_CREATED );
			evt.liveStream = ls;
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveBroadcastResult( o:Object ):void {
			
			var lb:LiveBroadcast = LiveBroadcast.create( o );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_BROADCAST_CREATED );
			evt.liveBroadcast = lb;
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveBroadcastTransitionResult( ldr:YouTubeLoader ):void {
			
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_BROADCAST_TRANSITIONED );
			if ( ldr.liveBroadcast ) {
				
				ldr.liveBroadcast.update( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				
			} else {
				
				var lb:LiveBroadcast = LiveBroadcast.create( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				evt.liveBroadcast = lb;
				
			}
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveBroadcastBindResult( ldr:YouTubeLoader ):void {
			
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_BROADCAST_BOUND_TO_STREAM );
			
			if ( ldr.liveBroadcast ) {
				
				ldr.liveBroadcast.update( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				
			} else {
				
				var lb:LiveBroadcast = LiveBroadcast.create( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				evt.liveBroadcast = lb;
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveBroadcastUpdateResult( ldr:YouTubeLoader ):void {
			
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_BROADCAST_UPDATED );
			
			if ( ldr.liveBroadcast ) {
				
				ldr.liveBroadcast.update( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				//evt.liveBroadcast = ldr.liveBroadcast;
				
			} else {
				
				var lb:LiveBroadcast = LiveBroadcast.create( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				evt.liveBroadcast = lb;
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveBroadcastListResponseResult( ldr:YouTubeLoader ):void {
			
			var lblr:LiveBroadcastListResponse = LiveBroadcastListResponse.create( com.adobe.serialization.json.JSON.decode( ldr.data ) );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_BROADCAST_LIST_LOADED );
			evt.liveBroadcastListResponse = lblr;
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveStreamListResponseResult( o:Object ):void {
			
			var lslr:LiveStreamListResponse = LiveStreamListResponse.create( o );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_STREAM_LIST_LOADED );
			evt.liveStreamListResponse = lslr;
			this.dispatchEvent( evt );
			
		}

		private function processLiveStreamUpdateResult( ldr:YouTubeLoader ):void {
			
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_STREAM_UPDATED );
			
			if ( ldr.liveStream ) {
				
				ldr.liveStream.update( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				//evt.liveBroadcast = ldr.liveBroadcast;
				
			} else {
				
				var ls:LiveStream = LiveStream.create( com.adobe.serialization.json.JSON.decode( ldr.data ) );
				evt.liveStream = ls;
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		private function processLiveChatMessageListResponseResult( o:Object ):void {
			
			var lcr:LiveChatMessageListResponse = LiveChatMessageListResponse.create( o );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.LIVE_CHAT_MESSAGES_LOADED );
			evt.liveChatMessageListResponse = lcr;
			this.dispatchEvent( evt );
			
		}
		
		private function processVideoListResponseResult( o:Object ):void {
			
			var vlr:VideoListResponse = VideoListResponse.create( o );
			var evt:YouTubeEvent = new YouTubeEvent( YouTubeEvent.VIDEO_LIST_LOADED );
			evt.videoListResponse = vlr;
			this.dispatchEvent( evt );
			
		}
		
		//
		// Public functions
		//
		
		public function search( query:String ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			var req:URLRequest = new URLRequest( BASE_URL + SEARCH );
			var vars:URLVariables = new URLVariables();
			vars.part = PART_SNIPPET;
			vars.q = query;
			req.data = vars;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function listLiveStreams( id:String = null, maxResults:int = 5, part:Array = null ):void {
			
			var parts:Array = [ PART_ID, PART_SNIPPET, PART_CONTENT_DETAILS, PART_STATUS, PART_CDN ];
			if ( part ) parts = part;
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.LIST;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS );
			var vars:URLVariables = new URLVariables();
			//vars.part = "id,snippet,contentDetails,status,cdn";
			vars.part = parts.join( "," );
			vars.maxResults = maxResults;
			if ( id ) vars.id = id else vars.mine = true;
			req.data = vars;
			req.method = URLRequestMethod.GET;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function listLiveBroadcasts( id:String = null, maxResults:int = 5, listDefault:Boolean = false, part:Array = null ):void {
			
			var parts:Array = [ PART_ID, PART_SNIPPET, PART_CONTENT_DETAILS, PART_STATUS ];
			if ( part ) parts = part;
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.LIST;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS );
			var vars:URLVariables = new URLVariables();
			//vars.part = "id,snippet,contentDetails,status";
			vars.part = parts.join( "," );
			vars.maxResults = maxResults;
			if ( listDefault ) {
				
				vars.broadcastType = "persistent";
				
			}
			if ( id ) vars.id = id else vars.mine = true;
			req.method = URLRequestMethod.GET;
			req.data = vars;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function insertLiveStream( liveStream:LiveStream ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.INSERT;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS + "?part=snippet,cdn,id,status" );
			req.method = URLRequestMethod.POST;
			req.requestHeaders = HEADERS;
			req.contentType = "application/json";
			req.data = liveStream.json;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function insertLiveBroadcast( liveBroadcast:LiveBroadcast ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.INSERT;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "?part=snippet,id,status,contentDetails" );
			req.method = URLRequestMethod.POST;
			req.requestHeaders = HEADERS;
			req.contentType = "application/json";
			req.data = liveBroadcast.json;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function bindLiveStreamToLiveBroadcast( liveBroadcast:LiveBroadcast, liveStream:LiveStream ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.liveBroadcast = liveBroadcast;
			ldr.liveStream = liveStream;
			ldr.action = YouTubeLoader.BIND;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "/bind?part=snippet,id,status,contentDetails&id=" + escape( liveBroadcast.id ) + "&streamId=" + escape( liveStream.id ) );
			var vars:URLVariables = new URLVariables();
			vars.id = liveBroadcast.id;
			vars.part = "snippet";
			vars.streamId = liveStream.id;
			req.method = URLRequestMethod.POST;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function bindLiveStreamIdToLiveBroadcastId( liveBroadcastId:String, liveStreamId:String ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.BIND;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "/bind?part=snippet,id,status,contentDetails&id=" + escape( liveBroadcastId ) + "&streamId=" + escape( liveStreamId ) );
			var vars:URLVariables = new URLVariables();
			vars.id = liveBroadcastId;
			vars.part = "snippet";
			vars.streamId = liveStreamId;
			req.method = URLRequestMethod.POST;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function transitionLiveBroadcast( liveBroadcast:LiveBroadcast, broadcastStatus:String ):void {
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.TRANSITION;
			ldr.liveBroadcast = liveBroadcast;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "/transition?part=snippet,id,status,contentDetails&id=" + escape( liveBroadcast.id ) + "&broadcastStatus=" + broadcastStatus );
			req.method = URLRequestMethod.POST;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function updateLiveBroadcast( liveBroadcast:LiveBroadcast, part:Array = null ):void {
			
			var parts:Array = [ PART_ID, PART_SNIPPET, PART_CONTENT_DETAILS, PART_STATUS ];
			if ( part ) parts = part;
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.UPDATE;
			ldr.liveBroadcast = liveBroadcast;
			//var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "?part=snippet,id,status,contentDetails");
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "?part=" + parts.join( "," ) );
			req.method = URLRequestMethod.PUT;
			req.requestHeaders = HEADERS;
			req.contentType = "application/json";
			req.data = liveBroadcast.json;
			
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function updateLiveStreamCDN( liveStream:LiveStream, part:Array = null ):void {
			
			var parts:Array = [ PART_ID, PART_SNIPPET, PART_CDN, PART_STATUS ];
			if ( part ) parts = part;
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.UPDATE;
			ldr.liveStream = liveStream;
			//var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS + "?part=snippet,id,status,cdn");
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS + "?part" + parts.join( "," ) );
			req.method = URLRequestMethod.PUT;
			req.requestHeaders = HEADERS;
			req.contentType = "application/json";
			var o:Object = { id:liveStream.id, cdn:liveStream.cdn.object };
			var s:String = com.adobe.serialization.json.JSON.encode( o );
			//req.data = liveStream.cdn.json;
			req.data = s;
			
			trace( "DATA", req.data );
			
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function listVideos( id:String = null, maxResults:int = 5, part:Array = null ):void {
			
			var parts:Array = [ PART_ID, PART_STATISTICS, PART_LIVE_STREAMING_DETAILS ];
			if ( part ) parts = part;
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.LIST;
			var req:URLRequest = new URLRequest( BASE_URL + VIDEOS );
			var vars:URLVariables = new URLVariables();
			vars.part = parts.join( "," );
			vars.maxResults = maxResults;
			if ( id ) vars.id = id else vars.mine = true;
			req.data = vars;
			req.method = URLRequestMethod.GET;
			req.requestHeaders = HEADERS;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
			loaders.push( ldr );
			requests.push( req );
			
		}
		
		public function dispose():void {
			
			var i:int;
			
			for ( i = 0; i < loaders.length; i++ ) loaders[i] = null;
			for ( i = 0; i < requests.length; i++ ) requests[i] = null;
			HDR = null;
			
		}
		
		//
		// Getters and Setters
		//
		
		/*
		public function get accessToken():String {
			
			return token;
			
		}
		
		public function set accessToken( value:String ):void {
			
			token = value;
			hdr = new URLRequestHeader( "Authorization", "Bearer " + token );
			headers = new Array( hdr );
			
		}
		*/
		
		public static function get ACCESS_TOKEN():String {
			
			return TOKEN;
			
		}
		
		public static function set ACCESS_TOKEN( value:String ):void {
			
			TOKEN = value;
			HDR = new URLRequestHeader( "Authorization", "Bearer " + TOKEN );
			HEADERS = new Array( HDR );
			
		}
		
		public function get refreshToken():String {
			
			return rToken;
			
		}
		
		public function set refreshToken( value:String ):void {
			
			rToken = value;
			
		}
		
		//
		// Helper functions, not included directly in YouTube API
		//
		
		public function deleteAllLiveBroadcasts():void {
			
			//
			// Deletes ALL LiveBroadcast resources on YouTube.
			// Currently, no error handling implemented
			//
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.LIST;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS );
			var vars:URLVariables = new URLVariables();
			vars.part = "id,snippet,contentDetails,status";
			vars.mine = true;
			req.method = URLRequestMethod.GET;
			req.data = vars;
			req.requestHeaders = HEADERS;
			
			ldr.addEventListener( Event.COMPLETE, function( e:Event ):void {
				
				if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "deleteAllLiveBroadcasts {0}", ldr.data );
				var jsonObject:Object = com.adobe.serialization.json.JSON.decode( ldr.data );
				for ( var i:int = 0; i < jsonObject.items.length; i++ ) {
					
					deleteLiveBroadcastById( jsonObject.items[i].id );
					
				}
				
			});
			
			ldr.addEventListener( IOErrorEvent.IO_ERROR, function( e:IOErrorEvent ):void {
				
			});
			
			
			ldr.load( req );
			
			//loaders.push( ldr );
			//requests.push( req );
			
		}
		
		public function deleteLiveBroadcastById( id:String ):void {
			
			//
			// Deletes a LiveBroadcast resources on YouTube.
			// Currently, no error handling implemented
			//
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_BROADCASTS + "?id=" + id );
			req.method = URLRequestMethod.DELETE;
			req.requestHeaders = HEADERS;
			
			ldr.addEventListener( Event.COMPLETE, function( e:Event ):void {
				
				if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "deleteLiveBroadcastById {0}", ldr.data );
				
			});
			
			ldr.addEventListener( IOErrorEvent.IO_ERROR, function( e:IOErrorEvent ):void {
				
			});
			
			ldr.load( req );
			
		}
		
		public function deleteAllLiveStreams():void {
			
			//
			// Deletes ALL LiveStream resources on YouTube.
			// Currently, no error handling implemented
			//
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			ldr.action = YouTubeLoader.LIST;
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS );
			var vars:URLVariables = new URLVariables();
			vars.part = "id,snippet,contentDetails,status";
			vars.mine = true;
			vars.maxResults = 50;
			req.method = URLRequestMethod.GET;
			req.data = vars;
			req.requestHeaders = HEADERS;
			
			ldr.addEventListener( Event.COMPLETE, function( e:Event ):void {
				
				if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "deleteAllLiveStreams {0}", ldr.data );
				var jsonObject:Object = com.adobe.serialization.json.JSON.decode( ldr.data );
				for ( var i:int = 0; i < jsonObject.items.length; i++ ) {
					
					deleteLiveStreamById( jsonObject.items[i].id );
					
				}
				
			});
			
			ldr.addEventListener( IOErrorEvent.IO_ERROR, function( e:IOErrorEvent ):void {
				
			});
			
			
			ldr.load( req );
			
			//loaders.push( ldr );
			//requests.push( req );
			
		}
		
		public function deleteLiveStreamById( id:String ):void {
			
			//
			// Deletes a LiveBroadcast resources on YouTube.
			// Currently, no error handling implemented
			//
			
			var ldr:YouTubeLoader = new YouTubeLoader();
			var req:URLRequest = new URLRequest( BASE_URL + LIVE_STREAMS + "?id=" + id );
			req.method = URLRequestMethod.DELETE;
			req.requestHeaders = HEADERS;
			
			ldr.addEventListener( Event.COMPLETE, function( e:Event ):void {
				
				if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "deleteLiveStreamById {0}", ldr.data );
				
			});
			
			ldr.addEventListener( IOErrorEvent.IO_ERROR, function( e:IOErrorEvent ):void {
				
				if ( loggerDebugFunction != null ) loggerDebugFunction.call( this, "deleteLiveStreamById ERROR {0}", ldr.data );
				
			});
			
			ldr.load( req );
			
		}
		
		//
		// Chat
		//
		
		public function listLiveChatMessages( id:String, nextPageToken:String = null ):void {
			
			liveChatLoader = new YouTubeLoader();
			liveChatLoader.action = YouTubeLoader.LIST;
			liveChatRequest = new URLRequest( BASE_URL + LIVE_CHAT_MESSAGES );
			var vars:URLVariables = new URLVariables();
			vars.part = "id,snippet,authorDetails";
			vars.mine = true;
			vars.liveChatId = id;
			if ( nextPageToken ) vars.pageToken = nextPageToken;
			liveChatRequest.method = URLRequestMethod.GET;
			liveChatRequest.data = vars;
			liveChatRequest.requestHeaders = HEADERS;
			liveChatLoader.addEventListener( Event.COMPLETE, ldrComplete );
			liveChatLoader.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			liveChatLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			
			liveChatLoader.load( liveChatRequest );
			
			loaders.push( liveChatLoader );
			requests.push( liveChatRequest );
			
		}
		
	}

}