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
package org.as3commons.logging.setup.log4j {
	
	import org.as3commons.logging.setup.HierarchicalSetup;
	import org.as3commons.logging.setup.LogSetupLevel;
	
	/**
	 * <code>Log4JStyleSetup</code> is a setup that works much like the log4j 
	 * properties format, without the text part.
	 * 
	 * <p>Important note: <code>Log4JStyleSetup</code> <strong>can not</strong>
	 * implement <code>ILogSetup</code>. To setup this system its necessary to
	 * use the <code>compile()</code> method that returns a valid setup.</p>
	 * 
	 * <listing>
	 * LOGGER_FACTORY.setup = (new Log4JStyleSetup()).compile();
	 * </listing>
	 * 
	 * <p>This setup allows the definition of appenders, named <code>ILogTargets</code>,
	 * eigther by direct referencing or using a class name to instantiation.</p>
	 * 
	 * <listing>
	 * var log4j: Log4JStyleSetup = new Log4JStyleSetup();
	 * log4j.appender["referenced"] = new TraceTarget();
	 * log4j.appender["generated"] = "org.as3commons.logging.setup.target::TraceTarget";
	 * </listing>
	 * 
	 * <p>We just defined the two appenders named "referenced" and "generated".
	 * As you can see <code>appender</code> is dyanmic so you can actually
	 * just type it like this:</p>
	 * 
	 * <listing>
	 * log4j.appender.generated = "org.as3commons.logging.setup.target::TraceTarget";
	 * </listing>
	 * 
	 * <p>You can also set primitive properties like "format". They will be filled
	 * after the instantiation.</p>
	 * 
	 * <listing>
	 * log4j.appender.generated.format = "{message} ({logLevel}, {logTime})";
	 * </listing>
	 * 
	 * <p>These appenders can be used for example with the rootLogger.</p>
	 * 
	 * <listing>
	 * log4j.rootLogger = "WARN, generated";
	 * </listing>
	 * 
	 * <p>The <code>rootLogger</code> defines the basic setup. The first value passed is always
	 * the level. It can be <code>DEBUG</code>,<code>INFO</code>,<code>WARN</code>,
	 * <code>ERROR</code> or <code>FATAL</code>. Following the level you can pass
	 * a list of appenders seperated by a colon.</p>
	 * 
	 * <p>That means with <code>"WARN, generated"</code> we allow <code>warn</code>,
	 * <code>error</code> and <code>fatal</code> log statements to be used and send
	 * them to our target with the name <code>generated</code>.</p>
	 * 
	 * <p>It is further possible to use the same kind of syntax for hierarchical
	 * setups using the <code>logger</code> property.</p>
	 * 
	 * <listing>
	 * log4j.logger["org"]["as3commons"] = "ERROR, referenced";
	 * </listing>
	 * 
	 * <p>Also here we make strong use of dynamic proxies and you could just write
	 * it without the braces and quotes:</p>
	 * 
	 * <listing>
	 * log4j.logger.org.as3commons = "ERROR, referenced";
	 * </listing>
	 * 
	 * <p>The passed in log-level <code>"ERROR"</code> always overrides the level
	 * definition in the upper levels. The target is by default <strong>merged</strong>
	 * with the parent target. This means that now <code>error</code> and <code>
	 * fatal</code> messages will be sent to the targets named <code>generated</code>
	 * and <code>referenced</code>!</p>
	 * 
	 * <p>To avoid the merging of the targets of lower levels the setup allows
	 * switching of appending using the <code>additivity</code> flag.</p>
	 * 
	 * <listing>
	 * log4j.additivity["org"]["as3commons"] = false;
	 * </listing>
	 * 
	 * <p>Again, thanks to dynamic proxies, you can write it also without the braces.</p>
	 * 
	 * <listing>
	 * log4j.additivity.org.as3commons = false;
	 * </listing>
	 * 
	 * <p>Now the former setup will be changed to just send to the appender named
	 * <code>referenced</code>.</p>
	 * 
	 * <p>There is also a way to limit the setup output using the <code>threshold</code>
	 * property.</p>
	 * 
	 * <listing>
	 * log4j.threshold = "FATAL";
	 * </listing>
	 * 
	 * <p>After setting of the threshold, any other configuration will be limited
	 * to this log level. That means that even though we defined the targets before
	 * as sending to <code>"ERROR"</code> it will be limited to <code>"FATAL"</code>.
	 * </p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.7
	 * @see org.as3commons.logging.setup#log4j
	 */
	public final class Log4JStyleSetup {
		
		use namespace log4j;
		
		private const _root: HierarchyEntry = new HierarchyEntry("");
		private var _threshold: LogSetupLevel;
		
		/**
		 * Appender Registry.
		 */
		public const appender: Appenders = new Appenders();
		
		/**
		 * Logger path configuration.
		 */
		public const logger: LevelSetup = new LevelSetup( _root );
		
		/**
		 * Additive setup definitions.
		 */
		public const additivity: AdditivitySetup = new AdditivitySetup(_root);
		
		public function Log4JStyleSetup() {}
		
		/**
		 * Root logger definition
		 */
		public function set rootLogger(value: String):void {
			parseValue(_root,value);
		}
		
		public function set threshold(level: String):void {
			_threshold = getLevel(level);
		}
		
		/**
		 * Compiles the setup into a <code>HierarchialSetup</code>
		 * 
		 * @return Compiled HierarchialSetup with all the properties prepared.
		 */
		public function compile():HierarchicalSetup {
			var setup: HierarchicalSetup = new HierarchicalSetup(".", _threshold);
			_root.applyTo( setup, appender.generateAppenders(), {} );
			return setup;
		}
	}
}
import org.as3commons.logging.api.ILogTarget;
import flash.utils.Proxy;
import flash.utils.flash_proxy;
import flash.utils.getDefinitionByName;
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.as3commons.logging.setup.HierarchicalSetup;
import org.as3commons.logging.setup.LogSetupLevel;
import org.as3commons.logging.setup.log4j.Log4JStyleSetup;
import org.as3commons.logging.setup.target.mergeTargets;
import org.as3commons.logging.util.instantiate;

