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
	
	public class BindableSettings {
		
		[Bindable] public static var MAIN_WINDOW_PADDING:int = 10;
		
		// Values for background skin
		[Bindable] public static var USE_STAGE_VIDEO:Boolean = false;
		[Bindable] public static var BG_COLOR:uint = 0x272A32;
		[Bindable] public static var LEFT_WIDTH:int = 291;
		[Bindable] public static var RIGHT_WIDTH:int = 291;
		[Bindable] public static var HEADER_HEIGHT:int = 60;
		[Bindable] public static var FOOTER_HEIGHT:int = 160;
		
		public function BindableSettings() {}
		
	}

}