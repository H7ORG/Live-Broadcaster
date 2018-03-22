package org.igazine.media.cameras {
	
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
	import flash.events.IEventDispatcher;
	
	public interface IIPCamera extends IEventDispatcher {
		
		function getSnapshot():void;
		function getIPInfo():void;
		function getDevInfo():void;
		function getDevState():void;
		function getStatus():void;
		function getImageFlip():void;
		function setImageFlip( flipped:Boolean ):void;
		function getImageMirror():void;
		function setImageMirror( mirrored:Boolean ):void;
		function getInfraRedConfig():void;
		function setInfraRedConfig( mode:int ):void;
		function openInfraRed():void;
		function closeInfraRed():void;
		
		function get type():String;
		function get username():String;
		function set username( s:String ):void;
		function get password():String;
		function set password( s:String ):void;
		function get address():String;
		function set address( s:String ):void;
		function get streamAddress():String;
		function set streamAddress( s:String ):void;
		function get port():int;
		function set port( i:int ):void;
		function get name():String;
		function get imageFlip():Boolean;
		function get imageMirror():Boolean;
		function get autoInfraRed():Boolean;
		function get infraRed():Boolean;
		
		function get supportsAutoInfraRed():Boolean;
		function get supportsInfraRed():Boolean;
		function get supportsImageFlip():Boolean;
		function get supportsImageMirror():Boolean;
		
	}
	
	
}