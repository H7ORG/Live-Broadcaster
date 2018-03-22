package org.igazine.nativeprocess.encoder {
	
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
	
	public class FFMPEGOutputPattern {
		
		public static const VERSION:RegExp = new RegExp( /^(ffmpeg version)/ );
		public static const FRAME:RegExp = new RegExp( /^(frame=)/ );
		//public static const VIDEO_STREAM_0:RegExp = new RegExp( /(Stream #0:0: Video: )/ );
		//public static const VIDEO_STREAM_0_TYPE_START:RegExp = new RegExp( /(Input #0)+([\s\S])+(Stream #0:0: Video: )/ );
		public static const VIDEO_STREAM:RegExp = new RegExp( /(Input #0)/ );
		public static const VIDEO_STREAM_0_TYPE:RegExp = new RegExp( /(?<=(Stream #0:0: Video: ))(.*?)(?=,)/ );
		public static const VIDEO_STREAM_0_RESOLUTION:RegExp = new RegExp( /(\d{2,4}x\d{2,4})/ );
		public static const AUDIO_STREAM_0:RegExp = new RegExp( /(Stream #0:1: Audio: )/ );
		
		public static const IGNOREDS:Vector.<RegExp> = new <RegExp>[
			new RegExp( /(monotonous)/g ),
			new RegExp( /(Queue input is backward in time)/g ),
			new RegExp( /(Past duration)/g ),
			new RegExp( /(This may result in incorrect)/g ),
			new RegExp( /(EOI missing, emulating)/g ),
			new RegExp( /(Last message repeated)/g )
		];
		
		public function FFMPEGOutputPattern() { }
		
	}

}