package org.igazine.apis.events {

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
	
	public class FacebookEvent extends Event {
		
		public static const ERROR:String = "facebookError";
		public static const SUCCESS:String = "facebookSuccess";
		
		public var status:int;
		public var code:int;
		public var message:String;
		public var errorType:String;
		public var user:Object;
		public var permissions:Array;
		public var liveVideo:Object;
		public var title:String;
		public var liveStatus:String;
		public var embedHtml:String;
		public var id:String;
		public var liveViews:int;
		public var secondsLeft:int;
		public var permalink:String;
		public var likes:int;
		public var cursorBefore:String;
		public var cursorAfter:String;
		public var comments:Array;
		public var accounts:Array;
		
		public function FacebookEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			
			super(type, bubbles, cancelable);
			
		}
		
	}

}