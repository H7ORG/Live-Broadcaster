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
	
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.api.ILogSetup;
	import org.as3commons.logging.api.Logger;
	
	/**
	 * Heritance based setup process much like log4j.
	 * 
	 * <p>Much like a log4j setup this setup allows hierarchical defininition of
	 * loggers. It allows the definition of a target and level per hierarchy level
	 * and automatically pass it to all sublevels.</p>
	 * 
	 * <p>The setup allows to define a "threshold", a global maximal LogLevel. This
	 * allows to switch off the setup with a simple flag.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 */
	public final class HierarchicalSetup implements ILogSetup {
		
		/** Global level threshold */
		private var _threshold: LogSetupLevel = LogSetupLevel.ALL;
		
		/** Root hierachy */
		private var _root: HierarchyData = new HierarchyData();
		
		/** Seperator used to split loggers names into a hierachy path. */
		private var _separator: String;
		
		/**
		 * Creates a new <code>HierarchicalSetup</code>
		 * 
		 * @param levelSeparator Seperator for the levels in our hierarchy (as loggers just have names)
		 * @param threshold Global threshold that limits the output level.
		 */
		public function HierarchicalSetup(levelSeparator:String=".",threshold:LogSetupLevel=null) {
			_separator = levelSeparator;
			_threshold = threshold || LogSetupLevel.ALL;
		}
		
		/**
		 * Global threshold that limits the output levels.
		 */
		public function set threshold(level:LogSetupLevel): void {
			_threshold = level;
			_root.dirty = true;
		}
		
		/**
		 * Sets the properties of one hierarchy level
		 * 
		 * @param path Hierarchy path, unseparated.
		 * @param target Target to be used for logging in this hierarchy and subhierarchies.
		 * @param level Level to be used from this hierarchy on, if not given, the parent level will be used
		 * @param additive Flat to set if the hierarchy level should merge the target
		 *        with the parent targets or not.
		 */
		public function setHierarchy(path:String=null, target:ILogTarget=null,
										level:LogSetupLevel=null, additive:Boolean=true): void {
			var pathSplit: Array = (path && path != "") ? path.split(_separator) : null;
			var info: HierarchyData = _root;
			if( pathSplit ) {
				while( pathSplit.length > 0 ) {
					var name: String = pathSplit.shift();
					var child: HierarchyData = info.children[name];
					if( !child ) {
						info.children[name] = child = new HierarchyData();
						info.dirty = true;
					}
					info = child;
				}
			}
			info.target = target;
			info.level = level;
			info.additive = additive;
			info.dirty = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function applyTo(logger: Logger): void {
			var path: Array =  logger.name == "" ? null : logger.name.split(_separator);
			_root.applyConfigTo(logger, path, LogSetupLevel.ALL, null, _threshold);
		}
	}
}

import org.as3commons.logging.setup.target.mergeTargets;
import org.as3commons.logging.api.Logger;
import org.as3commons.logging.api.ILogTarget;
import org.as3commons.logging.setup.LogSetupLevel;

class HierarchyData {
	
	internal var children: Object = {};
	internal var level: LogSetupLevel = null;
	internal var target: ILogTarget;
	internal var additive: Boolean = true;
	
	private var _dirty: Boolean = true;
	private var _target: ILogTarget;
	private var _level: LogSetupLevel;
	
	public function HierarchyData() {}
	
	internal function set dirty( dirty: Boolean ): void {
		if( _dirty != dirty ) {
			_dirty = dirty;
			for each( var child: HierarchyData in children ) {
				child.dirty = true;
			}
		}
	}
	
	internal function applyConfigTo(logger: Logger, path: Array, level: LogSetupLevel,
									appender: ILogTarget, threshold: LogSetupLevel):void {
		if(_dirty) {
			if(additive && appender) {
				_target  = mergeTargets( appender, this.target );
			} else {
				_target = this.target;
			}
			_level = LogSetupLevel.getLevelByValue( (this.level || level).valueOf() & threshold.valueOf() );
			_dirty = false;
		}
		var child: HierarchyData;
		if( path && (child = children[path[0]] as HierarchyData) ) {
			path.shift();
			child.applyConfigTo(logger, path, _level, _target, threshold);
		} else {
			_level.applyTo(logger, _target);
		}
	}
}
