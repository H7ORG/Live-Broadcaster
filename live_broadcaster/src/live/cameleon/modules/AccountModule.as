package live.cameleon.modules {

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
 
	import com.adobe.protocols.oauth2.OAuth2;
	import com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent;
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	
	import live.cameleon.licenser.Licenser;
	import live.cameleon.licenser.LicenserEvent;
	import live.cameleon.logger.LogEntry;
	import live.cameleon.logger.Logger;
	import live.cameleon.settings.UserSettings;
	import live.cameleon.views.FacebookLoginWindow;
	import live.cameleon.views.GoogleLoginWindow;
	
	import org.igazine.apis.events.FacebookEvent;
	import org.igazine.apis.events.YouTubeEvent;
	import org.igazine.apis.facebook.FacebookLoader;
	import org.igazine.apis.youtube.YouTube;
	
	import settings.API;
	
	public class AccountModule extends LBModule {
		
		protected var oauth2:OAuth2;
		protected var youTube:YouTube;
		protected var youtubeTester:YouTube;
		protected var googleTokenRefreshTimer:Timer;
		protected var googleUser:Object;
		protected var username:String;
		protected var password:String;
		protected var cameraSettings:Object;
		protected var facebookUser:Object;
		
		// User
		[Bindable] public var googleAuthorized:Boolean;
		[Bindable] public var googleAccessToken:String;
		[Bindable] public var googleRefreshToken:String;
		[Bindable] public var googleAccessTokenTime:Number;
		[Bindable] public var googleAccessTokenExpirity:Number;
		[Bindable] public var defaultYouTubeLiveBroadcastId:String;
		[Bindable] public var defaultYouTubeLiveStreamId:String;
		[Bindable] public var defaultYouTubeLiveStreamIngestionAddress:String;
		[Bindable] public var defaultYouTubeLiveStreamName:String;
		[Bindable] public var loginError:Boolean;
		[Bindable] public var loggedIn:Boolean;
		[Bindable] public var youtubeLiveEnabled:Boolean;
		[Bindable] public var facebookAuthorized:Boolean;
		[Bindable] public var facebookPublishActions:Boolean;
		[Bindable] public var facebookManagePages:Boolean;
		[Bindable] public var facebookPublishPages:Boolean;
		[Bindable] public var facebookToken:String;
		[Bindable] public var facebookTokenExpirity:Number;
		[Bindable] public var facebookTokenTime:Number;
		[Bindable] public var facebookGrantedScopes:Array;
		[Bindable] public var facebookDeniedScopes:Array;
		// YouTube States: loggedOut, disabled, enabled, connecting, streaming
		[Bindable] public var youtubeState:String = "loggedOut";
		
		public function AccountModule() {
			
			super();
			
		}
		
		override protected function init():void {
			
			super.init();
			
			Licenser.instance.addEventListener( LicenserEvent.COMPLETE, licenserComplete );
			Licenser.instance.check( UserSettings.licenseEmail, UserSettings.licenseKey, false );
			
			googleAccessToken = UserSettings.googleAccessToken;
			googleRefreshToken = UserSettings.googleRefreshToken;
			googleAccessTokenTime = UserSettings.googleAccessTokenTime;
			googleAccessTokenExpirity = UserSettings.googleAccessTokenExpirity;
			googleAuthorized = UserSettings.googleAuthorized;
			cameraSettings = UserSettings.cameraSettings;
			facebookToken = UserSettings.facebookToken;
			facebookTokenTime = UserSettings.facebookTokenTime;
			facebookTokenExpirity = UserSettings.facebookTokenExpirity;
			facebookGrantedScopes = UserSettings.facebookGrantedScopes;
			facebookDeniedScopes = UserSettings.facebookDeniedScopes;
			//Facebook.accessToken = "1";
			facebookAuthorized = false;
			
			refreshGoogleToken();
			refreshFacebookToken();
			
		}
		
		protected function licenserComplete( e:Event ):void {
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_LICENSE;
			l.text = "CHECK";
			l.addChildObject( { text:"Pro License: " + String( Licenser.instance.isPro ) } );
			Logger.addEntry( l );
			
		}
		
		//
		// Account functions
		//
		
		public function connectGoogleAccount():void {
			
			//refreshGoogleToken();
			checkGoogleToken();
			
		}
		
		private function refreshGoogleToken():void {
			
			oauth2 = new OAuth2(API.I.GOOGLE_ENDPOINT, API.I.GOOGLE_TOKEN_ENDPOINT );
			oauth2.addEventListener( RefreshAccessTokenEvent.TYPE, googleTokenRefreshed );
			oauth2.refreshAccessToken( googleRefreshToken, API.I.GOOGLE_CLIENT_ID, API.I.GOOGLE_CLIENT_SECRET, API.I.GOOGLE_SCOPE );
			
		}
		
		private function googleTokenRefreshed( e:RefreshAccessTokenEvent ):void {
			
			e.target.removeEventListener( RefreshAccessTokenEvent.TYPE, googleTokenRefreshed );
			//log.info( "googleTokenRefreshed {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}", e.accessToken, e.errorCode, e.errorMessage, e.expiresIn, e.refreshToken, e.response, e.tokenType, e.scope, e.state );
			//for ( var i:String in e.response ) trace( i, e.response[i] );
			
			if ( e.accessToken != null ) {
				
				if ( e.errorCode == null ) {
					
					googleAccessToken = e.accessToken;
					googleAccessTokenExpirity = e.expiresIn;
					googleAccessTokenTime = new Date().getTime();
					YouTube.ACCESS_TOKEN = googleAccessToken;
					//this.dispatchEvent( new Event( AppEvent.GOOGLE_AUTH_COMPLETE ) );
					
					googleAuthorized = true;
					UserSettings.googleAccessToken = googleAccessToken;
					UserSettings.googleRefreshToken = googleRefreshToken;
					UserSettings.googleAccessTokenExpirity = googleAccessTokenExpirity;
					UserSettings.googleAccessTokenTime = googleAccessTokenTime;
					UserSettings.save();

					startPeriodicalGoogleTokenRefresh();
					
					checkYouTubeLiveStreaming();
					
					getGoogleDetails();
				
				} else {
					
					UserSettings.googleAuthorized = false;
					//this.dispatchEvent( new Event( AppEvent.GOOGLE_AUTH_FAILED ) );
					
				}
				
			} else {
				
				//this.dispatchEvent( new Event( AppEvent.GOOGLE_AUTH_FAILED ) );
				
			}
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_GOOGLE;
			l.text = "CHECK";
			l.addChildObject( { text:"Authorized: " + googleAuthorized } );
			Logger.addEntry( l );
			
		}
		
		public function checkGoogleToken():void {
			
			if ( googleAuthorized ) {
				
				refreshGoogleToken();
				
			} else {
				
				var glw:GoogleLoginWindow = new GoogleLoginWindow();
				glw.addEventListener( Event.CLOSE, googleWindowClosed );
				glw.show( this );
				
			}
			
		}
		
		private function googleWindowClosed( e:Event ):void {
			
			e.target.removeEventListener( Event.CLOSE, googleWindowClosed );
			
			if ( e.target.success ) {
				
				for ( var i:String in e.target.response ) trace( i, e.target.response[i] );
				trace( "scope", e.target.scope );
				googleAuthorized = true;
				youtubeState = "disabled";
				mainWindow.youtubeState = youtubeState;
				googleAccessToken = e.target.accessToken;
				googleRefreshToken = e.target.refreshToken;
				googleAccessTokenExpirity = Number( e.target.expiresIn );
				googleAccessTokenTime = new Date().getTime();
				YouTube.ACCESS_TOKEN = googleAccessToken;
				//this.dispatchEvent( new Event( AppEvent.GOOGLE_AUTH_COMPLETE ) );
				
				UserSettings.googleAccessToken = googleAccessToken;
				UserSettings.googleRefreshToken = googleRefreshToken;
				UserSettings.googleAccessTokenExpirity = googleAccessTokenExpirity;
				UserSettings.googleAccessTokenTime = googleAccessTokenTime;
				UserSettings.save();
				
				startPeriodicalGoogleTokenRefresh();
				checkYouTubeLiveStreaming();
				
			} else {
				
				googleAuthorized = false;
				//this.dispatchEvent( new Event( AppEvent.GOOGLE_AUTH_FAILED ) );
				
			}
			
		}
		
		public function deauthorizeGoogle():void {
			
			if ( googleAuthorized ) {
				
				googleAuthorized = false;
				youtubeState = "loggedOut";
				mainWindow.youtubeState = youtubeState;
				stopPeriodicalGoogleTokenRefresh();
				//this.dispatchEvent( new Event( AppEvent.GOOGLE_DEAUTH_COMPLETE ) );
				
			}
			
		}
		
		protected function googleLogin( showWindow:Boolean = true ):void {
			
			loginError = false;
			this.processing = true;
			//this.addEventListener( AppEvent.GOOGLE_AUTH_COMPLETE, googleLoginSuccess );
			//this.addEventListener( AppEvent.GOOGLE_AUTH_FAILED, googleLoginFailed );
			
			if ( showWindow ) {
				
				checkGoogleToken();
				
			} else {
				
				refreshGoogleToken();
				
			}
			
		}
		
		protected function googleLoginSuccess( e:Event ):void {
			
			//this.removeEventListener( AppEvent.GOOGLE_AUTH_COMPLETE, googleLoginSuccess );
			//this.removeEventListener( AppEvent.GOOGLE_AUTH_FAILED, googleLoginFailed );
			//trace( 'googleLoginSuccess' );
			getGoogleDetails();
			
		}
		
		protected function googleLoginFailed( e:Event ):void {
			
			this.processing = false;
			//this.removeEventListener( AppEvent.GOOGLE_AUTH_COMPLETE, googleLoginSuccess );
			//this.removeEventListener( AppEvent.GOOGLE_AUTH_FAILED, googleLoginFailed );
			googleAccessToken = "";
			googleAccessTokenExpirity = 0;
			googleAccessTokenTime = 0;
			googleRefreshToken = "";
			googleAuthorized = false;
			youtubeState = "loggedOut";
			mainWindow.youtubeState = youtubeState;
			trace( 'googleLoginFailed' );
			
		}
		
		protected function getGoogleDetails():void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( API.I.GOOGLE_ME );
			var hdr:URLRequestHeader = new URLRequestHeader( "Authorization", "Bearer " + googleAccessToken );
			var hdrs:Array = new Array( hdr );
			req.requestHeaders = hdrs;
			req.method = URLRequestMethod.GET;
			ldr.addEventListener( Event.COMPLETE, getGoogleDetailsComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, getGoogleDetailsError );
			ldr.load( req );
			
		}
		
		protected function getGoogleDetailsComplete( e:Event ):void {
			
			//trace( 'getGoogleDetailsComplete', e.target.data );
			e.target.removeEventListener( Event.COMPLETE, getGoogleDetailsComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, getGoogleDetailsError );
			googleUser = com.adobe.serialization.json.JSON.decode( String( e.target.data ) );
			//for ( var i:String in googleUser ) trace( i, googleUser[i] );
			username = String( googleUser.id );
			password = String( googleUser.id );
			//continueLogin();
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_GOOGLE;
			l.text = "LOGIN";
			//l.addChildObject( { text:"User: " + googleAuthorized } );
			Logger.addEntry( l );
			
			//checkYouTubeLiveStreaming();
			
		}
		
		public function checkYouTubeLiveStreaming():void {
			
			processing = true;
			
			//trace( "FFFFFFFFFFFFFFFFFFFFFFF", this.googleAccessToken );
			YouTube.ACCESS_TOKEN = this.googleAccessToken;
			
			if ( !youtubeTester ) {
				
				youtubeTester = new YouTube();
				youtubeTester.addEventListener( YouTubeEvent.LIVE_BROADCAST_LIST_LOADED, youtubeLiveBroadcastListLoaded );
				youtubeTester.addEventListener( YouTubeEvent.LIVE_STREAM_LIST_LOADED, youtubeLiveStreamListLoaded );
				youtubeTester.addEventListener( YouTubeEvent.ERROR, youtubeLiveBroadcastListError );
				
			}
			
			youtubeTester.listLiveBroadcasts( null, 5, true );
			
		}
		
		protected function youtubeLiveBroadcastListLoaded( e:YouTubeEvent ):void {
			
			if ( e.liveBroadcastListResponse.items.length > 0 ) {
				
				//var liveBroadCast:LiveBroadcast = LiveBroadcast.create( e.liveBroadcastListResponse.items[0] );
				
				if ( e.liveBroadcastListResponse.items[0].snippet.isDefaultBroadcast ) {
					
					defaultYouTubeLiveBroadcastId = e.liveBroadcastListResponse.items[0].id;
					defaultYouTubeLiveStreamId = e.liveBroadcastListResponse.items[0].contentDetails.boundStreamId;
					//trace( "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", defaultYouTubeLiveBroadcastId, defaultYouTubeLiveStreamId );
					youtubePanel.defaultYouTubeLiveBroadcastId = defaultYouTubeLiveBroadcastId;
					youtubePanel.defaultYouTubeLiveStreamId = defaultYouTubeLiveStreamId;
					
				}
				
			}
			
			checkDefaultYouTubeStream();
			//if ( !loggedIn ) continueLogin() else processing = false;
			
		}
		
		protected function checkDefaultYouTubeStream():void {
			
			youtubeTester.listLiveStreams( defaultYouTubeLiveStreamId );
			
		}
		
		protected function youtubeLiveStreamListLoaded( e:YouTubeEvent ):void {
			
			if ( e.liveStreamListResponse.items.length > 0 ) {
				
				defaultYouTubeLiveStreamIngestionAddress = e.liveStreamListResponse.items[0].cdn.ingestionInfo.ingestionAddress;
				defaultYouTubeLiveStreamName = e.liveStreamListResponse.items[0].cdn.ingestionInfo.streamName;
				//trace( "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", defaultYouTubeLiveStreamIngestionAddress, defaultYouTubeLiveStreamName );
				youtubeLiveEnabled = true;
				youtubeState = "enabled";
				mainWindow.youtubeState = youtubeState;
				
			}
			
			processing = false;
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_YOUTUBE;
			l.text = "CHECK";
			l.addChildObject( { text:"YouTube Live: " + youtubeLiveEnabled } );
			Logger.addEntry( l );
			
		}
		
		protected function youtubeLiveBroadcastListError( e:YouTubeEvent ):void {
			
			youtubeLiveEnabled = false;
			youtubeState = "disabled";
			mainWindow.youtubeState = youtubeState;
			//if ( !loggedIn ) continueLogin() else processing = false;
			processing = false;
			
		}
		
		protected function getGoogleDetailsError( e:Event ):void {
			
			e.target.removeEventListener( Event.COMPLETE, getGoogleDetailsComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, getGoogleDetailsError );
			trace( 'getGoogleDetailsError' );
			googleUser = { };
			
		}
		
		public function googleSignOut():void {
			
			//this.keepLoggedIn = false;
			//this.close();
			
		}
		
		public function startPeriodicalGoogleTokenRefresh():void {
			
			if ( !googleTokenRefreshTimer ) {
				
				googleTokenRefreshTimer = new Timer( API.I.GOOGLE_TOKEN_REFRESH_INTERVAL, 1 );
				googleTokenRefreshTimer.addEventListener( TimerEvent.TIMER_COMPLETE, googleTokenRefreshTimerComplete );
				
			}			
			
			googleTokenRefreshTimer.reset();
			googleTokenRefreshTimer.start();
			
		}
		
		private function googleTokenRefreshTimerComplete( e:TimerEvent ):void {
			
			refreshGoogleToken();
			
		}
		
		public function stopPeriodicalGoogleTokenRefresh():void {
			
			if ( googleTokenRefreshTimer ) {
				
				googleTokenRefreshTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, googleTokenRefreshTimerComplete );
				googleTokenRefreshTimer.stop();
				googleTokenRefreshTimer = null;
				
			}
			
		}
		
		//
		// YouTube Streamer
		//
		
		protected function youtubeInit( e:Event ):void {
			
			facebookPanel.setDisabled();
			pipWindow.currentState = "youtube";
			
		}
		
		protected function youtubeFinished( e:Event ):void {
			
			facebookPanel.setEnabled();
			header.hasConnection = false;
			
		}
		
		//
		// Facebook logic
		//
		
		public function startFacebookLogin( controlKey:Boolean = false ):void {
			
			var fbw:FacebookLoginWindow = new FacebookLoginWindow();
			fbw.addEventListener( Event.CLOSE, facebookWindowClosed );
			fbw.reauthorize = true;
			fbw.showHome = controlKey; 
			fbw.show( this );
			
		}
		
		private function facebookWindowClosed( e:Event ):void {
			
			e.target.removeEventListener( Event.CLOSE, facebookWindowClosed );
			
			if ( e.target.success ) {
				
				facebookAuthorized = e.target.hasPublishActions;
				facebookToken = e.target.accessToken;
				facebookTokenExpirity = e.target.expiresIn;
				facebookTokenTime = new Date().getTime();
				facebookGrantedScopes = e.target.grantedScopes;
				facebookDeniedScopes = e.target.deniedScopes;
				
				UserSettings.facebookAuthorized = facebookAuthorized;
				UserSettings.facebookToken = facebookToken;
				UserSettings.facebookTokenExpirity = facebookTokenExpirity;
				UserSettings.facebookTokenTime = facebookTokenTime;
				UserSettings.facebookGrantedScopes = facebookGrantedScopes;
				UserSettings.facebookDeniedScopes = facebookDeniedScopes;
				UserSettings.save();
				
			} else {
				
				facebookAuthorized = false;
				
			}
			
			Mouse.cursor = MouseCursor.AUTO;
			
			refreshFacebookToken();
			
		}
		
		private function refreshFacebookToken():void {
			
			var fbldr:FacebookLoader = new FacebookLoader();
			fbldr.addEventListener( FacebookEvent.SUCCESS, facebookTokenSuccess );
			fbldr.addEventListener( FacebookEvent.ERROR, facebookTokenError );
			fbldr.accessToken = facebookToken;
			fbldr.permissions();
			
		}
		
		protected function facebookTokenSuccess( e:FacebookEvent ):void {
			
			//trace( "facebookTokenSuccess", e.user.name );
			//trace( "facebookTokenSuccess", e.permissions );
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookTokenSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookTokenError );
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_FACEBOOK;
			le.level = Logger.LEVEL_INFO;
			le.text = "CHECK";
			
			for ( var i:int = 0; i < e.permissions.length; i++ ) {
				
				if ( e.permissions[i].permission == "publish_actions" ) {
					
					facebookPublishActions = ( e.permissions[i].status == "granted" );
					le.addChildObject( { text:"Publish Actions: " + String( e.permissions[i].status ) } );
					
				}
				
				if ( e.permissions[i].permission == "manage_pages" ) {
					
					facebookManagePages = ( e.permissions[i].status == "granted" );
					le.addChildObject( { text:"Manage Pages: " + String( e.permissions[i].status ) } );
					
				}
				
				if ( e.permissions[i].permission == "publish_pages" ) {
					
					facebookPublishPages = ( e.permissions[i].status == "granted" );
					le.addChildObject( { text:"Publish Pages: " + String( e.permissions[i].status ) } );
					
				}
				
			}
			
			Logger.addEntry( le );
			
			facebookAuthorized = true;
			e.target.dispose();
			
			facebookPanel.facebookPublishActions = facebookPublishActions;
			facebookPanel.facebookManagePages = facebookManagePages;
			facebookPanel.facebookPublishPages = facebookPublishPages;
			facebookPanel.updateState();
			
			getFacebookUserDetails();
			//getFacebookAccounts();
			
		}
		
		protected function facebookTokenError( e:FacebookEvent ):void {
			
			trace( "facebookTokenError", e.message );
			facebookAuthorized = false;
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookTokenSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookTokenError );
			e.target.dispose();
			
			facebookPanel.facebookPublishActions = false;
			facebookPanel.currentState = "loggedOut";
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_FACEBOOK;
			le.level = Logger.LEVEL_INFO;
			le.text = "CHECK";
			le.addChildObject( { text:"Token Error / Unauthorized" } );
			Logger.addEntry( le );
			
		}
		
		protected function getFacebookUserDetails():void {
			
			var fbldr:FacebookLoader = new FacebookLoader();
			fbldr.addEventListener( FacebookEvent.SUCCESS, facebookUserDetailsSuccess );
			fbldr.addEventListener( FacebookEvent.ERROR, facebookUserDetailsError );
			fbldr.accessToken = facebookToken;
			fbldr.me();
			//getFacebookApplicationInfo();
			
		}
		
		protected function getFacebookApplicationInfo():void {
			
			var fbldr:FacebookLoader = new FacebookLoader();
			fbldr.addEventListener( FacebookEvent.SUCCESS, facebookUserDetailsSuccess );
			fbldr.addEventListener( FacebookEvent.ERROR, facebookUserDetailsError );
			fbldr.accessToken = facebookToken;
			fbldr.debugToken();
			
		}
		
		protected function facebookUserDetailsSuccess( e:FacebookEvent ):void {
			
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookUserDetailsSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookUserDetailsError );
			
			facebookUser = e.user;
			
			e.target.dispose();
			
			facebookPanel.setUser( facebookUser );
			
			getFacebookAccounts();
			
		}
		
		protected function facebookUserDetailsError( e:FacebookEvent ):void {
			
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookUserDetailsSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookUserDetailsError );
			e.target.dispose();
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_FACEBOOK;
			le.level = Logger.LEVEL_INFO;
			le.text = "ERROR";
			le.addChildObject( { text:"User Details Error" } );
			Logger.addEntry( le );
			
		}
		
		protected function getFacebookAccounts():void {
			
			var fbldr:FacebookLoader = new FacebookLoader();
			fbldr.addEventListener( FacebookEvent.SUCCESS, facebookAccountsSuccess );
			fbldr.addEventListener( FacebookEvent.ERROR, facebookAccountsError );
			fbldr.accessToken = facebookToken;
			fbldr.accounts();
			
		}
		
		protected function facebookAccountsSuccess( e:FacebookEvent ):void {
			
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookAccountsSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookAccountsError );
			
			if ( facebookUser ) {
				
				facebookUser.accounts = e.accounts;
				
			}
			
			e.target.dispose();
			
			facebookPanel.setUser( facebookUser );
			
		}
		
		protected function facebookAccountsError( e:FacebookEvent ):void {
			
			e.target.removeEventListener( FacebookEvent.SUCCESS, facebookAccountsSuccess );
			e.target.removeEventListener( FacebookEvent.ERROR, facebookAccountsError );
			e.target.dispose();
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_FACEBOOK;
			le.level = Logger.LEVEL_INFO;
			le.text = "ERROR";
			le.addChildObject( { text:"Accounts Error" } );
			Logger.addEntry( le );
			
		}
		
		//
		// Facebook streamer
		//
		
		protected function facebookInit( e:Event ):void {
			
			youtubePanel.setDisabled();
			pipWindow.currentState = "facebook";
			
		}
		
		protected function facebookFinished( e:Event ):void {
			
			youtubePanel.setEnabled();
			header.hasConnection = false;
			
		}
		
		
	}

}