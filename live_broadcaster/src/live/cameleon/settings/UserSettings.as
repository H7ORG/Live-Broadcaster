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
 * Author: Evgeny Boganov, 2017
 * 
 */
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import live.cameleon.utils.Utils;
	
	public class UserSettings {
		
		private static const RTMP_DEFAULT_PORT:int = 1935;
		private static const RTMFP_DEFAULT_PORT:int = 1935;
		private static const HTTP_DEFAULT_PORT:int = 8888;
		
		private static var applicationSettings:Object = {}
		private static var userSettings:Object = {}
		private static var deviceSettings:Object = {}
		private static var settingsFileName:String = "settings";
		private static var settingsFile:File;
		private static var settingsFileStream:FileStream;
		private static var settingsJSONString:String;
		private static var settingsJSON:Object = {};
		private static var premium:Boolean;
		private static var autoSave:Boolean;
		
		public static var facebookAppId:String;
		
		public function UserSettings() {}
		
		public static function load():void {
			
			// Loading json file
			settingsFile = File.applicationStorageDirectory.resolvePath( settingsFileName );
			settingsFileStream = new FileStream();
			
			try {
				
				settingsFileStream.open( settingsFile, FileMode.READ );
				var ba:ByteArray = new ByteArray();
				
				try {
					
					settingsFileStream.readBytes( ba );
					ba.uncompress();
					settingsJSONString = ba.readUTF();
					settingsJSON = JSON.parse( settingsJSONString );
					
				} catch ( e:Error ) {}
				
				//settingsJSONString = settingsFileStream.readUTFBytes( settingsFileStream.bytesAvailable );
				//settingsJSON = com.adobe.serialization.json.JSON.decode( settingsJSONString );
				settingsFileStream.close();
				
			} catch ( e:Error ) {}
			
			if ( settingsJSON ) {
				
				if ( settingsJSON.applicationSettings ) applicationSettings = settingsJSON.applicationSettings;
				if ( settingsJSON.userSettings ) userSettings = settingsJSON.userSettings;
				if ( settingsJSON.deviceSettings ) deviceSettings = settingsJSON.deviceSettings;
				
			}
			
			if ( applicationSettings["appId"] == null ) applicationSettings["appId"] = Utils.generateAppId();
			
		}
		
		public static function save():void {
			
			if ( enableLogout ) {
				
				googleAccessToken = null;
				googleAuthorized = false;
				googleRefreshToken = null;
				
				facebookAuthorized = false;
				facebookToken = null;
				
			}
			
			// Saving json file
			settingsFile = File.applicationStorageDirectory.resolvePath( settingsFileName );
			settingsFileStream = new FileStream();
			
			try {
				
				settingsFileStream.open( settingsFile, FileMode.WRITE );
				settingsJSON.applicationSettings = applicationSettings;
				settingsJSON.userSettings = userSettings;
				settingsJSON.deviceSettings = deviceSettings;
				settingsJSONString = JSON.stringify( settingsJSON );
				var ba:ByteArray = new ByteArray();
				ba.writeUTF( settingsJSONString );
				ba.compress();
				//settingsFileStream.writeUTFBytes( settingsJSONString );
				settingsFileStream.writeBytes( ba );
				settingsFileStream.close();
				
			} catch ( e:Error ) {}
			
		}
		
		private static function setApplicationProperty( name:String, value:* ):void {
			
			applicationSettings[ name ] = value;
			if ( autoSave ) save();
			
		}
		
		private static function setUserProperty( name:String, value:* ):void {
			
			userSettings[ name ] = value;
			if ( autoSave ) save();
			
		}
		
		//
		// Getters and Setters
		//
		
		public static function get windowBounds():Rectangle {
			
			if ( applicationSettings[ "windowBounds" ] )
				return new Rectangle( applicationSettings[ "windowBounds" ].x, applicationSettings[ "windowBounds" ].y, applicationSettings[ "windowBounds" ].width, applicationSettings[ "windowBounds" ].height );
				
			return null;
			
		}
		
		public static function set windowBounds( value:Rectangle ):void {
			
			setApplicationProperty( "windowBounds", { x:value.x, y:value.y, width:value.width, height:value.height } );
			
		}
		
		public static function get pipWindowBounds():Rectangle {
			
			if ( applicationSettings[ "pipWindowBounds" ] )
				return new Rectangle( applicationSettings[ "pipWindowBounds" ].x, applicationSettings[ "pipWindowBounds" ].y, applicationSettings[ "pipWindowBounds" ].width, applicationSettings[ "pipWindowBounds" ].height );
				
			return null;
			
		}
		
		public static function set pipWindowBounds( value:Rectangle ):void {
			
			setApplicationProperty( "pipWindowBounds", { x:value.x, y:value.y, width:value.width, height:value.height } );
			
		}
		
		public static function get windowMaximized():Boolean {
			
			return Boolean( applicationSettings[ "windowMaximized" ] );
			
		}
		
		public static function set windowMaximized( value:Boolean ):void {
			
			setApplicationProperty( "windowMaximized", value );
			
		}
		
		public static function get zoom():Boolean {
			
			return Boolean( applicationSettings[ "zoom" ] );
			
		}
		
		public static function set zoom( value:Boolean ):void {
			
			setApplicationProperty( "zoom", value );
			
		}
		
		public static function get googleAccessToken():String {
			
			return String( userSettings[ "googleAccessToken" ] );
			
		}
		
		public static function set googleAccessToken( value:String ):void {
			
			setUserProperty( "googleAccessToken", value );
			
		}
		
		public static function get googleRefreshToken():String {
			
			return String( userSettings[ "googleRefreshToken" ] );
			
		}
		
		public static function set googleRefreshToken( value:String ):void {
			
			setUserProperty( "googleRefreshToken", value );
			
		}
		
		public static function get googleAccessTokenTime():Number {
			
			return Number( userSettings[ "googleAccessTokenTime" ] );
			
		}
		
		public static function set googleAccessTokenTime( value:Number ):void {
			
			setUserProperty( "googleAccessTokenTime", value );
			
		}
		
		public static function get googleAccessTokenExpirity():Number {
			
			return Number( userSettings[ "googleAccessTokenExpirity" ] );
			
		}
		
		public static function set googleAccessTokenExpirity( value:Number ):void {
			
			setUserProperty( "googleAccessTokenExpirity", value );
			
		}
		
		public static function get googleAuthorized():Boolean {
			
			return Boolean( userSettings[ "googleAuthorized" ] ); 
			
		}
		
		public static function set googleAuthorized( value:Boolean ):void {
			
			setUserProperty( "googleAuthorized", value );
			
		}
		
		public static function get cameraSettings():Object {
			
			//return Object( applicationSettings[ "cameraSettings" ] );
			return Object( deviceSettings );
			
		}
		
		public static function set cameraSettings( value:Object ):void {
			
			//setApplicationProperty( "cameraSettings", value );
			deviceSettings = value;
			deviceSettings.label = String( value.mode.label );
			
		}
		
		public static function get youtubeSettings():Object {
			
			return Object( applicationSettings[ "youtubeSettings" ] );
			
		}
		
		public static function set youtubeSettings( value:Object ):void {
			
			setApplicationProperty( "youtubeSettings", value );
			
		}
		
		public static function get facebookAuthorized():Boolean {
			
			return Boolean( userSettings[ "facebookAuthorized" ] );
			
		}
		
		public static function set facebookAuthorized( value:Boolean ):void {
			
			setUserProperty( "facebookAuthorized", value );
			
		}
		
		public static function get facebookToken():String {
			
			return String( userSettings[ "facebookToken_" + facebookAppId ] );
			
		}
		
		public static function set facebookToken( value:String ):void {
			
			setUserProperty( "facebookToken_" + facebookAppId, value );
			
		}
		
		public static function get facebookTokenTime():Number {
			
			return Number( userSettings[ "facebookTokenTime" ] );
			
		}
		
		public static function set facebookTokenTime( value:Number ):void {
			
			setUserProperty( "facebookTokenTime", value );
			
		}
		
		public static function get facebookTokenExpirity():Number {
			
			return Number( userSettings[ "facebookTokenExpirity" ] );
			
		}
		
		public static function set facebookTokenExpirity( value:Number ):void {
			
			setUserProperty( "facebookTokenExpirity", value );
			
		}
		
		public static function get facebookGrantedScopes():Array {
			
			return userSettings[ "facebookGrantedScopes" ] as Array;
			
		}
		
		public static function set facebookGrantedScopes( value:Array ):void {
			
			setUserProperty( "facebookGrantedScopes", value );
			
		}
		
		public static function get facebookDeniedScopes():Array {
			
			return userSettings[ "facebookDeniedScopes" ] as Array;
			
		}
		
		public static function set facebookDeniedScopes( value:Array ):void {
			
			setUserProperty( "facebookDeniedScopes", value );
			
		}
		
		public static function get rtmpPort():int {
			
			if ( userSettings[ "rtmpPort" ] != null )
				return userSettings[ "rtmpPort" ]
			else
				return RTMP_DEFAULT_PORT;
			
		}
		
		public static function set rtmpPort( value:int ):void {
			
			setUserProperty( "rtmpPort", value );
			
		}
		
		public static function get httpPort():int {
			
			if ( userSettings[ "httpPort" ] != null )
				return userSettings[ "httpPort" ]
			else
				return HTTP_DEFAULT_PORT;
			
		}
		
		public static function set httpPort( value:int ):void {
			
			setUserProperty( "httpPort", value );
			
		}
		
		public static function get enableLogout():Boolean {
			
			return Boolean( userSettings[ "enableLogout" ] );
			
		}
		
		public static function set enableLogout( value:Boolean ):void {
			
			userSettings[ "enableLogout" ] = value;
			
		}
		
		public static function get appId():String {
			
			return applicationSettings["appId"];
			
		}
		
		public static function get licenseEmail():String {
			
			if ( ( userSettings[ "licenseEmail" ] == undefined ) || ( userSettings[ "licenseEmail" ] == null ) ) return "";
			return String( userSettings[ "licenseEmail" ] );
			
		}
		
		public static function set licenseEmail( value:String ):void {
			
			setUserProperty( "licenseEmail", value );
			
		}
		
		public static function get licenseKey():String {
			
			if ( ( userSettings[ "licenseKey" ] == undefined ) || ( userSettings[ "licenseKey" ] == null ) ) return "";
			return String( userSettings[ "licenseKey" ] );
			
		}
		
		public static function set licenseKey( value:String ):void {
			
			setUserProperty( "licenseKey", value );
			
		}
		
		//
		// Static functions
		//
		
		private static function scramble( input:String ):String {
			
			var s:String = "";
			var c:int;
			var r:String;
			
			for ( var i:int = 0; i < input.length; i++ ) {
				
				c = input.charCodeAt( i );
				r = c.toString( 36 );
				s += r;
				
			}
			
			return s;
			
		}
		
		private static function descramble( input:String ):String {
			
			var s:String = "";
			var c:int;
			var r:String;
			
			for ( var i:int = 0; i < input.length; i+=2 ) {
				
				r = input.charAt( i ) + input.charAt( i + 1 );
				c = parseInt( r, 36 );
				trace( "descramble", r, c )
				s += String.fromCharCode( c );
				
			}
			
			return s;
			
		}
		
		private static function zip( input:String ):String {
			
			var s:String = "";
			var ba:ByteArray = new ByteArray();
			var c:uint;
			var r:String;
			ba.writeUTFBytes( input );
			ba.compress();
			ba.position = 0;
			
			for ( var i:int = 0; i < ba.length; i++ ) {
				
				c = ba.readByte();
				r = c.toString( 16 );
				s += r;
				
			}
			
			return s;
			
		}
		
	}

}