/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.setup {
	
	import org.as3commons.logging.api.ILogSetup;
	import org.as3commons.logging.util.flatten;
	import org.as3commons.logging.util.removeDuplicates;
	
	/**
	 * Merges multiple setups into one.
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see MergedTarget
	 */
	public function mergeSetups( ...setups ):ILogSetup {
		var result: ILogSetup;
		flatten(setups);
		var i: int;
		for ( i = setups.length-1; i>=0; --i) {
			var mergedSetup: MergedSetup = setups[i] as MergedSetup;
			if( mergedSetup ) {
				setups.splice(i,1);
				mergedSetup.insertSetups(setups, i);
			}
		}
		removeDuplicates(setups);
		for ( i = setups.length-1; i>=0; --i) {
			var setup: ILogSetup = setups[i] as ILogSetup;
			if( setup ) {
				if( result ) {
					result = new MergedSetup(setup, result);
				} else {
					result = setup;
				}
			}
		}
		return result;
	}
}