// Using the internal namespace, so others DON'T use that.
namespace log4j;
	
use namespace log4j;

const LOGGER: ILogger = getLogger(Log4JStyleSetup);

dynamic class Appenders extends Proxy {
	
	log4j var _appenders: Object = {};
	
	public function Appenders() {}
	
	override flash_proxy function getProperty(name: *): * {
		var nameStr: String = name;
		return _appenders[nameStr] ||= new AppenderGenerator(nameStr);
	}
	
	override flash_proxy function setProperty(name: *, value: *) : void {
		(flash_proxy::getProperty(name) as AppenderGenerator)._value = value;
	}
	
	log4j function generateAppenders(): Object {
		var appenders: Object = {};
		for( var appenderName: String in _appenders ){
			var target: ILogTarget = AppenderGenerator( _appenders[appenderName] ).getAppender();
			appenders[appenderName] = target;
		}
		return appenders;
	}
}

dynamic class PropertyContainer extends Proxy {
	
	log4j var _properties : Object = {};
	log4j var _name: String;
	log4j var _value: * = undefined;
	
	public function PropertyContainer(propertyName: String) {
		_name = propertyName;
	}
	
	log4j function applyProperty(instance:*, stack: Array): void {
		
		var value: Object;
		try {
			if( _value === undefined ) {
				value = instance[_name];
			} else {
				value = _value;
				instance[_name] = _value;
			}
		} catch( e: Error ) {
			if( LOGGER.warnEnabled ) {
				LOGGER.warn("Can not access property '{1}' of appender '{0}': {2}", [stack[0], stack.slice(1, stack.length).concat(_name).join("."), e]);
			}
			return;
		}
		var child: String;
		if( value ) {
			stack.push(_name);
			for( child in _properties ) {
				if( child != "Threshold" || stack.length != 0) {
					// Ignore the "Threshold" child as its used in the setup process
					(_properties[child] as PropertyContainer).applyProperty(value, stack);
				}
			}
			stack.pop();
		} else {
			for( child in _properties ) {
				if( LOGGER.warnEnabled ) {
					LOGGER.warn("Can not set child properties for '{1}' of appender '{0}' as its 'null'", [stack[0], stack.slice(1, stack.length).concat(_name).join(".")]);
				}
				break;
			}
		}
	}
	
	override flash_proxy function getProperty(name: *): * {
		var nameStr: String = name;
		return _properties[nameStr] ||= new PropertyContainer( name );
	}
	
	override flash_proxy function setProperty(name: *, value: *) : void {
		(flash_proxy::getProperty(name) as PropertyContainer)._value = value;
	}
}

dynamic class AppenderGenerator extends PropertyContainer {
	
	public function AppenderGenerator(name: String) {
		super(name);
	}
	
	log4j function getAppender(): ILogTarget {
		var target: ILogTarget;
		if( _value is ILogTarget ) {
			target = _value;
		} else if( _value is String ) {
			var cls: *;
			try {
				cls = getDefinitionByName( _value );
			} catch (e:Error) {}
			if( cls ) {
				try {
					target = ILogTarget( instantiate( cls ) );
				} catch( e: Error ) {
					if( LOGGER.warnEnabled ) {
						LOGGER.warn( "Appender '{0}' could not be instantiated as '{1}' due to error '{2}'", [_name, _value, e] );
					}
				}
			} else if( LOGGER.warnEnabled ) {
				LOGGER.warn( "Appender '{0}' can not be instantiated from class '{1}' because the class wasn't available at runtime.", [_name, _value] );
			}
		} else if( LOGGER.warnEnabled ) {
			LOGGER.warn( "Appender '{0}' could not be used as its no ILogTarget implementation or class name! Defined as: {1}", [_name, _value] );
		}
		
		if( target ) {
			var stack: Array;
			for( var name: String in _properties ) {
				(_properties[name] as PropertyContainer).applyProperty(target, stack ||= [_name]);
			}
		}
		return target;
	}
}

