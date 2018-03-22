package live.cameleon.utils {

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
 * Author: Yatko, 2017
 * 
 */
	
	import com.adobe.crypto.MD5;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	public class Utils {
		
		public static var RATIO_16_9:Number = .5625;
		public static var RATIO_4_3:Number = .75;
		
		private static var chars:String = "abcdefghijklmnopqrstuvwxyz0123456789";
		private static var camNameChars:String = "0123456789QWERTYUIOPASDFGHJKLZXCVBNM";
		
		public function Utils() { }
		
		public static function calculateSize( target:Rectangle, source:Rectangle, zoom:Boolean = false ):Rectangle {
			
			var result:Rectangle = new Rectangle();
			var targetRatio:Number = target.height / target.width;
			var sourceRatio:Number = source.height / source.width;
			
			if ( zoom ) {
				
				if ( targetRatio < sourceRatio ) {
					result.width = target.width;
					result.height = int(target.width * sourceRatio);
				}
				
				if ( targetRatio == sourceRatio ) {
					result.width = target.width;
					result.height = target.height;
				}
				
				if ( targetRatio > sourceRatio ) {
					result.height = target.height;
					result.width = int(target.height / sourceRatio);
				}
				
			} else {
				
				if ( targetRatio < sourceRatio ) {
					result.height = target.height;
					result.width = int(target.height / sourceRatio);
				}
				if ( targetRatio == sourceRatio ) {
					result.width = target.width;
					result.height = target.height;
				}
				if ( targetRatio > sourceRatio ) {
					result.width = target.width;
					result.height = int(target.width * sourceRatio);
				}
			}
			
			if ( target.width < result.width ) {
				result.x = int((target.width / 2) - (result.width / 2));
			}
			if ( target.width == result.width ) {
				result.x = 0;
			}
			if ( target.width > result.width ) {
				result.x = int((target.width / 2) - (result.width / 2));
			}
			
			if ( target.height < result.height ) {
				result.y = int((target.height / 2) - (result.height / 2));
			}
			if ( target.height == result.height ) {
				result.y = 0;
			}
			if ( target.height > result.height ) {
				result.y = int((target.height / 2) - (result.height / 2));
			}
			
			return result;
			
		}
		
		public static function timeString( additionalHours:Number = 0, additionalMinutes:Number = 0, additionalSeconds:Number = 0 ):String {
			
			var s:String;
			var currentDate:Date = new Date();
			var currentTime:Number = currentDate.getTime();
			currentTime += additionalSeconds * 1000;
			currentTime += additionalMinutes * 60 * 1000;
			currentTime += additionalHours * 60 * 60 * 1000;
			
			var updatedDate:Date = new Date();
			updatedDate.setTime( currentTime );
			
			//s = String( updatedDate );
			s = String( updatedDate.fullYearUTC );
			s += "-";
			var m:String;
			( ( updatedDate.monthUTC + 1 ) < 10 ) ? m = "0" + String( updatedDate.monthUTC + 1 ) : m = String( updatedDate.monthUTC + 1 );
			s += m;
			s += "-";
			var da:String;
			( updatedDate.dateUTC < 10 ) ? da = "0" + String( updatedDate.dateUTC ) : da = String( updatedDate.dateUTC );
			s += da;
			s += "T";
			var h:String;
			( updatedDate.hoursUTC < 10 ) ? h = "0" + String ( updatedDate.hoursUTC ) : h = String( updatedDate.hoursUTC );
			s += h;
			s += ":";
			var mi:String;
			( updatedDate.minutesUTC < 10 ) ? mi = "0" + String( updatedDate.minutesUTC ) : mi = String( updatedDate.minutesUTC );
			s += mi;
			s += ":";
			var se:String;
			( updatedDate.secondsUTC < 10 ) ? se = "0" + String( updatedDate.secondsUTC ) : se = String( updatedDate.secondsUTC );
			s += se;
			s += ".";
			var ms:String;
			//ms = String( updatedDate.millisecondsUTC );
			ms = "0";
			s += ms;
			s += "Z";
			return s;
			
		}
		
		public static function conformedSize( width:int, height:int ):Point {
			
			var p:Point = new Point();
			var n:Number;
			var r:Number = height / width;
			if ( r >= RATIO_4_3 ) r = RATIO_4_3;
			if ( ( r > RATIO_16_9 ) && ( r < RATIO_4_3 ) ) r = RATIO_16_9;
			if ( r <= RATIO_16_9 ) r = RATIO_16_9;
			
			p.x = width;
			p.y = height;
			
			/*
			if ( r == RATIO_4_3 ) {
				
				p.y = 480;
				p.x = 640;
				return p;
				
			}
			*/
			
			if ( height >= 1080 ) {
				
				n = 1080 / height;
				//p.x = int( width * n );
				p.y = 1080;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			if ( ( height >= 720 ) && ( height < 1080 ) ) {
				
				n = 720 / height;
				p.y = 720;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			if ( ( height >= 480 ) && ( height < 720 ) ) {
				
				n = 480 / height;
				p.y = 480;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			if ( ( height >= 360 ) && ( height < 480 ) ) {
				
				n = 360 / height;
				p.y = 360;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			if ( ( height >= 240 ) && ( height < 360 ) ) {
				
				n = 240 / height;
				p.y = 240;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			if ( height < 240 ) {
				
				n = 240 / height;
				p.y = 240;
				p.x = int( p.y / r );
				if ( ( p.x % 2 ) == 1 ) p.x++;
				return p;
				
			}
			
			return p;
			
		}
		
		public static function conformedFPS( fps:int ):int {
			
			var i:int = fps;
			
			if ( fps > 30 ) i = 30;
			if ( ( fps > 25 ) && ( fps < 30 ) ) i = 25;
			if ( fps < 25 ) i = 25;
			
			return i;
			
		}
		
		public static function conformedRectangle( width:int, height:int ):Rectangle {
			
			var r:Rectangle = new Rectangle();
			
			var n:Number;
			
			return r;
			
		}
		
		public static function generateCameraName( brandName:String ):String {
			
			var s:String = brandName + " Live Stream - ";
			var c:String = "";
			for ( var i:int = 0; i < 8; i++ ) {
				c = camNameChars.charAt( int( Math.random() * camNameChars.length ) );
				s += c;
			}
			return s;
		}
		
		public static function getActiveCameraPixelFormat( name:String, isMac:Boolean = false ):String {
			
			if ( name.toLowerCase().search( "manycam" ) >= 0 ) {
				
				if ( isMac ) return "yuyv422" else return "bgr24";
				
			}
			
			return "";
			
		}
		
		public static function generateServerId( software:String ):String {
			
			var s:String = "";
			s += Capabilities.os;
			s += Capabilities.manufacturer;
			s += Capabilities.cpuArchitecture;
			s += Capabilities.language;
			s += software;
			s = MD5.hash( s );
			
			//s = MD5.hash( Capabilities.serverString );
			return s;
			
		}
		
		public static function generateAppId():String {
			
			var s:String = "";
			var n:int = 0;
			
			for ( var i:int = 0; i < 16; i++ ) {
				
				n = Math.random() * 256;
				s += n.toString( 16 );
				//s += String.fromCharCode( n ).;
				
			}
			
			return s;
			
		}

	}

}