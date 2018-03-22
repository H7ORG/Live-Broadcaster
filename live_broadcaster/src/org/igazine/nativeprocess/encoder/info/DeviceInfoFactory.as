package org.igazine.nativeprocess.encoder.info {
	
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
	
	
	public class DeviceInfoFactory {
		
		public function DeviceInfoFactory() { }
	
		public static function create( input:String ):DeviceInfo {
			
			var di:DeviceInfo = new DeviceInfo();
			var newLine:String;
			newLine = "\n";
			
			var a:Array = input.split( newLine );
			
			for ( var i:int = 0; i < a.length; i++ ) {
				
				if ( String( a[i] ).search( "dshow" ) >= 0 ) {
					
					var dshowString:String = String( a[i] );
					
					if ( ( dshowString.search( "vcodec=" ) >= 0 ) || ( dshowString.search( "pixel_format=" ) >= 0 ) ) {
						
						var dshowArray:Array = dshowString.split( " " );
						
						//trace( dshowArray );
						
						var die:DeviceInfoEntry = new DeviceInfoEntry();
						
						for ( var j:int = 0; j < dshowArray.length; j++ ) {
							
							if ( dshowArray[j].search( "vcodec=" ) >= 0 ) {
								
								die.vCodec = dshowArray[j].split( "vcodec=" )[1];
								
							}
							
							if ( dshowArray[j].search( "min" ) >= 0 ) {
								
								die.resolution = dshowArray[j+1].split( "s=" )[1];
								die.minFps = Number( dshowArray[j+2].split( "fps=" )[1] );
								
							}
							
							if ( dshowArray[j].search( "max" ) >= 0 ) {
								
								die.resolution = dshowArray[j+1].split( "s=" )[1];
								die.maxFps = Number( String( dshowArray[j+2].split( "fps=" )[1] ) );
								
							}
							
						}
						
						//trace( die.infoString );
						
						if ( !di.contains( die ) ) di.addEntry( die );
						
					}
					
				} else if ( String( a[i] ).search( "avfoundation" ) >= 0 ) {
					
					var valid:RegExp = /(\[avfoundation)(.+)(\s{3})/g;
					
					if ( valid.test( a[i] ) ) {
						
						var converted:String = String( a[i] ).replace( valid, "" );
						var parts:Array = converted.split( "@" );
						//trace( parts );
						
						var avfi:DeviceInfoEntry = new DeviceInfoEntry();
						avfi.resolution = String( parts[0] );
						
						var fpsPart:Array = String( parts[1] ).split( "fps" );
						
						var fpsString:String = String( fpsPart[0] ).replace( "[", "" );
						fpsString = fpsString.replace( "]", "" );
						//trace( fpsString );
						
						var aFps:Array = fpsString.split( " " );
						//trace( aFps );
						
						avfi.minFps = Number( aFps[0] );
						avfi.maxFps = Number( aFps[1] );
						
						if ( !di.contains( avfi ) ) di.addEntry( avfi );
						
						//trace( avfi.infoString );
						
					}
					
				}
				
			}
			
			//trace( 'DeviceInfoFactory.create() -----------------------------------' );
			
			di.sort();
			
			//for ( var z:int = 0; z < di.entries.length; z++ ) trace( di.entries[z].infoString );
			
			return di;
			
		}
		
	}

}