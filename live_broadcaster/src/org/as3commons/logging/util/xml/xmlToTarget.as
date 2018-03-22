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
	
	import org.as3commons.logging.util.instantiate;
	import org.as3commons.logging.api.ILogTarget;
	
	/**
	 * Creates a <code>ILogTarget</code> from a xml-target-node.
	 * 
	 * <p>The as3commons logging setup process allows to define targets to be generated.</p>
	 * 
	 * <listing>
	 * &lt;target xmlns="http://as3commons.org/logging/1" type="SOS"/&gt;
	 * </listing>
	 * 
	 * <p>The types allowed in the "type" field are passed in to the method (so: there is no
	 * fixed set of types allowed, which reduces the effective .swf size as you allow just
	 * the targets you need.</p>
	 * 
	 * <p>Targets can have primitive constructor parameters.</p>
	 * 
	 * <listing>
	 * &lt;target xmlns="http://as3commons.org/logging/1" type="SOS"&gt;
	 *   &lt;arg value="{message} / {logLevel}"/&gt;
	 * &lt;/target&gt;
	 * </listing>
	 * 
	 * <p>Those parameters will be passed to the the classes constructor function.</p>
	 * 
	 * <p>It automatically converts strings to <code>int</code>/<code>Boolean</code>/<code>Number</code>
	 * values if they are equal.</p>
	 * 
	 * <p>Besides primitive types it is also possible to pass-in other targets.</p>
	 * <listing>
	 * &lt;target xmlns="http://as3commons.org/logging/1" type="FrameBufferTarget"&gt;
	 *   &lt;arg&gt;
	 *     &lt;target type="TraceTarget"/&gt;
	 *   &lt;/arg&gt;
	 * &lt;/target&gt;
	 * </listing>
	 * 
	 * <p>If a value is given it will always take the value!</p>
	 * 
	 * <p>It is also possible to pass-in target references like:</p>
	 * <listing>
	 * &lt;target xmlns="http://as3commons.org/logging/1" type="FrameBufferTarget"&gt;
	 *   &lt;arg&gt;
	 *     &lt;target-ref ref="console-text-field"/&gt;
	 *   &lt;/arg&gt;
	 * &lt;/target&gt;
	 * </listing>
	 * 
	 * <p>You have to use eighter a target reference or a target, both are not
	 * allowed.</p>
	 * 
	 * <p>We have a limit of maximum 14 constructor arguments that you can pass-in.</p>
	 * 
	 * <p>Much like constructor arguments its possible to set properties on the
	 * targets like this:</p>
	 * <listing>
	 * &lt;target xmlns="http://as3commons.org/logging/1" type="TraceTarget"&gt;
	 *   &lt;property name="format" value="{message}" /&gt;
	 * &lt;/target&gt;
	 * </listing>
	 * 
	 * <p>If a constructor throws an error for which reason soever null will be returned.
	 * If a property throws an error it will be just ignored. Any problems that
	 * occur during initation get send to the as3commons logging system.</p>
	 * 
	 * @param xml XML Node to be parsed
	 * @param targetTypes Class lookup to be used for <code>target</code> nodes.
	 * @param targetInstances Instance lookup to be used for <code>target-ref</code> nodes.
	 * @return <code>ILogTarget</code> instance if the instance was evaluatable for a target-node, else <code>null</code>
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see org.as3commons.logging.util.xml#xmlToSetup()
	 * @see http://as3-commons.googlecode.com/files/as3commons-logging.1.xsd
	 */
	public function xmlToTarget(xml:XML, targetTypes:Object, targetInstances:Object=null):ILogTarget {
		if (xml.namespace() == xmlNs && xml.localName() == "target" ) {
			var type: Class = targetTypes[QName(xml.@type).toString()];
			if (type) {
				var args: Array = [];
				for each (var subTargetXML:XML in xml..xmlNs::target.(hasOwnProperty("@name")) ) {
					var subTargetName: String = subTargetXML.@name;
					if( !targetInstances ) {
						targetInstances = {};
					}
					if( !targetInstances[subTargetName] ) {
						targetInstances[subTargetName] = xmlToTarget(subTargetXML, targetTypes, targetInstances);
					} else {
						LOGGER.warn("A target with the name {0} has been defined more than once: {1} will be dismissed", [subTargetName, xml]);
					}
					var list: XML = ( subTargetXML.parent() as XML );
					list.insertChildAfter( subTargetXML, <target-ref ref={subTargetName} xmlns={xmlNs.uri}/>);
					delete list.children()[subTargetXML.childIndex()];
				}
				for each (var arg: XML in xml.xmlNs::arg) {
					args.push(nodeToValue(arg, targetTypes, targetInstances || (targetInstances = {})));
				}
				
				try {
					var result: ILogTarget = ILogTarget( instantiate(type, args) );
				} catch( e: Error ) {
					if( LOGGER.warnEnabled ) {
						LOGGER.warn("The log target named {0} referencing to {1} was not possible to be instantiated with the arguments {2}. Error: {3}", [type, xml.@type, args.splice(0,1), e]);
					}
					return null;
				}
				// Enter the instance as referencable in case a child references to it
				if( targetInstances && xml.hasOwnProperty("@name") ) {
					var name: String = xml.@name;
					if( !targetInstances[name] ){
						targetInstances[name] = result;
					} else {
						LOGGER.warn("A target with the name {0} has been defined more than once: {1} will be dismissed", [subTargetName, xml]);
					}
				}
				for each (var property: XML in xml.xmlNs::property) {
					if( !targetInstances ) {
						targetInstances = {};
						if( xml.hasOwnProperty("@name") ) {
							targetInstances[xml.@name] = result;
						}
					}
					try {
						result[property.@name] = nodeToValue(property, targetTypes, targetInstances);
					} catch( e: Error ) {
						LOGGER.warn("Property {0} could not be set due to error {1}", [property.@name, e]);
					}
				}
				return result;
			}
		}
		return null;
	}
}
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.as3commons.logging.util.xml.xmlNs;
import org.as3commons.logging.util.xml.xmlToTarget;

import flash.utils.Dictionary;

const LOGGER: ILogger = getLogger("org.as3commons.logging.util.xml#xmlToTarget");

function nodeToValue( xml: XML, targetTypes: Object, targetInstances: Object ): * {
	var argValue: * = null;
	if (xml.hasOwnProperty("@value") ) {
		var string: String = QName(xml.@value).toString();
		if(string != "") {
			var bool: String = string.toLowerCase();
			if( bool == "true" || bool == "false") {
				argValue = bool == "true";
			} else {
				var float: Number = parseFloat(string);
				var i: int = parseInt(string);
				if(isNaN(float)) {
					argValue = string;
				} else if( float != i ) {
					argValue = float;
				} else {
					argValue = i;
				}
			}
		} else {
			argValue = string;
		}
	} else {
		var targetNode: XML = xml.xmlNs::target.(hasOwnProperty("@type"))[0];
		if( targetNode ) {
			argValue = xmlToTarget(targetNode,targetTypes,targetInstances);
		} else if( targetInstances ) {
			var targetRefNode: XML = xml.xmlNs::["target-ref"].(hasOwnProperty("@ref"))[0];
			if( targetRefNode) {
				argValue = targetInstances[targetRefNode.@ref];
				if(!argValue) {
					LOGGER.warn("<target-ref ref='{0}'/> could not be resolved.", [targetRefNode.@ref]);
				}
			}
		}
	}
	return argValue;
}