dynamic class LevelSetup extends Proxy {
	
	log4j var _children: Object = {};
	log4j var _entry: HierarchyEntry;
	
	public function LevelSetup( entry: HierarchyEntry ) {
		_entry = entry;
	}
	
	override flash_proxy function getProperty(name: *): * {
		var nameStr: String = name;
		return _children[nameStr] ||= new LevelSetup( _entry.child(nameStr) );
	}
	
	override flash_proxy function setProperty(name: *, value: *) : void {
		parseValue( _entry.child(name), value );
	}
}

dynamic class AdditivitySetup extends Proxy {
	
	internal var _children: Object = {};
	internal var _entry: HierarchyEntry;
	
	public function AdditivitySetup( entry: HierarchyEntry ) {
		_entry = entry;
	}
	
	override flash_proxy function getProperty(name: *): * {
		var nameStr: String = name;
		return _children[nameStr] ||= new AdditivitySetup( _entry.child(nameStr) );
	}
	
	override flash_proxy function setProperty(name: *, value: *) : void {
		var valueStr: String = value;
		_entry.child(name)._additive = valueStr.toUpperCase() == "TRUE";
	}
}

function parseValue(entry: HierarchyEntry, value: String):HierarchyEntry {
	var valueArr: Array = value.split(",");
	var levelStr: String = trim(valueArr.shift());
	var i: int = valueArr.length;
	while(--i-(-1)) {
		var child:String = trim(valueArr[i]);
		if( child.length > 0 ) {
			valueArr[i] = unesc(child);
		} else {
			valueArr.splice(i,1); // don't need empty values don't we
		}
	}
	entry._level = getLevel( levelStr );
	entry._appenders = valueArr.length > 0 ? valueArr : null;
	return entry;
}

function unesc(str:String):String {
	return str.replace(/\\([\\tnrb])/g, encodingReplace);
}

const tags: Object =  {
	"t": "\t",
	"n": "\n",
	"r": "\r",
	"\\": "\\",
	"b": "\b"
};

function encodingReplace(...args:Array):String {
	return tags[args[1]];
}

function getLevel(levelStr:String): LogSetupLevel {
	levelStr = levelStr.toUpperCase();
	var level:LogSetupLevel = null;
	if( levelStr == "DEBUG" ) {
		level = LogSetupLevel.DEBUG;
	} else if( levelStr == "INFO" ) {
		level = LogSetupLevel.INFO;
	} else if( levelStr == "WARN" ) {
		level = LogSetupLevel.WARN;
	} else if( levelStr == "ERROR" ) {
		level = LogSetupLevel.ERROR;
	} else if( levelStr == "FATAL" ) {
		level = LogSetupLevel.FATAL;
	} else if( levelStr == "NONE" ) {
		level = LogSetupLevel.NONE;
	} else if( levelStr == "ALL" ) {
		level = LogSetupLevel.ALL;
	}
	return level;
}

function trim(str:String): String {
	 return str.replace(/^\s*/, '').replace(/\s*$/, '');
}

class HierarchyEntry {
	
	internal var _appenders: Array = [];
	internal var _level: LogSetupLevel;
	internal var _additive: Boolean = true;
	internal var _name: String;
	internal var _children: Object = new Object();
	
	public function HierarchyEntry(name: String) {
		_name = name;
		_level = LogSetupLevel.NONE;
	}
	
	public function child(name:String): HierarchyEntry {
		return _children[name] ||= new HierarchyEntry(_name == "" ? name : _name+"."+name);
	}
	
	public function applyTo(setup: HierarchicalSetup, appenderLookup: Object, thrownErrors: Object ) : void {
		var target: ILogTarget;
		for each(var appenderName: String in _appenders) {
			if(appenderLookup[appenderName] == null && !thrownErrors[appenderName]) {
				thrownErrors[appenderName] = true;
				LOGGER.warn("Appender {} is used but not defined.", appenderName);
			}
			target = mergeTargets( target, appenderLookup[appenderName] );
		}
		setup.setHierarchy(_name, target, _level, _additive);
		for each(var child: HierarchyEntry in _children) {
			child.applyTo( setup, appenderLookup, thrownErrors );
		}
	}
}