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
package org.as3commons.logging.util.xml {
	
	import org.as3commons.logging.api.ILogSetup;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.setup.LevelTargetSetup;
	import org.as3commons.logging.setup.LogSetupLevel;
	import org.as3commons.logging.setup.SimpleRegExpSetup;
	import org.as3commons.logging.setup.SimpleTargetSetup;
	import org.as3commons.logging.setup.mergeSetups;
	import org.as3commons.logging.setup.target.mergeTargets;
	import org.as3commons.logging.util.regExpFromString;
	
	/**
	 * Creates a <code>ILogSetup</code> from a <code>setup</code> or <code>rule</code> nodes.
	 * 
	 * <p><b>Important:</b> nodes for this setups have to use the <code>http://as3commons.org/logging1</code>
	 * namespace. A matching xml-schema can be found on our page and in the svn.</p>
	 * 
	 * <p>A <code>setup</code> node will be transformed into a <code>MergedSetup</code>
	 * of setups to be applied one after another.</p>
	 * 
	 * <p>A <code>rule</code> node will be transformed into various types of setups
	 * depending on the given attributes.</p>
	 * 
	 * <p>A <code>setup</code>-node merges <code>rule</code> nodes together much
	 * like <code>RegExpSetup</code>. This means you can define as many rule nodes
	 * within a setup as you want.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;rule /&gt;
	 *     &lt;rule /&gt;
	 *   &lt;/setup&gt;
	 *   , {} // soon more to that
	 * );
	 * </listing>
	 * 
	 * <p>It is also possible to define targets within a setup node.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;target type="trace" name="common"/&gt;
	 *     &lt;rule /&gt;
	 *     &lt;rule /&gt;
	 *   &lt;/setup&gt;
	 *   , {}
	 * );
	 * </listing>
	 * 
	 * <p>Its will not work! The setup mechanism doesn't know how to link <code>type</code>
	 * with <code>trace</code>, so we have to tell it how to do it.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;target type="trace" name="common"/&gt;
	 *     &lt;rule /&gt;
	 *     &lt;rule /&gt;
	 *   &lt;/setup&gt;
	 *   , {trace: TraceTarget}
	 * );
	 * </listing>
	 * 
	 * <p>That should do the trick. <code>target</code>s defined like this
	 * will not be used. For a target to be active it has to be used within a <code>rule</code>
	 * node.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;target type="trace" name="common"/&gt;
	 *     &lt;rule&gt;
	 *       &lt;target-ref ref="common" /&gt;
	 *     &lt;/rule&gt;
	 *     &lt;rule /&gt;
	 *   &lt;/setup&gt;
	 *   , {trace: TraceTarget}
	 * );
	 * </listing>
	 * 
	 * <p>This can also be writting by passing-in the target as instance!</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;rule&gt;
	 *       &lt;target-ref ref="common" /&gt;
	 *     &lt;/rule&gt;
	 *     &lt;rule /&gt;
	 *   &lt;/setup&gt;
	 *   , {}, {common: new TraceTarget()}
	 * );
	 * </listing>
	 * 
	 * <p>Now the first rule sends out to the trace target.But the second rule
	 * has no target defined, yet its signature is same as of the former rule so
	 * it will override the first rule with an null target.</p>
	 * 
	 * <p>It is possible to distinguish rules using 3 properties: <code>level</code>,
	 * <code>name</code> and <code>person</code>. In detail about it later</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;rule&gt;
	 *       &lt;target-ref ref="common" /&gt;
	 *     &lt;/rule&gt;
	 *     &lt;rule level="ERROR"/&gt;
	 *   &lt;/setup&gt;
	 *   , {}, {common: new TraceTarget()}
	 * );
	 * </listing>
	 * 
	 * <p>Now just the <code>ERROR</code> and <code>FATAL</code> statements will
	 * be set to null. This can be simpler written like:</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;setup xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;rule level="DEBUG_ONLY|INFO_ONLY|WARN_ONLY"&gt;
	 *       &lt;target-ref ref="common" /&gt;
	 *     &lt;/rule&gt;
	 *   &lt;/setup&gt;
	 *   , {}, {common: new TraceTarget()}
	 * );
	 * </listing>
	 * 
	 * <p>Now the setup contains just one rule, so its also possible to just parse
	 * the rule.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;rule level="DEBUG_ONLY|INFO_ONLY|WARN_ONLY" xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;target-ref ref="common" /&gt;
	 *   &lt;/rule&gt;
	 *   , {}, {common: new TraceTarget()}
	 * );
	 * </listing>
	 * 
	 * <p>The <code>Level</code> in detail. You can define a level traditionally
	 * using:
	 * </p>
	 * <table>
	 *   <tr>
	 *     <th>Code</th>
	 *     <td>Meaning</td>
	 *   </tr>
	 *   <tr>
	 *     <th>DEBUG or ALL</th>
	 *     <td>All messages will be displayed.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>INFO</th>
	 *     <td>Only debug messages will be hidden</td>
	 *   </tr>
	 *   <tr>
	 *     <th>WARN</th>
	 *     <td>Info and Debug messages will be hidden.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>ERROR</th>
	 *     <td>Only Error and Fatal messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>FATAL</th>
	 *     <td>Only Fatal messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>NONE</th>
	 *     <td>No messages will be shown.</td>
	 *   </tr>
	 * </table>
	 * <p>But its also possible to choose just certain levels.</p>
	 * <table>
	 *   <tr>
	 *     <th>Code</th>
	 *     <td>Meaning</td>
	 *   </tr>
	 *   <tr>
	 *     <th>DEBUG_ONLY</th>
	 *     <td>Just debug messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>INFO_ONLY</th>
	 *     <td>Just info messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>WARN_ONLY</th>
	 *     <td>Just warn messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>ERROR_ONLY</th>
	 *     <td>Just error messages will be shown.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>FATAL_ONLY</th>
	 *     <td>Just fatal messages will be shown.</td>
	 *   </tr>
	 * </table>
	 * 
	 * <p>With a "<code>|</code>" (or) you can mix the levels you want to display.</p>
	 * <table>
	 *   <tr>
	 *     <th>Code</th>
	 *     <td>Meaning</td>
	 *   </tr>
	 *   <tr>
	 *     <th>DEBUG_ONLY|INFO_ONLY</th>
	 *     <td>Show info and debug message.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>ERROR|DEBUG_ONLY</th>
	 *     <td>Show error, fatal and debug message.</td>
	 *   </tr>
	 *   <tr>
	 *     <th>FATAL_ONLY|WARN_ONLY|DEBUG_ONLY</th>
	 *     <td>Show fatal, warn and debug message.</td>
	 *   </tr>
	 * </table>
	 * 
	 * <p>The <code>name</code> and the <code>person</code> properties can be used
	 * to filter just loggers of certain names.</p>
	 * 
	 * <listing>
	 * var mergedSetup: ILogSetup = xmlToSetup(
	 *   &lt;rule name="/^org\\.as3commons" xmlns="http://as3commons.org/logging/1"&gt;
	 *     &lt;target-ref ref="common" /&gt;
	 *   &lt;/rule&gt;
	 *   , {}, {common: new TraceTarget()}
	 * );
	 * getLogger("org.as3commons.test").info("hi"); // will be traced
	 * getLogger("my.company").info("hi"); // will NOT be traced
	 * </listing>
	 * 
	 * <p>Make sure that you use double escaping with "\\".</p>
	 * 
	 * @param xml <code>setup</code> or <code>rule</code> from the xml-definition.
	 * @param targetTypes Class lookup to be used for <code>target</code> nodes.
	 * @param targetInstances Instance lookup to be used for <code>target-ref</code> nodes.
	 * @return a new setup to be used for logging.
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see org.as3commons.logging.util.xml#xmlToTarget()
	 * @see http://as3-commons.googlecode.com/files/as3commons-logging.1.xsd
	 */
	public function xmlToSetup(xml:XML, targetTypes:Object, instances:Object=null): ILogSetup {
		if (xml.namespace() == xmlNs) {
			var nodeName: String = xml.localName();
			if (!instances) {
				instances = {};
			}
			var targetXML: XML;
			var list: XML;
			var target: ILogTarget;
			var targetName: String;
			if (nodeName == "setup") {
				var ruleNodes: XMLList = xml.xmlNs::rule;
				var rules: Array = [];
				for each (targetXML in xml.xmlNs::target.(hasOwnProperty("@name")) ) {
					targetName = targetXML.@name;
					if( !instances[targetName] ) {
						instances[targetName] = xmlToTarget(targetXML, targetTypes, instances);
					}
				}
				for each (targetXML in ruleNodes..xmlNs::target.(hasOwnProperty("@name")) ) {
					targetName = targetXML.@name;
					if( !instances[targetName] ) {
						instances[targetName] = xmlToTarget(targetXML, targetTypes, instances);
					}
					list = ( targetXML.parent() as XML );
					list.insertChildAfter( targetXML, <target-ref ref={targetName} xmlns={xmlNs.uri}/>);
					delete list.children()[targetXML.childIndex()];
				}
				for each (var rule:XML in ruleNodes) {
					rules.push( xmlToSetup(rule, targetTypes, instances) );
				}
				return mergeSetups(rules);
			} else if (nodeName == "rule") {
				var targets: Array = [];
				for each (targetXML in xml..xmlNs::target.(hasOwnProperty("@name")) ) {
					targetName = targetXML.@name;
					if( !instances[targetName] ) {
						instances[targetName] = xmlToTarget(targetXML, targetTypes, instances);
					}
					list = ( targetXML.parent() as XML );
					list.insertChildAfter( targetXML, <target-ref ref={targetName} xmlns={xmlNs.uri}/>);
					delete list.children()[targetXML.childIndex()];
				}
				for each (targetXML in xml.xmlNs::target.(hasOwnProperty("@type"))) {
					targets.push(xmlToTarget(targetXML, targetTypes, instances));
				}
				for each (targetXML in xml.xmlNs::["target-ref"].(hasOwnProperty("@ref"))) {
					// Referenced target
					if( (target = instances[targetXML.@ref]) ) {
						targets.push( target );
					}
				}
				var name: RegExp;
				if(xml.hasOwnProperty("@name")) {
					name = regExpFromString(String(xml.@name));
				}
				var person: RegExp;
				if(xml.hasOwnProperty("@person")) {
					person = regExpFromString(String(xml.@person));
				}
				var level: LogSetupLevel;
				levelcheck:if(xml.hasOwnProperty("@level")) {
					level = LogSetupLevel.NONE;
					var levels: Array = String(xml.@level).split("|");
					var foundValid: Boolean = false;
					levelloop:for each( var levelName:String in levels ) {
						switch( levelName ) {
							case "ALL":
							case "DEBUG":
								level = null;
								foundValid = true;
								break levelcheck;
							case "NONE":
								foundValid = true;
								break;
							case "DEBUG_ONLY":
								foundValid = true;
								level = level.or(LogSetupLevel.DEBUG_ONLY);
								break;
							case "INFO":
								foundValid = true;
								level = level.or(LogSetupLevel.INFO);
								break;
							case "INFO_ONLY":
								foundValid = true;
								level = level.or(LogSetupLevel.INFO_ONLY);
								break;
							case "WARN":
								foundValid = true;
								level = level.or(LogSetupLevel.WARN);
								break;
							case "WARN_ONLY":
								foundValid = true;
								level = level.or(LogSetupLevel.WARN_ONLY);
								break;
							case "ERROR":
								foundValid = true;
								level = level.or(LogSetupLevel.ERROR);
								break;
							case "ERROR_ONLY":
								foundValid = true;
								level = level.or(LogSetupLevel.ERROR_ONLY);
								break;
							case "FATAL":
								foundValid = true;
								level = level.or(LogSetupLevel.FATAL);
								break;
							case "FATAL_ONLY":
								foundValid = true;
								level = level.or(LogSetupLevel.FATAL_ONLY);
								break;
						}
							
					}
					if( !foundValid || level == LogSetupLevel.ALL ) {
						level = null;
					} else if( level == LogSetupLevel.NONE) {
						level = null;
						target = null;
					}
				}
				if( person || name ) {
					return new SimpleRegExpSetup(mergeTargets(targets), name, person, level);
				} else if( level ) {
					return new LevelTargetSetup(mergeTargets(targets), level);
				} else {
					return new SimpleTargetSetup(mergeTargets(targets));
				}
			}
		}
		return null;
	}
}
