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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import org.igazine.apis.events.FacebookEvent;
	import com.adobe.serialization.json.JSON;
	import flash.net.URLRequestMethod;
	
	public class FacebookLoader extends EventDispatcher {
		
		private static const ACTION_ME:String = "actionMe";
		private static const ACTION_PERMISSIONS:String = "actionPermissions";
		private static const ACTION_ACCOUNTS:String = "actionAccounts";
		private static const ACTION_CREATE_LIVE_VIDEO:String = "actionCreateLiveVideo";
		private static const ACTION_GET_LIVE_VIDEO:String = "actionGetLiveVideo";
		private static const ACTION_GET_LIVE_VIDEO_LIKES:String = "actionGetLiveVideoLikes";
		private static const ACTION_GET_LIVE_VIDEO_COMMENTS:String = "actionGetLiveVideoComments";
		private static const ACTION_END_LIVE_VIDEO:String = "actionEndLiveVideo";
		private static const ACTION_APPLICATION_INFO:String = "actionApplicationInfo";
		private static const ACTION_DEBUG_TOKEN:String = "actionDebugToken";
		
		public static const PRIVACY_EVERYONE:String = "EVERYONE";
		public static const PRIVACY_ALL_FRIENDS:String = "ALL_FRIENDS";
		public static const PRIVACY_FRIENDS_OF_FRIENDS:String = "FRIENDS_OF_FRIENDS";
		public static const PRIVACY_SELF:String = "SELF";
		public static const PRIVACY_CUSTOM:String = "CUSTOM";
		public static const STREAM_TYPE_REGULAR:String = "REGULAR";
		public static const STREAM_TYPE_AMBIENT:String = "AMBIENT";
		
		public static var traceResult:Boolean;
		
		private var action:String;
		
		public var accessToken:String;
		public var userId:String;
		public var privacy:String;
		public var title:String;
		public var description:String;
		public var streamType:String = STREAM_TYPE_REGULAR;
		public var id:String;
		public var after:String;
		public var before:String;
		public var ownerId:String;
		public var minAge:int;
		public var gender:int;
		
		public function FacebookLoader( target:flash.events.IEventDispatcher = null ) {
			
			super(target);
			
		}
		
		public function me():void {
			
			action = ACTION_ME;
			var req:URLRequest = new URLRequest( Facebook.ME );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			vars.fields = "id,name,picture";
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function permissions():void {
			
			action = ACTION_PERMISSIONS;
			var req:URLRequest = new URLRequest( Facebook.PERMISSIONS );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function accounts():void {
			
			action = ACTION_ACCOUNTS;
			var req:URLRequest = new URLRequest( Facebook.ACCOUNTS );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function createLiveVideo():void {
			
			action = ACTION_CREATE_LIVE_VIDEO;
			var req:URLRequest = new URLRequest( Facebook.API + userId + "/" + Facebook.LIVE_VIDEOS );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			if ( privacy ) vars.privacy = '{"value":"' + privacy + '"}';
			if ( title ) vars.title = title;
			if ( description ) vars.description = description;
			if ( streamType ) vars.stream_type = streamType;
			if ( minAge ) vars.age_min = minAge;
			if ( gender ) vars.genders = gender;
			
			req.data = vars;
			req.method = URLRequestMethod.POST;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function getLiveVideo():void {
			
			action = ACTION_GET_LIVE_VIDEO;
			var req:URLRequest = new URLRequest( Facebook.API + id );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			vars.fields = "live_views,id,embed_html,permalink_url,seconds_left,status";
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function getLiveVideoLikes():void {
			
			action = ACTION_GET_LIVE_VIDEO_LIKES;
			var req:URLRequest = new URLRequest( Facebook.getVideoLikesURI( id ) );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			vars.fields = "summary";
			vars.summary = "total_count";
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function getLiveVideoComments():void {
			
			action = ACTION_GET_LIVE_VIDEO_COMMENTS;
			var req:URLRequest = new URLRequest( Facebook.getVideoCommentsURI( id ) );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			vars.fields = "id,created_time,from,message";
			if ( after ) vars.after = after;
			if ( before ) vars.before = before;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function endLiveVideo():void {
			
			action = ACTION_END_LIVE_VIDEO;
			var req:URLRequest = new URLRequest( Facebook.getVideoURI( id ) );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			vars.end_live_video = "true";
			req.method = URLRequestMethod.POST;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function applicationInfo( appId:String ):void {
			
			action = ACTION_APPLICATION_INFO;
			var req:URLRequest = new URLRequest( Facebook.API + appId );
			var vars:URLVariables = new URLVariables();
			vars.access_token = accessToken;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		public function debugToken():void {
			
			action = ACTION_DEBUG_TOKEN;
			var req:URLRequest = new URLRequest( Facebook.DEBUG_TOKEN );
			var vars:URLVariables = new URLVariables();
			vars.input_token = accessToken;
			req.data = vars;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.load( req );
			
		}
		
		private function disposeLoader( ldr:URLLoader ):void {
			
			ldr.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.removeEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.removeEventListener( Event.COMPLETE, ldrComplete );
			ldr = null;
			
		}
		
		private function ldrError( e:IOErrorEvent ):void {
			
			if ( traceResult ) trace( "ldrError", e.errorID, e.text, e.target.data );
			var result:Object = com.adobe.serialization.json.JSON.decode( e.target.data );
			var evt:FacebookEvent = new FacebookEvent( FacebookEvent.ERROR );
			evt.code = result.error.code;
			evt.errorType = result.error.type;
			evt.message = result.error.message;
			this.dispatchEvent( evt );
			
			disposeLoader( e.target as URLLoader );
			
		}
		
		private function ldrStatus( e:HTTPStatusEvent ):void {
			
			//if ( traceResult ) trace( "ldrStatus", e.responseHeaders, e.responseURL, e.status );
			
		}
		
		private function ldrComplete( e:Event ):void {
			
			if ( traceResult ) trace( "ldrComplete", action, e.target.data );
			var result:Object = com.adobe.serialization.json.JSON.decode( e.target.data );
			var evt:FacebookEvent = new FacebookEvent( FacebookEvent.SUCCESS );
			
			switch( action ) {
				
				case ACTION_ME:
					evt.user = result;
					break;
					
				case ACTION_PERMISSIONS:
					evt.permissions = result.data;
					break;
				
				case ACTION_ACCOUNTS:
					evt.accounts = result.data;
					break;
				
				case ACTION_CREATE_LIVE_VIDEO:
					evt.liveVideo = result;
					break;
				
				case ACTION_GET_LIVE_VIDEO:
					evt.liveViews = result.live_views;
					evt.id = result.id;
					evt.embedHtml = result.embed_html;
					evt.liveStatus = result.status;
					evt.secondsLeft = result.seconds_left;
					evt.permalink = result.permalink_url;
					break;
				
				case ACTION_GET_LIVE_VIDEO_LIKES:
					evt.likes = result.summary.total_count;
					break;
				
				case ACTION_GET_LIVE_VIDEO_COMMENTS:
					evt.comments = result.data as Array;
					if ( result.paging && result.paging.cursors ) {
						
						evt.cursorBefore = result.paging.cursors.before;
						evt.cursorAfter = result.paging.cursors.after;
						
					}
					break;
				
				case ACTION_END_LIVE_VIDEO:
					break;
				
				case ACTION_APPLICATION_INFO:
					
					break;
				
			}
			
			this.dispatchEvent( evt );
			
		}
		
		public function dispose():void {
			
			
			
		}
		
	}

}