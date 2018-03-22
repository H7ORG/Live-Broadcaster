package org.igazine.apis.youtube {
	
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
	
	public class YouTubeHelper {
		
		// [ [ video low, video medium, video high ], [ video 60fps low, video 60fps medium, video 60fps high ], [ audio low, audio medium, audio high ] ]
		private static const H240P:Array = [ [ 300, 500, 700 ], [ 300, 500, 700 ], [ 24, 32, 96 ] ];
		private static const H360P:Array = [ [ 400, 700, 1000 ], [ 400, 700, 1000 ], [ 32, 64, 96 ] ];
		private static const H480P:Array = [ [ 500, 1250, 2000 ], [ 500, 1250, 2000 ], [ 64, 96, 128 ] ];
		private static const H720P:Array = [ [ 1500, 2500, 4000 ], [ 2250, 4000, 6000 ], [ 96, 128, 192 ] ];
		private static const H1080P:Array = [ [ 3000, 4500, 6000 ], [ 4500, 6500, 9000 ], [ 128, 192, 256 ] ];
		private static const H1440P:Array = [ [ 6000, 9000, 13000 ], [ 9000, 12000, 18000 ], [ 128, 192, 256 ] ];
		private static const H2160P:Array = [ [ 13000, 22000, 34000 ], [ 20000, 35000, 51000 ], [ 128, 192, 256 ] ];
		
		public static const QUALITY_LOW:int = 0;
		public static const QUALITY_MEDIUM:int = 1;
		public static const QUALITY_HIGH:int = 2;
		
		public function YouTubeHelper() {}
		
		public static function getQuality( height:int, fps:Number = 25, quality:int = QUALITY_MEDIUM, forceFacebookCompatibility:Boolean = false ):Object {
			
			var o:Object = {};
			
			var xHeight:int = height;
			var xFPS:Number = fps;
			
			if ( forceFacebookCompatibility ) {
				
				if ( xHeight > 720 ) xHeight = 720;
				xFPS = 30;
				
			}
			
			switch( xHeight ) {
				
				case 240:
					o.ba = H240P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H240P[ 1 ][ quality ] : o.bv = H240P[ 0 ][ quality ];
					break;
				
				case 360:
					o.ba = H360P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H360P[ 1 ][ quality ] : o.bv = H360P[ 0 ][ quality ];
					break;
				
				case 480:
					o.ba = H480P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H480P[ 1 ][ quality ] : o.bv = H480P[ 0 ][ quality ];
					break;
				
				case 720:
					o.ba = H720P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H720P[ 1 ][ quality ] : o.bv = H720P[ 0 ][ quality ];
					break;
				
				case 1080:
					o.ba = H1080P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H1080P[ 1 ][ quality ] : o.bv = H1080P[ 0 ][ quality ];
					break;
				
				case 1440:
					o.ba = H1440P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H1440P[ 1 ][ quality ] : o.bv = H1440P[ 0 ][ quality ];
					break;
				
				case 2160:
					o.ba = H2160P[ 2 ][ quality ];
					( xFPS >= 60 ) ? o.bv = H2160P[ 1 ][ quality ] : o.bv = H2160P[ 0 ][ quality ];
					break;
				
			}
		
			o.fps = xFPS;
			o.bv -= o.ba;
			return o;
			
		}
		
		public static function getQualities( height:int, fps:Number = 25, enableHigh:Boolean = true ):XML {
			
			var x:XML = new XML( "<root />" );
			var xLow:XML = new XML( "<quality />" );
			var xMedium:XML = new XML( "<quality />" );
			var xHigh:XML = new XML( "<quality />" );
			var d:int;
			
			var newHeight:int;
			
			if ( height < 240 ) newHeight = 240;
			if ( height >= 240 ) newHeight = 240;
			if ( height >= 360 ) newHeight = 360;
			if ( height >= 480 ) newHeight = 480;
			if ( height >= 720 ) newHeight = 720;
			if ( height >= 1080 ) newHeight = 1080;
			if ( height >= 1440 ) newHeight = 1440;
			if ( height >= 2160 ) newHeight = 2160;
			
			( fps >= 60 ) ? d = 1 : d = 0;
			
			switch( newHeight ) {
				
				case 240:
					xLow.label = "Low (" + String( H240P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H240P[ 2 ][ 0 ];
					xLow.bv = H240P[ 0 + d ][ 0 ] - H240P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H240P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H240P[ 2 ][ 1 ];
					xMedium.bv = H240P[ 0 + d ][ 1 ] - H240P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H240P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H240P[ 2 ][ 2 ];
					xHigh.bv = H240P[ 0 + d ][ 2 ] - H240P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 360:
					xLow.label = "Low (" + String( H360P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H360P[ 2 ][ 0 ];
					xLow.bv = H360P[ 0 + d ][ 0 ] - H360P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H360P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H360P[ 2 ][ 1 ];
					xMedium.bv = H360P[ 0 + d ][ 1 ] - H360P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H360P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H360P[ 2 ][ 2 ];
					xHigh.bv = H360P[ 0 + d ][ 2 ] - H360P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 480:
					xLow.label = "Low (" + String( H480P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H480P[ 2 ][ 0 ];
					xLow.bv = H480P[ 0 + d ][ 0 ] - H480P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H480P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H480P[ 2 ][ 1 ];
					xMedium.bv = H480P[ 0 + d ][ 1 ] - H480P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H480P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H480P[ 2 ][ 2 ];
					xHigh.bv = H480P[ 0 + d ][ 2 ] - H480P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 720:
					xLow.label = "Low (" + String( H720P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H720P[ 2 ][ 0 ];
					xLow.bv = H720P[ 0 + d ][ 0 ] - H720P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H720P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H720P[ 2 ][ 1 ];
					xMedium.bv = H720P[ 0 + d ][ 1 ] - H720P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H720P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H720P[ 2 ][ 2 ];
					xHigh.bv = H720P[ 0 + d ][ 2 ] - H720P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 1080:
					xLow.label = "Low (" + String( H1080P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H1080P[ 2 ][ 0 ];
					xLow.bv = H1080P[ 0 + d ][ 0 ] - H1080P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H1080P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H1080P[ 2 ][ 1 ];
					xMedium.bv = H1080P[ 0 + d ][ 1 ] - H1080P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H1080P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H1080P[ 2 ][ 2 ];
					xHigh.bv = H1080P[ 0 + d ][ 2 ] - H1080P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 1440:
					xLow.label = "Low (" + String( H1440P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H1440P[ 2 ][ 0 ];
					xLow.bv = H1440P[ 0 + d ][ 0 ] - H1440P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H1440P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H1440P[ 2 ][ 1 ];
					xMedium.bv = H1440P[ 0 + d ][ 1 ] - H1440P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H1440P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H1440P[ 2 ][ 2 ];
					xHigh.bv = H1440P[ 0 + d ][ 2 ] - H1440P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
				case 2160:
					xLow.label = "Low (" + String( H2160P[ 0 + d ][ 0 ] ) + " kbps)";
					xLow.ba = H2160P[ 2 ][ 0 ];
					xLow.bv = H2160P[ 0 + d ][ 0 ] - H2160P[ 2 ][ 0 ];
					xMedium.label = "Medium (" + String( H2160P[ 0 + d ][ 1 ] ) + " kbps)";
					xMedium.ba = H2160P[ 2 ][ 1 ];
					xMedium.bv = H2160P[ 0 + d ][ 1 ] - H2160P[ 2 ][ 1 ];
					xHigh.label = "High (" + String( H2160P[ 0 + d ][ 2 ] ) + " kbps)";
					xHigh.ba = H2160P[ 2 ][ 2 ];
					xHigh.bv = H2160P[ 0 + d ][ 2 ] - H2160P[ 2 ][ 2 ];
					xHigh.disabled = int( !enableHigh );
					break;
				
			}
			
			x.appendChild( xLow );
			x.appendChild( xMedium );
			x.appendChild( xHigh );
			return x;
			
		}
		
		public static function getConformedHeight( height:int, forceFacebookCompatibility:Boolean = false ):int {
			
			var h:int;
			
			if ( height < 240 ) h = 240;
			if ( height >= 240 ) h = 240;
			if ( height >= 360 ) h = 360;
			if ( height >= 480 ) h = 480;
			if ( height >= 720 ) h = 720;
			if ( height >= 1080 ) h = 1080;
			if ( height >= 1440 ) h = 1440;
			if ( height >= 2160 ) h = 2160;
			
			if ( forceFacebookCompatibility ) {
				
				if ( h > 720 ) h = 720;
				
			}
			
			return h;
			
		}
		
		public static function getConformedFPS( fps:Number, forceFacebookCompatibility:Boolean = false ):int {
			
			var f:int;
			
			if ( fps < 60 ) f = 30 else f = 60;
			if ( forceFacebookCompatibility ) f = 30;
			
			return f;
			
		}
		
		public static function getConformedCDNResolution( height:int ):String {
			
			var s:String;
			var h:int = getConformedHeight( height );
			
			switch( h ) {
				
				case 240:
					s = CDN.RESOLUTION_240P;
					break;
				
				case 360:
					s = CDN.RESOLUTION_360P;
					break;
				
				case 480:
					s = CDN.RESOLUTION_480P;
					break;
				
				case 720:
					s = CDN.RESOLUTION_720P;
					break;
				
				case 1080:
					s = CDN.RESOLUTION_1080P;
					break;
				
				case 1440:
					s = CDN.RESOLUTION_1440P;
					break;
				
				case 2160:
					s = CDN.RESOLUTION_2160P;
					break;
				
			}
			
			return s;
			
		}
		
		public static function getConformedCDNFPS( fps:Number ):String {
			
			var s:String;
			
			if ( fps < 60 ) s = CDN.FRAMERATE_30FPS else s = CDN.FRAMERATE_60FPS;
			
			return s;
			
		}
		
		public static function getHTMLEmbedCode( liveBroadcast:LiveBroadcast ):String {
			
			if ( liveBroadcast && liveBroadcast.snippet && liveBroadcast.snippet.channelId ) {
				
				var l:String = "https://www.youtube.com/embed/live_stream?channel=" + liveBroadcast.snippet.channelId;
				return '<iframe width="560" height="315" src="'+ l + '" frameborder="0" allowfullscreen></iframe>';
				
			}
			
			return null;
			
		}
		
		public static function getWebLink( liveBroadcast:LiveBroadcast ):String {
			
			if ( liveBroadcast ) {
				
				return "https://www.youtube.com/watch?v=" + liveBroadcast.id;
				
			}
			
			return null;
			
		}
		
	}

}